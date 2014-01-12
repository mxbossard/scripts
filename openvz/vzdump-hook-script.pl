#!/usr/bin/perl -w
# hook script for vzdump (--script option)

use strict;

print "HOOK: " . join (' ', @ARGV) . "\n";

# config

# Time the snapshots are keep on remote in minutes
my $ftp_minutes_time_length = (1.5 * 60 * 24);

# Remote snapshot dir
my $snapshotsDir = "/mnt/ftpBackup/backup";
#my $snapshotsDir = "/tmp";

my $phase = shift;
my $mode = shift; # stop/suspend/snapshot
my $vmid = shift;
my $vmtype = $ENV{VMTYPE}; # openvz/qemu
my $dumpdir = $ENV{DUMPDIR};
my $hostname = $ENV{HOSTNAME};
my $tarfile = $ENV{TARFILE};
my $logfile = $ENV{LOGFILE}; 

my %dispatch = (
        "job-start"     => \&nop,
        "job-end"       => \&nop,
        "job-abort"     => \&nop,
        "backup-start"  => \&nop,
        "backup-end"    => \&backup_end,
        "backup-abort"  => \&nop,
        "log-end"       => \&nop,
        "pre-stop"      => \&nop,
        "pre-restart"   => \&nop,
);

sub copyUpload {
        my $file = shift;
        print "HOOK: uploading " . $file . " to mount point " . $snapshotsDir . " ...\n";

        # try it twice
        system("touch $snapshotsDir/\$(basename $file)") == 0 &&
        system("cp $file $snapshotsDir") == 0 ||
        die "Copy upload to backup-host failed !";

        print "HOOK: copy upload " . $file . " to mount point " . $snapshotsDir . " done\n";
}

sub cleanOldBackup {
	# rm files modified $ftp_minutes_time_length + min ago
	system("find $snapshotsDir -cmin +$ftp_minutes_time_length -name '*-$vmtype-$vmid-*' -exec rm -v '{}' \\;") == 0 ||
	die "Old backup cleaning failed !";

	print "HOOK: Old backup cleaned\n";
}

sub nop {
        # nothing
}

sub backup_end {
        copyUpload($tarfile);
	cleanOldBackup();
}

sub log_end {
        copyUpload($logfile);
}

if (defined $tarfile && $tarfile =~ /.*\.tar\.gz/) {
	exists $dispatch{$phase} ? $dispatch{$phase}() : die "got unknown phase '$phase'";
}

exit (0);
