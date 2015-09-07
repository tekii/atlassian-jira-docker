##
## JIRA
##
JIRA_VERSION:=6.4.11
JIRA_TARBALL:=atlassian-jira-$(JIRA_VERSION).tar.gz
JIRA_LOCATION:=https://www.atlassian.com/software/jira/downloads/binary
JIRA_ROOT:=patched
JIRA_HOME=/var/atlassian/application-data/jira
DOCKER_TAG:=tekii/jira:$(JIRA_VERSION)
##
## M4
##
M4= $(shell which m4)
M4_FLAGS= -P \
	-D __JIRA_VERSION__=$(JIRA_VERSION) \
	-D __JIRA_ROOT__=$(JIRA_ROOT) \
	-D __JIRA_HOME__=$(JIRA_HOME) \
	-D __DOCKER_TAG__=$(DOCKER_TAG)

$(JIRA_TARBALL):
	wget $(JIRA_LOCATION)/$(JIRA_TARBALL)
#	md5sum --check $(JDK_TARBALL).md5

$(JIRA_ROOT): $(JIRA_TARBALL) config.patch
	mkdir -p $@
	tar zxvf $(JIRA_TARBALL) -C $@ --strip-components=1
	patch -p0 -i config.patch

#.SECONDARY
Dockerfile: Dockerfile.m4 Makefile
	$(M4) $(M4_FLAGS) $< >$@


PHONY += update-patch
update-patch:
	#mkdir original
	#tar zxvf atlassian-jira-6.4.11.tar.gz -C original --strip-components=1
	diff -ruN -p1 original/ $(JIRA_ROOT)/  > config.patch; [ $$? -eq 1 ]

PHONY += image
image: $(JIRA_TARBALL) Dockerfile $(JIRA_ROOT)
	docker build -t $(DOCKER_TAG) .

PHONY+= run
run: #image
	docker run -p 8080:8080 -p 8443:8443 -e "CATALINA_OPTS=-Dtekii.contextPath=" -v $(shell pwd)/volume:$(JIRA_HOME) $(DOCKER_TAG)
#	docker run -p 8080:8080 -p 8443:8443 -e "CATALINA_OPTS=-Dtekii.contextPath=" -v $(shell pwd)/volume:$(JIRA_HOME) gcr.io/mrg-teky/jira:$(JIRA_VERSION)
	#docker run -p 8080:8080 -p 8443:8443 -v $(shell pwd)/volume:$(JIRA_HOME) $(DOCKER_TAG)
	#docker run -p 8080:8080 --link postgres-makefile-run:jira-makefile-run  -v $(shell pwd)/volume:$(JIRA_HOME) $(DOCKER_TAG)

PHONY+= push-to-docker
push-to-docker: image
	docker push $(DOCKER_TAG)

PHONY += push-to-google
push-to-google: image
	docker tag $(DOCKER_TAG) gcr.io/mrg-teky/jira:$(JIRA_VERSION)
	gcloud docker push gcr.io/mrg-teky/jira:$(JIRA_VERSION)

PHONY += clean
clean:
	rm -rf $(JIRA_ROOT)
	rm -f Dokerfile	

PHONY += realclean
realclean: clean
	rm -f $(JIRA_TARBALL)

PHONY += all
all: $(JDK_TARBALL)

.PHONY: $(PHONY)
.DEFAULT_GOAL := all
