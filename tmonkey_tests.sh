#!/bin/bash
echo "Please enter cloud id"
read cloud
[[ "$#" -lt 1 ]] && echo "Please specify name of atleast one test. Usage: t1.sh test1 test2" && exit 1
tests=("do_nothing" "smoke_test" "primary_restore_and_become_master" "secondary_restore_and_become_master_s3" "secondary_restore_and_become_master_cloudfiles" "create_master_from_slave_backup" "promote_slave_with_dead_master" "check_monitoring" "backup_schedule" "verify_lock_conflict" "timestamp_override_primary" "lineage_override_primary" "lineage_and_timestamp_override_primary" "sync_state" "verify_slave_dns" "negative_do_force_reset" "terminate_test")
awtest=("timestamp_override_primary" "lineage_and_timestamp_override_primary")
for i in $@
  do
  match=$(echo "${tests[@]:0}" | grep -wo $1 )
  [[  -z $match ]] && echo "Please specify valid test name. for example. `echo "${tests[@]:0}"` "
  if [ $cloud -gt 10 ] ; then
    submatch=$(echo "${awtest[@]:0}" | grep -wo $match )
    [[ ! -z $submatch ]] && echo "test \"$submatch\" is not supported on cloud $cloud" && exit 1
  fi
  echo $match
  shift
done
