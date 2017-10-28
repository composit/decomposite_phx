FROM phusion/baseimage

RUN apt-get update
RUN apt-get install -y wget postgresql-client rebar build-essential

# set the locale to UTF-8
RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8 

# install elixir http://elixir-lang.org/install.html#unix-and-unix-like
RUN wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && dpkg -i erlang-solutions_1.0_all.deb
RUN apt-get update
RUN apt-get install -y esl-erlang elixir

# install HEX and Phoenix http://www.phoenixframework.org/docs/installation
RUN mix local.hex --force
RUN mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez

# install ruby and sass
RUN apt-get install -y ruby ruby-dev
RUN gem install sass

# install nodejs
RUN apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup_4.x | bash -
RUN apt-get install -y nodejs
RUN npm -g install npm@latest

# install inotify https://github.com/rvoicilas/inotify-tools/wiki
RUN apt-get install -y inotify-tools

COPY . /root/code
WORKDIR /root/code
RUN npm install
RUN mix deps.get
RUN MIX_ENV=prod mix compile
RUN mix hex.info

# compile prod assets
RUN node_modules/webpack/bin/webpack.js -p
RUN MIX_ENV=prod mix phoenix.digest

CMD ["mix", "phoenix.server"]
