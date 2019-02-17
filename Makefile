# Copyright (C) 2019 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

GEMS    := Gemfile.lock
SOURCES := $(shell find . -name '*.r?')
MK_TESTED := .mk-tested

.PHONY: clean clobber spec

spec: $(MK_TESTED)

$(MK_TESTED): $(GEMS) $(SOURCES)
	@bundle exec rspec
	@touch $@

$(GEMS): Gemfile
	bundle install

clean:
	$(RM) $(MK_TESTED)

clobber: clean
	$(RM) $(GEMS)

