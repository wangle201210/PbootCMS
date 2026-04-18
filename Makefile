PORT ?= 8080

.PHONY: run stop

run:
	php -S 0.0.0.0:$(PORT)

stop:
	@lsof -ti:$(PORT) | xargs kill -9 2>/dev/null || echo "no process on port $(PORT)"
