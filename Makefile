.PHONY: all clean test
OUTDIR = bin
SRC = $(shell find src -name "*.coffee")
TEST = test
COFFEE = ./node_modules/.bin/coffee -c -o $(OUTDIR)
MOCHA = ./node_modules/.bin/mocha --compilers coffee:coffee-script

all: $(OUTDIR)/*.js
	
$(OUTDIR)/*.js: $(SRC)
	@mkdir -p $(OUTDIR)
	$(COFFEE) $(SRC)

test: all
	$(MOCHA) $(TEST)

clean:
	rm -rf $(OUTDIR)
