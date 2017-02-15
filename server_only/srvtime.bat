@echo off

set dt=%date%
rem 23.11.2015

set tm=%time%
rem 12:53:33.21

echo SYG_mission_start = [%dt:~6,4%,%dt:~3,2%,%dt:~0,2%,%tm:~0,2%,%tm:~3,2%,%tm:~6,2%]; > "C:\Program Files\ArmA\srvtime.sqf"

start "" "C:\Program Files\ArmA\arma_server.exe" -config=server.cfg -mod=@ACE;@SIX_Pack3;@GDTModTracked -name=server -pid=pids.log