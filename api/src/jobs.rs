extern crate diesel;

use commons::pg_pool;
use diesel::prelude::*;
use data::schema::links::dsl;
use data::link::*;

pub fn run_job(command: &str) {
    let conn = pg_pool::establish_connection();
    match &*command {
        "--scrape-missing-data" => scrape_missing_data(&conn),
        _ => println!("Job not found"),
    }
}

pub fn scrape_missing_data(conn: &PgConnection) -> () {
    let links = dsl::links
        .filter(dsl::content.is_null().or(dsl::content.eq("")))
        .load::<Link>(conn)
        .unwrap();

    for link in links {
        println!("Scrapping {:?}", link.url);
        rescrape_content(&link, conn).unwrap();
    }
}
