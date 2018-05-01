extern crate rocket;

use rocket::response::status;
use rocket::http::Status;

#[get("/healthcheck")]
fn healthcheck() -> status::Custom<String> {
    status::Custom(Status::Ok, String::from("OK"))
}

#[cfg(test)]
mod tests {

    use super::*;

    #[test]
    fn return_custom_status_ok() {
        let health_status = healthcheck();
        let expected_status = status::Custom(Status::Ok, String::from("OK"));
        assert_eq!(health_status, expected_status);
    }
}
