// by Xeno: x_jip.sqf
if (!X_Client) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

#define __DEBUG__

setViewDistance d_viewdistance;

#ifdef __DEBUG__
// set time here as date_str is already synchonized with server (in init.sqf before call to x_jip.sqf)
setDate date_str;
SYG_mission_start = missionStart;
hint localize format["x_jip.sqf: client date %1, missionStart %2", call SYG_nowTimeToStr, SYG_mission_start call SYG_dateToStr];
#endif

#ifdef __OLD_INTRO__
execVM "x_scripts\x_intro_old.sqf";
#endif
#ifndef __OLD_INTRO__
execVM "x_scripts\x_intro.sqf";
#endif

execVM "x_scripts\x_setupplayer.sqf";

if (true) exitWith {};
