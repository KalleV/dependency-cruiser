.SUFFIXES: .js .css .html
GIT=git
GIT_CURRENT_BRANCH=$(shell utl/get_current_git_branch.sh)
GIT_DEPLOY_FROM_BRANCH=master
NPM=npm
NODE=node
RM=rm -f
MAKEDEPEND=node_modules/.bin/js-makedepend --exclude "node_modules|fixtures|extractor-fixtures" --system cjs
GENERATED_SOURCES=src/report/csv.template.js \
	src/report/dot.template.js \
	src/report/html.template.js \
	src/report/vis.template.js

.PHONY: help dev-build install check fullcheck mostlyclean clean lint cover prerequisites static-analysis test update-dependencies run-update-dependencies depend

help:
	@echo
	@echo " -------------------------------------------------------- "
	@echo "| More information and other targets: open the Makefile  |"
	@echo " -------------------------------------------------------- "
	@echo

# production rules
src/report/%.template.js: src/report/%.template.hbs
	handlebars --commonjs handlebars/runtime -f $@ $<

.npmignore: .gitignore
	cp $< $@
	echo "doc/api.md" >> $@
	echo "doc/cli.md" >> $@
	echo "doc/output-format.md" >> $@
	echo "doc/real-world-samples.md" >> $@
	echo "doc/real-world-samples/**" >> $@
	echo "doc/assets/ZKH-Dependency-recolored-320.png" >> $@
	echo "doc/assets/ZKH-Dependency-recolored-320.svg" >> $@
	echo "doc/rules.md" >> $@
	echo "doc/rules.starter.json.md" >> $@
	echo "doc/sample-output.md" >> $@
	echo "test/**" >> $@
	echo "utl/**" >> $@
	echo ".bithoundrc" >> $@
	echo ".dependency-cruiser-custom.json" >> $@
	echo ".eslintignore" >> $@
	echo ".eslintrc.json" >> $@
	echo ".gitlab-ci.yml" >> $@
	echo ".istanbul.yml" >> $@
	echo "Makefile" >> $@

# "phony" targets
prerequisites:
	$(NPM) install

dev-build: bin/dependency-cruise $(GENERATED_SOURCES) $(ALL_SRC) .npmignore

lint:
	$(NPM) run lint

cover: dev-build
	$(NPM) run cover

bump-patch:
	$(NPM) version patch

bump-minor:
	$(NPM) version minor

bump-major:
	$(NPM) version major

tag:
	$(GIT) tag -a v`utl/getver` -m "v`utl/getver`"
	$(GIT) push --tags

publish:
	$(GIT) push
	$(GIT) push --tags
	$(NPM) publish

profile:
	$(NODE) --prof src/cli.js -f - test
	@echo "output will be in a file called 'isolate-xxxx-v8.log'"
	@echo "- translate to readable output with:"
	@echo "    node --prof-process isolate-xxxx-v8.log | more"

test: dev-build
	$(NPM) run test

nsp:
	$(NPM) run nsp

outdated:
	$(NPM) outdated

update-dependencies: run-update-dependencies dev-build test
	$(GIT) diff package.json

run-update-dependencies:
	$(NPM) run npm-check-updates
	$(NPM) install

dependency-cruise:
	./bin/dependency-cruise -T err -v .dependency-cruiser-custom.json src bin/dependency-cruise

check: lint test dependency-cruise
	./bin/dependency-cruise --version # if that runs the cli script works

fullcheck: check outdated nsp

depend:
	$(MAKEDEPEND) src/main/index.js
	$(MAKEDEPEND) --append --flat-define ALL_SRC src/main/index.js
	$(MAKEDEPEND) --append test

clean:
	$(RM) $(GENERATED_SOURCES)

# DO NOT DELETE THIS LINE -- js-makedepend depends on it.

# cjs dependencies
src/main/index.js: \
	src/extract/index.js \
	src/report/csvReporter.js \
	src/report/dotReporter.js \
	src/report/errReporter.js \
	src/report/htmlReporter.js \
	src/report/jsonReporter.js \
	src/report/visReporter.js

src/extract/index.js: \
	src/extract/extract.js \
	src/extract/gatherInitialSources.js \
	src/extract/summarize.js

src/extract/extract.js: \
	src/extract/extract-AMD.js \
	src/extract/extract-ES6.js \
	src/extract/extract-commonJS.js \
	src/resolve/index.js \
	src/utl/index.js \
	src/validate/index.js

src/resolve/index.js: \
	src/resolve/resolve-AMD.js \
	src/resolve/resolve-commonJS.js

