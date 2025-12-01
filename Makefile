# Docker Services:
#   up - Start services (use: make up [service...] or make up MODE=prod, ARGS="--build" for options)
#   down - Stop services (use: make down [service...] or make down MODE=prod, ARGS="--volumes" for options)
#   build - Build containers (use: make build [service...] or make build MODE=prod)
#   logs - View logs (use: make logs [service] or make logs SERVICE=backend, MODE=prod for production)
#   restart - Restart services (use: make restart [service...] or make restart MODE=prod)
#   shell - Open shell in container (use: make shell [service] or make shell SERVICE=gateway, MODE=prod, default: backend)
#   ps - Show running containers (use MODE=prod for production)
#
# Convenience Aliases (Development):
#   dev-up - Alias: Start development environment
#   dev-down - Alias: Stop development environment
#   dev-build - Alias: Build development containers
#   dev-logs - Alias: View development logs
#   dev-restart - Alias: Restart development services
#   dev-shell - Alias: Open shell in backend container
#   dev-ps - Alias: Show running development containers
#   backend-shell - Alias: Open shell in backend container
#   gateway-shell - Alias: Open shell in gateway container
#   mongo-shell - Open MongoDB shell
#
# Convenience Aliases (Production):
#   prod-up - Alias: Start production environment
#   prod-down - Alias: Stop production environment
#   prod-build - Alias: Build production containers
#   prod-logs - Alias: View production logs
#   prod-restart - Alias: Restart production services
#
# Backend:
#   backend-build - Build backend TypeScript
#   backend-install - Install backend dependencies
#   backend-type-check - Type check backend code
#   backend-dev - Run backend in development mode (local, not Docker)
#
# Database:
#   db-reset - Reset MongoDB database (WARNING: deletes all data)
#   db-backup - Backup MongoDB database
#
# Cleanup:
#   clean - Remove containers and networks (both dev and prod)
#   clean-all - Remove containers, networks, volumes, and images
#   clean-volumes - Remove all volumes
#
# Utilities:
#   status - Alias for ps
#   health - Check service health
#
# Help:
#   help - Display this help message

.PHONY: help up down build logs restart shell ps \
	dev-up dev-down dev-build dev-logs dev-restart dev-shell dev-ps \
	prod-up prod-down prod-build prod-logs prod-restart \
	backend-shell gateway-shell mongo-shell \
	backend-build backend-install backend-type-check backend-dev \
	db-reset db-backup \
	clean clean-all clean-volumes \
	status health

# Default mode
MODE ?= dev
SERVICE ?= backend

# Compose file selection
ifeq ($(MODE),prod)
	COMPOSE_FILE = docker/compose.production.yaml
	ENV_SUFFIX = prod
else
	COMPOSE_FILE = docker/compose.development.yaml
	ENV_SUFFIX = dev
endif

# Docker compose command
DOCKER_COMPOSE = docker compose -f $(COMPOSE_FILE) --env-file .env

#################################
# Help
#################################

help:
	@echo "==================================================================="
	@echo "  E-Commerce Backend - Docker Management"
	@echo "==================================================================="
	@echo ""
	@echo "Development Commands:"
	@echo "  make dev-up          - Start development environment"
	@echo "  make dev-down        - Stop development environment"
	@echo "  make dev-build       - Build development containers"
	@echo "  make dev-logs        - View development logs"
	@echo "  make dev-restart     - Restart development services"
	@echo "  make dev-ps          - Show running development containers"
	@echo ""
	@echo "Production Commands:"
	@echo "  make prod-up         - Start production environment"
	@echo "  make prod-down       - Stop production environment"
	@echo "  make prod-build      - Build production containers"
	@echo "  make prod-logs       - View production logs"
	@echo "  make prod-restart    - Restart production services"
	@echo ""
	@echo "Shell Access:"
	@echo "  make backend-shell   - Open shell in backend container"
	@echo "  make gateway-shell   - Open shell in gateway container"
	@echo "  make mongo-shell     - Open MongoDB shell"
	@echo ""
	@echo "Database:"
	@echo "  make db-backup       - Backup MongoDB database"
	@echo "  make db-reset        - Reset database (WARNING: deletes all data)"
	@echo ""
	@echo "Utilities:"
	@echo "  make status          - Show running containers"
	@echo "  make health          - Check service health"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean           - Remove containers and networks"
	@echo "  make clean-volumes   - Remove all volumes"
	@echo "  make clean-all       - Remove everything (containers, volumes, images)"
	@echo ""
	@echo "Backend (Local Development):"
	@echo "  make backend-install - Install backend dependencies"
	@echo "  make backend-build   - Build backend TypeScript"
	@echo "  make backend-dev     - Run backend locally (not Docker)"
	@echo ""
	@echo "==================================================================="

#################################
# Docker Services
#################################

up:
	$(DOCKER_COMPOSE) up -d $(ARGS) $(filter-out $@,$(MAKECMDGOALS))

down:
	$(DOCKER_COMPOSE) down $(ARGS) $(filter-out $@,$(MAKECMDGOALS))

build:
	$(DOCKER_COMPOSE) build $(ARGS) $(filter-out $@,$(MAKECMDGOALS))

logs:
	@if [ -n "$(filter-out $@,$(MAKECMDGOALS))" ]; then \
		$(DOCKER_COMPOSE) logs -f $(filter-out $@,$(MAKECMDGOALS)); \
	elif [ -n "$(SERVICE)" ]; then \
		$(DOCKER_COMPOSE) logs -f $(SERVICE); \
	else \
		$(DOCKER_COMPOSE) logs -f; \
	fi

