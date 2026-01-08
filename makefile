# Auto-detect username and repo from git remote origin
USERNAME := $(shell git remote get-url origin 2>/dev/null | sed -n 's|.*github.com[/:]\([^/]*\)/.*|\1|p')
REPO := $(shell git remote get-url origin 2>/dev/null | sed -n 's|.*\/\([^/]*\)\.git$$|\1|p')

# Detect if this is a user/org site (repo name ends with .github.io)
ifeq ($(findstring .github.io,$(REPO)),.github.io)
    BASE_HREF := /
    SITE_URL := https://$(USERNAME).github.io/
else
    BASE_HREF := /$(REPO)/
    SITE_URL := https://$(USERNAME).github.io/$(REPO)/
endif

.PHONY: build post-build deploy

build:
	flutter build web --release --base-href "$(BASE_HREF)"

post-build:
	cp build/web/index.html build/web/404.html
	echo "" > build/web/.nojekyll

deploy: build post-build
	npx gh-pages -d build/web
	@echo "Deployed to $(SITE_URL)"