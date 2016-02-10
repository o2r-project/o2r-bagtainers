#!/usr/bin/perl -w
# via http://texblog.org/2012/08/07/semi-automatic-directory-tree-in-latex/#comment-5396
#
# perl dirtree.pl path/to/directory
# 
use strict;
use File::Find;
 
my $top = shift @ARGV;
die "specify top directory\n" unless defined $top;
chdir $top or die "cannot chdir to $top: $!\n";
 
find(sub {
    local $_ = $File::Find::name;
    my @F = split '/';
    #printf "DEBUG %s\n", $F[-1];
    
    # don't list .git directories
    return if ($F[-1] =~ /\.git/);
    # dont list files ending in ~
    return if ($F[-1] =~ /~$/);
    # dont list files starting with .
    return if ($F[-1] =~ /^\.[a-zA-Z0-9_]/);
    printf ".%d %s.\n", scalar @F, @F==1 ? $top : $F[-1];
}, '.');
