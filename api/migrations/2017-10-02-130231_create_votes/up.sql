CREATE TABLE votes (
  link_id INTEGER REFERENCES links(id),
  uuid VARCHAR NOT NULL,
  category_id INTEGER REFERENCES categories(id),
  ip VARCHAR NOT NULL,
  PRIMARY KEY (link_id, uuid)
);

INSERT INTO votes(link_id, uuid, category_id, ip) VALUES (1, '123', 5, '0.0.0.0');
