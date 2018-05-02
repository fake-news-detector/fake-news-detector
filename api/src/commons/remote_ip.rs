extern crate diesel;
extern crate rocket;
extern crate rocket_contrib;

use rocket::Outcome;
use rocket::request::{self, Request, FromRequest};

pub struct RemoteIp {
    pub ip: String,
}

impl<'a, 'r> FromRequest<'a, 'r> for RemoteIp {
    type Error = ();

    fn from_request(request: &'a Request<'r>) -> request::Outcome<RemoteIp, ()> {
        let remote_ip = request
            .remote()
            .map(|socket| format!("{}", socket.ip()))
            .unwrap_or(String::from("0.0.0.0"));

        return Outcome::Success(RemoteIp { ip: remote_ip });
    }
}
