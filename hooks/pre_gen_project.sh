#!/usr/bin/env bash

red='\e[0;31m'
reset='\e[0;0m'

error() {
  printf "$red$1$reset\n"
}

{% if cookiecutter.deploy_to == "heroku" %}
heroku apps:info {{ cookiecutter.heroku_app_name }} 2>&1 | grep "Couldn't find that app." -q
status=$?
if [ "$status" -ne "0" ]; then
  error '{{ cookiecutter.heroku_app_name }} already exists on Heroku.'
  exit 1
fi
{% endif %}
