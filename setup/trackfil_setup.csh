#! /bin/csh
#
# Script to load environment variables 
# required by TRACKFIL.
# Must be placed in the trackfil/setup sub-directory. 
#
# To load this script:
# >source trackfil_setup.csh
#
# X.Bonnin, 20-JUN-2013

set CURRENT_DIR=`pwd`

# Define trackfil home directory
set ARGS=($_)
cd `dirname $ARGS[2]`/..
setenv TRACKFIL_HOME_DIR `pwd`
cd $CURRENT_DIR

# Append python library path to $PYTHONPATH
setenv PYTHONPATH "$PYTHONPATH":$TRACKFIL_HOME_DIR/lib/python/hfc

# Append idl library path to $IDL_PATH
setenv IDL_PATH "$IDL_PATH":+$TRACKFIL_HOME_DIR/src
