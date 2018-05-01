extern crate rocket;
extern crate rocket_contrib;
use rocket_contrib::Json;
use rocket_contrib::Template;
use diesel::prelude::*;
use data::link::*;
use commons::pg_pool::DbConn;
use rocket::response::status;
use rocket::http::Status;
use rocket::http::{Cookie, Cookies};
use rocket::request::{self, FromRequest, Request};
use rocket::outcome::IntoOutcome;
use std::env;

#[get("/admin")]
fn admin() -> Template {
    Template::render("admin", {})
}

#[derive(Deserialize)]
struct LoginParams {
    email: String,
    password: String,
}

#[derive(Debug, Serialize, Deserialize)]
struct User {
    email: String,
}

impl<'a, 'r> FromRequest<'a, 'r> for User {
    type Error = ();

    fn from_request(request: &'a Request<'r>) -> request::Outcome<User, ()> {
        request
            .cookies()
            .get_private("user_email")
            .and_then(|cookie| cookie.value().parse().ok())
            .map(|email| User { email: email })
            .or_forward(())
    }
}

#[post("/admin/login", data = "<params>")]
fn login(
    mut cookies: Cookies,
    params: Json<LoginParams>,
) -> Result<Json<User>, status::Custom<String>> {

    let admin_email = env::var("ADMIN_EMAIL").unwrap_or(String::from("admin@fakenewsdetector.org"));
    let admin_password = env::var("ADMIN_PASSWORD").unwrap_or(String::from("123"));

    if params.email == admin_email && params.password == admin_password {
        cookies.add_private(Cookie::new("user_email", params.email.to_owned()));
        return Ok(Json(User { email: params.email.to_owned() }));
    }
    Err(status::Custom(
        Status::Forbidden,
        String::from("Invalid email or password"),
    ))
}

#[get("/admin/login")]
fn get_login(user: User) -> Json<User> {
    Json(user)
}

#[post("/admin/logout")]
fn logout(mut cookies: Cookies) -> Json<bool> {
    cookies.remove_private(Cookie::named("user_email"));
    Json(true)
}

#[derive(Deserialize)]
struct VerifyLinkParams {
    link_id: i32,
    category_id: Option<i32>,
}
#[post("/admin/verify_link", data = "<params>")]
fn verify_link(
    _user: User,
    params: Json<VerifyLinkParams>,
    conn: DbConn,
) -> QueryResult<Json<Link>> {
    set_verified_category_id(params.link_id, params.category_id, &*conn).map(Json)
}

#[derive(Deserialize)]
struct VerifyLinkClickbaitTitleParams {
    link_id: i32,
    clickbait_title: Option<bool>,
}
#[post("/admin/verify_link_clickbait_title", data = "<params>")]
fn verify_link_clickbait_title(
    _user: User,
    params: Json<VerifyLinkClickbaitTitleParams>,
    conn: DbConn,
) -> QueryResult<Json<Link>> {
    set_verified_clickbait_title(params.link_id, params.clickbait_title, &*conn).map(Json)
}

#[derive(Deserialize)]
struct RemoveLinkParams {
    link_id: i32,
}
#[delete("/admin/remove_link", data = "<params>")]
fn remove_link(
    _user: User,
    params: Json<RemoveLinkParams>,
    conn: DbConn,
) -> QueryResult<Json<Link>> {
    set_removed(params.link_id, true, &*conn).map(Json)
}