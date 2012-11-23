#!/bin/bash
# This script registers private ip of newly created db server to user created predified FQDN
# This script works now with DNSmadeEASY and you need add user dnsid and hostname manually

usage() {
  echo "USAGE: $0 audb1 privateip"
}

dnsid=

case "$1" in
  audb1)
    dnsid=7855687
    ;;
  audb2)
    dnsid=7979478
    ;;
  vm)
    dnsid=8077691
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

echo "Please enter DME username"
read user
echo "Please enter DME password"
read pass

curl -S -s -o - -f https://www.dnsmadeeasy.com/servlet/updateip?username=$user\&password=$pass\&id=$dnsid\&ip="$2"
