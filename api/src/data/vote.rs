extern crate diesel;
extern crate reqwest;

use diesel::prelude::*;
use diesel::expression::dsl::*;
use data::schema::links::dsl;
use data::schema::votes;
use data::link::Link;
use diesel::types::{BigInt, Integer};
use data::verified_domains;
use scrapper::scrapper;

#[derive(Serialize, Deserialize, Identifiable, Queryable, Associations)]
#[belongs_to(Link, Category)]
#[primary_key(link_id, uuid)]
pub struct Vote {
    pub link_id: i32,
    pub uuid: String,
    pub category_id: i32,
    pub ip: String,
    pub clickbait_title: Option<bool>,
}

#[derive(Insertable)]
#[table_name = "votes"]
pub struct NewVote<'a> {
    pub link_id: i32,
    pub uuid: &'a str,
    pub category_id: i32,
    pub ip: &'a str,
    pub clickbait_title: Option<bool>,
}

#[derive(Queryable, Serialize, Deserialize)]
struct PeopleContentVote {
    category_id: i32,
    count: i64,
}

#[derive(Serialize, Deserialize)]
struct RobotContentVote {
    category_id: i32,
    chance: f32,
}

#[derive(Queryable, Serialize, Deserialize)]
struct PeopleTitleVote {
    clickbait: bool,
    count: i64,
}

#[derive(Serialize, Deserialize)]
struct RobotTitleVote {
    clickbait: bool,
    chance: f32,
}

#[derive(Serialize, Deserialize)]
struct VerifiedVote {
    category_id: i32,
}

#[derive(Serialize, Deserialize)]
struct ContentVotes {
    robot: Vec<RobotContentVote>,
    people: Vec<PeopleContentVote>,
}

#[derive(Serialize, Deserialize)]
struct TitleVotes {
    robot: RobotTitleVote,
    people: PeopleTitleVote,
}

#[derive(Serialize, Deserialize)]
struct PeopleVotes {
    content: Vec<PeopleContentVote>,
    title: PeopleTitleVote,
}

#[derive(Serialize, Deserialize)]
pub struct AllVotes {
    domain: Option<VerifiedVote>,
    robot: RobinhoPredictions,
    people: PeopleVotes,
    keywords: Vec<String>,
}

#[derive(Serialize, Deserialize)]
struct RobinhoPredictions {
    fake_news: f32,
    extremely_biased: f32,
    clickbait: f32,
}

#[derive(Deserialize)]
struct RobinhoResponse {
    predictions: RobinhoPredictions,
    keywords: Vec<String>,
}

fn get_robinho_prediction(title: &str, content: &str, url: &str) -> RobinhoResponse {
    let mut prediction_url = reqwest::Url::parse("https://robinho.fakenewsdetector.org/predict")
        .unwrap();
    let limited_content: String = content.chars().take(7000).collect();
    prediction_url.query_pairs_mut().append_pair("title", title);
    prediction_url.query_pairs_mut().append_pair(
        "content",
        &*limited_content,
    );
    prediction_url.query_pairs_mut().append_pair("url", url);

    reqwest::get(prediction_url)
        .and_then(|mut r| r.json())
        .unwrap_or(RobinhoResponse {
            predictions: RobinhoPredictions {
                fake_news: 0.0,
                extremely_biased: 0.0,
                clickbait: 0.0,
            },
            keywords: Vec::new(),
        })
}

fn get_people_votes(url: &str, conn: &PgConnection) -> QueryResult<Vec<PeopleContentVote>> {
    let link: Result<Link, diesel::result::Error> = dsl::links.filter(dsl::url.eq(url)).first(conn);

    match link {
        Ok(link) => {
            let query = sql::<(Integer, BigInt)>(&format!(
                "SELECT category_id, count(*) FROM \
                 votes WHERE link_id = {} AND category_id <> 3 GROUP BY \
                 category_id",
                link.id
            ));
            query.load::<PeopleContentVote>(conn)
        }
        Err(_) => Ok(Vec::new()),
    }
}

fn get_people_clickbait_votes(url: &str, conn: &PgConnection) -> QueryResult<PeopleTitleVote> {
    let link: Result<Link, diesel::result::Error> = dsl::links.filter(dsl::url.eq(url)).first(conn);

    match link {
        Ok(link) => {
            let query = sql::<(BigInt)>(&format!(
                "SELECT a.count - b.count FROM \
                 (SELECT count(*) AS count FROM votes WHERE link_id = {} AND clickbait_title = TRUE) AS a,
                 (SELECT count(*) AS count FROM votes WHERE link_id = {} AND clickbait_title = FALSE) AS b",
                link.id,
                link.id
            ));
            query.get_result::<i64>(conn).map(|count| {
                PeopleTitleVote {
                    clickbait: (count > 0),
                    count: count,
                }
            })
        }
        Err(_) => Ok(PeopleTitleVote {
            clickbait: false,
            count: 0,
        }),
    }
}

fn get_domain_category(url: &str) -> Option<VerifiedVote> {
    verified_domains::get_category(&url).map(|cid| VerifiedVote { category_id: cid })
}

pub fn get_all_votes(
    url: &str,
    title: &str,
    content: Option<&str>,
    conn: &PgConnection,
) -> QueryResult<AllVotes> {
    let domain = get_domain_category(&url);
    let content_ = match content {
        Some(text) => String::from(text),
        None => scrapper::extract_text(&url).unwrap_or(String::from("")),
    };
    let robinho_response = get_robinho_prediction(&title, &content_, &url);
    let robinho_votes = robinho_response.predictions;
    let keywords = robinho_response.keywords;
    let people_content_votes_clone = get_people_votes(&url, &*conn)?;
    let people_clickbait_votes_clone = get_people_clickbait_votes(&url, &*conn)?;

    Ok(AllVotes {
        domain: domain,
        robot: robinho_votes,
        people: PeopleVotes {
            content: people_content_votes_clone,
            title: people_clickbait_votes_clone,
        },
        keywords: keywords,
    })
}