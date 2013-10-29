#Perl Script
# Utility for sanity
# Works ONLY if atleast 9 disk are are free and zeroed 
# Usage:
#	Sanity.pl [-source source filer ip] [-dest destination filer ip]
#
# Note:
# -------
# Make sure RSH works on client machine
# make sure not get any authentication problem regarding logins.
# For sync sanpmirror, cluster should be disabled
# Check licenses
# Requires Perl module IO-Capture.pm, Net::Ftp
# Make the filer entries in /etc/hosts  file

use Net::FTP;
use IO::Capture::Stdout;
use IO::Capture::Stderr;
use Getopt::Long;

$rsh='rsh';
 
my $source = '';   # option variable with default value (false)
my $dest   = '';       # option variable with default value (false)
$type = 'windows';

GetOptions ('source=s' => \$filer1, 
            'dest=s'   => \$filer2);
             
if (!defined($filer1) or !defined($filer2)){
   print "Please enter valid values"; 
   &usage();
   exit;
 }
 
$user = "root";
@passw = ('netapp','');
@filer_pwd = ();
@filers = ($filer1,$filer2);

foreach $filer(@filers){
   foreach $var(@passw){
      $temp = system ("rsh $filer -l root:$var -n date");
      if(!$temp){
         push(@filer_pwd,$var);
      }
      last if(!$temp);
   }   
}

#----------------------------
# Get Source Filer Names
#----------------------------
$user_1 = $user . ":".$filer_pwd[0];
$user_2 = $user . ":".$filer_pwd[1];

$filer_name1 = &get_filer_name($filer1, $user_1);
chomp($filer_name1);
$filer_name2 = &get_filer_name($filer2, $user_2);
chomp($filer_name2);

open(fpin, "$rsh $filer2 -l $user_2 -n priv set diag;registry set state.clioutput.auditlog.enable false|") || die "Cannot execute: registry command";
#Enable NFS on both the filers
open(fpin, "$rsh $filer1 -l $user_1 -n nfs on|") || die "Cannot execute: nfs on";
open(fpin, "$rsh $filer2 -l $user_2 -n nfs on|") || die "Cannot execute: nfs on";
#Enable CIFS on both the filers
open(fpin, "$rsh $filer1 -l $user_1 -n cifs restart|") || die "Cannot execute: cifs restart";
open(fpin, "$rsh $filer2 -l $user_2 -n cifs restart|") || die "Cannot execute: cifs restart";

#----------------------------
# Create 2 files for logs
#----------------------------
$name1 = $filer_name1 . "_src.txt";
$name2 = $filer_name2 . "_dst.txt";
open (FH ,"> $name1");
open (DH ,"> $name2");

# disable cluster
print FH "$filer_name1\> cf disable \n";
&cf_options($filer1,$user_1,FH,0);         # cf disable
print DH "$filer_name2\> cf disable \n";
$temp=&cf_options($filer2,$user_2,DH,0);   # cf disable

# date;uptime
print FH "$filer_name1\> date;uptime \n";
open(fpin, "$rsh $filer1 -l $user_1 -n date;uptime;|") || die "Cannot execute: date;uptime;";
while($op=<fpin>){
   print $op;
   print FH $op	;
}

#version
print FH "$filer_name1\> version \n";
$filer_version = &filer_version($filer1, $user_1,FH);
print "$filer_version \n";

#sysconfig
print FH "$filer_name1\> sysconfig \n";
open(fpin, "$rsh $filer1 -l $user_1 -n sysconfig|") || die "Cannot execute: sysconfig";
while($op=<fpin>){
   print $op;
   print FH $op	;
}

#sysconfig -t
print FH "$filer_name1\> sysconfig -t\n";
open(fpin, "$rsh $filer1 -l $user_1 -n sysconfig -t|") || die "Cannot execute: sysconfig -t";
while($op=<fpin>){
   print $op;
   print FH $op	;
}

#sysconfig -m
print FH "$filer_name1\> sysconfig -m\n";
open(fpin, "$rsh $filer1 -l $user_1 -n sysconfig -m|") || die "Cannot execute: sysconfig -m";
while($op=<fpin>){
   print $op;
   print FH $op	;
}

#df;df -i;
print FH "$filer_name1\> df;df -i;\n";
open(fpin, "$rsh $filer1 -l $user_1 -n df;df -i;|") || die "Cannot execute: df;df -i";
while($op=<fpin>){
   print $op;
   print FH $op	;
}

#vol status;
print FH "$filer_name1\> vol status \n";
$volume_status= &volume_status($filer1, $user_1,FH);

#vol status -r;
print FH "$filer_name1\> vol status -r \n";
open(fpin, "$rsh $filer1 -l $user_1 -n vol status -r|") || die "Cannot execute: vol status -r";
while($op=<fpin>){
   print $op;
   print FH $op	;
}

#vol status -v;
print FH "$filer_name1\> vol status -v \n";
open(fpin, "$rsh $filer1 -l $user_1 -n vol status -v|") || die "Cannot execute: vol status -v";
while($op=<fpin>){
   print $op;
   print FH $op	;
}

#aggr status
print FH "$filer_name1\> aggr status \n";
$aggregate_status= &aggregate_status($filer1, $user_1,FH);

#license
print FH "$filer_name1\> license \n";
open(fpin, "$rsh $filer1 -l $user_1 -n license|") || die "Cannot execute: license";
while($op=<fpin>){
   print $op;
   print FH $op	;
}

#sysconfig -r
print FH "$filer_name1\> sysconfig -r\n";
$filer_configuration= &filer_sysconfig($filer1, $user_1,FH);

$scr_aggr      = "src_aggr";
$scr_vol       = "src_vol";
$scr_vol_size  = "15g";
$scr_qtree     = "src_qtree";
$disk_number   = 3;

#-----------------
# Create Aggregate
#-----------------
#aggr create
print FH "\n #####  CREATING AGGR ##### \n"; 
print FH "$filer_name1\> aggr create $scr_aggr 3 \n";
$aggregate_create= &aggregate_create($filer1, $user_1, $scr_aggr, $disk_number,FH);
sleep 2;
print FH "$filer_name1\> date; \n";
&filer_date($filer1,$user_1,FH);
print FH "$filer_name1\> aggr status \n";
$aggregate_status= &aggregate_status($filer1, $user_1,FH);
#vol status
print FH "$filer_name1\> date; \n";
&filer_date($filer1,$user_1,FH);

#-----------------
# Create Volume
#-----------------
#vol status
print FH "$filer_name1\> vol status \n";
$volume_status= &volume_status($filer1, $user_1,FH);
#vol create
print FH "$filer_name1\> vol create $scr_vol $scr_aggr $scr_vol_size\n";
$volume_create= &volume_create($filer1, $user_1, $scr_aggr, $scr_vol, $scr_vol_size,1,FH);
sleep 1;
#vol status
print FH "$filer_name1\> vol status \n";
$volume_status= &volume_status($filer1, $user_1,FH);

#--------------------------------
# Create some data on the volume
#--------------------------------
$parent_dir = `pwd`;
chomp($parent_dir);
$parent_dir1 = $parent_dir;
$dir_name = "dir_" . rand();
mkdir ("/$dir_name" ,0777);
$exportfs = &exportfs($filer1, $user_1,$scr_vol,FH,0);
print `mount $filer1:/vol/$scr_vol /$dir_name/`;
chdir("/$dir_name");
for($i=0;$i<20;$i++){
   open (HH,">files[$i].txt");
   $buff = "##########" x 1000000;
   print HH $buff;
   close HH;
}
chdir($parent_dir);
print `umount $filer1:/vol/$scr_vol`;

#-----------------
# Qtree Creation
#-----------------
#qtree status
print FH "$filer_name1\> qtree status \n";
$qtree_status= &qtree_status($filer1, $user_1,FH);
#qtree create
print FH "$filer_name1\> qtree create /vol/$scr_vol/$scr_qtree \n";
$qtree_create= &qtree_create($filer1, $user_1, $scr_vol, $scr_qtree,FH);
#qtree status
print FH "$filer_name1\> date; \n";
&filer_date($filer1,$user_1,FH);
print FH "$filer_name1\> qtree status \n";
$qtree_status= &qtree_status($filer1, $user_1,FH);
#Changing Qtree Security Style
print FH "$filer_name1\> qtree security /vol/$scr_vol/$scr_qtree mixed \n";
$qtree_security= &qtree_security($filer1, $user_1, $scr_vol, $scr_qtree,FH);
print FH "$filer_name1\> qtree status \n";
$qtree_status= &qtree_status($filer1, $user_1,FH);

