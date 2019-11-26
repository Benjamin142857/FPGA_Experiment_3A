@echo off

rem Restore the class path to what it was before DSP Builder was installed
rem Invoked as follows:
rem addToClassPath <Matlab directory> <DSPB install dir> <DSPB Matlab script directory>

set matlab_dir=%1
set dspb_dir=%2
set matlab_script_dir=%3

if "%matlab_script_dir%" neq "" goto skip_set_path
set matlab_script_dir=%dspb_dir%\bin\matlab
:skip_set_path

set classpath=%1/toolbox/local/classpath.txt
if "%TMP%" NEQ "" goto gottemp
	set TMP=C:\tmp
:gottemp

@mkdir %TMP% 2>NUL

set tempfile=%TMP%\tempclasspath
	
cp %classpath% %classpath%.restore.backup

sed "/# DSPBuilder START/,/# DSPBuilder END/d;" %classpath% > %tempfile%

cp %tempfile% %classpath%

set cmd=cd '%matlab_script_dir%'; alt_dspbuilder_restoreMatlabPath('%matlab_script_dir%', '%dspb_dir%'); exit

echo %cmd%

%matlab_dir%\bin\win32\matlab.exe -automation -r "%cmd%"
