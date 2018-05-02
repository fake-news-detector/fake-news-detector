extern crate diesel;
extern crate r2d2_diesel;
extern crate r2d2;
extern crate rocket;

use std::ops::Deref;
use rocket::http::Status;
use rocket::request::{self, FromRequest};
use rocket::{Request, State, Outcome};
use diesel::prelude::*;
use diesel::pg::PgConnection;
use self::r2d2_diesel::ConnectionManager;
use std::env;

type Pool = r2d2::Pool<ConnectionManager<PgConnection>>;

fn database_url() -> String {
    env::var("DATABASE_URL").unwrap_or(String::from(
        "postgres://postgres:password@localhost:5432/fakenews",
    ))
}

pub fn init_pool() -> Pool {
    let config = r2d2::Config::default();
    let manager = ConnectionManager::<PgConnection>::new(database_url());
    r2d2::Pool::new(config, manager).expect("db pool")
}

pub fn establish_connection() -> PgConnection {
    PgConnection::establish(&database_url()).expect(
        "Failed to stabilish a connection with the database",
    )
}

pub struct DbConn(pub r2d2::PooledConnection<ConnectionManager<PgConnection>>);

/// Attempts to retrieve a single connection from the managed database pool. If
/// no pool is currently managed, fails with an `InternalServerError` status. If
/// no connections are available, fails with a `ServiceUnavailable` status.
impl<'a, 'r> FromRequest<'a, 'r> for DbConn {
    type Error = ();

    fn from_request(request: &'a Request<'r>) -> request::Outcome<DbConn, ()> {
        let pool = request.guard::<State<Pool>>()?;
        match pool.get() {
            Ok(conn) => Outcome::Success(DbConn(conn)),
            Err(_) => Outcome::Failure((Status::ServiceUnavailable, ())),
        }
    }
}

// For the convenience of using an &DbConn as an &PgConnection.
impl Deref for DbConn {
    type Target = PgConnection;

    fn deref(&self) -> &Self::Target {
        &self.0
    }
}