#-----------------------------------
#Changing security style of Volume
#-----------------------------------
print FH "$filer_name1\> qtree security /vol/$scr_vol mixed \n";
$vol_security= &vol_security($filer1, $user_1, $scr_vol,1,FH);
print FH "$filer_name1\> date; \n";
&filer_date($filer1,$user_1,FH);
#Display security style of Volume
print FH "$filer_name1\> qtree security /vol/$scr_vol \n";
$vol_security= &vol_security($filer1, $user_1, $scr_vol,0,FH);

#---------------------------
##Volume Creation (Trad)###
#---------------------------
$scr_vol      = "traditional";
$scr_vol_size = "15g";
print FH "\n ## Volume Creation (Traditional) ### \n";
print FH "$filer_name1\> vol create $scr_vol 3 \n";
$volume_create= &volume_create($filer1, $user_1, $scr_aggr, $scr_vol, 3,0,FH); 
#vol status
print FH "$filer_name1\> vol status \n";
$volume_status= &volume_status($filer1, $user_1,FH);
#volume usage
print FH "$filer_name1\> df -Vh $scr_vol \n";
$vol_usage =&vol_usage ($filer1, $user_1, $scr_vol,FH);

#-----------------------
# CIFS Shares Creation
#-----------------------
print FH "\n ### CIFS SHARES ### \n";
#vol status
print FH "$filer_name1\> date; \n";
&filer_date($filer1,$user_1,FH);
print FH "$filer_name1\> vol status \n";
$volume_status= &volume_status($filer1, $user_1,FH);
#cifs add
$scr_vol = "src_vol";
print FH "$filer_name1\> cifs shares -add cshare /vol/$scr_vol \n";
$cifs_shares =&cifs_shares($filer1, $user_1, $scr_vol,FH);
#cifs shares;
print FH "$filer_name1\> cifs shares \n";
open(fpin, "$rsh $filer1 -l $user_1 -n cifs shares|") || die "Cannot execute: cifs shares";
while($op=<fpin>){
   print $op;
   print FH $op	;
}

#-------------------------
# CIFS Access checking
#-------------------------
# open(fpin, "rsh 10.52.60.61 -n net use /d P:") || die "Cannot execute: net use /d";
open(fpin, "rsh 10.52.60.61 -n net use /d P\:|") || die "Cannot execute: net use /d";
open(fpin, "rsh 10.52.60.61 -n net use P: \\\\\\\\$filer1\\\\cshare /u:netapp-pune\\\\ubale netapp\@123|") || die "Cannot execute: could not map share\n";

print FH "$filer_name1\> cifs sessions \n";
open(fpin, "$rsh $filer1 -l $user_1 -n cifs sessions|") || die "Cannot execute: cifs sessions";
while($op=<fpin>){
   print $op;
   print FH $op	;
}

#volume usage
print FH "\n$filer_name1\> df -Vh $scr_vol \n";
$vol_usage =&vol_usage ($filer1, $user_1, $scr_vol,FH);
#snapmirror options
print FH "$filer_name1\> date; \n";
&filer_date($filer1,$user_1,FH);
print FH "$filer_name1\> snapmirror options \n";
$snapmirror_options= &snapmirror_options($filer1, $user_1,$filer_name1,FH);
#snapmirror status
print FH "$filer_name1\> snapmirror status \n";
$snapmirror_status= &snapmirror_status($filer1, $user_1 ,$filer_name1,FH);
#snapmirror on
print FH "$filer_name1\> snapmirror on \n";
$snapmirror_on= &snapmirror_on($filer1, $user_1,FH);
sleep 2;
#snapmirror status
print FH "$filer_name1\> snapmirror status \n";
$snapmirror_status= &snapmirror_status($filer1, $user_1,$filer_name1,FH);

#-------------------
#DESTINATION FILER
#-------------------
# get source filer name
print DH "$filer_name2\> date; \n";
&filer_date($filer2,$user,DH);

print DH "$filer_name2\> date;uptime \n";
open(fpin, "$rsh $filer2 -l $user -n date;uptime;|") || die "Cannot execute: date;uptime;";
while($op=<fpin>){
   print $op;
   print DH $op	;
}

#version
print DH "$filer_name2\> version \n";
$filer_version = &filer_version($filer2, $user_2,DH);
print "$filer_version \n";

#sysconfig
print DH "$filer_name1\> sysconfig \n";
open(fpin, "$rsh $filer2 -l $user_2 -n sysconfig|") || die "Cannot execute: sysconfig";
while($op=<fpin>){
   print $op;
   print DH $op	;
}

#sysconfig -t
print DH "$filer_name2\> sysconfig -t\n";
open(fpin, "$rsh $filer2 -l $user_2 -n sysconfig -t|") || die "Cannot execute: sysconfig -t";
while($op=<fpin>){
   print $op;
   print DH $op	;
}

#sysconfig -m
print DH "$filer_name2\> sysconfig -m\n";
open(fpin, "$rsh $filer2 -l $user_2 -n sysconfig -m|") || die "Cannot execute: sysconfig -m";
while($op=<fpin>){
   print $op;
   print DH $op	;
}

#df;df -i;
print DH "$filer_name2\> df;df -i;\n";
open(fpin, "$rsh $filer2 -l $user_2 -n df;df -i;|") || die "Cannot execute: df;df -i";
while($op=<fpin>){
   print $op;
   print DH $op	;
}

#vol status;
print DH "$filer_name2\> vol status \n";
$volume_status= &volume_status($filer2, $user_2,DH);

#vol status -r;
print DH "$filer_name2\> vol status -r \n";
open(fpin, "$rsh $filer2 -l $user_2 -n vol status -r|") || die "Cannot execute: vol status -r";
while($op=<fpin>){
   print $op;
   print DH $op	;
}

#vol status -v;
print DH "$filer_name2\> vol status -v \n";
open(fpin, "$rsh $filer2 -l $user_2 -n vol status -v|") || die "Cannot execute: vol status -v";
while($op=<fpin>){
   print $op;
   print DH $op	;
}

#aggr status
print DH "$filer_name2\> aggr status \n";
$aggregate_status= &aggregate_status($filer2, $user_2,DH);

#license
print DH "$filer_name2\> license \n";
open(fpin, "$rsh $filer2 -l $user_2 -n license|") || die "Cannot execute: license";
while($op=<fpin>){
   print $op;
   print DH $op	;
}

#sysconfig -r
print DH "$filer_name2\> sysconfig -r\n";
$filer_configuration= &filer_sysconfig($filer2, $user_2,DH);

$dst_aggr    = "dst_aggr";
$disk_number = 3;

print DH "\n #####  CREATING AGGREGATE ##### \n"; 
print DH "$filer_name2\> aggr create $dst_aggr $disk_number \n";
$aggregate_create= &aggregate_create($filer2, $user_2,$dst_aggr, $disk_number,DH);
sleep 2;
print DH "$filer_name2\> date; \n";
&filer_date($filer2,$user_2,DH);

#aggr status
print DH "$filer_name2\> aggr status \n";
$aggregate_status= &aggregate_status($filer2, $user_2,DH);
#vol status
print DH "$filer_name2\> vol status \n";
$volume_status= &volume_status($filer2, $user_2,DH);
#vol create
$dst_vol = "dst_vol";
$dst_vol_size = "15g";
print DH "$filer_name2\> date; \n";
&filer_date($filer2,$user_2,DH);
print DH "$filer_name2\> vol create $dst_vol $dst_aggr $dst_vol_size\n";
$volume_create= &volume_create($filer2, $user_2, $dst_aggr, $dst_vol, $dst_vol_size,1,DH);
sleep 1;
$dst_vol1 = "dst_vol1";
print DH "$filer_name2\> date; \n";
&filer_date($filer2,$user_2,DH);
print DH "$filer_name2\> vol create $dst_vol1 $dst_aggr $dst_vol_size\n";
$volume_create= &volume_create($filer2, $user_2, $dst_aggr, $dst_vol1, $dst_vol_size,1,DH);
#vol status
print DH "$filer_name2\> vol status \n";
$volume_status= &volume_status($filer2, $user_2,DH);
sleep 2;

#--------------------------------
# Create some data on the volume
#--------------------------------
$dir_name = "dir_" . rand();
mkdir ("/$dir_name" ,0777);
print `mount $filer1:/vol/$scr_vol /$dir_name/`;
chdir("/$dir_name");
for($i=0;$i<20;$i++){
   open (HH,">filess[$i].txt");
   $buff = "##########" x 100000;
   print HH $buff;
   close HH;
}
chdir($parent_dir);
print `umount $filer1:/vol/$scr_vol`;

