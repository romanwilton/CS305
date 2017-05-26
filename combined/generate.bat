@echo off

type ..\images\MainMenu.hex > combined.hex
type ..\images\WinScreen.hex >> combined.hex
type ..\images\FailScreen.hex >> combined.hex
type ..\images\BG1.hex >> combined.hex
type ..\images\BG2.hex >> combined.hex
type ..\images\BG3.hex >> combined.hex
type ..\images\BG4.hex >> combined.hex
type ..\audio\mercury_32k.hex >> combined.hex

echo Done
pause
