##
## Dockerfile
##

#
# ALPINE RUBY IMAGE
#

FROM ruby:3.0.2-alpine as alpine

#
# BASE IMAGE
# This image is used by final running containers. It should contain only runtime dependencies
#

FROM alpine as base

ENV BUNDLE_SILENCE_ROOT_WARNING 1
ENV LANG C.UTF-8
ENV RUBYOPT "-KU -E utf-8:utf-8"

WORKDIR /app

RUN set -ex \
  && apk add --update --no-cache \
  nodejs sqlite sqlite-libs \
  tzdata yarn libxml2 libxslt gcompat \
  && gem install bundler -v 2.3.5

#
# BUILDER IMAGE
# This image is used in intermediate steps. Should contain all binaries needed only at build time
#

FROM base as builder

RUN set -ex \
  && apk add --update --no-cache \
  sqlite-dev libstdc++ libxml2-dev libxslt-dev \
  build-base alpine-sdk

#
# TEST DEPS
#

FROM builder as test-deps

COPY Gemfile Gemfile.lock ./

RUN bundle check || bundle install

COPY . ./

#
# TEST
#

FROM base as test

COPY . ./

COPY --from=test-deps /usr/local/bundle/ /usr/local/bundle/
