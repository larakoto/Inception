path= srcs/docker-compose.yml


up:
	docker-compose -f $(path) build
	docker-compose -f $(path) up
down:
	docker-compose -f $(path) down --volumes
re:down up