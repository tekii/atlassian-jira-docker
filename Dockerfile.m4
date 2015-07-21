#
# JIRA Service Desk Dockerfile
#

# 
FROM tekii/debian-server-jre

MAINTAINER pr@tekii.com.ar

LABEL version="__JIRA_VERSION__-standalone"

#RUN apt-get update && apt-get install -y \
#  mc 

RUN useradd --create-home --comment "Account for running JIRA" jira

VOLUME /home/jira

COPY __JIRA_ROOT__ /opt/jira/

RUN chown --recursive root.root /opt/jira && \
    chown --recursive jira.root /opt/jira/logs && \
    chown --recursive jira.root /opt/jira/temp && \
    chown --recursive jira.root /opt/jira/work

ENV JIRA_HOME=/home/jira \
    JIRA_VERSION=__JIRA_VERSION__

EXPOSE 8080

USER jira

ENTRYPOINT ["/opt/jira/bin/start-jira.sh", "-fg"]
