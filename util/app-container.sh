#!/bin/bash
set +H

if [ "${BASH_SOURCE[0]}" -ef "$0" ]
then
    echo "Hey, you should source this script, not execute it!"
    exit 1
fi

cd ../react
npm install --silent
npm run build
cd -

if [ ! -z $1 ]; then
  version=":$(cat ../version)-${1}-beta"
  if [[ ! -z ${CIRCLE_BRANCH} && ${CIRCLE_BRANCH} == "master" ]]; then
    version=":$(cat ../version)-${1}"
  fi
  docker build -t verbalwebsites/rrk9_store${version} ../
  # testing only; this is for CI/CD
  # export VERBAL_RRK9_APP_CONTAINER=$(sudo docker run -dit --name rrk9_store -p 443:443 verbalwebsites/rrk9_store${version})
else
  sudo docker rm -f $VERBAL_RRK9_APP_CONTAINER
  if [ $? -ne 0 ]; then sudo docker rm -f rrk9_store; fi
  docker build -t verbalwebsites/rrk9_store ../
  export VERBAL_RRK9_APP_CONTAINER=$(sudo docker run -dit --name rrk9_store -p 443:443 verbalwebsites/rrk9_store)
  echo $VERBAL_RRK9_APP_CONTAINER
  docker ps -a
fi

set -H