#volume usage
print FH "$filer_name1\> df -Vh $scr_vol \n";
$vol_usage =&vol_usage ($filer1, $user_1, $scr_vol,FH);
print FH "$filer_name1\> date; \n";
&filer_date($filer1,$user,FH);
$scr_vol1 = "src_vol1";
$scr_vol_size = "15g";

print FH "\n ### Creating Flex Volume ### \n";
print FH "$filer_name1\> vol create $scr_vol1 $scr_aggr $scr_vol_size\n";
$volume_create= &volume_create($filer1, $user_1, $scr_aggr, $scr_vol1, $scr_vol_size,1,FH);
sleep 1;
#vol status
print FH "$filer_name1\> vol status \n";
$volume_status= &volume_status($filer1, $user_1,FH);
sleep 2;
print FH "$filer_name1\> vol restrict scr_vol1 \n";
$volume_restrict= &volume_restrict($filer1, $user_1, $scr_vol1,FH);
print FH "$filer_name1\> vol copy -S $scr_vol $scr_vol1 \n";
$vol_copy = &vol_copy($filer1,$user_1,$scr_vol,$scr_vol1,FH);
print FH "$filer_name1\> vol online $scr_vol1 \n";
$volume_online = &volume_online($filer1, $user_1, $scr_vol1,FH);
#volume usage
print FH "$filer_name1\> df -Vh $scr_vol \n";
$vol_usage =&vol_usage ($filer1, $user_1, $scr_vol,FH);

#-----------------------
# Performing Aggr copy
#-----------------------
print FH "$filer_name1\> date; \n";
&filer_date($filer1,$user_1,FH);
$scr_aggr1 = "scr_aggr1";

print FH "\n ### Creating new aggregrate for aggr copy ### \n";
print FH "$filer_name1\> aggr create $scr_aggr1 3 \n";
$aggregate_create= &aggregate_create($filer1, $user_1, $scr_aggr1, 3,FH);
sleep 2;
#aggr status
print FH "$filer_name1\> aggr status \n";
$aggregate_status= &aggregate_status($filer1, $user_1,FH);
#aggr usage
print FH "$filer_name1\> date; \n";
&filer_date($filer1,$user_1,FH);
print FH "$filer_name1\> df -Ah $scr_vol \n";
$aggr_usage =&aggr_usage ($filer1, $user_1, $scr_aggr1,FH);

print FH "\n ### Starting aggr copy ### \n\n";
print FH "$filer_name1\> date; \n";
&filer_date($filer1,$user_1,FH);
print FH "$filer_name1\> aggr restrict $scr_aggr1 \n";
$aggr_restrict= &aggr_restrict($filer1, $user_1, $scr_aggr1,FH);
print FH "$filer_name1\> aggr copy -S $scr_aggr $scr_aggr1 \n";
$aggr_copy = &aggr_copy($filer1,$user_1,$scr_aggr,$scr_aggr1,FH);
print FH "$filer_name1\> date; \n";
&filer_date($filer1,$user_1,FH);
print FH "$filer_name1\> aggr online $scr_aggr1 \n";
$aggr_online = &aggr_online($filer1, $user_1, $scr_aggr1,FH);

print DH "$filer_name2\> ### CHECKING VSM ### \n\n";
#snapmirror options
print DH "$filer_name2\> snapmirror options \n";
$snapmirror_options= &snapmirror_options($filer2, $user_2,$filer_name2,DH);
#vol restrict 
print DH "$filer_name2\> date; \n";
&filer_date($filer2,$user_2,DH);
print DH "$filer_name2\> vol restrict $dst_vol\n";
$volume_restrict= &volume_restrict($filer2, $user_2, $dst_vol,DH);
print DH "$filer_name2\> vol status \n";
$volume_status= &volume_status($filer2, $user_2,DH);
print FH "$filer_name1\> date; \n";
&filer_date($filer1,$user_1,FH);
sleep 2;

#-------
# VSM
#-------
$config_path = "/etc";
$etc_conf_file = "/$dir_name"."/"."hosts";
$dir_name = "dir_" . rand();
mkdir ("/$dir_name" ,0777);
print `mount $filer1:/etc /$dir_name/`;
open(SH ,">> $etc_conf_file");
$str = "$filer2    $filer_name2";
print SH `echo $str`;
close SH;
print `umount $filer1:/etc`;
sleep 10;

print `mount $filer2:/etc /$dir_name/`;
open(SH ,">>$etc_conf_file");
$str = "$filer1    $filer_name1";
print SH `echo $str`;
close SH;
print `umount $filer2:/etc`;
sleep 10;

#snapmirror status
print DH "$filer_name2\> snapmirror status \n";
$snapmirror_status= &snapmirror_status($filer2, $user_2 ,DH);
#snapmirror on
print DH "$filer_name2\> snapmirror on \n";
$snapmirror_on= &snapmirror_on($filer2, $user_2,DH);
sleep 2;
#snapmirror status
print DH "$filer_name2\> snapmirror status \n";
$snapmirror_status= &snapmirror_status($filer2, $user_2,DH);
$snapmirror_on= &snapmirror_on($filer2, $user_2,DH);
sleep 1;
print DH "$filer_name2\> snapmirror initialize -S $filer_name1:$scr_vol $filer_name2:$dst_vol \n";
$snapmirror_initialize= &snapmirror_initialize($filer_name1, $filer_name2, $user_2, $scr_vol, $dst_vol,DH,$filer2);
print "\nSleeping for 30 seconds....\n";
sleep 30;
print DH "$filer_name2\> snapmirror status \n";
$snapmirror_status= &snapmirror_status($filer2, $user_2,DH);
print DH "$filer_name2\> date; \n";
&filer_date($filer2,$user_2,DH);

#-------
# RSM
#-------
print DH "\n ### Adding entry in conf file to convert VSM to RSM ### \n";
#For Asynchronous Snap mirror
$config_path = "/etc";
$dir_name = "dir_" . rand();
mkdir ("/$dir_name" ,0777);
print `mount $filer2:/etc /$dir_name/`;
$snapmirror_conf_file = "/$dir_name"."/"."snapmirror.conf";
open(SH ,">>$snapmirror_conf_file");
$str = "$filer_name1:$scr_vol1	$filer_name2:$dst_vol1 - sync";
print SH `echo $str`;
close SH;
print DH "$filer_name2\> rdfile /etc/snapmirror.conf \n";
$snapmirror_conf_file ="snapmirror.conf";
$read_file= &read_file($filer2, $user_2, $config_path, $snapmirror_conf_file,DH);
print `umount $filer2:/etc`;
sleep 10;
print DH "$filer_name2\> snapmirror status \n";
$snapmirror_status= &snapmirror_status($filer2, $user_2,DH);
print DH "$filer_name2\> date; \n";
&filer_date($filer2,$user_2,DH);
print DH "$filer_name2\> vol restrict $dst_vol1\n";
$volume_restrict= &volume_restrict($filer2, $user_2, $dst_vol1,DH);
print DH "$filer_name2\> vol status \n";
$volume_status= &volume_status($filer2, $user_2,DH);
print FH "$filer_name1\> date; \n";
&filer_date($filer1,$user_1,FH);
sleep 2;
print DH "$filer_name2\> snapmirror initialize -S $filer_name1:$scr_vol1 $filer_name2:$dst_vol1 \n";
$snapmirror_initialize= &snapmirror_initialize($filer_name1, $filer_name2, $user_2, $scr_vol1, $dst_vol1,DH,$filer2);
print "Sleeping for 90 seconds.....";
sleep 90;
print DH "$filer_name2\> snapmirror status \n";
$snapmirror_status= &snapmirror_status($filer2, $user_2,DH);
print DH "$filer_name2\> date; \n";
&filer_date($filer2,$user_2,DH);

#-------
# QSM
#-------
print DH "$filer_name2\> date; \n";
&filer_date($filer2,$user_2,DH);
print DH "\n ### QSM Testing ### \n";
#vol create
$dst_vol2     = "dst_vol2";
$dst_vol_size = "15g";
print DH "$filer_name2\> date; \n";
&filer_date($filer2,$user_2,DH);
print DH "$filer_name2\> vol create $dst_vol2 $dst_aggr $dst_vol_size\n";
$volume_create= &volume_create($filer2, $user_2, $dst_aggr, $dst_vol2, $dst_vol_size,1,DH);
$source_qtree ="/vol/$scr_vol/$scr_qtree";
$dest_qtree = "/vol/$dst_vol2/snap_qtree";
print DH "$filer_name2\> snapmirror initialize -S $filer_name1:$source_qtree $filer_name2:$dest_qtree \n";
$snapmirror_initialize= &snapmirror_initialize($filer_name1, $filer_name2, $user_2, $source_qtree, $dest_qtree,DH,$filer2);
print "Sleeping for 30 seconds.....";
sleep 30;
print DH "$filer_name2\> snapmirror status \n";
$snapmirror_status= &snapmirror_status($filer2, $user_2,DH);
print DH "$filer_name2\> date; \n";
&filer_date($filer2,$user_2,DH);

