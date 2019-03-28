#!/usr/bin/env bash

set -e

if [[ "{{cookiecutter.use_webpack}}" == "True" ]]; then
  echo boom
else
  echo aha
fi
exit 1

asdf install

mix archive.install hex phx_new {{cookiecutter.phoenix_version}}

# Generate Umbrella app
mix phx.new {{cookiecutter.project_name}} --umbrella

# Move generated files so that dir name is the same as the user inputed project name.
mv {{cookiecutter.project_name}}_umbrella/** .
rm -rf {{cookiecutter.project_name}}_umbrella