src/resolve/resolve-AMD.js: \
	src/utl/index.js

src/extract/extract-AMD.js: \
	src/extract/extract-commonJS.js

src/extract/gatherInitialSources.js: \
	src/utl/index.js

src/report/csvReporter.js: \
	src/report/csv.template.js \
	src/report/dependencyToIncidenceTransformer.js

src/report/dotReporter.js: \
	src/report/dot.template.js

src/report/htmlReporter.js: \
	src/report/dependencyToIncidenceTransformer.js \
	src/report/html.template.js

src/report/visReporter.js: \
	src/report/vis.template.js

# cjs dependencies
ALL_SRC=src/main/index.js \
	src/extract/extract-AMD.js \
	src/extract/extract-ES6.js \
	src/extract/extract-commonJS.js \
	src/extract/extract.js \
	src/extract/gatherInitialSources.js \
	src/extract/index.js \
	src/extract/summarize.js \
	src/report/csv.template.js \
	src/report/csvReporter.js \
	src/report/dependencyToIncidenceTransformer.js \
	src/report/dot.template.js \
	src/report/dotReporter.js \
	src/report/errReporter.js \
	src/report/html.template.js \
	src/report/htmlReporter.js \
	src/report/jsonReporter.js \
	src/report/vis.template.js \
	src/report/visReporter.js \
	src/resolve/index.js \
	src/resolve/resolve-AMD.js \
	src/resolve/resolve-commonJS.js \
	src/utl/index.js \
	src/validate/index.js
# cjs dependencies
test/cli/cli.spec.js: \
	src/cli/processCLI.js \
	test/utl/testutensils.js

src/cli/processCLI.js: \
	src/cli/normalizeOptions.js \
	src/cli/validateParameters.js \
	src/main/index.js \
	src/validate/readRuleSet.js

src/main/index.js: \
	src/extract/index.js \
	src/report/csvReporter.js \
	src/report/dotReporter.js \
	src/report/errReporter.js \
	src/report/htmlReporter.js \
	src/report/jsonReporter.js \
	src/report/visReporter.js

src/extract/index.js: \
	src/extract/extract.js \
	src/extract/gatherInitialSources.js \
	src/extract/summarize.js

src/extract/extract.js: \
	src/extract/extract-AMD.js \
	src/extract/extract-ES6.js \
	src/extract/extract-commonJS.js \
	src/resolve/index.js \
	src/utl/index.js \
	src/validate/index.js

src/resolve/index.js: \
	src/resolve/resolve-AMD.js \
	src/resolve/resolve-commonJS.js

src/resolve/resolve-AMD.js: \
	src/utl/index.js

src/extract/extract-AMD.js: \
	src/extract/extract-commonJS.js

src/extract/gatherInitialSources.js: \
	src/utl/index.js

src/report/csvReporter.js: \
	src/report/csv.template.js \
	src/report/dependencyToIncidenceTransformer.js

src/report/dotReporter.js: \
	src/report/dot.template.js

src/report/htmlReporter.js: \
	src/report/dependencyToIncidenceTransformer.js \
	src/report/html.template.js

src/report/visReporter.js: \
	src/report/vis.template.js

src/validate/readRuleSet.js: \
	src/validate/normalizeRuleSet.js \
	src/validate/validateRuleSet.js

src/validate/validateRuleSet.js: \
	src/validate/jsonschema.json

src/cli/validateParameters.js: \
	src/utl/index.js

test/cli/normalizeOptions.spec.js: \
	src/cli/normalizeOptions.js

test/cli/validateParameters.spec.js: \
	src/cli/validateParameters.js

test/extract/extract-composite.spec.js: \
	src/extract/index.js \
	src/extract/jsonschema.json

test/extract/extract.spec.js: \
	src/extract/extract.js

test/extract/gatherInitialSources.spec.js: \
	src/extract/gatherInitialSources.js

test/main/main.spec.js: \
	src/extract/jsonschema.json \
	src/main/index.js

test/report/dotReporter.spec.js: \
	src/report/dotReporter.js

test/report/errReporter.spec.js: \
	src/report/errReporter.js

test/report/htmlReporter.spec.js: \
	src/report/htmlReporter.js

test/validate/normalizeRuleSet.spec.js: \
	src/validate/normalizeRuleSet.js

test/validate/readRuleSet.spec.js: \
	src/validate/readRuleSet.js

test/validate/validate.spec.js: \
	src/validate/index.js \
	src/validate/readRuleSet.js
