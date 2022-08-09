build:
	docker-compose build web

serve:
	docker-compose up

s:
	docker-compose up

test:
	docker-compose run --rm web bundle exec rubocop
	docker-compose run --rm web bundle exec rspec

rebuild:
	docker-compose run --rm web bundle install
	docker-compose build web

bash:
	docker-compose run web bash

rspec:
	docker-compose run --rm web bundle exec rspec

rubocop:
	docker-compose run --rm web bundle exec rubocop

release:
	docker-compose run --rm web bundle install
	docker-compose run --rm web gem build rectify.gemspec
