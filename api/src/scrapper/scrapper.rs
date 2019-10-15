extern crate reqwest;
extern crate select;
extern crate serde_json;

use select::document::Document;
use select::predicate::Class;
use select::predicate::Name;
use std::process::Command;
use std::io::Read;

#[derive(Serialize, Deserialize)]
pub struct UnfluffResponse {
    pub title: String,
    pub text: String,
}

pub fn extract_facebook_text(url: &str) -> Option<UnfluffResponse> {
    let mut request = reqwest::get(url).ok()?;
    let mut body = String::new();
    request.read_to_string(&mut body).ok()?;

    // Remove BigPipe's commented code
    body = str::replace(&body, "<!-- <", "<");
    body = str::replace(&body, "> -->", ">");

    let document = Document::from(&*body);
    let mut title = String::new();
    for node in document.find(Name("title")).take(1) {
        title = String::from(node.text());
    }
    for node in document.find(Class("userContent")).take(1) {
        return Some(UnfluffResponse {
            title: title,
            text: node.text(),
        });
    }
    None
}

pub fn extract_text(url: &str) -> Option<UnfluffResponse> {
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

    serde_json::from_str(&response).ok()
}

#[cfg(test)]
mod tests {

    use super::*;

    #[test]
    fn it_extracts_text_and_title_from_url() {
        let response = extract_text("https://www.folhaimpacto.com.br/noticia/2552/urgente-crivella-mandou-20-homens-armados-recolher-livros-de-felipe-neto").unwrap();

        println!("Found text: {}", response.text);
        assert!(response.text.contains("Neste momento a tropa do Crivella"));

        println!("Found title: {}", response.title);
        assert!(response.title.contains("Crivella mandou 20 homens"));
    }

    #[test]
    fn it_returns_none_when_some_error_happens() {
        let response = extract_text("https://");

        assert!(response.is_none());
    }

    #[test]
    fn it_extracts_text_from_facebook_posts() {
        let url = "https://www.facebook.com/verdadesemmanipulacao/videos/687409251687311/";
        let response = extract_text(url).unwrap();

        println!("Found text: {}", response.text);
        assert!(response.text.contains(
            "O Papa Francisco mandou uma mensagem para a população mundial, pedindo justiça e imparcialidade",
        ));

        println!("Found title: {}", response.title);
        assert!(response.title.contains("Papa envia mensagem a juízes"));
    }
}
