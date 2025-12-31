# Makefile for Elfateh Blog (Jekyll)
# Usage examples:
#   make install            # install gems
#   make serve              # serve site locally (with livereload)
#   make build              # build site into _site
#   make clean              # remove build artifacts
#   make newpost

BUNDLE ?= bundle
JEKYLL  ?= $(BUNDLE) exec jekyll
PORT    ?= 4000

.PHONY: help install serve build clean newpost check ci validate

help:
	@echo "Makefile targets for this repo"
	@echo "  install        Install Ruby gems (bundle install)"
	@echo "  serve          Serve site locally (requires bundler & jekyll)"
	@echo "  build          Build site into _site (with validation)"
	@echo "  clean          Remove _site and caches"
	@echo "  newpost        Scaffold a new post interactively"
	@echo "  check          Run 'jekyll doctor'"
	@echo "  validate       Validate base_slug uniqueness per lang"

install:
	@echo "Installing gems..."
	$(BUNDLE) install

serve:
	@echo "Serving site at http://localhost:$(PORT)"
	$(JEKYLL) serve --livereload --port $(PORT)

build:
	./validate.rb
	$(JEKYLL) build

check:
	$(JEKYLL) doctor || true

validate:
	./validate.rb

ci:
	@echo "Running CI checks..."
	$(JEKYLL) doctor
	$(JEKYLL) build

clean:
	@echo "Cleaning build artifacts..."
	rm -rf _site .jekyll-cache .sass-cache .bundle vendor/bundle

# Use: make newpost
newpost:
	@echo "Scaffolding new post..."
	@sh scripts/new_post.sh

