VERSION=$(shell cat VERSION)

.PHONY: default all clean install
default: clean all
all: build install alias

build: lib/phase/version.rb
	gem build phase.gemspec

lib/phase/version.rb:
	mkdir -p $(@D)
	@echo 'module Phase\n	VERSION = "$(VERSION)"\nend' > $@

install:
	gem install phase-$(VERSION).gem --no-rdoc --no-ri
	rbenv rehash

alias:
	alias phase=/Users/piers/.rbenv/shims/phase

clean:
	rm -rf lib/phase/version.rb
