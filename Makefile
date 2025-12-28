# Makefile for Elfateh Blog (Jekyll)
# Usage examples:
#   make install            # install gems
#   make serve              # serve site locally (with livereload)
#   make build              # build site into _site
#   make clean              # remove build artifacts
#   make newpost TITLE="My Post" [TAGS="a,b"] [EXCERPT="Short summary"]

BUNDLE ?= bundle
JEKYLL  ?= $(BUNDLE) exec jekyll
PORT    ?= 4000

.PHONY: help install serve build clean newpost check ci

help:
	@echo "Makefile targets for this repo"
	@echo "  install        Install Ruby gems (bundle install)"
	@echo "  serve          Serve site locally (requires bundler & jekyll)"
	@echo "  build          Build site into _site"
	@echo "  clean          Remove _site and caches"
	@echo "  newpost        Scaffold a new post: make newpost TITLE=\"Title\" [TAGS=\"t1,t2\"] [EXCERPT=\"short\"]"
	@echo "  check          Run 'jekyll doctor'"

install:
	@echo "Installing gems..."
	$(BUNDLE) install

serve:
	@echo "Serving site at http://localhost:$(PORT)"
	$(JEKYLL) serve --livereload --port $(PORT)

build:
	$(JEKYLL) build

check:
	$(JEKYLL) doctor || true

ci:
	@echo "Running CI checks..."
	$(JEKYLL) doctor
	$(JEKYLL) build

clean:
	@echo "Cleaning build artifacts..."
	rm -rf _site .jekyll-cache .sass-cache .bundle vendor/bundle

# Use: make newpost TITLE="My Post" [TAGS="a,b"] [EXCERPT="Short summary"]
newpost:
	@# Use: make newpost TITLE="My Post" [TAGS="a,b"] [EXCERPT="Short summary"]
	@if [ -z "$(TITLE)" ]; then \
		echo "TITLE is required. Usage: make newpost TITLE=\"My Post\" [TAGS=\"a,b\"] [EXCERPT=\"Short summary\"]"; exit 1; \
	fi
	@echo "Scaffolding new post..."
	@sh scripts/new_post.sh --title "$(TITLE)" $(if $(TAGS),--tags "$(TAGS)") $(if $(EXCERPT),--excerpt "$(EXCERPT)")

