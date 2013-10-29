#test 1 2 3 4

<<COMMENT
 takes test number as argument and executes the given test in different screen sessions of the machine.
 create the deployement per test names and starts the jobs in screen.
COMMENT
function usage {
  echo " Usage: $0 [--cloud]
      [--feature <feature_name>] [--cloud]
      [--mysqlconnector]
      [--runonstartup]

  Option notes:
  --noprompt      makes safe assumptions and runs without user interaction
  --installtarget optional install location (default is $DEFAULTINSTALLTARGET)

"
}


###
# Function: parsecommandline
# Take parameters as given on command line and set those up so we can do
# cooler stuff, or complain that nothing will work. Set some reasonable
# defaults so we dont have to type so much.
#
function parsecommandline {
  while [ -n "$1" ]; do
    PARAM=$1
    case "$1" in
    --noprompt)
      NOPROMPT=n
      ;;
    --installtarget)
      shift
      if [[ -e "$1" && ! -d "$1" ]]; then
        ERRORMSG="target already $1 exists but is not a folder"
        return 1
      fi
      if [[ $(echo $1 | grep ^/ ) == "0" ]]; then
        ERRORMSG="please pass in --installtarget as an absolute folder (eg: $DEFAULTINSTALLTARGET, gave $1)"
        return 1
      fi
      INSTALLTARGET="$1"
      ;;
    --runonstartup)
      RUNONSTARTUP="y"
      ;;
    --skip-java)
      NOJAVA="y"
      ;;
    --mysqlconnector)
      MYSQLCONNECTOR="y"
      ;;
    -h|help|-help|--help|?|-?|--?)
      usage
      exit 1;
      ;;
    *)
      ERRORMSG="unrecognised paramter '$PARAM'"
      return 1;
      ;;
    esac
    shift
  done


 
 t=`egrep ^test features/postgres_ha_chef.rb |  awk  {'print $2'}`
 #t=`egrep ^test features/postgres_ha_chef.rb | cut -c 6- | rev | cut -c 3- | rev`
 
 bin/monkey create -f collateral/servertemplate_tests/troops/postgres_ha_chef.json -i 1956 -x aux_t1
 screen -S test -p 1 -X stuff cd /root/virtualmonkey`echo -ne '\015'`
 screen -S test -p 1 -X stuff bin\/monkey\ run\ -f\ collateral\/servertemplate_tests\/troops\/postgres_ha_chef\.json\ -i\ 1956\ -x\ aux_t1\ -t\ \'smoke_test\'\ -y`echo -ne '\015'`
