#!/bin/sh
#
#  Déploiement de l'exemple
#
#  Simule ce que puppet ferait
#

# Config
# -------------
# nom système du service
myapp='my_app_demo'
# version
version='1.0.0-SNAPSHOT'
# numéro de build de la version
release='123'
# fichier de conf externalisé (ex: /etc/sysconfig/myapp/myapp
myapp_conf='/etc/sysconfig/my_app_demo/my_app_demo'
# répertoire où trouver l'application
myappdir="/opt/tomcat"
# de la configuration tomcat (ex: /opt/projet/app/conf)
myappconfdir="${myappdir}/conf"
# user système pour lancer l'application
myappusername="vagrant"
# groupe pour les droits sur les fichiers
myappgroupname="vagrant"
# script de lancement (ex: /opt/projet/app/bin/catalina.sh)
myappexec="${myappdir}/bin/catalina.sh"
# répertoire des logs
myapplogdir="${myappdir}/logs"
# répertoire temporaire
myapptempdir="${myappdir}/tmp"
# Résumé de l'application (pour les métadonnées de service)
myapp_sum="Une appli sous tomcat"
# Description de l'application (pour les métadonnées de service)
myapp_desc="Super appli qui va sauver la boutique. Tourne sous tomcat."
# -------------


# Fonction de remplacement des paramétrages 
doConf () {
  if (( $# <1  )); then
    echo 'Il doit y avoir le fichier de conf en paramètre'
	  exit 2
  fi
  
  if [ -z $1 ]; then
    echo 'Il doit y avoir le fichier de conf en paramètre'
	  exit 2
  fi

  if [ ! -w $1 ]; then
    echo "Le fichier $1  n'est pas acecssible en écriture"
	  exit 2
  fi
  
  echo "configuration statique (@@...@@) du fichier $1"
  # remplacement de la conf 'statique'
  sed -i "s|@@SKEL_APP@@|${myapp}|g; \
		s|@@SKEL_APPDIR@@|${myappdir}|g;\
		s|@@SKEL_USER@@|${myappusername}|g;\
		s|@@SKEL_GROUP@@|${myappgroupname}|g;\
		s|@@SKEL_VERSION@@|version ${version} release ${release}|g;\
		s|@@SKEL_VERSION_MONITORING@@|${version}_release${release}|g;\
		s|@@SKEL_EXEC@@|${myappexec}|g;\
		s|@@SKEL_LOGDIR@@|${myapplogdir}|g;\
		s|@@SKEL_APP_SUM@@|${myapp_sum}|g;\
		s|@@SKEL_APP_DESC@@|${myapp_desc}|g;
		s|@@SKEL_TMPDIR@@|${myapptempdir}|g;\
		s|@@SKEL_CONFDIR@@|${myappconfdir}|g;\
		s|@@SKEL_APP_CONF@@|${myapp_conf}|g" \
		$1
}


#
# Déploiement
#

# init.d
cp  initd "/etc/init.d/${myapp}"
doConf "/etc/init.d/${myapp}"

# JMX (JMX Remote)
cp jmxremote.access.skel    "${myappconfdir}/jmxremote.access.skel"
cp jmxremote.password.skel  "${myappconfdir}/jmxremote.password.skel"

# custom setenv.sh
cp  setenv.sh "${myappdir}/bin/setenv.sh"
doConf "${myappdir}/bin/setenv.sh"

# logrotate
cp logrotate "/etc/logrotate.d/${myapp}"
doConf "/etc/logrotate.d/${myapp}"

# Install server.xml.skel
cp server.xml.skel "${myappconfdir}/server.xml.skel"
doConf "${myappconfdir}/server.xml.skel"
		
# Setup user limits
cp limits.conf "/etc/security/limits.d/${myapp}.conf"
doConf "/etc/security/limits.d/${myapp}.conf"

# Setup Systemd
#cp ${SOURCE10} ${_systemdir}/${myapp}.service
#doConf "${_systemdir}/${myapp}.service"

# Ajustement des logs Tomcat
\cp --force logging.properties "${myappconfdir}/logging.properties"
doConf "${myappconfdir}/logging.properties"
sed -i "s|\${catalina.base}/logs|${myapplogdir}|g" "${myappconfdir}/logging.properties"

# la config
myapp_conf_dir="$(dirname $myapp_conf)"
if [ ! -d $myapp_conf_dir ]; then
  echo "creation du répertorie $myapp_conf_dir"
  mkdir -p "$myapp_conf_dir"
fi
cp  sysconfig.sample  "${myapp_conf}"
doConf "${myapp_conf}"
