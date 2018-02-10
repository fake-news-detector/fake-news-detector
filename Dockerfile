FROM python:3.6

WORKDIR /app

COPY requirements.txt .
RUN pip3 install -r requirements.txt
RUN python3 -m nltk.downloader stopwords

COPY . .

ARG FLOYDHUB_TOKEN
ARG CACHEBUST=1
RUN pip3 install -U floyd-cli
RUN bash floydhub_scripts/download.sh

CMD bash -c "python3 . --server"
