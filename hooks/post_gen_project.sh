#!/usr/bin/env bash
{% set web_app = "{}_web".format(cookiecutter.project_name) %}

set -e

blue='\e[0;34m'
reset='\e[0;0m'

log() {
  printf "$blue$1$reset\n"
}

# Move generated files so that dir name is the same as the user provided project name.
rsync -au {{cookiecutter.project_name}}_umbrella/ .
rm -rf {{cookiecutter.project_name}}_umbrella

nl=$'\n'
core_folder=apps/{{cookiecutter.project_name}}
web_name={{cookiecutter.project_name}}_web
web_folder=apps/${web_name}
web_folder_web=${web_folder}/lib/${web_name}

sed -i '' -e "/import_config/s/^/# /" $web_folder'/config/prod.exs'

db_url='config :{{ cookiecutter.project_name }}, {{ cookiecutter.phoenix_module_name }}.Repo, url: System.get_env("DATABASE_URL"), pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"), ssl: true'
sed -i '' -e "/import_config/s/^/${db_url}\\$nl# /" $core_folder'/config/prod.exs'

case '{{cookiecutter.phoenix_auth}}' in
     'Ueberauth')
         config='config :ueberauth, Ueberauth, providers: [identity: {Ueberauth.Strategy.Identity, [callback_methods: ["POST"]]}]'
         sed -i '' -e "/^# Import/s/^/\\$config\\$nl/" $web_folder'/config/config.exs'

         routes='scope "/auth", {{ cookiecutter.phoenix_module_name }} do \
         pipe_through :browser \
         get "/:provider", AuthController, :request \
         get "/:provider/callback", AuthController, :callback \
         post "/:provider/callback", AuthController, :callback \
         delete "/logout", AuthController, :delete \
       end'
         sed -i '' -e "/use.*:router/s/$/\\${nl}require Ueberauth/" $web_folder_web'/router.ex'
         sed -i '' -e "/^end/s~^~\\$routes\\$nl~" $web_folder_web'/router.ex'

         pkgs='{:ueberauth, "~> 0.6"}, {:ueberauth_identity, "~> 0.2"},'
         sed -i '' -e "/extra_applications/s/\]$/, :ueberauth, :ueberauth_identity]/" $web_folder'/mix.exs'
         sed -i '' -e "/plug_cowboy/s/^/${pkgs}\\${nl}/" $web_folder'/mix.exs'

         mix deps.get
         mix format
         ;;
     *)
         rm apps/{{web_app}}/lib/{{web_app}}/controllers/auth_controller.ex
         rm apps/{{web_app}}/lib/{{web_app}}/views/auth_view.ex
         rm -Rf apps/{{web_app}}/lib/{{web_app}}/templates/auth
         ;;
esac

# Start Cleanup Logic for Optional Files
{% if cookiecutter.deploy_to != "heroku" %}
rm Procfile
rm compile
rm elixir_buildpack.config
rm phoenix_static_buildpack.config
rm setup_heroku
{% endif %}
# Stop Cleanup Logic

git init

git add .

git commit -m 'Initial commit'

log 'TODO:'
log '- You will need to add your repository to CircleCI'

# TODO add a check for CircleCI option
{% if cookiecutter.deploy_to == "heroku" %}
log '- Set the HEROKU_API_KEY environment variable in CircleCI.'
{% endif %}

{% if cookiecutter.deploy_to == "heroku" %}
log '- A script called setup_heroku has been placed in the project root.'
log ''
log 'You are logged into Heroku as:'
heroku whoami
{% endif %}
