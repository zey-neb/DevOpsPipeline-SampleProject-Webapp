 #!/bin/bash


if test $# -ne 1
then
	kill $$ 
fi

docker ps > /tmp/kek 
a=`cat /tmp/kek | grep $1-`

if test -z "$a"
then
	kill $$ 
else
	echo $a | cut -d " " -f 1 | xargs docker stop
	echo $a | cut -d " " -f 1 | xargs docker container rm  
	rm /tmp/kek
fi
