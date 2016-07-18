#!/bin/sh

#set -x

for i in ts-pe1 ts-gw-tn
do
	echo $i
	sudo ovs-ofctl -OOpenFlow13 dump-flows $i
done
