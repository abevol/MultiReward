echo off
set preLink=C:\Users\jayvi\AppData\Roaming\r2modmanPlus-local\HadesII\profiles\Default\ReturnOfModding\plugins\Abevol-MultiReward
set preTarget=D:\workspace\games\hades2\ReturnOfModding\plugins\Abevol-MultiReward\src

mklink %preLink%\config.lua %preTarget%\config.lua
mklink %preLink%\def.lua %preTarget%\def.lua
mklink %preLink%\main.lua %preTarget%\main.lua
mklink %preLink%\ready.lua %preTarget%\ready.lua
mklink %preLink%\reload.lua %preTarget%\reload.lua

pause
