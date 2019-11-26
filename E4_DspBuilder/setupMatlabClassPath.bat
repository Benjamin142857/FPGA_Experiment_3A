@echo off
echo setupMatlabClassPath.bat started > %temp%\dspbuilder_install.log
rem Add the DSPBuilder Jar files to the java class path file found in the specified MATLAB directory
rem Invoked as follows:
rem setupMatlabClassPath <setuptype> <Matlab directory> <DSPB install dir> <DSPB Matlab script directory>
rem  where setuptype can be buildmachine, development or install

set setuptype=%1
set matlab_dir=%~2
set dspb_dir=%~3

set CYGWIN=nodosfilewarning
set QUARTUS_ROOTDIR=%dspb_dir%\..
set matlab_script_dir=%4
if "%matlab_script_dir%" neq "" goto skip_set_path
set matlab_script_dir=%dspb_dir%\bin\matlab
:skip_set_path
set old_path=%path%
set path=%dspb_dir%\bin64;%dspb_dir%\bin;%dspb_dir%\..\bin\cygwin\bin;%path%
set classpath=%matlab_dir%/toolbox/local/classpath.txt
echo setupMatlabClassPath.bat updating class path >> %temp%\dspbuilder_install.log
echo "%dspb_dir%/addToClassPath.bat" "%classpath%" >> %temp%\dspbuilder_install.log
call "%dspb_dir%/addToClassPath.bat" "%classpath%"
echo setupMatlabClassPath.bat done updating class path >> %temp%\dspbuilder_install.log
set cmd=cd '%matlab_script_dir%'; setupDSPBuilderPath('%setuptype%', true, '%dspb_dir%'); exit
echo %cmd%
set matlab_exe=%matlab_dir%\bin
if exist "%matlab_exe%\matlab.exe" goto good_matlab_path
set matlab_exe=%matlab_exe%\win32
:good_matlab_path
echo setupMatlabClassPath.bat starting matlab >> %temp%\dspbuilder_install.log
echo "%dspb_dir%\dsp_builder.bat" -m "%matlab_exe%\matlab.exe" -wait -logfile '%temp%\dspbuilder_install_matlab.log' -nosplash -minimize -r '%cmd%' >> %temp%\dspbuilder_install.log
"%dspb_dir%\dsp_builder.bat" -m "%matlab_exe%\matlab.exe" -wait -logfile '%temp%\dspbuilder_install_matlab.log' -nosplash -minimize -r "%cmd%"
echo setupMatlabClassPath.bat finished >> %temp%\dspbuilder_install.log
set path=%old_path%
