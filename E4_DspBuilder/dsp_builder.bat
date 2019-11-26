@ECHO OFF
SETLOCAL ENABLEEXTENSIONS
ECHO DSP_BUILDER.BAT RUNNING!

SET MATLAB_ARGS=
SET MATLAB_SCRP=""
SET MATLAB_PATH=MATLAB
SET NORUN=0

:: Find Quartus root directory
SET QUARTUS_ROOTDIR=%~dp0
SET QUARTUS_ROOTDIR=%QUARTUS_ROOTDIR:~0,-1%
FOR %%A in ("%QUARTUS_ROOTDIR%") DO SET QUARTUS_ROOTDIR=%%~dpA
SET QUARTUS_ROOTDIR=%QUARTUS_ROOTDIR:~0,-1%

:: Override Quartus root directory if override variable is set
IF DEFINED %QUARTUS_ROOTDIR_OVERRIDE (
    SET QUARTUS_ROOTDIR=%QUARTUS_ROOTDIR_OVERRIDE%
)

:: Parse command line arguments
:LOOP
  IF "%~1"=="" (
    GOTO ENDLOOP
  )^
  ELSE IF "%~1"=="-echo" (
    SET NORUN=1
  )^
  ELSE IF "%~1"=="-r" (
    IF "%~2"=="" GOTO USAGE
    SET MATLAB_SCRP=%2
    SHIFT
  )^
  ELSE IF "%~1"=="-m" (
    IF "%~2"=="" GOTO USAGE
    SET MATLAB_PATH=%2
    SHIFT
  )^
  ELSE IF "%~1"=="-q" (
    IF "%~2"=="" GOTO USAGE
    SET QUARTUS_ROOTDIR=%2
    SHIFT
  )^
  ELSE (
    SET MATLAB_ARGS=%MATLAB_ARGS% %1
  )

  SHIFT
GOTO LOOP
:ENDLOOP

:: Prepend setup commands for DSP Builder Standard
SET DSP_BUILDER_ROOT=%QUARTUS_ROOTDIR%\dsp_builder
IF EXIST "%DSP_BUILDER_ROOT%\setup_dsp_builder.m" (
  FOR /F "usebackq delims=" %%A IN ('%MATLAB_SCRP%') DO ^
SET MATLAB_SCRP="setenv('DSP_BUILDER_ROOT','%DSP_BUILDER_ROOT%');run('%DSP_BUILDER_ROOT%\setup_dsp_builder.m');%%~A"
)

:: Prepend setup commands for DSP Builder Advanced
SET DSPBA_ROOT=%QUARTUS_ROOTDIR%\dspba
IF EXIST "%DSPBA_ROOT%\setup_dspba.m" (
  FOR /F "usebackq delims=" %%A IN ('%MATLAB_SCRP%') DO ^
SET MATLAB_SCRP="setenv('DSPBA_ROOT','%DSPBA_ROOT%');run('%DSPBA_ROOT%\setup_dspba.m');%%~A"
)

:: Launch Matlab
SET MATLAB_ARGS=%MATLAB_ARGS% -r %MATLAB_SCRP%
IF "%NORUN%"=="1" (
  ECHO %MATLAB_PATH% %MATLAB_ARGS%
)^
ELSE (
  %MATLAB_PATH% %MATLAB_ARGS%
)
