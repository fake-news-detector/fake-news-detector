extern crate reqwest;
extern crate select;

use select::document::Document;
use select::predicate::Class;
use std::process::Command;
use std::io::Read;

pub fn extract_facebook_text(url: &str) -> Option<String> {
    let mut request = reqwest::get(url).ok()?;
    let mut body = String::new();
    request.read_to_string(&mut body).ok()?;

    // Remove BigPipe's commented code
    body = str::replace(&body, "<!-- <", "<");
    body = str::replace(&body, "> -->", ">");

    let document = Document::from(&*body);
    for node in document.find(Class("userContent")).take(1) {
        return Some(node.text());
    }
    None
}

pub fn extract_text(url: &str) -> Option<String> {
    if url.contains("facebook.com/") {
        return extract_facebook_text(url);
    }

    let output = Command::new("node")
        .arg("src/scrapper/unfluff.js")
        .arg(url)
        .output()
        .ok()?;

    let encoded = String::from_utf8_lossy(&output.stdout.as_slice());
    let response = format!("{}", encoded);

    if response.is_empty() {
        return None;
    }
    Some(response)
}

#[cfg(test)]
mod tests {

    use super::*;

    #[test]
    fn it_extracts_text_from_url() {
        let text = extract_text("https://goo.gl/d9WM3W").unwrap_or(String::from(""));

        println!("Found text: {}", text);
        assert!(text.contains(
            "Em setembro, a imagem de uma menina tocando o pé do artista Wagner Schwartz",
        ));
    }

    #[test]
    fn it_extracts_text_from_facebook_posts() {
        let url = "https://www.facebook.com/VerdadeSemManipulacao/videos/479313152193503/";
        let text = extract_text(url).unwrap_or(String::from(""));

        println!("Found text: {}", text);
        assert!(text.contains(
            "Feliciano,admite que estaria com um grupo, blindando e salvando a pele de Eduardo Cunha",
        ));
    }
}
