#!/bin/sh
#
# Arréter un process avec une boucle d'attente
#

#===============================================================================
# Boucle d'attente avant kill
#===============================================================================
# Après lancement de la commande d'arrêt (hors de la fonction).
# Attend que le process (via pid) soit absent.
# Au bout de l'attente (n boucles de sleep 1) un kill -9 est fait
#
# $1=pid_file
# $2=nb boucles d'attentes (facultatif, default = 10)
#
# retour 10 en cas d'erreur
attenteArret() {
  run_util_SHUTDOWN_WAIT=10

  if [ $# -lt 1 ]; then
    echo "Le fichier de PID doit être passé en argument"
    return 10
  fi
  run_util_FICHIER_PID="$1"
  run_util_nb_regex="[0-9]+"
  if (( $# > 1 )); then
    if [[ $2 =~ ${run_util_nb_regex} ]]; then
      run_util_SHUTDOWN_WAIT=$2
    else
      echo "Le second paramètre doit être un nombre de boucles d'attente. La valeur $2 n'est pas conforme au format ${run_util_nb_regex}. Utilisation de la valeur par défaut ${run_util_SHUTDOWN_WAIT}"
    fi
  fi


  # Attente (limitee) de l'arret
  run_util_count="0"
  if [ -s "${run_util_FICHIER_PID}" ]; then
    read kpid < ${run_util_FICHIER_PID}
    if [ ! -z $kpid ]; then
      # tant que le process est actif et que l'on a pas épuisé la patience
      checkpid ${kpid}
      until [ ! $? -eq 0 ] || \
            [ "$run_util_count" -gt "$run_util_SHUTDOWN_WAIT" ]; do
        echo "attente de l'arrêt du process $kpid ${run_util_count}"
        sleep 1
        let run_util_count="${run_util_count}+1"
        checkpid ${kpid}
      done
      if [ "$run_util_count" -gt "$run_util_SHUTDOWN_WAIT" ]; then
        log_warning_msg "kill ($kpid) après ${run_util_SHUTDOWN_WAIT} seconds $(date  +'%Y/%m/%d %T')"
        kill -9 $kpid
      else
        log_success_msg
      fi
    fi
  else
    log_success_msg
  fi
  return 0
}

#===============================================================================
# Etat d'un process à partir d'un fichier PID
#===============================================================================
# $1=pid_file
# 
# Valorise kpid avec le pid
#
# retour 
# 10 en cas d'erreur
#  0 process actif
#  1 process inactif
#  2 pas de fichier pid
function checkpidfile() {
  if [ $# -lt 1 ]; then
    echo "Le fichier de PID doit être passé en argument"
    return 10
  fi
  run_util_FICHIER_PID="$1"
  run_util_RETVAL=0
  
  if [ -s "${run_util_FICHIER_PID}" ]; then
    read kpid < ${run_util_FICHIER_PID}
    if [ ! -z "${kpid}" ]; then
      checkpid ${kpid}
      run_util_RETVAL=$?
    else
      run_util_RETVAL=1
    fi
  else
    # pid file does not exist and program is not running
    run_util_RETVAL=2
  fi
  return ${run_util_RETVAL}
}

#===============================================================================
# Etat d'un process à partir d'un PID
#===============================================================================
# $1=pid
# 
# Valorise kpid avec le pid
# 
# retour 
# 10 en cas d'erreur
#  0 process actif
#  1 process inactif
function checkpid() {
  if [ $# -lt 1 ]; then
    echo "Le PID doit être passé en argument"
    return 10
  fi
  
  kpid=$1
  if [ ! "$(ps --pid $kpid | grep -c $kpid)" -eq "0" ]; then
    # pid existe et process running
    run_util_RETVAL="0"
  else
    # pid existe mais pas de process
    run_util_RETVAL="1"
  fi
  return ${run_util_RETVAL}
}

#===============================================================================
# MAJ des variables d'environnement dans les fichiers de configuration
#===============================================================================
# $1=path
# $2=user (facultatif)
# $3=groupe (facultatif)

# retour 
# 10 en cas d'erreur
#
# Recherche les fichiers *.skel dans le path donné.
# Utilise les variables d'environnement APP_* pour 
# 1- créer un fichier sans le suffixe .skel
# 2- remplacer dans ce fichier les tag @APP_*@ par la valeur de la variable APP_* associée
# 3- si user et groupe sont passés en paramètre le fichier généré est changé (chown user:groupe)
#
# ex: server.xml.skel donne server.xml
# ex: si APP_PORT=80 dans le fichier de configuration
#     alors myport=@APP_PORT@ dans le .skel donnera myport=80 dans le fichier créé
#
updateconfig(){
  if [ $# -lt 1 ]; then
    echo "Le chemin doit être passé en argument"
    return 10
  fi
  if [ ! -d $1 ]; then
    echo "Le chemin ($1) est invalide"
    return 10
  fi
  _cfg_confdir=$1
  #changement de user
  _cfg_user=
  _cfg_grou=
  if [ $# -ge 3 ]; then
    _cfg_user=$2
    _cfg_grou=$3
  fi

  echo "MAJ fichiers de configuration dans : ${_cfg_confdir}"


  _cfg_ALL_VARS=$(compgen -A variable | grep APP_)

  _cfg_XREPLACE=
  for RES_KEY in $_cfg_ALL_VARS; do
    eval RES_VAL=\$${RES_KEY}
    _cfg_XREPLACE="$_cfg_XREPLACE | sed 's|@${RES_KEY}@|$RES_VAL|g'"
  done

  for XFILE in ` find "${_cfg_confdir}/" -name "*.skel"`; do
    echo "Variabilisation du fichier ${XFILE}"
    SXFILE=${XFILE%.skel}
    eval "cat ${XFILE} $_cfg_XREPLACE > ${SXFILE}"
  if [ -n ${_cfg_user} -a -n ${_cfg_grou} ]; then
      chown ${_cfg_user}:${_cfg_grou} ${SXFILE}
  fi
  done
  
  return 0
}