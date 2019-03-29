#!/usr/bin/env bash

set -e

blue='\e[0;34m'
reset='\e[0;0m'

log() {
  printf "$blue$1$reset\n"
}

asdf install

mix archive.install hex phx_new {{cookiecutter.phoenix_version}}

# Generate Umbrella app
mix phx.new {{cookiecutter.project_name}} --umbrella

# Move generated files so that dir name is the same as the user inputed project name.
rsync -au {{cookiecutter.project_name}}_umbrella/ .
rm -rf {{cookiecutter.project_name}}_umbrella

web_name={{cookiecutter.project_name}}_web
web_folder=apps/${web_name}
web_folder_web=${web_folder}/lib/${web_name}

case '{{cookiecutter.phoenix_auth}}' in
     'Ueberauth')
         config='config :ueberauth, Ueberauth, providers: [identity: {Ueberauth.Strategy.Identity, [callback_methods: ["POST"]]}]'
         nl=$'\n'
         sed -i -e "/^# Import/s/^/\\$config\\$nl/" $web_folder'/config/config.exs'

         routes='scope "/auth", MyApp do pipe_through :browser get "/:provider", AuthController, :request get "/:provider/callback", AuthController, :callback post "/:provider/callback", AuthController, :callback delete "/logout", AuthController, :delete end'
         sed -i -e "/use.*:router/s/$/\\${nl}require Ueberauth/" $web_folder_web'/router.ex'
         sed -i -e "/^end/s~^~\\$routes\\$nl~" $web_folder_web'/router.ex'

         pkgs='{:ueberauth, "~> 0.6"}, {:ueberauth_identity, "~> 0.2"},'
         sed -i -e "/extra_applications/s/\]$/, :ueberauth, :ueberauth_identity]/" $web_folder'/mix.exs'
         sed -i -e "/plug_cowboy/s/^/${pkgs}\\${nl}/" $web_folder'/mix.exs'
         ;;
     *)
         rm lib/{{cookiecutter.project_name}}_web/controllers/auth_controller.ex
         rm lib/{{cookiecutter.project_name}}_web/views/auth_view.ex
         rm -Rf lib/{{cookiecutter.project_name}}_web/templates/auth
         ;;
esac

git init

git add .

git commit -m 'Initial commit'

log 'TODO:'
log '1) You will need to add your repository to CircleCI and set the HEROKU_API_KEY environment variable.'
log '2) A script called setup_heroku has been placed in the project root.'

log ''
log 'You are logged into Heroku as:'
heroku whoami
