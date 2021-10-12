docker build -t nile-db .
docker run -it --rm -p 5432:5432 -v $PWD/data:/var/lib/postgresql/data nile-db
