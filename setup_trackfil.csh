#! /bin/csh
#
# PURPOSE:
# Script to load environment variables
# required by TRACKFIL and
# build bin file
# Create required directories if not found
# Must be placed in the scripts/ sub-directory.
#
# USAGE:
#   source setup_trackfil.csh
#
# RESTRICTIONS/COMMENTS:
#  be sure to have SolarSoft (SSW) ready to be
#  called with "sswidl" command
#
# X.Bonnin, 20-NOV-2015

# Define $TRACKFIL_HOME_DIR env. variable
setenv TRACKFIL_HOME_DIR `pwd`

# Load Trackfil4hfc env. variables
csh -f $TRACKFIL_HOME_DIR/scripts/setup_trackfil_env.csh

cd scripts/
sswidl -e @trackfil_make_bin
cd $TRACKFIL_HOME_DIR
