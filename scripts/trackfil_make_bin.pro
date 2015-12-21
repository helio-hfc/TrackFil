;IDL batch file to build an binary runtime file (.sav)
;to run trackfil code using a command line or a script.
;time SSW packages must be loaded before
;running this script.
;X.Bonnin, 21-DEC-2015

sep = path_sep()
trackfil_home_dir=getenv("TRACKFIL_HOME_DIR")
if (trackfil_home_dir eq '') then message, '$TRACKFIL_HOME_DIR must be defined!'
src_dir = trackfil_home_dir + sep + 'src'
lib_dir = trackfil_home_dir + sep + 'lib' + sep + 'idl'
pathsep = path_sep(/search_path)
!PATH = expand_path('+'+src_dir) + pathsep + !PATH
!PATH = expand_path('+'+lib_dir) + pathsep + !PATH
binfile = trackfil_home_dir + sep + 'bin' + sep +'trackfil.sav'

@compile_trackfil

cd,src_dir,current=cur_dir
proname= ['trackfil']
;funcname = ['sock_header']
;classname=
resolve_all, /CONTINUE_ON_ERROR, class=classname, resolve_procedure=proname, resolve_function=funcname
save, /ROUTINES, filename=binfile, description='Runtime IDL program to call trackfil.pro', /VERBOSE, /EMBEDDED
if not file_test(binfile) then message,binfile+ ' has not been saved correctly!' else print,binfile+' saved'
cd,cur_dir