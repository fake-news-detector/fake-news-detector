#![feature(plugin)]
#![feature(custom_derive)]
#![plugin(rocket_codegen)]

#[macro_use]
extern crate diesel;
#[macro_use]
extern crate diesel_codegen;
#[macro_use]
extern crate serde_derive;
extern crate rocket;
extern crate rocket_contrib;
extern crate select;
extern crate md5;
extern crate egg_mode;
extern crate tokio_core;
extern crate cookie;

pub mod data;
pub mod endpoints;
pub mod commons;
pub mod scrapper;
pub mod jobs;

use rocket_contrib::Template;
use rocket::response::NamedFile;
use std::path::{Path, PathBuf};

pub fn run_job(command: &str) {
    jobs::run_job(command);
}

#[get("/<file..>")]
fn static_files(file: PathBuf) -> Option<NamedFile> {
    NamedFile::open(Path::new("target/").join(file)).ok()
}

pub fn start_server() {
    rocket::ignite()
        .manage(commons::pg_pool::init_pool())
        .mount(
            "/",
            routes![
                endpoints::healthcheck::healthcheck,
                endpoints::twitter::auth,
                endpoints::twitter::callback,
                endpoints::twitter::user,
                endpoints::twitter::search,
                endpoints::categories::get_categories,
                endpoints::votes::get_votes,
                endpoints::votes::get_votes_by_content,
                endpoints::votes::post_vote,
                endpoints::votes::post_vote_preflight,
                endpoints::votes::post_vote_by_content,
                endpoints::votes::post_vote_by_content_preflight,
                endpoints::links::get_all_links,
                endpoints::index::index,
                endpoints::admin::admin,
                endpoints::admin::login,
                endpoints::admin::get_login,
                endpoints::admin::logout,
                endpoints::admin::verify_link,
                endpoints::admin::verify_link_clickbait_title,
                endpoints::admin::remove_link,
                static_files,
            ],
        )
        .attach(Template::fairing())
        .launch();
}
