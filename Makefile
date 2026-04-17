.PHONY: install test release

install:
	npm install

test:
	bash scripts/test-bump-version.sh

release:
	npx semantic-release
