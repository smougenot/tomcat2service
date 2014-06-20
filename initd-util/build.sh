#!/bin/sh
#===============================================================================
# Construction du livrable RPM
#  1 - D�finition des param�tres (version, # de build, ...
#  2 - Lancement rpmbuild
#===============================================================================

clearBuild(){
  rm -rf BUILD RPMS SRPMS TEMP
}

prepareBuild(){
  mkdir -p BUILD RPMS SRPMS TEMP
}

# validation de la saisie de version
v_=
if [ $# -lt 1 ]; then
  # version par d�faut
  v_="1.1.0_SNAPSHOT"
  echo "passer le num�ro de version en param�tre; utilisation du d�faut ${v_}"
else
  v_=$1
fi

_regexp_version="[0-9]+\.[0-9]+\.[0-9]+(_SNAPSHOT)?"
if [[ ! $v_ =~ $_regexp_version ]]; then
  echo "version $v_ non valide. Le format est ${_regexp_version}"
  exit 1
fi
MYAPP_REL=$v_

clearBuild

# Pr�paration des r�pertoires
_BUILDROOT="/tmp/rpm-common"
if [ -d "${_BUILDROOT}" ]; then
  rm -Rf "${_BUILDROOT}/*"
else
  mkdir -p ${_BUILDROOT}
fi
prepareBuild

#Gestion du num�ro de build (positionn� par Jenkins)
if [ -z "$BUILD_NUMBER" ]; then
  MYAPP_BUILD=1
else
  MYAPP_BUILD=$BUILD_NUMBER
fi

rpmbuild -bb  --buildroot "${_BUILDROOT}" --define="_topdir $PWD" --define="_tmppath $PWD/TEMP"\
 --define="MYAPP_BUILD $MYAPP_BUILD"\
 --define="MYAPP_REL $MYAPP_REL"\
 SPECS/*.spec