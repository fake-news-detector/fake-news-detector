FROM python:3.6

WORKDIR /app

COPY requirements.txt .
RUN pip3 install -r requirements.txt

ARG FLOYDHUB_TOKEN
ARG CIRCLE_CI_TOKEN

COPY . .

RUN bash download_floydhub.sh

CMD bash -c "python3 . --server"