#-----------------------------------
# Lun creation and mapping test
#-----------------------------------
print FH "\n ###Lun creation and mapping test### \n";
print DH "\n ###Lun creation and mapping test### \n";
$vol_lun      = "vol_lun";
$scr_vol_size = "15g";
# Create a volume called vol_lun on both the filers
print FH "$filer_name1\> vol create $vol_lun $scr_aggr $scr_vol_size\n";
$volume_create= &volume_create($filer1, $user_1, $scr_aggr, $vol_lun, $scr_vol_size,1,FH);
print DH "$filer_name2\> vol create $vol_lun $dst_aggr $scr_vol_size\n";
$volume_create= &volume_create($filer2, $user_2, $dst_aggr, $vol_lun, $scr_vol_size,1,DH);
print FH "$filer_name1\> date; \n";
&filer_date($filer1,$user_1,FH);
print DH "$filer_name2\> date; \n";
&filer_date($filer2,$user_2,DH);
sleep 1;
#vol status
print FH "$filer_name1\> vol status \n";
$volume_status= &volume_status($filer1, $user_1,FH);
print DH "$filer_name2\> vol status \n";
$volume_status= &volume_status($filer2, $user_2,DH);
sleep 2;

# Create a LUN
print FH "$filer_name1\> lun create -s 2g -t windows /vol/$vol_lun/lun_windows \n";
$lun_create = &lun_create($filer1, $user_1, $scr_aggr, $vol_lun, $type,FH);
#print FH "$filer_name1\> lun create -s 2g -t windows /vol/$vol_lun/fcp_windows \n";
#$lun_create = &lun_create($filer1, $user_1, $scr_aggr, $vol_lun, $type,FH);
#open(fpin, "$rsh $filer1 -l $user_1 -n lun create -s 2g -t $type /vol/$vol_lun/fcp_windows|") || die "Cannot execute: lun create";
#while($lun_create=<fpin>){
#   print FH $lun_create;
#	  print $lun_create;
#}

print DH "$filer_name2\> lun create -s 2g -t windows /vol/$vol_lun/lun_windows \n";
$lun_create = &lun_create($filer2, $user_2, $dst_aggr, $vol_lun, $type,DH);

#print DH "$filer_name2\> lun create -s 2g -t windows /vol/$vol_lun/fcp_windows \n";
#$lun_create = &lun_create($filer1, $user_1, $scr_aggr, $vol_lun, $type,FH);
#open(fpin, "$rsh $filer2 -l $user_2 -n lun create -s 2g -t $type /vol/$vol_lun/fcp_windows|") || die "Cannot execute: lun create";
##   print DH $lun_create;
##}

print FH "$filer_name1\> date; \n";
&filer_date($filer1,$user_1,FH);
print DH "$filer_name2\> date; \n";
&filer_date($filer2,$user_2,DH);
sleep 1;
print FH "$filer_name1\> lun show -m \n";
&lun_show($filer1,$user_1,FH);
print DH "$filer_name2\> lun show -m \n";
&lun_show($filer2,$user_2,DH);

print FH "$filer_name1\> igroup show \n";
&igroup_show($filer1,$user_1,FH);
print DH "$filer_name2\> igroup show \n";
&igroup_show($filer2,$user_2,DH);

#igroup create -i -t windows windowsgr iqn.1991-05.com.microsoft:pund4773.symphonysv.com
$igrp_name = $type . "_igrp_src";
#$igroup ="iqn.1991-05.com.microsoft:sushw01.suswin2k3.qa";   ####10.52.67.27 is used
#$igroup="iqn.1991-05.com.microsoft:sushw-02.suswin2k3.qa";	###10.52.67.30 is used
print "Enter IQN Target name : ";
$igroup = <STDIN>;
chomp($igroup);
#$igroup="iqn.1991-05.com.microsoft:pund4773.symphonysv.com";  ###10.52.60.201

# Create an Igroup
print FH "$filer_name1\> igroup create -i -t $type $igrp_name $igroup\n";
&igroup_create($filer1,$user_1,$type,$igrp_name,$igroup,FH);
$igrp_name1 = $type . "_igrp_dst";
print DH "$filer_name2\> igroup create -i -t $type $igrp_name1 $igroup\n";
&igroup_create($filer2,$user_2,$type,$igrp_name1,$igroup,DH);
#fcp igroup creation 
#$fcp_igrp_name = "fcp_igroup";
#$fcp_igroup1 = "10000000C943F272";
#$fcp_igroup2 = "10000000C9582B40";
#print FH "$filer_name1\> igroup create -f -t $type $fcp_igrp_name $fcp_igroup1\n";
#&fcp_igroup_create($filer1,$user_1,$type,$fcp_igrp_name,$fcp_igroup1,FH);
#print DH "$filer_name2\> igroup create -f -t $type $fcp_igrp_name $fcp_igroup2\n";
#&fcp_igroup_create($filer2,$user_2,$type,$fcp_igrp_name,$fcp_igroup2,DH);

print FH "$filer_name1\> igroup show \n";
&igroup_show($filer1,$user_1,FH);
print DH "$filer_name2\> igroup show \n";
&igroup_show($filer2,$user_2,DH);

# Lun Mapping
print FH "$filer_name1\> lun map /vol/$vol_lun/lun_windows $igrp_name \n";
$lun_map = &lun_map($filer1, $user_1, $vol_lun,$igrp_name,$type,FH);
print DH "$filer_name2\> lun map /vol/$vol_lun/lun_windows $igrp_name1 \n";
$lun_map = &lun_map($filer2, $user_2, $vol_lun,$igrp_name1,$type,DH);
# fcp lun map
#print FH "$filer_name1\> lun map /vol/$vol_lun/fcp_windows $fcp_igrp_name \n";
#$lun_map = &lun_map_fcp($filer1, $user_1, $vol_lun,$fcp_igrp_name,$type,FH);
#print DH "$filer_name2\> lun map /vol/$vol_lun/fcp_windows $fcp_igrp_name \n";
#$lun_map = &lun_map_fcp($filer2, $user_2, $vol_lun,$fcp_igrp_name,$type,DH);

print FH "$filer_name1\> lun show \n";
&lun_show($filer1,$user_1,FH);
print DH "$filer_name2\> lun show \n";
&lun_show($filer2,$user_2,DH);

print FH "$filer_name1\> date; \n";
&filer_date($filer1,$user_1,FH);
print DH "$filer_name2\> date; \n";
&filer_date($filer2,$user_2,DH);

#$port    = "3260";
#&add_portal($filer1,$port);
#&add_portal($filer2,$port);

print "Please manually logon the iSCSI target and then press enter to continue..";
$temp =<STDIN>;

#open(fpin, "rsh 10.52.67.27 -n E:\\\\TOOLS\\\\devcon.exe rescan disks|");
#open(fpin, "rsh 10.52.67.27 -n E:\\\\TOOLS\\\\mpc.exe show disks|");
#while($cmd_status=<fpin>){
#   print "$cmd_status\n";
#}

open(fpin, "rsh $filer1 -l $user_1 -n lun stats|");
print "LUN STATS FOR $filer1 before sio.exe is executed\n";
while($cmd_status=<fpin>){
   print "$cmd_status\n";
}

open(fpin, "rsh $filer2 -l $user_2 -n lun stats|");
print "LUN STATS FOR $filer2 before sio.exe is executed\n";
while($cmd_status=<fpin>){
   print "$cmd_status\n";
}

#open(fpin, "rsh 10.52.67.27 -n E:\\\\TOOLS\\\\sio.exe 25 50 4k 0 100m 10 \\\\.\\PHYSICALDRIVE1 \\\\.\\PHYSICALDRIVE2 \\\\.\\PHYSICALDRIVE3 \\\\.\\PHYSICALDRIVE4|");
#while($cmd_status=<fpin>){
#   print "$cmd_status\n";
#}

open(fpin, "rsh $filer1 -l $user_1 -n lun stats|");
print "LUN STATS FOR $filer1 after sio.exe is executed\n";
while($cmd_status=<fpin>){
   print "$cmd_status\n";
}

