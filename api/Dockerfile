FROM python:3.8-slim-buster
COPY processor.py requirements.txt /app/
WORKDIR /app
RUN pip install -r requirements.txt
EXPOSE 5000
ENTRYPOINT ["python", "processor.py"]