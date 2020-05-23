#!/bin/bash


if test $# -ne 1
then
	echo "missing arg"
	kill $$ 
fi

docker ps > /tmp/kek 
a=`cat /tmp/kek | grep $1-`
echo $1
if test -z "$a"
then
	echo "not found"
else
	echo $a | cut -d " " -f 1 | xargs docker stop
	echo $a | cut -d " " -f 1 | xargs docker container rm  
	rm /tmp/kek
fi
