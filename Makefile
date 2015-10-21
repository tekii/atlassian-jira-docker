##
## JIRA
##
JIRA_VERSION:=7.0.0
TARBALL:=atlassian-jira-core-$(JIRA_VERSION).tar.gz
LOCATION:=https://www.atlassian.com/software/jira/downloads/binary
ORIGINAL_INSTALL:=original
PATCHED_INSTALL:=patched
HOME=/var/atlassian/application-data/jira
INSTALL:=/opt/atlassian/jira
TAG:=tekii/atlassian-jira-core
RUN_USER:=daemon
RUN_GROUP:=daemon

##
## M4
##
M4= $(shell which m4)
M4_FLAGS= -P \
	-D __VERSION__=$(JIRA_VERSION) \
	-D __LOCATION__=$(LOCATION) \
	-D __TARBALL__=$(TARBALL) \
	-D __INSTALL__=$(INSTALL) \
	-D __HOME__=$(HOME) \
	-D __USER__=$(RUN_USER) -D __GROUP__=$(RUN_GROUP) \
	-D __TAG__=$(TAG)

$(TARBALL):
	wget $(LOCATION)/$(TARBALL)

$(ORIGINAL_INSTALL): $(TARBALL)
	mkdir -p $@
	tar zxvf $(TARBALL) -C $@ --strip-components=1

$(PATCHED_INSTALL): $(TARBALL) config.patch
	mkdir -p $@
	tar zxvf $(TARBALL) -C $@ --strip-components=1
	patch -p0 -i config.patch

#.SECONDARY
Dockerfile: Dockerfile.m4 Makefile
	$(M4) $(M4_FLAGS) $< >$@


PHONY += update-patch
update-patch: $(ORIGINAL_INSTALL)
	diff -ruN -p1 $(ORIGINAL_INSTALL)/ $(PATCHED_INSTALL)/  > config.patch; [ $$? -eq 1 ]

PHONY += image
image: Dockerfile config.patch
	docker build -t $(TAG) .

PHONY+= run
run: #image
	docker run -p 8080:8080 -p 8443:8443 -e "CATALINA_OPTS=-Dtekii.contextPath=/jira" -v $(shell pwd)/volume:$(HOME) $(TAG)
#	docker run -p 8080:8080 -p 8443:8443 -e "CATALINA_OPTS=-Dtekii.contextPath=" -v $(shell pwd)/volume:$(JIRA_HOME) gcr.io/mrg-teky/jira:$(JIRA_VERSION)
#	docker run -p 8080:8080 -p 8443:8443 -v $(shell pwd)/volume:$(JIRA_HOME) $(DOCKER_TAG)
#	docker run -p 8080:8080 --link postgres-makefile-run:jira-makefile-run  -v $(shell pwd)/volume:$(JIRA_HOME) $(TAG)

PHONY += push-to-google
push-to-google: image
	docker tag $(TAG) gcr.io/mrg-teky/atlassian-jira
	gcloud docker push gcr.io/mrg-teky/atlassian-jira

PHONY += clean
clean:
	rm -rf $(ORIGINAL_INSTALL) $(PATCHED_INSTALL)

PHONY += realclean
realclean: clean
	rm -f $(TARBALL)

PHONY += all
all: Dockerfile

.PHONY: $(PHONY)
.DEFAULT_GOAL := all
