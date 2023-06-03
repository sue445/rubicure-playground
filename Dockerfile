FROM ruby:3.2

ENV RACK_ENV=production

RUN useradd -m app
USER app

WORKDIR /home/app/app

COPY Gemfile Gemfile.lock /home/app/app/

RUN bundle config set --local jobs 2 && \
    bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test' && \
    bundle install

COPY . .

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
