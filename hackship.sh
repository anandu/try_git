#!/bin/sh
# git name-rev is fail
CURRENT=`git branch | grep '\*' | awk '{print $2}'`

usage() {
  echo "USAGE: $0 hack or $0 ship"
}

case "$1" in
  hack)
    git checkout master
    git pull origin master
    git checkout ${CURRENT}
    git rebase master
    ;;
  ship)
    git checkout master
    git merge ${CURRENT}
    git push origin master
    git checkout ${CURRENT}
    ;;
  h|-h|--help|?|-?)
    usage
    exit 0;
    ;;
  *)
    ERRORMSG="unrecognised paramter '$PARAM'"
    usage
    exit 1
    ;;
esac
