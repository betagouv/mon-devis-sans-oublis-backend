web: bin/rails server -p $PORT -e $RAILS_ENV
worker: bundle exec good_job start
postdeploy: bin/rails db:migrate
release: bin/rails db:migrate
