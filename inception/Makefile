path = srcs/docker-compose.yml

build:
	srcs/tools/script.sh
	docker-compose -f $(path) build
up:
	docker-compose -f $(path) up
down:
	docker-compose -f $(path) down --volumes
clean:
	srcs/tools/scriptdelete.sh
re:down build up