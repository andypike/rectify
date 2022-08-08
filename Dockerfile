FROM ruby:3.0.4

ENV APP_HOME /app
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

RUN apt-get update && apt-get install -y apt-transport-https --no-install-recommends \
      build-essential \
      ruby-dev \
      libgdbm-dev \
      libncurses5-dev \
      curl \
      vim \
      graphviz \
      && rm -rf /var/lib/apt/lists/*

COPY . $APP_HOME

ENV BUNDLE_GEMFILE=$APP_HOME/Gemfile \
  BUNDLE_PATH=/gems \
  BUNDLE_BIN=/gems/bin

RUN bundle install

ENTRYPOINT ["/app/docker-entrypoint.sh"]
