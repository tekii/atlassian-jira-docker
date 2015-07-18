#
# JIRA Service Desk Dockerfile
#

# 
FROM tekii/debian-server-jre:latest

MAINTAINER pr@tekii.com.ar

#WORKDIR /opt 
#ADD https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-6.4.8.tar.gz .

RUN useradd -m jira

VOLUME /home/jira

ADD atlassian-jira-6.4.8.tar.gz /opt
ADD server.xml /opt/atlassian-jira-6.4.8-standalone/conf/

RUN chown --recursive root.root /opt/atlassian-jira-6.4.8-standalone && \
    chown --recursive jira.root /opt/atlassian-jira-6.4.8-standalone/logs && \
    chown --recursive jira.root /opt/atlassian-jira-6.4.8-standalone/temp && \
    chown --recursive jira.root /opt/atlassian-jira-6.4.8-standalone/work

# ./atlassian-jira-6.4.8-standalone/atlassian-jira/WEB-INF/classes/jira-application.properties

ENV JIRA_HOME=/home/jira