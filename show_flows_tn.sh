#!/bin/sh

#set -x

for i in tn-pe1 tn-pe2 tn-pc1
do
	echo $i
	sudo ovs-ofctl -OOpenFlow13 dump-flows $i
done
