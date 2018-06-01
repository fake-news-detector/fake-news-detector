extern crate rocket;
extern crate egg_mode;
extern crate tokio_core;
extern crate cookie;

use rocket::response::{status, Redirect};
use rocket::http::Status;
use tokio_core::reactor;
use rocket::http::{Cookie, Cookies};
use cookie::SameSite;
use std::env;
use rocket_contrib::Json;
use std::borrow::Cow;
use commons::responders::*;


#[derive(FromForm)]
pub struct AuthParams {
    return_to: String,
}

#[get("/twitter/auth?<params>")]
fn auth(mut cookies: Cookies, params: AuthParams) -> Result<Redirect, status::Custom<String>> {
    let (mut core, handle, con_token) = get_config();
    let request_token = core.run(egg_mode::request_token(
        &con_token,
        env::var("TWITTER_CALLBACK").unwrap_or(String::from(
            "http://localhost:8000/twitter/callback",
        )),
        &handle,
    )).map_err(|err| internal_error(&*format!("{}", err)))?;

    cookies = add_cookie(
        "twitter_request_token_secret",
        request_token.secret.to_owned(),
        cookies,
    );
    add_cookie("twitter_return_to", params.return_to, cookies);

    Ok(Redirect::found(
        &*egg_mode::authenticate_url(&request_token),
    ))
}

#[derive(FromForm)]
pub struct TwitterCallbackParams {
    oauth_token: String,
    oauth_verifier: String,
}

#[get("/twitter/callback?<params>")]
fn callback(
    mut cookies: Cookies,
    params: TwitterCallbackParams,
) -> Result<Redirect, status::Custom<String>> {
    let (mut core, handle, con_token) = get_config();
    let request_token_secret = cookies
        .get_private("twitter_request_token_secret")
        .map(|cookie| cookie.value().to_owned())
        .unwrap_or(String::from(""));
    let return_to = cookies
        .get_private("twitter_return_to")
        .map(|cookie| cookie.value().to_owned())
        .unwrap_or(String::from("https://fakenewsdetector.org/"));

    if request_token_secret.is_empty() {
        return Ok(Redirect::found(
            &*format!("/twitter/auth?return_to={}", return_to),
        ));
    }

    let request_token = egg_mode::KeyPair::new(params.oauth_token, request_token_secret);

    let (token, _user_id, _screen_name) = core.run(egg_mode::access_token(
        con_token,
        &request_token,
        params.oauth_verifier,
        &handle,
    )).map_err(|err| internal_error(&*format!("{}", err)))?;

    match token {
        egg_mode::Token::Access {
            ref access,
            consumer: ref _consumer,
        } => {
            cookies = add_cookie("twitter_access_key", access.key.to_owned(), cookies);
            add_cookie("twitter_access_secret", access.secret.to_owned(), cookies);
        }
        egg_mode::Token::Bearer(_token) => {}
    }

    Ok(Redirect::found(&*return_to))
}

#[derive(Debug, Serialize)]
struct SearchResponse {
    statuses: Vec<SearchTweet>,
}

#[derive(Debug, Serialize)]
struct SearchTweet {
    id_str: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    user: Option<SearchUser>,
    #[serde(skip_serializing_if = "Option::is_none")]
    retweeted_status: Option<IdAndUser>,
}

#[derive(Debug, Serialize)]
struct SearchUser {
    id_str: String,
    screen_name: String,
}

#[derive(Debug, Serialize)]
struct IdAndUser {
    id_str: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    user: Option<SearchUser>,
}

fn parse_statuses(result: &egg_mode::Response<egg_mode::search::SearchResult>) -> Vec<SearchTweet> {
    result
        .statuses
        .iter()
        .map(|tweet| {
            SearchTweet {
                id_str: format!("{}", tweet.id),
                user: tweet.to_owned().user.map(|user| {
                    SearchUser {
                        id_str: format!("{}", user.id),
                        screen_name: user.screen_name,
                    }
                }),
                retweeted_status: tweet.to_owned().retweeted_status.map(|rt| {
                    IdAndUser {
                        id_str: format!("{}", rt.id),
                        user: rt.to_owned().user.map(|user| {
                            SearchUser {
                                id_str: format!("{}", user.id),
                                screen_name: user.screen_name,
                            }
                        }),
                    }
                }),
            }
        })
        .collect()
}

#[derive(FromForm)]
pub struct TwitterSearchParams {
    q: String,
}

#[get("/twitter/search?<params>")]
fn search(
    cookies: Cookies,
    params: TwitterSearchParams,
) -> Result<Cached<CredentialsCors<Json<SearchResponse>>>, status::Custom<String>> {
    let (mut core, handle, _) = get_config();
    let access_token = get_authenticated_token(cookies).ok_or(not_authenticated())?;

    println!("Search page {} for {}", 1, params.q);
    let mut search_result = core.run(
        egg_mode::search::search(params.q)
            .result_type(egg_mode::search::ResultType::Mixed)
            .count(100)
            .call(&access_token, &handle),
    ).map_err(|err| internal_error(&*format!("{}", err)))?;

    let mut statuses = parse_statuses(&search_result);
    let mut page = 1;
    while page < 5 {
        if search_result.statuses.is_empty() {
            break;
        }
        println!("Search page {}", page + 1);
        search_result = core.run(search_result.older(&access_token, &handle))
            .map_err(|err| internal_error(&*format!("{}", err)))?;
        statuses.extend(parse_statuses(&search_result));
        page = page + 1;
    }

    Ok(Cached(
        CredentialsCors(Json(SearchResponse { statuses: statuses })),
    ))
}

fn get_config() -> (tokio_core::reactor::Core, tokio_core::reactor::Handle, egg_mode::KeyPair) {
    let core = reactor::Core::new().unwrap();
    let handle = core.handle();
    let con_token = egg_mode::KeyPair::new(
        env::var("TWITTER_APP_KEY").unwrap(),
        env::var("TWITTER_APP_SECRET").unwrap(),
    );

    (core, handle, con_token)
}

fn internal_error(text: &str) -> status::Custom<String> {
    status::Custom(Status::InternalServerError, String::from(text))
}

fn not_authenticated() -> status::Custom<String> {
    status::Custom(
        Status::Unauthorized,
        String::from("User is not authenticated"),
    )
}

fn add_cookie<'a, V>(name: &'static str, value: V, mut cookies: Cookies<'a>) -> Cookies<'a>
where
    V: Into<Cow<'static, str>>,
{
    let mut secret_cookie = Cookie::new(name, value);
    secret_cookie.set_same_site(SameSite::Lax);
    cookies.add_private(secret_cookie);
    cookies
}

fn get_authenticated_token(mut cookies: Cookies) -> Option<egg_mode::Token> {
    let (_, _, con_token) = get_config();
    let acesss_key = cookies.get_private("twitter_access_key").map(|cookie| {
        cookie.value().to_owned()
    })?;
    let acesss_secret = cookies.get_private("twitter_access_secret").map(|cookie| {
        cookie.value().to_owned()
    })?;
    let access_token = egg_mode::KeyPair::new(acesss_key, acesss_secret);

    Some(egg_mode::Token::Access {
        access: access_token,
        consumer: con_token,
    })
}