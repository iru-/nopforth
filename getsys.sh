#!/bin/sh

sys=$(uname -o | tr A-Z a-z)
case $sys in
gnu/linux)
	echo linux
	;;
*)
	echo $sys
	;;
esac
