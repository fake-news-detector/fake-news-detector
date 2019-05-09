FROM python:3.7

RUN pip3 install --no-cache-dir Cython

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt
RUN python -m nltk.downloader stopwords

COPY . .

ARG CACHEBUST=1
RUN make retrain

CMD bash -c "python . --server"
