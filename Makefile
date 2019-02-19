# Copyright (C) 2019 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

GEMS    := Gemfile.lock
SOURCES := $(shell find . -name '*.r?')
MK_TESTED := .mk-tested
MK_PUBLISHED := .mk-published

.PHONY: clean clobber spec publish

spec: $(MK_TESTED)

publish: $(MK_PUBLISHED)

$(MK_PUBLISHED): spec
	@touch $@

$(MK_TESTED): $(GEMS) $(SOURCES)
	@bundle exec rspec
	@touch $@

$(GEMS): Gemfile
	bundle install

clean:
	$(RM) $(MK_TESTED) $(MK_PUBLISHED)

clobber: clean
	$(RM) $(GEMS)