open(fpin, "rsh $filer2 -l $user_2 -n lun stats|");
print "LUN STATS FOR $filer2 after sio.exe is executed\n";
while($cmd_status=<fpin>){
   print "$cmd_status\n";
}

 #E:\TOOLS>sio.exe 25 50 4k 0 100m 10 \\.\PHYSICALDRIVE1 \\.\PHYSICALDRIVE2 \\.\PH
#YSICALDRIVE3 \\.\PHYSICALDRIVE4

# Iscsi stats
print FH "$filer_name1\> iscsi stats \n";
&iscsi_stats($filer1,$user_1,FH);
# Iscsi stats
print DH "$filer_name2\> iscsi stats \n";
&iscsi_stats($filer2,$user_2,DH);

# Lun stats
print FH "$filer_name1\> lun stats \n";
&lun_stats($filer1,$user_1,FH);
print DH "$filer_name2\> lun stats \n";
&lun_stats($filer2,$user_2,DH);

print FH "$filer_name1\> date; \n";
&filer_date($filer1,$user_1,FH);
print DH "$filer_name2\> date; \n";
&filer_date($filer2,$user_2,DH);

#---------------------
# Adding NFS Exports
#---------------------
print FH "$filer_name1\> date; \n";
&filer_date($filer1,$user_1,FH);
print FH "\n\n###Adding NFS Exports### \n";
$vol_nfs      = "vol_nfs";
$scr_vol_size = "30m";
print FH "$filer_name1\> vol create $vol_nfs $scr_aggr $scr_vol_size\n";
$volume_create= &volume_create($filer1, $user_1, $scr_aggr, $vol_nfs, $scr_vol_size,1,FH);
print FH "$filer_name1\> date; \n";
&filer_date($filer1,$user_1,FH);
sleep 1;
#vol status
print FH "$filer_name1\> vol status \n";
$volume_status= &volume_status($filer1, $user_1,FH);
sleep 2;
#exportfs -p rw,anon=0 /vol/vol_nfs
print FH "$filer_name1 \> exportfs -p rw,anon=0 /vol/$vol_nfs \n";
$exportfs = &exportfs($filer1, $user_1,$vol_nfs,FH,0);
print FH "$filer_name1\> date; \n";
&filer_date($filer1,$user_1,FH);
print FH "$filer_name1\> exportfs \n";
$exportfs = &exportfs($filer1, $user_1,$vol_nfs,FH,1);
print FH "$filer_name1\> date; \n";
&filer_date($filer1,$user_1,FH);

#-----------------------
# NFS Client Logs
#-----------------------
print FH "\n ### NFS Client Logs ### \n";
print FH "$filer_name1\> date; \n";
&filer_date($filer1,$user_1,FH);
$nfs_dir = "nfs_dir";
mkdir("/$nfs_dir",0777);
print FH "$filer_name1\> mount $filer1:/vol/$vol_nfs /$nfs_dir/ \n";
print FH `mount $filer1:/vol/$vol_nfs /$nfs_dir`;
print FH "$filer_name1\> cd $nfs_dir/ \n";
#print FH `cd $nfs_dir/`;
chdir("/$nfs_dir");
print FH "$filer_name1\> ls -l \n";
print FH `ls -l`;
print FH "$filer_name1\> touch file1.txt \n";
print FH `touch file1.txt`;
print FH "$filer_name1\> ls -l \n";
print FH `ls -l`;
print `echo "This is NFS volume" > file1.txt`;
print FH "$filer_name1\> cat file1.txt \n";
print FH `cat file1.txt`;
chdir($parent_dir);
print `umount $filer1:/vol/$vol_nfs`;

#------------------------
#  ANONYMOUS FTP TESTING
#------------------------
#options ftpd;
print FH "$filer_name1\> date; \n";
&filer_date($filer1,$user_1,FH);
print FH "\n\n### Anonymous FTP Testing ###\n";
print FH "$filer_name1\> options ftpd \n";
open(fpin, "$rsh $filer1 -l $user_1 -n options ftpd|") || die "Cannot execute: options ftpd";
while($op=<fpin>){
   print $op;
   print FH $op	;
}

print "\n";
print FH "\n### FTP Client Logs ###\n";
print "\nEnter the Username =>  ";
chomp ($username = <STDIN>);
print "\nEnter the Password =>  ";
chomp ($password = <STDIN>);
$file_name = `date +%y%m%d`;
chomp($file_name);
print "file name : $file_name";
`touch $file_name`;                 # create a file which will be transferred  using FTP
 
$capture = IO::Capture::Stdout->new();
$capture->start();                                      # STDOUT Output captured
$capture1 = IO::Capture::Stderr->new();
$capture1->start();                                     # STDERR Output captured
my $ftp = Net::FTP->new("$filer1",Debug => 1)           # do FTP in debug mode  
   or die "Cannot connect to some.host.name: $@";

$ftp->login("$username","$password")
    or die "Cannot login ", $ftp->message;

$ftp->put("$file_name")
   or die "put failed ", $ftp->message;
   
$direc = $ftp->pwd();
@list = $ftp->dir($direc);        
foreach $element(@list){
   print "$element \n";
}

$ftp->quit();
$capture->stop();           # STDOUT output sent to wherever it was before 'start'
$capture1->stop();          # STDERR output sent to wherever it was before 'start'
@buffer = $capture->read;
@buffer1 = $capture1->read;
print FH "@buffer1";
print FH "@buffer";


#---------------------------------------------
# Cluster Failover and Giveback Testing
#---------------------------------------------
print DH "\n ###Cluster Failover and Giveback Testing### \n";
print DH "$filer_name2\> date; \n";
&filer_date($filer2,$user_2,DH);
#priv set diag;registry set state.clioutput.auditlog.enable false
open(fpin, "$rsh $filer2 -l $user_2 -n priv set diag;registry set state.clioutput.auditlog.enable false|") || die "Cannot execute: registry command";

#---------------------------------------------
# Cluster Failover and Giveback Testing
#---------------------------------------------
print DH "\n ###Cluster Failover and Giveback Testing### \n";
print DH "$filer_name2\> cf enable \n";
$temp=&cf_options($filer2,$user_2,DH,1);   # cf enable
print FH "$filer_name1\> cf enable \n";
&cf_options($filer1,$user_1,FH,1);   # cf enable
#license
print DH "$filer_name2\> date; \n";
&filer_date($filer2,$user_2,DH);
print DH "$filer_name2\> license \n";
open(fpin, "$rsh $filer2 -l $user_2 -n license|") || die "Cannot execute: license";
while($op=<fpin>){
   print $op;
   print DH $op	;
}

open(fpin, "$rsh $filer2 -l $user_2 -n lun stats -z|") || die "Cannot execute: lun stats -z";
open(fpin, "$rsh $filer1 -l $user_1 -n lun stats -z|") || die "Cannot execute: lun stats -z";

#rsh 10.52.67.27 perl E:\\TOOLS\\sio.pl
#open(fpin, "rsh 10.52.67.27 -n perl E:\\\\TOOLS\\\\sio.pl|");
#sleep 60;

print DH "\n ###Lun Stats Before Takeover### \n";
print FH "\n ###Lun Stats Before Takeover### \n";

# Lun stats
print FH "$filer_name1\> lun stats \n";
&lun_stats($filer1,$user_1,FH);

print DH "$filer_name2\> lun stats \n";
&lun_stats($filer2,$user_2,DH);

#priv set diag;registry set state.clioutput.auditlog.enable true
chdir($parent_dir);
$dir_name = "dir_" . rand();
mkdir ("/$dir_name" ,0777);
print `mount $filer2:/etc /$dir_name/`;
$audit_file = "/$dir_name"."/log"."/"."auditlog";
$msg_file   = "/$dir_name"."/"."messages";
`rm -rf $audit_file`;
`rm -rf $msg_file`;
sleep 10;
open(fpin, "$rsh $filer2 -l $user_2 -n priv set diag;registry set state.clioutput.auditlog.enable true|") || die "Cannot execute: registry command";
print DH "$filer_name2\> cf takeover \n";
&cf_options($filer2,$user_2,DH,2);   # cf takeover
print "\n Sleeping for 3 mins...";
sleep 180;
`cat $audit_file >> $name2`;
`cat $msg_file   >> $name2`;
`rm -rf $audit_file`;
`rm -rf $msg_file`;
open(fpin, "$rsh $filer2 -l $user_2 -n lun stats -z|") || die "Cannot execute: lun stats -z";
open(fpin, "$rsh $filer1 -l $user_1 -n lun stats -z|") || die "Cannot execute: lun stats -z";
sleep 100;

