@echo off
rem Only local scope for variables
setlocal
rem This script is now misnamed. It actually removes any previous changes
rem to the MATLAB classpath that DSP Builder might have made.
rem addToClassPath <classpath file>

set classpath=%~1
if "%TMP%" NEQ "" goto gottemp
    set TMP=C:\tmp
:gottemp

@mkdir %TMP% 2>NUL

set tempfile=%TMP%\tempclasspath

set match=
For /F %%i in (' sed -n "/# DSPBuilder START/p" "%classpath%" ') do set match=%%i

if "%match%" EQU "" goto end
	cp "%classpath%" "%classpath%.backup"
	sed "/# DSPBuilder START/,/# DSPBuilder END/d;" "%classpath%" > %tempfile%
	cp "%tempfile%" "%classpath%"

:end