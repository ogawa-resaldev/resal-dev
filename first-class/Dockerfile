FROM ruby:3.1.4
ARG RUBYGEMS_VERSION=3.3.20
RUN mkdir /first-class
WORKDIR /first-class
COPY Gemfile /first-class/Gemfile
COPY Gemfile.lock /first-class/Gemfile.lock
RUN bundle install
COPY . /first-class

# node、prelineの追加。
RUN curl -sL https://deb.nodesource.com/setup_14.x
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo 'deb http://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list
RUN set -x && apt-get update -qq && apt-get install -yq npm yarn vim default-mysql-client

# cronの追加。
RUN apt-get -y install cron

# pingの追加。
RUN apt-get -y install iputils-ping net-tools

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]