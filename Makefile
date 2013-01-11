.PHONY: all clean test
SRCDIR = src
SRC = $(shell find src -name "*.coffee")
OUTDIR = bin
OUT = $(SRC:src/%.coffee=bin/%.js)
TESTDIR = test
TESTGREP = ""
COFFEE = ./node_modules/.bin/coffee -c -o $(OUTDIR)
MOCHA = ./node_modules/.bin/mocha -R spec --compilers coffee:coffee-script
PRODDIR = prod
PROD = package.json Procfile bin

all: $(OUT)
	
$(OUT): $(SRC)
	@mkdir -p $(OUTDIR)
	$(COFFEE) $(SRCDIR)

test: all
	$(MOCHA) $(TESTDIR) --grep $(TESTGREP)

clean:
	rm -rf $(OUTDIR)

deploy: all
	git checkout deploy
	@# We can add the bin because .gitignore in the deploy branch has been edited
	@# to not ignore bin
	git add $(OUTDIR)
	@# Commit only if there are changes
	git diff --quiet --staged --exit-code || git commit -m "Updated bin"
	git merge master --no-edit
	git push heroku deploy:master
	@echo "Hold on, about to run 'heroku ps' to check the deployment"
	@sleep 2
	heroku ps
