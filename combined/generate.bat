@echo off

type ..\images\MainMenu.hex > combined.hex
type ..\images\test_background2.hex >> combined.hex
type ..\images\mootoo.hex >> combined.hex
type ..\images\test_background2.hex >> combined.hex
type ..\images\mootoo.hex >> combined.hex
type ..\images\test_background2.hex >> combined.hex
type ..\audio\Thomas_32k.hex >> combined.hex

echo Done
pause
