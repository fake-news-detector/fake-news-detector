CREATE TABLE categories (
  id SERIAL PRIMARY KEY,
  name VARCHAR NOT NULL
);

INSERT INTO categories(name) VALUES ('Real News');
INSERT INTO categories(name) VALUES ('Fake News');
INSERT INTO categories(name) VALUES ('Click Bait');
INSERT INTO categories(name) VALUES ('Extremely Biased');
INSERT INTO categories(name) VALUES ('Satire');
