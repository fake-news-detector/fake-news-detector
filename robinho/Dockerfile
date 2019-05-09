FROM python:3.6-alpine

RUN apk add --no-cache --virtual .build-deps gcc musl-dev \
    && pip install cython \
    && apk del .build-deps

WORKDIR /app

COPY requirements.txt .
RUN pip install Cython
RUN pip install -r requirements.txt
RUN python -m nltk.downloader stopwords

COPY . .

ARG CACHEBUST=1
RUN make retrain

CMD bash -c "python . --server"
