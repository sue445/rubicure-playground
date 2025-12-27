ARG RUBY_VERSION=4.0

FROM ruby:${RUBY_VERSION}-alpine

ENV RACK_ENV=production

RUN adduser -D app
WORKDIR /home/app/app

COPY Gemfile Gemfile.lock /home/app/app/

RUN apk add --upgrade --no-cache --virtual .build-deps alpine-sdk build-base && \
    bundle config set --local jobs 2 && \
    bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test' && \
    bundle install && \
    apk del --purge .build-deps

COPY . .

USER app

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
