use rocket::Response;
use rocket::request::Request;
use rocket::response::Responder;
use rocket::http::Status;

pub struct Cors<R>(pub R);

impl<'r, R: Responder<'r>> Responder<'r> for Cors<R> {
    #[inline(always)]
    fn respond_to(self, req: &Request) -> Result<Response<'r>, Status> {
        Response::build()
            .merge(self.0.respond_to(req)?)
            .raw_header("Access-Control-Allow-Origin", "*")
            .ok()
    }
}

pub struct CredentialsCors<R>(pub R);

impl<'r, R: Responder<'r>> Responder<'r> for CredentialsCors<R> {
    #[inline(always)]
    fn respond_to(self, req: &Request) -> Result<Response<'r>, Status> {
        let origin = format!("{}", req.headers().get("Origin").next().unwrap_or(""));

        Response::build()
            .merge(self.0.respond_to(req)?)
            .raw_header("Access-Control-Allow-Credentials", "true")
            .raw_header("Access-Control-Allow-Origin", origin)
            .raw_header("Access-Control-Allow-Methods", "GET")
            .ok()
    }
}


pub struct Cached<R>(pub R);

impl<'r, R: Responder<'r>> Responder<'r> for Cached<R> {
    #[inline(always)]
    fn respond_to(self, req: &Request) -> Result<Response<'r>, Status> {
        Response::build()
            .merge(self.0.respond_to(req)?)
            .raw_header("Cache-Control", "max-age=86400") // 1 day
            .ok()
    }
}

pub struct PreflightCors<R>(pub R);

impl<'r, R: Responder<'r>> Responder<'r> for PreflightCors<R> {
    #[inline(always)]
    fn respond_to(self, req: &Request) -> Result<Response<'r>, Status> {
        Response::build()
            .merge(self.0.respond_to(req)?)
            .raw_header("Allow", "OPTIONS, POST")
            .raw_header("Access-Control-Allow-Origin", "*")
            .raw_header("Access-Control-Allow-Headers", "Content-Type")
            .ok()
    }
}