print DH "\n ###Lun Stats and Sysstat in Takeover mode ### \n";

# sus3050-2(takeover)
print DH "$filer_name2\(takeover\)\> sysstat -c 5 -x 1 \n";
open(fpin, "$rsh $filer2 -l $user_2 -n sysstat -c 5 -x 1|") || die "Cannot execute: registry command";
while($op=<fpin>){
   print $op;
   print DH $op	;
}

print DH "$filer_name2\(takeover\)\> partner sysstat -c 5 -x 1 \n";
open(fpin, "$rsh $filer2 -l $user_2 -n partner sysstat -c 5 -x 1 |") || die "Cannot execute: registry command";
while($op=<fpin>){
   print $op;
   print DH $op	;
}

print DH "$filer_name2\(takeover\)\> lun stats \n";
open(fpin, "$rsh $filer2 -l $user_2 -n lun stats|") || die "Cannot execute: registry command";
while($op=<fpin>){
   print $op;
   print DH $op	;
}

print DH "$filer_name2\(takeover\)\> partner lun stats \n";
open(fpin, "$rsh $filer2 -l $user_2 -n partner lun stats|") || die "Cannot execute: registry command";
while($op=<fpin>){
   print $op;
   print DH $op	;
}

sleep 20;

&cf_options($filer2,$user_2,DH,3);   # cf giveback
sleep 60;
`cat $audit_file >> $name2`;
`cat $msg_file   >> $name2`;
print `umount $filer2:/etc`;

print DH "\n ###Lun Stats and Sysstat after Giveback ### \n";

print DH "$filer_name2 \> sysstat -c 5 -x 1 \n";
open(fpin, "$rsh $filer2 -l $user_2 -n sysstat -c 5 -x 1|") || die "Cannot execute: registry command";
while($op=<fpin>){
   print $op;
   print DH $op	;
}

sleep 100;

print DH "$filer_name2 \> lun stats \n";
open(fpin, "$rsh $filer2 -l $user_2 -n lun stats|") || die "Cannot execute: registry command";
while($op=<fpin>){
   print $op;
   print DH $op	;
}

#------------------------------------------------------------------------------------
#----------------------------
# Subroutines start here
#----------------------------
sub filer_sourceinfo{
	  local($filer) = @_[0];
	  local($user) = @_[1];
	  local($handle)= @_[2];
	  open(fpin, "$rsh $filer -l $user -n source -v /etc/info.txt|") || die "Cannot execute: source /etc/info.txt";
	  print "\n RSH on $filer \> source /etc/info.txt \n";
  	while($sourceinfo=<fpin>){
     	print $sourceinfo;
     	print $handle $sourceinfo	;
  	}
   print $handle "\n"	;
}

sub filer_date{
	  local($filer) = @_[0];
	  local($user)  = @_[1];
	  local($handle)= @_[2];
	  open(fpin, "$rsh $filer -l $user -n date|") || die "Cannot execute: date";
	  print "\n RSH on $filer \> date \n";
  	while($filer_date=<fpin>){
     	print $filer_date;
     	print $handle $filer_date	;
  	}
   print $handle "\n"	;
}

sub cf_options{   # 0: cf disable , 1: cf enable , 2: cf takeover , 3: cf giveback
	  local($filer) = @_[0];
	  local($user)  = @_[1];
	  local($handle)= @_[2];
	  local($option)= @_[3];
	  if ($option == 0){
   	  open(fpin, "$rsh $filer -l $user -n cf disable|") || die "Cannot execute: cf command";
	  }elsif($option == 1){
   	  open(fpin, "$rsh $filer -l $user -n cf enable|") ||  die "Cannot execute: cf command";
	  }elsif($option == 2){
   	  open(fpin, "$rsh $filer -l $user -n cf takeover|") || die "Cannot execute: cf command";
	  }elsif($option == 3){
   	  open(fpin, "$rsh $filer -l $user -n cf giveback -f|") || die "Cannot execute: cf command";
	  }else{
	     print "\n WRONG OPTION";
	  }
	  
  	while($cf_options=<fpin>){
     	print $cf_options;
     	print $handle $cf_options;
  	}
   print $handle "\n"	;
}

sub igroup_show{
	  local($filer) = @_[0];
	  local($user)  = @_[1];
	  local($handle)= @_[2];
	  open(fpin, "$rsh $filer -l $user -n igroup show|") || die "Cannot execute: igroup show";
	  print "\n RSH on $filer \> igroup show \n";
  	while($igroup_show=<fpin>){
     	print $igroup_show;
     	print $handle $igroup_show	;
  	}
   print $handle "\n"	;
}

sub lun_show{
	  local($filer) = @_[0];
	  local($user)  = @_[1];
	  local($handle)= @_[2];
	  open(fpin, "$rsh $filer -l $user -n lun show|") || die "Cannot execute: lun show";
	  print "\n RSH on $filer \> lun show \n";
  	while($lun_show=<fpin>){
     	print $lun_show;
     	print $handle $lun_show	;
  	}
   print $handle "\n"	;
}

sub iscsi_stats{
	  local($filer) = @_[0];
	  local($user)  = @_[1];
	  local($handle)= @_[2];
	  open(fpin, "$rsh $filer -l $user -n iscsi stats|") || die "Cannot execute: iscsi stats";
	  print "\n RSH on $filer \> iscsi stats \n";
  	while($iscsi_stats=<fpin>){
     	print $iscsi_stats;
     	print $handle $iscsi_stats	;
  	}
   print $handle "\n"	;
}

sub lun_stats{
	  local($filer) = @_[0];
	  local($user)  = @_[1];
	  local($handle)= @_[2];
	  open(fpin, "$rsh $filer -l $user -n lun stats|") || die "Cannot execute: lun stats";
	  print "\n RSH on $filer \> lun stats \n";
  	while($lun_stats=<fpin>){
     	print $lun_stats;
     	print $handle $lun_stats	;
  	}
   print $handle "\n"	;
}

sub priv_set{
	  local($filer) = @_[0];
	  local($user)  = @_[1];
	  local($handle)= @_[2];
	  local($flag)  = @_[3];
	  if(!$flag){
	     open(fpin, "$rsh $filer -l $user -n priv set advanced|") || die "Cannot execute: priv set advanced";
	  }else{
	     open(fpin, "$rsh $filer -l $user -n priv set test|") || die "Cannot execute: priv set test";
	  }
  	while($priv_set=<fpin>){
     	print $priv_set;
     	print $handle $priv_set	;
  	}
   print $handle "\n"	;
}

sub log_comments
{
	local($filer) = @_[0];
	local($user) = @_[1];
	local($comments) = @_[2];
	open(fpin, "$rsh $filer -l $user -n $comments|") || die "Cannot execute: comments ";
	print "\n RSH on $filer \> version \n";
	$version=<fpin>;
	print "$version \n";

}

sub filer_version{
	  local($filer) = @_[0];
	  local($user) = @_[1];
	  local($handle)= @_[2];
	  open(fpin, "$rsh $filer -l $user -n version|") || die "Cannot execute: version ";
	  print "\n RSH on $filer \> version \n";
	  $version=<fpin>;
	  print $handle $version;
   print $handle "\n"	;
}

sub get_filer_name{
	  local($filer) = @_[0];
	  local($user) = @_[1];
	  open(fpin, "$rsh $filer -l $user -n hostname|") || die "Cannot execute: hostname ";
	  print "\n RSH on $filer \> Filer Name \n";
	  $name=<fpin>;
	  return $name;
}

sub filer_sysconfig{
  	local($filer) = @_[0];
  	local($user)  = @_[1];
  	local($handle)= @_[2];
  	open(fpin, "$rsh $filer -l $user -n sysconfig -r|") || die "Cannot execute: sysconfig -r ";
  	print "\n RSH on $filer \> sysconfig -r \n";
  	while($sysconfig=<fpin>){
     	print $sysconfig;
     	print $handle $sysconfig	;
   }
   print $handle "\n"	;
}

#vol_copy
sub volume_status{
  	local($filer) = @_[0];
  	local($user) = @_[1];
	  local($handle)= @_[2];
  	open(fpin, "$rsh $filer -l $user -n vol status|") || die "Cannot execute: vol status ";
  	print "\n RSH on $filer \> vol status \n";
  	while($volume_status=<fpin>){
	     print $volume_status;
	     print $handle $volume_status	;

	  }
   print $handle "\n"	;
}

