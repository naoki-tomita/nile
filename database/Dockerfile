# syntax=docker/dockerfile:1.2

FROM postgres:latest
COPY ./sql /docker-entrypoint-initdb.d
ENV POSTGRES_USER=nile
ENV POSTGRES_PASSWORD=nile
ENV POSTGRES_DB=nile
