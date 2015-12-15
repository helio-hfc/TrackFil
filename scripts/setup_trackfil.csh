#! /bin/csh
#
# Script to load environment variables
# required by TRACKFIL.
# Create required directories if not found
# Must be placed in the /scripts sub-directory.
#
# Usage:
#   source setup_trackfil.csh
#
# X.Bonnin, 20-NOV-2015

# Define trackfil home directory

set currentdir=`pwd`
set args=($_)
set scriptpath=`dirname $ARGS[2]`
cd $scriptpath/..
setenv TRACKFIL_HOME_DIR `pwd`
cd $currentdir

# Append python library path to $PYTHONPATH
setenv PYTHONPATH "$PYTHONPATH":$TRACKFIL_HOME_DIR/lib/python/hfc

# Append idl library path to $IDL_PATH
setenv IDL_PATH "$IDL_PATH":+$TRACKFIL_HOME_DIR/src
