#!/bin/bash

bundle install
bundle exec foreman start -f Procfile.dev
