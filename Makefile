VERSION=$(shell cat VERSION)

.PHONY: default all clean install
default: clean all
all: build install alias

build: lib/exos/version.rb
	gem build exos.gemspec

lib/exos/version.rb:
	mkdir -p $(@D)
	@echo 'module Exos\n	VERSION = "$(VERSION)"\nend' > $@

install:
	gem install exos-$(VERSION).gem --no-rdoc --no-ri
	rbenv rehash

alias:
	alias exos=/Users/piers/.rbenv/shims/exos

clean:
	rm -rf lib/exos/version.rb
