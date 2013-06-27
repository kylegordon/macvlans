#!/bin/bash
# Shamelessly stolen from http://superuser.com/questions/218340/how-to-generate-a-valid-random-mac-address-with-bash-shell

hexchars="0123456789ABCDEF"
end=$( for i in {1..6} ; do echo -n ${hexchars:$(( $RANDOM % 16 )):1} ; done | sed -e 's/\(..\)/-\1/g' )
echo 00-60-2F$end
