#
# JIRA Service Desk Dockerfile
#

# 
FROM tekii/debian-server-jre:latest

MAINTAINER pr@tekii.com.ar

WORKDIR /tmp

#ADD https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-6.4.8.tar.gz .

RUN pwd

ADD atlassian-jira-6.4.8.tar.gz /opt

RUN ls -l /opt

RUN rm -r /opt/atlassian-jira-6.4.8-standalone
