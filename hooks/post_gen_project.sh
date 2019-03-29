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
rsync -a {{cookiecutter.project_name}}_umbrella/ .
rm -rf {{cookiecutter.project_name}}_umbrella

log 'You will need to add your repository to CircleCI and set the HEROKU_API_KEY environment variable.'
