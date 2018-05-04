extern crate rocket;
extern crate rocket_contrib;

use rocket::response::Redirect;

#[get("/")]
fn index() -> Redirect {
    Redirect::moved("https://github.com/fake-news-detector/fake-news-detector/tree/master/api/#json-api-endpoints")
}
