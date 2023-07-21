@echo off
echo Quickly setting up Vs. Foxa for compiling...
haxelib --global install hmm
haxelib --global run hmm install
echo Finished. You may now compile Vs. Foxa!
echo Oh wait!! Just a little precaution...
haxelib install hxCodec 2.5.1
haxelib set hxCodec 2.5.1
echo There. NOW we're done.
echo Press any key to exit.
pause >nul
