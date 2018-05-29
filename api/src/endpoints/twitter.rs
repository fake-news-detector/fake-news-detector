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

#[get("/twitter/auth")]
fn auth(mut cookies: Cookies) -> Result<Redirect, status::Custom<String>> {
    let (mut core, handle, con_token) = get_config();
    let request_token = core.run(egg_mode::request_token(
        &con_token,
        "http://localhost:8000/twitter/callback",
        &handle,
    )).map_err(|err| internal_error(&*format!("{}", err)))?;

    let mut secret_cookie = Cookie::new("request_token_secret", request_token.secret.to_owned());
    secret_cookie.set_same_site(SameSite::Lax);
    cookies.add_private(secret_cookie);

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
        .get_private("request_token_secret")
        .map(|cookie| cookie.value().to_owned())
        .unwrap_or(String::from(""));

    if request_token_secret.is_empty() {
        return Ok(Redirect::found("/twitter/auth"));
    }

    let request_token = egg_mode::KeyPair::new(params.oauth_token, request_token_secret);

    let (_token, _user_id, screen_name) = core.run(egg_mode::access_token(
        con_token,
        &request_token,
        params.oauth_verifier,
        &handle,
    )).map_err(|err| internal_error(&*format!("{}", err)))?;

    Err(status::Custom(Status::Ok, String::from(screen_name)))
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