# Use latest jboss/base-jdk:11 image as the base
FROM jboss/base-jdk:11

# Set the JBOSS_VERSION env variable
ENV JBOSS_VERSION 7.2.0
ENV JBOSS_HOME /opt/jboss/jboss-eap-7.2/

COPY downloads/jboss-eap-$JBOSS_VERSION.zip $HOME

# Add the JBoss distribution to /opt, and make jboss the owner of the extracted zip content
# Make sure the distribution is available from a well-known place
RUN cd $HOME \
    && unzip jboss-eap-$JBOSS_VERSION.zip \
    && rm jboss-eap-$JBOSS_VERSION.zip

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

# Add a user in administration realm
RUN /opt/jboss/jboss-eap-7.2/bin/add-user.sh admin Admin01$ --silent

# Copy OJDBC modules
COPY modules/com $JBOSS_HOME/modules/com

# Configuring drivers and DS like - http://www.adam-bien.com/roller/abien/entry/installing_oracle_jdbc_driver_on
COPY standalone.xml $JBOSS_HOME/standalone/configuration

# SET Spring profile to davos (also added in standalone.xml)
ENV SPRING_PROFILES_ACTIVE davos

# SET NO_PROXY
ENV NO_PROXY="127.0.0.1,localhost"


# Expose the ports we're interested in
EXPOSE 8080 9990 8787

# Set the default command to run on boot
# This will boot JBoss EAP in the standalone mode and bind to all interface
CMD ["/opt/jboss/jboss-eap-7.2/bin/standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0", "--debug", "8787"]
