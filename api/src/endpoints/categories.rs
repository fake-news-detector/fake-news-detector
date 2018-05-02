extern crate diesel;
extern crate rocket;
extern crate rocket_contrib;

use rocket_contrib::Json;
use diesel::prelude::*;
use data::category::Category;
use commons::pg_pool::DbConn;
use data::schema::categories::dsl::*;
use commons::responders::*;

#[get("/categories")]
pub fn get_categories(conn: DbConn) -> QueryResult<Cached<Cors<Json<Vec<Category>>>>> {
    categories
        .load::<Category>(&*conn)
        .map(Json)
        .map(Cors)
        .map(Cached)
}
