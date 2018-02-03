FROM python:3.6

WORKDIR /app

COPY requirements.txt .
RUN pip3 install -r requirements.txt

COPY . .

ARG FLOYDHUB_TOKEN
RUN bash floydhub_scripts/download.sh

CMD bash -c "python3 . --server"
