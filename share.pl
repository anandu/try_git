$filer1 = "192.168.1.1"
system "rsh 192.168.1.2 -n net use /d p\: ";
open(fpin, "rsh 192.168.1.2 -n net use P: \\\\\\\\$filer1\\\\cshare /u:dcname\\\\user_name pass\@123|") || die "Cannot execute: could not map share\n";
