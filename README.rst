About TrackFil
============

The TrackFil software provides an algorithm to automatically track filaments on Sun images.

TrackFil was initially developped in the framework of the HELIO Virtual Observatory European project (http://www.helio-vo.eu/),
to populate its Heliophysics Feature Catalogue (HFC).
TrackFil data results on the Meudon Spectroheliograph observations are available in the HFC web portal at: http://hfc.helio-vo.eu.

The software algorithm is described in details in: http://dx.doi.org/10.1007/s11207-012-9985-9.

Note that TrackFil software assumes that the solar filaments to be tracked have been previously detected.
For instance, the HFC filaments are detected using the Fuller et al., 2005 alogorithm (see 10.1007/s11207-005-8364-1).

Content
======

The TrackFil package contains the TrackFil source code, as well as scripts to
install and configure the software.

It stores the following items:

     bin/           binary files (e.g., idl runtime file to launch trackfil as a script).
     config/      configuration files providing the metadata and algorithm input parameters.
     data/         can be used to store input data files.
     hfc/           contains the wrapper for the HFC
     lib/            contains external libraries required to run trackfil
     logs/         can be used to store log file
     products/ can be used to store trackfil data products
     scripts/     scripts to set up and run trackfil.
     src/           code source files (written in IDL).
     tmp/          can be used to store temporary files
     tools/        extra tools (e.g., program to train trackfil).

Installation
=========

System requirements
------------------------------

Trackfil requires IDL 7.0 or higher.

The main SolarSoft (SSW) package shall be also installed and callable on your system.
(Visit http://www.lmsal.com/solarsoft/ for more details).

Trackfil can only by run using the (t)csh shell.

How to get Trackfil
------------------------------

You can download the TrackFil package from Github, entering:

    git https://github.com/HELIO-HFC/TrackFil.git

This will create a local "TrackFil" directory containing the TrackFil software.

*In the next sections, all of the commands are executed assuming you are in the TrackFil/ directory.*

How to set up Trackfil
------------------------------

Before set up and run Trackfil, be sure that SSW can be loaded in IDL using the "sswidl" command.

Then, enter:

    source scripts/setup_trackfil.csh

If everything goes right, it should create a "trackfil.sav" file in the bin/ subdirectory.

How to run Trackfil
------------------------------

Open a IDL interpreter session, then enter:

    restore,'bin/trackfil.sav',/VERBOSE

This will loaded all of the Trackfil compiled routines.

The Trackfil main program is called "trackfil". Enter "trackfil" in the interpreter should return something like:

    % TRACKFIL: Usage:
    Results = trackfil(fil_data, config_file=config_file, /SILENT)



