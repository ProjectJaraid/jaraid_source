FROM ubuntu:latest
RUN apt-get update && apt-get -y install openjdk-11-jdk-headless \
  rename \
  wget \
  curl \
  zip 
RUN apt-get update && apt-get -y install git \
  libsaxonhe-java 
RUN echo "#! /bin/bash" > /usr/local/bin/saxon \
    && echo "java -jar /usr/share/java/Saxon-HE.jar \$*" >> /usr/local/bin/saxon \
    && chmod 755 /usr/local/bin/saxon
RUN mkdir /opt/actions
COPY process.sh /opt/actions/process.sh
ENTRYPOINT ["/opt/actions/process.sh"]
