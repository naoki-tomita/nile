docker build --rm -t nile-db .
docker run -it -p 5432:5432 nile-db
