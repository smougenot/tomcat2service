#
# Read config file
#

if [ -r "@@SKEL_APP_CONF@@" ]; then
    . "@@SKEL_APP_CONF@@"
fi

if [ ! -z "$APP_JAVA_HOME" ]; then
  JAVA_HOME=$APP_JAVA_HOME
fi

CATALINA_OPTS=$APP_JAVA_OPTS

#
# CATALINA tuning
#

JMX_EXT_IP=""

CATALINA_OPTS="$CATALINA_OPTS -Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false"
CATALINA_OPTS="$CATALINA_OPTS -Dcom.sun.management.jmxremote.password.file=$CATALINA_HOME/conf/jmxremote.password -Dcom.sun.management.jmxremote.access.file=$CATALINA_HOME/conf/jmxremote.access"

if [ ! -z "$_DEBUG" ]; then
	CATALINA_OPTS=$CATALINA_OPTS" -Xdebug -Xrunjdwp:transport=dt_socket,address="$APP_DEBUG_PORT",server=y,suspend=n"
fi
  
echo "Using Options ${CATALINA_OPTS}"
