VERSION=$(shell cat VERSION)

.PHONY: default all clean install
default: clean all
all: build install alias

build: lib/cloud/version.rb
	gem build cloud.gemspec

lib/cloud/version.rb:
	mkdir -p $(@D)
	@echo 'module Cloud\n	VERSION = "$(VERSION)"\nend' > $@

install:
	gem install cloud-$(VERSION).gem --no-rdoc --no-ri
	rbenv rehash

alias:
	alias cloud=/Users/piers/.rbenv/shims/cloud

clean:
	rm -rf lib/cloud/version.rb
