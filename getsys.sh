#!/bin/sh
# SPDX-License-Identifier: MIT
# Copyright (c) 2018-2020 Iruatã Martins dos Santos Souza

sys=$(uname -o | tr A-Z a-z)
case $sys in
gnu/linux)
	echo linux
	;;
*)
	echo $sys
	;;
esac
