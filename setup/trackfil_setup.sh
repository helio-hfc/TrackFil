#! /bin/sh

# Script to load environment variables 
# required by TRACKFIL.
# Must be placed in the trackfil/setup sub-directory. 
#
# To load this script:
# >source trackfil_setup.sh
#
# X.Bonnin, 20-JUN-2013

CURRENT_DIR=`pwd`

ARGS=${BASH_SOURCE[0]}
cd `dirname $ARGS`/..
export TRACKFIL_HOME_DIR=`pwd`
cd $CURRENT_DIR

# Append python library path to $PYTHONPATH
PYTHONPATH=$PYTHONPATH:$TRACKFIL_HOME_DIR/lib/python/hfc
export PYTHONPATH

# Append idl library path to $IDL_PATH
IDL_PATH=$IDL_PATH:+$TRACKFIL_HOME_DIR/src
export IDL_PATH