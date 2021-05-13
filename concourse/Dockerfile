FROM ruby:2.7.3-buster

RUN apt-get update --fix-missing && apt-get -y upgrade \
    && apt-get install -y --no-install-recommends \
      postgresql-11

COPY Gemfile* .ruby-version /application/

WORKDIR /application/

RUN bundle install

COPY . /application/

ENTRYPOINT ["/bin/bash"]
