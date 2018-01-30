FROM python:3.6

WORKDIR /app

COPY requirements.txt .
RUN pip3 install -r requirements.txt
RUN python3 -m nltk.downloader stopwords snowball_data

COPY . .

CMD bash -c "rm data/links.csv; python3 . --retrain && python3 . --server"
