.PHONY: dev stop seed check neutrality clean

# Development
dev:
	docker compose -f infra/docker-compose.yml up --build -d

# Stop services
stop:
	docker compose -f infra/docker-compose.yml down

# Seed Neo4j with development fixture data
seed:
	@if [ -f .env ]; then export $$(cat .env | xargs); fi; \
	bash infra/scripts/seed-dev.sh

# Quality check (simulating CI checks)
check:
	cd api && uv run ruff check src/ tests/
	cd api && uv run mypy src/
	cd etl && uv run ruff check src/ tests/
	cd etl && uv run mypy src/
	cd frontend && npx eslint src/
	cd frontend && npx tsc --noEmit

# Neutrality audit (from CI)
neutrality:
	@! grep -rn \
		"suspicious\|corrupt\|criminal\|fraudulent\|illegal\|guilty" \
		api/src/ etl/src/ frontend/src/ \
		--include="*.py" --include="*.ts" --include="*.tsx" --include="*.json" \
		|| (echo "NEUTRALITY VIOLATION: banned words found in source" && exit 1)

# Clean up docker volumes
clean:
	docker compose -f infra/docker-compose.yml down -v
