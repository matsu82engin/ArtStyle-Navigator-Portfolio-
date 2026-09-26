FROM ruby:3.1.3

ENV APP_ROOT=/app
WORKDIR $APP_ROOT

RUN sed -i '/bullseye-security/d' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    default-libmysqlclient-dev \
    default-mysql-client \
    imagemagick \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock $APP_ROOT/
RUN bundle install

COPY . $APP_ROOT

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
