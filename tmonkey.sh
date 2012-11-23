#test 1 2 3 4

<<COMMENT
 takes test number as argument and executes the given test in different screen sessions of the machine.
 create the deployement per test names and starts the jobs in screen.
COMMENT

 
 t=`egrep ^test features/postgres_ha_chef.rb |  awk  {'print $2'}`
 #t=`egrep ^test features/postgres_ha_chef.rb | cut -c 6- | rev | cut -c 3- | rev`
 
 bin/monkey create -f collateral/servertemplate_tests/troops/postgres_ha_chef.json -i 1956 -x aux_t1
 screen -S test -p 1 -X stuff cd /root/virtualmonkey`echo -ne '\015'`
 screen -S test -p 1 -X stuff bin\/monkey\ run\ -f\ collateral\/servertemplate_tests\/troops\/postgres_ha_chef\.json\ -i\ 1956\ -x\ aux_t1\ -t\ \'smoke_test\'\ -y`echo -ne '\015'`
