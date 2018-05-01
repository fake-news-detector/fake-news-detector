CREATE TABLE links (
  id SERIAL PRIMARY KEY,
  url VARCHAR UNIQUE NOT NULL,
  title VARCHAR NOT NULL
);

INSERT INTO links(url, title) VALUES (
  'http://www.sensacionalista.com.br/2017/09/26/stf-decide-hoje-se-video-de-aecio-explicando-mala-de-r2-mi-representara-brasil-no-oscar/',
  'STF decide hoje se vídeo de Aécio explicando mala de R$2 mi representará Brasil no Oscar'
);
