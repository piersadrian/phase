VERSION=$(shell cat VERSION)

.PHONY: default all clean install
default: all
all: reset build

build: lib/phase/version.rb
	gem build phase.gemspec

lib/phase/version.rb:
	mkdir -p $(@D)
	@echo 'module Phase\n	VERSION = "$(VERSION)"\nend' > $@

reset:
	rm lib/phase/version.rb

push:
	gem push phase-$(VERSION).gem
