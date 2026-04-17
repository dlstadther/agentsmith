.PHONY: install test release

install:
	npm ci

test:
	bash scripts/test-bump-version.sh

release:
	npx semantic-release
