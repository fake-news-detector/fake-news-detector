#![feature(plugin, decl_macro)]
#![plugin(rocket_codegen)]
extern crate fake_news_api;
extern crate rocket;
extern crate rocket_contrib;

use rocket::http::Status;
use rocket::local::Client;
use rocket_contrib::Template;
use fake_news_api::endpoints::admin;

const TEMPLATE_ROOT: &'static str = "src/views";

#[test]
fn return_admin_page() {
    let client = create_admin_client();

    let mut response = client.get("/admin").dispatch();

    let expected = get_template_content("admin");
    assert_eq!(response.status(), Status::Ok);
    assert_eq!(response.body_string(), expected);
}

fn create_admin_client() -> Client {
    let rocket = rocket::ignite()
        .mount("/", routes![admin::admin])
        .attach(Template::fairing());

    Client::new(rocket).unwrap()
}

fn get_template_content<S>(template_name: S) -> Option<String>
    where S: Into<String>
{
    let content = Template::show(TEMPLATE_ROOT, template_name.into(), {}).unwrap();

    Some(content)
}
