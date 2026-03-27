FROM mcr.microsoft.com/devcontainers/python:3.13-bullseye
LABEL maintainer="qte@77" \
      version="0.1" \
      description="This is a custom Python image containing nektos/act."
WORKDIR /app
COPY Makefile requirements.txt ./
RUN make setup
