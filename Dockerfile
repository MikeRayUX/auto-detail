FROM --platform=linux/amd64 ruby:2.6.1

RUN mkdir /usr/src/app
WORKDIR /usr/src/app
COPY . /usr/src/app

# install latest node
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash
RUN apt-get install nodejs -yq
# docker-compose run --rm -e EDITOR=nano app bin/rails credentials:edit to edit credentials
RUN apt-get update -qq
RUN apt-get install -y nano 
# remove cmdtest to fix yarn install error
RUN apt-get remove cmdtest 
# install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - 
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list 
RUN apt-get update && apt-get install yarn 
# install postgres client
RUN apt-get update -qq 
RUN apt-get install -y nodejs postgresql-client 
# fixes 'you must use bundler 2 or higher with this lockfile'
RUN gem update --system && gem install bundler 
RUN bundler update --bundler 
RUN bundle install 
# fixes yanked mimemagic version
RUN apt-get install -y shared-mime-info 
RUN bundle update mimemagic 
RUN yarn install --check-files 
# RUN fix permissions for docker_entrypoint.sh
RUN chmod +x docker_entrypoint.sh

COPY docker_entrypoint.sh /usr/bin/
# Add a script to be executed every time the container starts.
ENTRYPOINT ["./docker_entrypoint.sh"]
EXPOSE 3001

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0", "--pid=/tmp/server.pid"]
