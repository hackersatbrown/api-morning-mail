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

prod: all
	cp -r $(PROD) $(PRODDIR)
	cd prod \
		&& npm install --production \
		&& git add . \
		&& git commit -m "update"
