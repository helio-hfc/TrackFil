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

# Check if $TRACKFIL_HOME_DIR environment variable is defined

if ( -z "$TRACKFIL_HOME_DIR ") then
    echo "$TRACKFIL_HOME_DIR is not defined, exit!"
    exit 1
endif

# Append idl library path to $IDL_PATH
setenv IDL_PATH "$IDL_PATH":+$TRACKFIL_HOME_DIR/src

# Append idl library path to $IDL_PATH
setenv IDL_PATH "$IDL_PATH":+$TRACKFIL_HOME_DIR/lib/idl