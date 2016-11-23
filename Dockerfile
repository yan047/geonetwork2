# Version: 1
# Name: geonetwork2
# 
FROM yan047/tomcat8

MAINTAINER "boyan.au@gmail.com"

ENV DEBIAN_FRONTEND noninteractive

# In case someone loses the Dockerfile
RUN rm -rf /etc/Dockerfile
ADD Dockerfile /etc/Dockerfile
Add tomcatstart.sh /etc/Dockerfile

# install postgres client
RUN apt-get update && apt-get install -y postgresql-client

#prepare work, data, and config folders
RUN mkdir /var/geonetwork && \
    mkdir /geonetwork_data && chmod a+rw /geonetwork_data && \
    mkdir /geonetwork_config && chmod a+rw /geonetwork_config && cat > /geonetwork_config/config.xml

# download compiled geonetwork.war    
WORKDIR /var/geonetwork
RUN wget http://siss.csiro.au/siss/geonetwork/geonetwork-2.10.4/65/geonetwork.war.zip

# deploy geonetwork
RUN unzip geonetwork.war.zip
USER tomcat 
RUN mkdir -p $CATALINA_HOME/webapps/geonetwork && \
    cp /var/geonetwork/web/target/geonetwork.war $CATALINA_HOME/webapps && \
    unzip -e $CATALINA_HOME/webapps/geonetwork.war -d $CATALINA_HOME/webapps/geonetwork && \
    mkdir $CATALINA_HOME/webapps/geonetwork/WEB-INF/geonetwork_config

# overwrite config.xml with config file in mapped volume     
RUN ln -sf /geonetwork_config/config.xml $CATALINA_HOME/webapps/geonetwork/WEB-INF/config.xml
USER root
RUN rm -rf /var/geonetwork/

# run tomcat

RUN mkdir /etc/service/tomcatd
ADD tomcatstart.sh /etc/service/tomcatd/run

EXPOSE 8080
