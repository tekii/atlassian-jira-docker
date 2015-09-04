#
# JIRA Dockerfile
#
# 
FROM tekii/debian-server-jre

MAINTAINER Pablo Jorge Eduardo Rodriguez <pr@tekii.com.ar>

LABEL version="__JIRA_VERSION__"

ENV JIRA_HOME=__JIRA_HOME__ \
    JIRA_VERSION=__JIRA_VERSION__

RUN groupadd --gid 2000 jira && \
    useradd --uid 2000 --gid 2000 --home-dir __JIRA_HOME__ \
            --shell /bin/sh --comment "Account for running JIRA" jira

# you must 'chown 2000.2000 .' this directory in the host in order to
# allow the jira user to write in it.
VOLUME __JIRA_HOME__

# IT-200 - check is this chown actually works...  note: this change
# the ownership in the aufs only, see the comment above.
RUN mkdir -p __JIRA_HOME__ && \
    chown -R jira.jira __JIRA_HOME__

COPY __JIRA_ROOT__ /opt/jira/

RUN chown --recursive root.root /opt/jira && \
    chown --recursive jira.root /opt/jira/logs && \
    chown --recursive jira.root /opt/jira/temp && \
    chown --recursive jira.root /opt/jira/work

EXPOSE 8080
EXPOSE 8443

USER jira

ENTRYPOINT ["/opt/jira/bin/start-jira.sh", "-fg"]