sub vol_usage{
  	local($filer) = @_[0];
  	local($user) = @_[1];
  	local($vol_name) = @_[2];
	  local($handle)= @_[3];
  	open(fpin, "$rsh $filer -l $user -n df -Vh $vol_name|") || die "Cannot execute: df -Vh $vol_name ";
  	while($volume_usage=<fpin>){
	     print $volume_usage;
	     print $handle $volume_usage	;
	  }
   print $handle "\n"	;
}

sub exportfs{
  	local($filer) = @_[0];
  	local($user)  = @_[1];
  	local($vol_name) = @_[2];
	  local($handle)= @_[3];
	  local($flag)  = @_[4];
	  if(!$flag){# if flag = 0 then add to export list
  	   open(fpin, "$rsh $filer -l $user -n exportfs -p rw,anon=0 /vol/$vol_name|") || die "Cannot execute: exportfs -p rw,anon=0 /vol/$vol_name";
  	}else{
  	   open(fpin, "$rsh $filer -l $user -n exportfs|") || die "Cannot execute: exportfs";
  	}
  	while($exportfs=<fpin>){
	     print $exportfs;
	     print $handle $exportfs	;
	  }
   print $handle "\n"	;
}


sub aggr_usage{
  	local($filer) = @_[0];
  	local($user) = @_[1];
  	local($aggr_name) = @_[2];
	  local($handle)= @_[3];
  	open(fpin, "$rsh $filer -l $user -n df -Ah $aggr_name|") || die "Cannot execute: df -Ah $aggr_name ";
  	while($aggr_usage=<fpin>){
	     print $aggr_usage;
	     print $handle $aggr_usage	;
	  }
   print $handle "\n"	;
}

sub vol_copy{
  	local($filer)   = @_[0];
  	local($user)    = @_[1];
  	local($vol_one) = @_[2];
  	local($vol_two) = @_[3]; 
	  local($handle)  = @_[4];
  	open(fpin, "$rsh $filer -l $user -n vol copy start -S $vol_one $vol_two|") || die "Cannot execute: vol copy";
  	while($vol_copy=<fpin>){
     	print $vol_copy;
     	print $handle $vol_copy;
   }
   print $handle "\n"	;
}

sub aggr_copy{
  	local($filer)   = @_[0];
  	local($user)    = @_[1];
  	local($aggr_one) = @_[2];
  	local($aggr_two) = @_[3]; 
	  local($handle)  = @_[4];
  	open(fpin, "$rsh $filer -l $user -n aggr copy start -S $aggr_one $aggr_two|") || die "Cannot execute: aggr copy";
  	while($aggr_copy=<fpin>){
     	print $aggr_copy;
     	print $handle $aggr_copy;
   }
   print $handle "\n"	;
}

sub cifs_shares{
  	local($filer) = @_[0];
  	local($user)  = @_[1];
  	local($vol_name) = @_[2];
	  local($handle)= @_[3];
  	open(fpin, "$rsh $filer -l $user -n cifs shares -add cshare /vol/$vol_name|") || die "Cannot execute: cifs shares -add $vol_name /vol/ ";
  	while($cifs_shares=<fpin>){
	     print $cifs_shares;
	     print $handle $cifs_shares	;
	  }
   print $handle "\n"	;
}

sub aggregate_status{
  	local($filer) = @_[0];
  	local($user) = @_[1];
	  local($handle)= @_[2];
  	open(fpin, "$rsh $filer -l $user -n aggr status|") || die "Cannot execute: aggr status ";
  	print "\n RSH on $filer \> aggr status \n";
  	while($aggregate_status=<fpin>){
	     print $handle $aggregate_status;
	     print $aggregate_status;
	  }
   print $handle "\n"	;
}

sub aggregate_create {
  	local($filer) = @_[0];
  	local($user) = @_[1];
  	local($aggr_name) = @_[2];
  	local($disk_number) = @_[3];
	  local($handle)= @_[4];

	  open(fpin, "$rsh $filer -l $user -n aggr create $aggr_name $disk_number|") || die "Cannot execute: aggr create ";
	  print "\n RSH on $filer \> aggr create $aggr_name 3 \n";
	  print fpin;
		 while($aggregate_create=<fpin>){
		   	print $handle $aggregate_create;
		   	print $aggregate_create;
		 }
   print $handle "\n"	;
}

sub volume_create{
  	local($filer) = @_[0];
  	local($user) = @_[1];
  	local($aggr_name) = @_[2];
  	local($vol_name) = @_[3];
  	local($vol_size) = @_[4]; 
  	local($vol_type) = @_[5];   # vol_type = 0 : traditional volume  vol_type = 1 : flex volume
	  local($handle)= @_[6];
  	
  	if(!$vol_type){
  	   open(fpin, "$rsh $filer -l $user -n vol create $vol_name $vol_size|") || die "Cannot execute: vol create";
  	}else{
  	   open(fpin, "$rsh $filer -l $user -n vol create $vol_name $aggr_name $vol_size|") || die "Cannot execute: vol create";
  	}

  	while($volume_create=<fpin>){
     	print $handle $volume_create;
	    	print $volume_create;
	  }
   print $handle "\n"	;
		
}

sub lun_create{
  	local($filer)     = @_[0];
  	local($user)      = @_[1];
  	local($aggr_name) = @_[2];
  	local($vol_name)  = @_[3];
  	local($type)      = @_[4]; 
	  local($handle)    = @_[5];
  	
   open(fpin, "$rsh $filer -l $user -n lun create -s 2g -t $type /vol/$vol_name/lun_$type|") || die "Cannot execute: lun create";
  	while($lun_create=<fpin>){
     	print $handle $lun_create;
	    	print $lun_create;
	  }
   print $handle "\n"	;
}

sub igroup_create{
  	local($filer)     = @_[0];
  	local($user)      = @_[1];
  	local($type)      = @_[2]; 
  	local($igrp_name) = @_[3];
  	local($igroup)    = @_[4];
	  local($handle)    = @_[5];
  	
   open(fpin, "$rsh $filer -l $user -n igroup create -i -t $type $igrp_name $igroup|") || die "Cannot execute: igroup create";
  	while($igroup_create=<fpin>){
     	print $handle $igroup_create;
	    	print $igroup_create;
	  }
   print $handle "\n"	;
}

sub fcp_igroup_create{
  	local($filer)     = @_[0];
  	local($user)      = @_[1];
  	local($type)      = @_[2]; 
  	local($igrp_name) = @_[3];
  	local($igroup)    = @_[4];
	  local($handle)    = @_[5];
  	
   open(fpin, "$rsh $filer -l $user -n igroup create -f -t $type $igrp_name $igroup|") || die "Cannot execute: igroup create";
  	while($fcp_igroup_create=<fpin>){
     	print $handle $fcp_igroup_create;
	    	print $fcp_igroup_create;
	  }
   print $handle "\n"	;
}

sub lun_map{
  	local($filer)     = @_[0];
  	local($user)      = @_[1];
  	local($vol_name)  = @_[2];
  	local($igroup)    = @_[3];
  	local($type)      = @_[4]; 
	  local($handle)    = @_[5];
  	
   open(fpin, "$rsh $filer -l $user -n lun map /vol/$vol_name/lun_$type $igroup|") || die "Cannot execute: lun map";
  	while($lun_map=<fpin>){
     	print $handle $lun_map;
	    	print $lun_map;
	  }
   print $handle "\n"	;
}

sub volume_restrict{
  	local($filer) = @_[0];
  	local($user) = @_[1];
  	local($vol_name) = @_[2];
	  local($handle)= @_[3];
  	open(fpin, "$rsh $filer -l $user -n vol restrict $vol_name|") || die "Cannot restrict: vol $vol_name";
  	while($volume_restrict=<fpin>){
	    	print $handle $volume_restrict;
	    	print $volume_restrict;
	  }
   print $handle "\n"	;
}

sub aggr_restrict{
  	local($filer) = @_[0];
  	local($user) = @_[1];
  	local($aggr_name) = @_[2];
	  local($handle)= @_[3];
  	open(fpin, "$rsh $filer -l $user -n aggr restrict $aggr_name|") || die "Cannot restrict: aggr $aggr_name";
  	while($aggr_restrict=<fpin>){
	    	print $handle $aggr_restrict;
	    	print $aggr_restrict;
	  }
   print $handle "\n"	;
}

sub volume_online{
  	local($filer) = @_[0];
  	local($user) = @_[1];
  	local($vol_name) = @_[2];
	  local($handle)= @_[3];
  	open(fpin, "$rsh $filer -l $user -n vol online $vol_name|") || die "Cannot online: vol $vol_name";
  	while($volume_online=<fpin>){
	    	print $handle $volume_online;
	    	print $volume_online;
	  }
   print $handle "\n"	;
}

