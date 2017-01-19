FROM ruby:2.3.3
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /getoutofnyc-rails
WORKDIR /getoutofnyc-rails
ADD Gemfile /getoutofnyc-rails/Gemfile
ADD Gemfile.lock /getoutofnyc-rails/Gemfile.lock
RUN bundle install
ADD . /getoutofnyc-rails
EXPOSE 80