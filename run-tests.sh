#!/bin/sh

echo "******* Loading database schema *******"
bundle exec rake db:schema:load
echo "***************************************"

echo "******* Running pending database migrations *******"
bundle exec rake db:migrate
echo "***************************************"


echo "******* Running tests *******"
bundle exec rails test -v
