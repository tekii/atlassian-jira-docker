#
# JIRA Service Desk Dockerfile
#

# 
FROM tekii/debian-server-jre

MAINTAINER pr@tekii.com.ar

LABEL version="__JIRA_VERSION__-standalone"

#WORKDIR /opt 
#ADD https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-__JIRA_VERSION__.tar.gz .

RUN apt-get update && apt-get install -y \
  mc 

RUN useradd --create-home --comment "Account for running JIRA" jira

VOLUME /home/jira

ADD atlassian-jira-__JIRA_VERSION__.tar.gz /opt/
ADD setenv.sh /opt/atlassian-jira-__JIRA_VERSION__-standalone/bin/
#ADD server.xml /opt/atlassian-jira-__JIRA_VERSION__-standalone/conf/

RUN echo "jira.home = /home/jira" > /opt/atlassian-jira-__JIRA_VERSION__-standalone/atlassian-jira/WEB-INF/classes/jira-application.properties 

RUN chown --recursive root.root /opt/atlassian-jira-__JIRA_VERSION__-standalone && \
    chown --recursive jira.root /opt/atlassian-jira-__JIRA_VERSION__-standalone/logs && \
    chown --recursive jira.root /opt/atlassian-jira-__JIRA_VERSION__-standalone/temp && \
    chown --recursive jira.root /opt/atlassian-jira-__JIRA_VERSION__-standalone/work

# ./atlassian-jira-__JIRA_VERSION__-standalone/atlassian-jira/WEB-INF/classes/jira-application.properties

ENV JIRA_HOME=/home/jira

EXPOSE 8080

USER jira
