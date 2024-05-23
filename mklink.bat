echo off
set preLink=D:\Data\r2modmanPlus-local\HadesII\profiles\Default\ReturnOfModding\plugins\Abevol-MultiReward
set preTarget=D:\workspace\games\hades2\ReturnOfModding\plugins\Abevol-MultiReward\src

mklink /h %preLink%\config.lua %preTarget%\config.lua
mklink /h %preLink%\def.lua %preTarget%\def.lua
mklink /h %preLink%\main.lua %preTarget%\main.lua
mklink /h %preLink%\ready.lua %preTarget%\ready.lua
mklink /h %preLink%\reload.lua %preTarget%\reload.lua

pause
