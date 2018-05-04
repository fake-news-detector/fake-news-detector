#![feature(plugin, decl_macro)]
#![plugin(rocket_codegen)]
extern crate fake_news_api;
extern crate rocket;
extern crate rocket_contrib;

use rocket::http::Status;
use rocket::local::Client;
use rocket_contrib::Template;
use fake_news_api::endpoints::index;
use std::ops::Deref;

#[test]
fn return_index_page() {
    let client = create_index_client();

    let response = client.get("/").dispatch();

    let location = response.deref().headers().get("Location").next();

    assert_eq!(response.status(), Status::MovedPermanently);
    assert_eq!(location, Some("https://github.com/fake-news-detector/fake-news-detector/tree/master/api/#json-api-endpoints"));
}

fn create_index_client() -> Client {
    let rocket = rocket::ignite()
        .mount("/", routes![index::index])
        .attach(Template::fairing());

    Client::new(rocket).unwrap()
}
