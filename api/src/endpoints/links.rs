extern crate diesel;
extern crate rocket;
extern crate rocket_contrib;

use rocket_contrib::Json;
use diesel::prelude::*;
use diesel::expression::dsl::*;
use commons::pg_pool::DbConn;
use diesel::types::{Nullable, Text, Integer, BigInt, Bool};

#[derive(Queryable, Serialize, Deserialize)]
struct LinkWithTopVote {
    id: i32,
    url: String,
    title: String,
    content: Option<String>,
    category_id: i32,
    clickbait_title: Option<bool>,
    verified_category_id: Option<i32>,
    verified_clickbait_title: Option<bool>,
    count: i64,
}

#[get("/links/all")]
fn get_all_links(conn: DbConn) -> QueryResult<Json<Vec<LinkWithTopVote>>> {
    let query = sql::<
        (Integer,
         Text,
         Text,
         Nullable<Text>,
         Integer,
         Nullable<Bool>,
         Nullable<Integer>,
         Nullable<Bool>,
         BigInt),
    >(
        "SELECT links.id, links.url, links.title, links.content,
            top_votes.category_id, clickbait_votes.clickbait_title,
            links.verified_category_id, links.verified_clickbait_title,
            top_votes.total
         FROM links
         INNER JOIN
            (SELECT distinct on (link_id) category_id, link_id, count(category_id) total
            FROM votes
            GROUP by link_id, category_id
            ORDER by link_id, total DESC) AS top_votes
         ON top_votes.link_id = links.id
         LEFT JOIN
            (SELECT link_id, AVG(
                CASE WHEN clickbait_title = TRUE THEN
                    1
                ELSE
                    0
                END) > 0.5
            AS clickbait_title
            FROM votes WHERE clickbait_title IS NOT NULL
            GROUP BY link_id) AS clickbait_votes
         ON clickbait_votes.link_id = links.id
         WHERE links.removed = FALSE
         ORDER BY links.id DESC",
    );
    query.load::<LinkWithTopVote>(&*conn).map(Json)
}
