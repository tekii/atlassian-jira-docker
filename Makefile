##
## JIRA
##
JIRA_VERSION:=7.0.0

CORE_PRODUCT:=jira-core
CORE_VERSION:=7.0.0
SOFT_PRODUCT:=jira-software
SOFT_VERSION:=7.0.0
SDES_PRODUCT:=servicedesk
SDES_VERSION:=3.0.0

LOCATION:=https://www.atlassian.com/software/jira/downloads/binary
ORIGINAL_INSTALL:=original
PATCHED_INSTALL:=patched

HOME=/var/atlassian/application-data/jira
INSTALL:=/opt/atlassian/jira
#TAG_BASE:=atlassian
#TAG:=tekii/$(TAG_BASE)
RUN_USER:=daemon
RUN_GROUP:=daemon

##
## M4
##
M4= $(shell which m4)
M4_FLAGS= -P \
	-D __VERSION__=$(JIRA_VERSION) \
	-D __LOCATION__=$(LOCATION) \
	-D __INSTALL__=$(INSTALL) \
	-D __HOME__=$(HOME) \
	-D __USER__=$(RUN_USER) -D __GROUP__=$(RUN_GROUP)

$(CORE_PRODUCT).Dockerfile: TARBALL=atlassian-$(CORE_PRODUCT)-$(CORE_VERSION).tar.gz
$(SOFT_PRODUCT).Dockerfile: TARBALL=atlassian-$(SOFT_PRODUCT)-$(SOFT_VERSION)-jira-$(JIRA_VERSION).tar.gz
$(SDES_PRODUCT).Dockerfile: TARBALL=atlassian-$(SDES_PRODUCT)-$(SDES_VERSION)-jira-$(JIRA_VERSION).tar.gz

$(TARBALL):
	wget $(LOCATION)/$(TARBALL)

$(ORIGINAL_INSTALL): $(TARBALL)
	mkdir -p $@
	tar zxvf $(TARBALL) -C $@ --strip-components=1

# ver si esto de puede vincular al jira-core
$(PATCHED_INSTALL): $(TARBALL) config.patch
	mkdir -p $@
	tar zxvf $(TARBALL) -C $@ --strip-components=1
	patch -p0 -i config.patch

PHONY += update-patch
update-patch: $(ORIGINAL_INSTALL)
	diff -ruN -p1 $(ORIGINAL_INSTALL)/ $(PATCHED_INSTALL)/  > config.patch; [ $$? -eq 1 ]

%.Dockerfile: Dockerfile.m4
	$(M4) $(M4_FLAGS) -D __TARBALL__=$(TARBALL) $< >$@

%-image: %.Dockerfile config.patch
	docker build -t tekii/atlassian-$* -f $< .

PRODUCTS:=$(CORE_PRODUCT) $(SOFT_PRODUCT) $(SDES_PRODUCT)
IMAGES:=$(addsuffix -image, $(PRODUCTS))
#PHONY+= $(IMAGES)
$(IMAGES):
#	$(info A top-level info)

PHONY+= run
run:
	docker run -p 8080:8080 -p 8443:8443 -e "CATALINA_OPTS=-Dtekii.contextPath=/jira" -v $(shell pwd)/volume:$(HOME) tekii/atlassian-jira-core
#	docker run -p 8080:8080 --link postgres-makefile-run:jira-makefile-run  -v $(shell pwd)/volume:$(JIRA_HOME) $(TAG)

PHONY += push-to-google
push-to-google:
	docker tag $(TAG) gcr.io/mrg-teky/$(TAG_BASE)
	gcloud docker push gcr.io/mrg-teky/$(TAG_BASE)

PHONY += clean
clean:
	rm -rf $(ORIGINAL_INSTALL) $(PATCHED_INSTALL)

PHONY += realclean
realclean: clean
#	rm -f $(TARBALL)

PHONY += all
all: $(addsuffix .Dockerfile, $(PRODUCTS))

.PHONY: $(PHONY)
.DEFAULT_GOAL := all
