.PHONY: all clean distclean

NODE_DIR := node_modules

# node binaries
NPM_BIN := $(NODE_DIR)/.bin
COFFEE_CC := $(NPM_BIN)/coffee
BROWSERIFY := $(NPM_BIN)/browserify
DEPS := $(COFFEE_CC)

# opts
COFFEE_OPTS := -bc --no-header

# js libs
ZALGIFY := zalgify
REPLACE_TEXT := replace-all-text-nodes
BROWSERIFY_TARGETS := $(ZALGIFY) $(REPLACE_TEXT)
BROWSERIFY_REQUIRES := $(patsubst %,-r %,$(BROWSERIFY_TARGETS))

# target-specific stuff
COMMON_DIR := common
COFFEE_COMMON := $(wildcard $(COMMON_DIR)/*.coffee)

CHROME_DIR := chrome
CHROME_INJECT_IN := $(COMMON_DIR)/zalgify-impl.js $(CHROME_DIR)/replace.js
CHROME_INJECT_BUNDLE := $(CHROME_DIR)/inject-bundle.js
CHROME_BACKGROUND_IN := $(COMMON_DIR)/setup-urls.js $(CHROME_DIR)/toggle.js \
	$(COMMON_DIR)/zalgify-impl.js
CHROME_BACKGROUND_BUNDLE := $(CHROME_DIR)/background-bundle.js

FF_DIR := firefox
FF_DATA_DIR := $(FF_DIR)/data
FF_INJECT_IN := $(FF_DIR)/replace.js $(COMMON_DIR)/zalgify-impl.js
FF_INJECT_BUNDLE := $(FF_DATA_DIR)/inject-bundle.js
FF_IGNORE := sdk/self sdk/ui/button/action sdk/tabs net/xhr
FF_BACKGROUND_IN := $(COMMON_DIR)/setup-urls.js \
	$(FF_DIR)/toggle.js $(COMMON_DIR)/zalgify-impl.js
FF_BACKGROUND_BUNDLE := $(FF_DIR)/background-bundle.js

# targets
IN_COFFEE := $(wildcard $(CHROME_DIR)/*.coffee) $(wildcard $(FF_DIR)/*.coffee)
OUT_JS := $(patsubst %.coffee,%.js,$(IN_COFFEE))

# recipes
all: $(CHROME_BACKGROUND_BUNDLE) $(CHROME_INJECT_BUNDLE) \
	$(FF_BACKGROUND_BUNDLE) $(FF_INJECT_BUNDLE) $(OUT_JS)

$(CHROME_BACKGROUND_BUNDLE): $(CHROME_BACKGROUND_IN) $(BROWSERIFY)
	$(BROWSERIFY) $(CHROME_BACKGROUND_IN) -o $@

$(CHROME_INJECT_BUNDLE): $(CHROME_INJECT_IN) $(BROWSERIFY)
	$(BROWSERIFY) $(BROWSERIFY_REQUIRES) $(CHROME_INJECT_IN) -o $@

# require is a built in function here, so we just copy
$(FF_BACKGROUND_BUNDLE): $(FF_BACKGROUND_IN)
	cp $(FF_DIR)/toggle.js $@

$(FF_INJECT_BUNDLE): $(FF_INJECT_IN) $(BROWSERIFY)
	$(BROWSERIFY) $(BROWSERIFY_REQUIRES) $(FF_INJECT_IN) -o $@

%.js: %.coffee $(COFFEE_CC)
	$(COFFEE_CC) $(COFFEE_OPTS) $<

$(FF_DIR)/%.js: $(COMMON_DIR)/%.coffee $(COFFEE_CC)
	$(COFFEE_CC) $(COFFEE_OPTS) -o $(FF_DIR) $<

clean:
	rm -f $(OUT_JS) $(CHROME_BACKGROUND_BUNDLE) $(CHROME_BACKGROUND_IN) \
		$(CHROME_INJECT_BUNDLE) $(CHROME_INJECT_IN) \
		$(FF_BACKGROUND_BUNDLE) $(FF_BACKGROUND_IN) \
		$(FF_INJECT_BUNDLE) $(FF_INJECT_IN)

distclean: clean
	rm -rf $(NODE_DIR)

$(DEPS):
	npm install