sub aggr_online{
  	local($filer) = @_[0];
  	local($user) = @_[1];
  	local($aggr_name) = @_[2];
	  local($handle)= @_[3];
  	open(fpin, "$rsh $filer -l $user -n aggr online $aggr_name|") || die "Cannot online: aggr $aggr_name";
  	while($aggr_online=<fpin>){
	    	print $handle $aggr_online;
	    	print $aggr_online;
	  }
   print $handle "\n"	;
}

sub qtree_status{
  	local($filer) = @_[0];
  	local($user) = @_[1];
  	local($handle)= @_[2];

  	open(fpin, "$rsh $filer -l $user -n qtree status|") || die "Cannot execute: qtree status";
  	print "\n RSH on $filer \> qtree status \n";
  	while($qtree_status=<fpin>){
     	print $handle $qtree_status;
     	print $qtree_status;
  	}
   print $handle "\n"	;
}

sub qtree_create{
  	local($filer) = @_[0];
  	local($user) = @_[1];
  	local($vol_name) = @_[2];
  	local($qtree_name) = @_[3]; 
  	local($handle)= @_[4];

  	open(fpin, "$rsh $filer -l $user -n qtree create /vol/$vol_name/$qtree_name|") || die "Cannot execute:qtree create";
  	print "\n RSH on $filer \> qtree create /vol/$vol_name/$qtree_name \n";
  	while($qtree_create=<fpin>){
     	print $handle $qtree_create;
	    	print $qtree_create;
	  }
   print $handle "\n"	;
}

sub qtree_security{
  	local($filer) = @_[0];
  	local($user) = @_[1];
  	local($vol_name) = @_[2];
  	local($qtree_name) = @_[3]; 
  	local($handle)= @_[4];

  	open(fpin, "$rsh $filer -l $user -n qtree security /vol/$vol_name/$qtree_name mixed|") || die "Cannot execute: qtree status";
  	print "\n RSH on $filer \> qtree status \n";
  	while($qtree_security=<fpin>){
     	print $handle $qtree_security;
     	print $qtree_security;
  	}
   print $handle "\n"	;
}

sub vol_security{
  	local($filer) = @_[0];
  	local($user) = @_[1];
  	local($vol_name) = @_[2];
  	local($flag) = @_[3];
  	local($handle)= @_[4];

  	if ($flag){ #if flag is 1 then change security of volume
  	   open(fpin, "$rsh $filer -l $user -n qtree security /vol/$vol_name mixed|") || die "Cannot execute: qtree security";
  	}else{#just display
  	   open(fpin, "$rsh $filer -l $user -n qtree security /vol/$vol_name|") || die "Cannot execute: qtree security";
  	}

  	while($vol_security=<fpin>){
     	print $handle $vol_security;
     	print $vol_security;
  	}
   print $handle "\n"	;
}

sub snapmirror_options{
  	local($filer) = @_[0];
  	local($user) = @_[1];
  	local($filer_name) = @_[2];
	  local($handle)= @_[3];
  	
  	print $handle "$filer_name \> options snapmirror.access host=all \n";
  	open(fpin, "$rsh $filer -l $user -n options snapmirror.access host=all|") || die "Cannot set: snapmirror options snapmirror.access";
  	print "\n RSH on $filer \>  options snapmirror.access host=all\n";
  	while($snapmirror_access=<fpin>){
     	print $handle $snapmirror_access;
	    	print $snapmirror_access;
	  }
	  close(fpin);
  	print $handle "$filer_name \> options snapmirror.enable on \n";
	  open(fpin, "$rsh $filer -l $user -n options snapmirror.enable on|") || die "Cannot set: snapmirror enable on";
	  print "\n RSH on $filer \>  options snapmirror.enable on\n";
	  while($snapmirror_enable=<fpin>){
     	print $handle $snapmirror_enable;
	    	print $snapmirror_enable;
	  }
	  close(fpin);
  	print $handle "$filer_name \> options snapmirror \n";
	  open(fpin, "$rsh $filer -l $user -n options snapmirror|") || die "Cannot display: snapmirror options";
	  print "\n RSH on $filer \>  options snapmirror\n";
	  while($snapmirror_options_display=<fpin>){
     	print $handle $snapmirror_options_display;
	    	print $snapmirror_options_display;
	  }
	  close(fpin);
   print $handle "\n"	;
}

sub snapmirror_on{
  	local($filer) = @_[0];
  	local($user) = @_[1];
	  local($handle)= @_[2];
  	
  	open(fpin, "$rsh $filer -l $user -n snapmirror on|") || die "Cannot set: snapmirror on";
  	print "\n RSH on $filer \> snapmirror on  \n";
  	while($snapmirror_on=<fpin>){
     	print $handle $snapmirror_on;
	     print $snapmirror_on;
	  }
   print $handle "\n"	;
}

sub snapmirror_status{
  	local($filer) = @_[0];
  	local($user) = @_[1];
	  local($handle)= @_[2];
  	
  	open(fpin, "$rsh $filer -l $user -n snapmirror status|") || die "Cannot display: snapmirror status";
  	
  	print "\n RSH on $filer \> snapmirror status \n";
  	while($snapmirror_status=<fpin>){
     	print $handle $snapmirror_status;
	     print $snapmirror_status;
	  }
   print $handle "\n"	;
}

sub snapmirror_initialize{
  	local($scr_filer) = @_[0];
  	local($dst_filer) = @_[1];
  	local($user)      = @_[2];
  	local($scr_vol)   = @_[3];
  	local($dst_vol)   = @_[4];
	  local($handle)    = @_[5];
	  local($fil)       = @_[6];
	  open(fpin, "$rsh $fil -l $user -n snapmirror initialize -S $scr_filer:$scr_vol $dst_filer:$dst_vol|") || die "Cannot initialize: snapmirror";
	  while($snapmirror_initialize=<fpin>){
     	print $handle $snapmirror_initialize;
	     print $snapmirror_initialize;
	  }
   print $handle "\n"	;
}

sub read_file{
  	local($filer)     = @_[0];
  	local($user)      = @_[1];
  	local($file_path) = @_[2];
  	local($file_name) = @_[3];
   local($handle)    = @_[4];
  	open(fpin, "$rsh $filer -l $user -n rdfile $file_path/$file_name|") || die "Cannot read file ";
  	while($read_file=<fpin>){
     	print $handle $read_file;
	     print $read_file;
	  }
   print $handle "\n"	;
}

sub usage{
  	print "Utility to run build verification test \n";
  	print "Usage:perl Sanity.pl [-source source filer] [-dest Destination filer]\n";
  	print "\t-source : Source filer name\n";
  	print "\t-dest : Destination filer name\n";
}

##API for add target portal ##
#vol_copy
sub add_portal{
  	local($ip_addr) = @_[0];
  	local($port)    = @_[1];
  	open(fpin, "$rsh 10.52.67.27 -n C:\\\\Windows\\\\system32\\\\iscsicli AddTargetPortal $ip_addr $port|") || die "Cannot execute: vol status ";
  	print "\n RSH on 10.52.67.27 iscsicli AddTargetPortal $ip_addr $port\>  \n";
  	while($cmd_status=<fpin>){
	     print $cmd_status;
	  }
}

sub lun_map_fcp{
  	local($filer)     = @_[0];
  	local($user)      = @_[1];
  	local($vol_name)  = @_[2];
  	local($igroup)    = @_[3];
  	local($type)      = @_[4]; 
	  local($handle)    = @_[5];
  	
   open(fpin, "$rsh $filer -l $user -n lun map /vol/$vol_name/fcp_$type $igroup|") || die "Cannot execute: lun map";
  	while($lun_map=<fpin>){
     	print $handle $lun_map;
	    	print $lun_map;
	  }
   print $handle "\n"	;
}

sub fcp_igroup_create{
  	local($filer)     = @_[0];
  	local($user)      = @_[1];
  	local($type)      = @_[2]; 
  	local($igrp_name) = @_[3];
  	local($igroup)    = @_[4];
	  local($handle)    = @_[5];
  	
   open(fpin, "$rsh $filer -l $user -n igroup create -f -t $type $igrp_name $igroup|") || die "Cannot execute: igroup create";
  	while($fcp_igroup_create=<fpin>){
     	print $handle $fcp_igroup_create;
	    	print $fcp_igroup_create;
	  }
   print $handle "\n"	;
}

#--------------------------END--------------------------------------------------------------------#