restart:
	$(DOCKER_COMPOSE) restart $(filter-out $@,$(MAKECMDGOALS))

shell:
	@if [ -n "$(filter-out $@,$(MAKECMDGOALS))" ]; then \
		$(DOCKER_COMPOSE) exec $(filter-out $@,$(MAKECMDGOALS)) sh; \
	else \
		$(DOCKER_COMPOSE) exec $(SERVICE) sh; \
	fi

ps:
	$(DOCKER_COMPOSE) ps

#################################
# Development Aliases
#################################

dev-up:
	@$(MAKE) up MODE=dev

dev-down:
	@$(MAKE) down MODE=dev

dev-build:
	@$(MAKE) build MODE=dev

dev-logs:
	@$(MAKE) logs MODE=dev

dev-restart:
	@$(MAKE) restart MODE=dev

dev-shell:
	@$(MAKE) shell MODE=dev SERVICE=backend

dev-ps:
	@$(MAKE) ps MODE=dev

#################################
# Production Aliases
#################################

prod-up:
	@$(MAKE) up MODE=prod

prod-down:
	@$(MAKE) down MODE=prod

prod-build:
	@$(MAKE) build MODE=prod

prod-logs:
	@$(MAKE) logs MODE=prod

prod-restart:
	@$(MAKE) restart MODE=prod

#################################
# Shell Access
#################################

backend-shell:
	@$(MAKE) shell SERVICE=backend

gateway-shell:
	@$(MAKE) shell SERVICE=gateway

mongo-shell:
	@if [ "$(MODE)" = "prod" ]; then \
		docker exec -it ecommerce-mongo-prod mongosh -u ${MONGO_INITDB_ROOT_USERNAME} -p ${MONGO_INITDB_ROOT_PASSWORD} --authenticationDatabase admin; \
	else \
		docker exec -it ecommerce-mongo-dev mongosh -u ${MONGO_INITDB_ROOT_USERNAME} -p ${MONGO_INITDB_ROOT_PASSWORD} --authenticationDatabase admin; \
	fi

#################################
# Backend (Local Development)
#################################

backend-build:
	cd backend && npm run build

backend-install:
	cd backend && npm install

backend-type-check:
	cd backend && npm run type-check

backend-dev:
	cd backend && npm run dev

#################################
# Database
#################################

db-backup:
	@mkdir -p backups
	@TIMESTAMP=$$(date +%Y%m%d_%H%M%S); \
	if [ "$(MODE)" = "prod" ]; then \
		docker exec ecommerce-mongo-prod mongodump --username ${MONGO_INITDB_ROOT_USERNAME} --password ${MONGO_INITDB_ROOT_PASSWORD} --authenticationDatabase admin --archive > backups/mongodb_backup_prod_$$TIMESTAMP.archive; \
	else \
		docker exec ecommerce-mongo-dev mongodump --username ${MONGO_INITDB_ROOT_USERNAME} --password ${MONGO_INITDB_ROOT_PASSWORD} --authenticationDatabase admin --archive > backups/mongodb_backup_dev_$$TIMESTAMP.archive; \
	fi
	@echo "Backup created: backups/mongodb_backup_$(ENV_SUFFIX)_$$TIMESTAMP.archive"

db-reset:
	@echo "WARNING: This will delete ALL data in the $(MODE) database!"
	@echo "Press Ctrl+C to cancel, or Enter to continue..."
	@read dummy
	@if [ "$(MODE)" = "prod" ]; then \
		docker exec -it ecommerce-mongo-prod mongosh -u ${MONGO_INITDB_ROOT_USERNAME} -p ${MONGO_INITDB_ROOT_PASSWORD} --authenticationDatabase admin --eval "db.getSiblingDB('${MONGO_DATABASE}').dropDatabase()"; \
	else \
		docker exec -it ecommerce-mongo-dev mongosh -u ${MONGO_INITDB_ROOT_USERNAME} -p ${MONGO_INITDB_ROOT_PASSWORD} --authenticationDatabase admin --eval "db.getSiblingDB('${MONGO_DATABASE}').dropDatabase()"; \
	fi
	@echo "Database reset complete"

#################################
# Cleanup
#################################

clean:
	docker compose -f docker/compose.development.yaml down
	docker compose -f docker/compose.production.yaml down
	@echo "Containers and networks removed"

clean-volumes:
	docker compose -f docker/compose.development.yaml down -v
	docker compose -f docker/compose.production.yaml down -v
	@echo "Volumes removed"

clean-all: clean-volumes
	docker rmi -f ecommerce-backend-dev ecommerce-backend-prod ecommerce-gateway-dev ecommerce-gateway-prod 2>/dev/null || true
	docker system prune -f
	@echo "Everything cleaned (containers, volumes, images, networks)"

#################################
# Utilities
#################################

status:
	@$(MAKE) ps

health:
	@echo "Checking service health..."
	@echo ""
	@echo "Gateway health:"
	@curl -f http://localhost:5921/health 2>/dev/null && echo " ✓" || echo " ✗"
	@echo ""
	@echo "Backend health (via gateway):"
	@curl -f http://localhost:5921/api/health 2>/dev/null && echo " ✓" || echo " ✗"
	@echo ""

# Allow passing arguments to targets
%:
	@:
