FROM python:3.6

WORKDIR /app

COPY requirements.txt .
RUN pip3 install -r requirements.txt
RUN python3 -m nltk.downloader stopwords

COPY . .

ARG CACHEBUST=1
RUN make retrain

CMD bash -c "python3 . --server"
