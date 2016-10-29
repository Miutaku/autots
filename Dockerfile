FROM ruby:2.3

ADD . /app
WORKDIR /app
RUN echo "Asia/Tokyo" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata
RUN bundle install -j4
