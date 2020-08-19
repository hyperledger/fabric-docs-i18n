FROM python:3.7-alpine

RUN apk update \
  && apk add --no-cache git \
  openssh-client \
  make\
  && pip install pipenv

ARG BASE_REPO_DIR=repo
ENV TRANSLATION es

# Creating working directory
RUN mkdir /${BASE_REPO_DIR}
WORKDIR /${BASE_REPO_DIR}

COPY docker-entrypoint.sh .
CMD ["./docker-entrypoint.sh"]