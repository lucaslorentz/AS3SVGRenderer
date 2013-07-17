@ECHO OFF

rem create svglist.txt with list of all svg files in svg-files directory
rem then check for if svgfile.svg.png is older then svgfile.svg 
rem and if not call inkscape to create svgfile.svg.png

SET INKSCAPE_PATH="C:\Program Files (x86)\Inkscape\inkscape.exe"
IF NOT EXIST %INKSCAPE_PATH% SET INKSCAPE_PATH="C:\Program Files\Inkscape\inkscape.exe"
IF NOT EXIST %INKSCAPE_PATH% SET INKSCAPE_PATH="C:\Inkscape\inkscape.exe"
IF NOT EXIST %INKSCAPE_PATH% SET INKSCAPE_PATH="D:\Inkscape\inkscape.exe"
IF NOT EXIST %INKSCAPE_PATH% (
  ECHO ERROR: Inkscape not found
  GOTO :eof
)

DIR svg-files\*.svg /b > svglist.txt

FOR /F %%F IN (svglist.txt) DO CALL :processFile %%F

GOTO :eof



:processFile

FOR /F %%N IN ('dir /b /o:d svg-files\%1 svg-files\%1.png') DO SET NEWEST=%%N
IF %NEWEST%==%1 GOTO :runInkscape

GOTO :eof

:runInkscape:

ECHO %1 changed, creating %1.png...
%INKSCAPE_PATH% -z -f svg-files\%1 -e svg-files\%1.png

GOTO :eof