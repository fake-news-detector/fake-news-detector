extern crate reqwest;

const LEGITIMATE: &'static [&'static str] = &[
    "cnn.com",
    "nytimes.com",
    "theguardian.com",
    "washingtonpost.com",
    "bbc.co.uk",
    "forbes.com",
    "g1.globo.com",
    "estadao.com.br",
    "folha.com.br",
    "uol.com.br",
];

const SATIRE: &'static [&'static str] = &["theonion.com", "sensacionalista.com.br"];

pub fn get_category(url: &str) -> Option<i32> {
    let parsed_url = reqwest::Url::parse(&url).ok()?;
    let domain = parsed_url.domain()?;

    if LEGITIMATE.iter().any(|&legit| domain.ends_with(legit)) {
        return Some(1);
    }
    if SATIRE.iter().any(|&satire| domain.ends_with(satire)) {
        return Some(5);
    }

    None
}

#[cfg(test)]
mod tests {

    use super::*;

    #[test]
    fn it_finds_category_for_legitimate_domain() {
        assert_eq!(get_category("https://g1.globo.com"), Some(1));
    }

    #[test]
    fn it_finds_category_for_satire_domain() {
        assert_eq!(get_category("https://g1.globo.com"), Some(1));
    }

    #[test]
    fn it_finds_category_for_url_containing_the_domain() {
        assert_eq!(get_category("https://g1.globo.com/some/news"), Some(1));
        assert_eq!(
            get_category("https://bizarro.g1.globo.com/some/news"),
            Some(1)
        );
    }

    #[test]
    fn it_returns_none_for_fake_url_containing_the_domain() {
        assert_eq!(
            get_category("https://fake.news/g1.globo.com/some/news"),
            None
        );
        assert_eq!(
            get_category("https://g1.globo.com.fake.news/some/news"),
            None
        );
    }

    #[test]
    fn it_returns_none_invalid_url() {
        assert_eq!(get_category("foo"), None);
    }
}
