.SILENT:
.DEFAULT:

MAKEFILES_DIR = makefiles

# Print some basic help text followed by the `shortdesc` goal from all makefiles
help:
	if [ $(firstword $(MAKECMDGOALS)) == $@ ]; then \
		echo 'Run `make <command> help` for more specific help' | fold -s; \
		echo ''; \
		echo 'commands:'; \
		for file in $(wildcard $(MAKEFILES_DIR)/*.mk); do \
			echo "	`$(MAKE) -f $$file shortdesc`"; \
		done \
	fi


# Test goal can't have a recipe; instead, it can have dependencies.
test: run-tests

# `run-tests` is the dependency of `test` which defines the recipe
# for calling the test.mk
run-tests:
	GOAL_MAKEFILE=$(MAKEFILES_DIR)/$@.mk
	NEXT_GOAL_CMD=$(filter-out test, $(MAKECMDGOALS))
	if [ 'run-tests' == $@ ]; then \
		$(MAKE) -f $(GOAL_MAKEFILE) run $(NEXT_GOAL_CMD); \
	fi

# Match all goals but only act on the first one, and pass
# all goals (space delim words) except for the first to the next makefile.
#
# Makefiles should be named <goal>.mk

FIRST_GOAL = $(word 1, $(MAKECMDGOALS))
SECOND_GOAL = $(word 2, $(MAKECMDGOALS))
NEXT_GOAL_CMD = $(filter-out $@, $(MAKECMDGOALS))
GOAL_MAKEFILE = $(MAKEFILES_DIR)/$@.mk

%:
	if [ $(FIRST_GOAL) == $@ ] && [ $@ != 'test' ] && [ -a $(GOAL_MAKEFILE) ]; then \
		if [ "$(SECOND_GOAL)" == 'help' ]; then \
			$(MAKE) -f $(GOAL_MAKEFILE) help; \
		else \
			$(MAKE) -f $(GOAL_MAKEFILE) run $(NEXT_GOAL_CMD); \
		fi \
	fi

# all goals are phony, this ensures that if there is a
# directory with the same name as a goal, it still works
.PHONY: all
