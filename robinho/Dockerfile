FROM python:3.6-alpine

RUN apk add --no-cache --virtual .build-deps gcc musl-dev \
  && pip install cython \
  && apk del .build-deps

RUN apk --no-cache add musl-dev linux-headers g++
RUN apk --no-cache --update-cache add gcc gfortran python python-dev py-pip build-base wget freetype-dev libpng-dev openblas-dev
RUN ln -s /usr/include/locale.h /usr/include/xlocale.h

RUN pip install numpy

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt
RUN python -m nltk.downloader stopwords

COPY . .

ARG CACHEBUST=1
RUN make retrain

CMD bash -c "python . --server"
