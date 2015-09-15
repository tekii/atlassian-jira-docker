#
# JIRA Dockerfile
#
# 
FROM tekii/server-jre

MAINTAINER Pablo Jorge Eduardo Rodriguez <pr@tekii.com.ar>

LABEL version=6.4.11

COPY config.patch /opt/atlassian/jira/

USER root

#RUN groupadd --gid 2000 jira && \
#    useradd --uid 2000 --gid 2000 --home-dir __JIRA_HOME__ \
#            --shell /bin/sh --comment "Account for running JIRA" jira

# IT-200 - check is this chown actually works...  note: this change
# the ownership in the aufs only, see the comment above.
#RUN mkdir -p __JIRA_HOME__ && \
#    chown -R jira.jira __JIRA_HOME__

RUN apt-get update && \
    apt-get install --assume-yes --no-install-recommends git wget patch ca-certificates && \
    echo "start downloading and decompressing https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-6.4.11.tar.gz" && \
    wget -q -O - https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-6.4.11.tar.gz | tar -xz --strip=1 -C /opt/atlassian/jira && \
    echo "end downloading and decompressing." && \
    cd /opt/atlassian/jira && patch -p1 -i config.patch && cd - && \
    ls -la /opt/atlassian/jira
    
RUN mkdir --parents /opt/atlassian/jira/conf/Catalina && \
    chmod --recursive 700 /opt/atlassian/jira/conf/Catalina && \
    chmod --recursive 700 /opt/atlassian/jira/logs && \
    chmod --recursive 700 /opt/atlassian/jira/temp && \
    chmod --recursive 700 /opt/atlassian/jira/work && \
    chown --recursive root:root /opt/atlassian/jira && \
    chown --recursive daemon:daemon /opt/atlassian/jira/logs && \
    chown --recursive daemon:daemon /opt/atlassian/jira/temp && \
    chown --recursive daemon:daemon /opt/atlassian/jira/work && \
    chown --recursive daemon:daemon /opt/atlassian/jira/conf/Catalina && \
    apt-get purge --assume-yes wget patch && \
    apt-get clean autoclean && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/



#
ENV JIRA_HOME=/var/atlassian/application-data/jira
# override by conf/bin/user.sh
ENV JIRS_USER=daemon
# default value for the tomcat contextPath, to be override by kubernetes
ENV CATALINA_OPTS="-Dtekii.contextPath="
#
ENV JAVA_OPTS="-Datlassian.plugins.enable.wait=300"

# you must 'chown __USER__.__GROUP__ .' this directory in the host in
# order to allow the jira user to write in it.
VOLUME /var/atlassian/application-data/jira
# HTTP Port
EXPOSE 8080
# HTTPS Proxy Port
EXPOSE 8443
#
USER daemon:daemon

ENTRYPOINT ["/opt/atlassian/jira/bin/start-jira.sh", "-fg"]
