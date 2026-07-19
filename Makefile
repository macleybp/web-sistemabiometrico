.PHONY: help build up down restart logs status clean

COMPOSE := docker compose

help: ## Mostrar ayuda
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Construir imagenes Docker
	$(COMPOSE) build --no-cache

up: ## Levantar servicios (detached)
	$(COMPOSE) up -d

up-build: ## Reconstruir y levantar servicios
	$(COMPOSE) up -d --build

down: ## Detener y eliminar contenedores
	$(COMPOSE) down

stop: ## Detener contenedores sin eliminar
	$(COMPOSE) stop

restart: ## Reiniciar servicios
	$(COMPOSE) restart

logs: ## Ver logs en tiempo real
	$(COMPOSE) logs -f

logs-db: ## Ver logs de la base de datos
	$(COMPOSE) logs -f db

logs-web: ## Ver logs del servidor web
	$(COMPOSE) logs -f web

status: ## Estado de los contenedores
	$(COMPOSE) ps

shell-db: ## Shell MySQL en el contenedor de BD
	$(COMPOSE) exec db mysql -u root -p$${DB_ROOT_PASS:-123456} bioasistencia

shell-web: ## Shell bash en el contenedor web
	$(COMPOSE) exec web bash

clean: ## Eliminar contenedores, redes y volúmenes
	$(COMPOSE) down -v --remove-orphans

clean-all: ## Eliminar todo incluyendo imagenes
	$(COMPOSE) down -v --rmi all --remove-orphans

reset: ## Limpiar y reconstruir desde cero
	$(COMPOSE) down -v --remove-orphans
	$(COMPOSE) up -d --build

db-export: ## Exportar base de datos
	$(COMPOSE) exec db mysqldump -u root -p$${DB_ROOT_PASS:-123456} bioasistencia > backup_$$(date +%Y%m%d_%H%M%S).sql

test: ## Verificar configuración
	$(COMPOSE) config

env: ## Mostrar variables de entorno
	@echo "DB_ROOT_PASS: $${DB_ROOT_PASS:-123456}"
	@echo "DB_NAME: $${DB_NAME:-bioasistencia}"
	@echo "ARDUINO_API_KEY: $${ARDUINO_API_KEY:-no definido}"