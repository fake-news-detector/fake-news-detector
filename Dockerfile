FROM python

COPY requirements.txt .
RUN pip3 install -r requirements.txt

COPY . .

CMD python3 . --server
