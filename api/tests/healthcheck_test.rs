#![feature(plugin, decl_macro)]
#![plugin(rocket_codegen)]
extern crate rocket;
extern crate fake_news_api;

use rocket::local::Client;
use fake_news_api::endpoints::healthcheck;

#[test]
fn return_ok_on_health_check() {
    let rocket = rocket::ignite().mount("/", routes![healthcheck::healthcheck]);
    let client = Client::new(rocket).unwrap();

    let mut response = client.get("/healthcheck").dispatch();
    assert_eq!(response.body_string(), Some("OK".into()));
}
