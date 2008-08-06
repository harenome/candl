#! /bin/sh
#
#   /**-------------------------------------------------------------------**
#    **                              CAnDL                                **
#    **-------------------------------------------------------------------**
#    **                            checker.sh                             **
#    **-------------------------------------------------------------------**/
#
#/*****************************************************************************
# *   CAnDL : the Chunky Analyser for Dependences in Loops (experimental)     *
# *****************************************************************************
# *                                                                           *
# * Copyright (C) 2003-2008 Cedric Bastoul                                    *
# *                                                                           *
# * This is free software; you can redistribute it and/or modify it under the *
# * terms of the GNU General Public License as published by the Free Software *
# * Foundation; either version 2 of the License, or (at your option) any      *
# * later version.							      *
# *                                                                           *
# * This software is distributed in the hope that it will be useful, but      *
# * WITHOUT ANY WARRANTY; without even the implied warranty of                *
# * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General *
# * Public License for more details.                                          *
# *                                                                           *
# * You should have received a copy of the GNU General Public License along   *
# * with software; if not, write to the Free Software Foundation, Inc.,       *
# * 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA                    *
# *                                                                           *
# * CAnDL, the Chunky Dependence Analyser                                     *
# * Written by Cedric Bastoul, Cedric.Bastoul@inria.fr                        *
# *                                                                           *
# *****************************************************************************/


output=0
TEST_FILES="$2";
echo "[CHECK:] ** $1 **";
for i in $TEST_FILES; do
    outtemp=0
    ##
    ## Base .candl tests.
    echo "[TEST:] Dependence analyzer test:== $i.candl ==";
    $top_builddir/source/candl $i.candl > $i.candltest 2>/tmp/clanout
    z=`diff $i.candltest $i.dep 2>&1`
    err=`cat /tmp/clanout`;
    if ! [ -z "$z" ]; then
	echo -e "\033[31m[FAIL:] Dependence analyzer: Error in dependence computation\033[0m";
	outtemp=1;
    fi
    if ! [ -z "$err" ]; then
	if [ $outtemp = "0" ]; then
	    echo "[INFO:] Dependence analyzer: OK";
	fi
	echo -e "\033[31m[FAIL:] Dependence analyzer: stderr output: $err\033[0m";
	outtemp=1
	output=1
    fi
    if [ $outtemp = "0" ]; then
	echo "[PASS:] Dependence analyzer: OK";
	rm -f $i.candltest
    fi
    rm -f /tmp/clanout
    ##
    ## Base .SCoP tests.
    echo "[TEST:] Dependence analyzer test:== $i.scop ==";
    $top_builddir/source/candl -inscop -structure $i.scop > $i.structest
    y=`diff $i.structest $i.struct`
    if ! [ -z "$y" ]; then
	echo -e "\033[31m[FAIL:] Dependence analyzer: Error in dependence computation\033[0m";
	outtemp=1
	output=1
    else
	echo "[PASS:] Dependence analyzer: OK";
	rm -f $i.structest
    fi
    ##
    ## .SCoP with optional tags tests.
    echo "[TEST:] Dependence analyzer test:== $i.opt.scop ==";
    $top_builddir/source/candl -inscop -outscop -structure $i.opt.scop > $i.outscop
    $top_builddir/source/candl -inscop -structure $i.opt.scop > $i.optscoptest
    x=`diff $i.optscoptest $i.struct`
    z=`diff $i.outscop $i.depscop`
    if ! [ -z "$x" ] || ! [ -z "$z" ]; then
	echo -e "\033[31m[FAIL:] Dependence analyzer: Error in dependence computation\033[0m";
	outtemp=1
	output=1
    else
	echo "[PASS:] Dependence analyzer: OK";
	rm -f $i.optscoptest
	rm -f $i.outscop
    fi
    ##
    ## Scalar analysis tests.
    echo "[TEST:] Scalar analysis test:== $i.scop ==";
    $top_builddir/source/candl -inscop -structure -scalpriv 1 -scalexp 1 -scalren 1 $i.scop > $i.scaltest
    y=`diff $i.scaltest $i.scalstruct`
    if ! [ -z "$y" ] || ! [ -z "$x" ]; then
	echo -e "\033[31m[FAIL:] Scalar analysis: Error in dependence computation\033[0m";
	outtemp=1
	output=1
    else
	echo "[PASS:] Scalar analysis test: OK";
	rm -f $i.scaltest
    fi
done
if [ $output = "1" ]; then
    echo -e "\033[31m[FAIL:] $1\033[0m";
else
    echo "[PASS:] ** $1 **";
fi
exit $output