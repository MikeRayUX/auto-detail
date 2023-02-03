# for windows using wsl

1. install wsl
2. use this guide to set it to docker default (https://docs.docker.com/docker-for-windows/wsl/#develop-with-docker-and-wsl-2_)
3. open terminal and navigate to file location
4. type `wsl`
5. then `code .`

### docker environment setup

1. copy and rename `master.key_backup` to `~/config/master.key`
2. `docker-compose build`
3. `docker-compose run app yarn install --check-files`
4. `docker-compose run app bundle install`
5. `docker-compose up`
6. `docker-compose exec app bundle exec rails db:create`
7. `docker-compose exec app bundle exec rails db:migrate`
8. `docker-compose exec app bundle exec rails db:seed`

### using guard for automatic test run on save

`bundle exec guard` and wait for (main)> prompt
then `bundle exec guard -p` in order for spec saves to trigger test run

problem:
`Error response from daemon: OCI runtime create failed: container_linux.go:370: starting container process caused: exec: "./docker_entrypoint.sh": permission denied: unknown`

solution:
`chmod u+x docker_entrypoint.sh`

problem:
`bash: /usr/src/app/bin/webpack-dev-server: /usr/bin/env: bad interpreter: Permission denied`

solution:
`chmod +x app/bin/webpack-dev-server`

### Create and send an email via sendgrid dynamic templates

1. Create a template on sendgrid using the `{{user}}` handlebars syntax to target the user/washer name
2. Copy the template id
3. Preview the email and copy the url
4. In the new email form fill the fields with the above copied data

### Environment variable creation

1. `EDITOR=nano rails credentials:edit` in the console or `docker-compose run --rm -e EDITOR=nano app bin/rails credentials:edit` for docker
