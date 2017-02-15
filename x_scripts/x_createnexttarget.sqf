// x_createnexttarget.sqf, by Xeno

if (!isServer) exitWith{};

#include "x_setup.sqf"

#define __DEBUG__

#define COUNT_DELAY 4

private ["_current_target_pos","_current_target_radius","_dummy","_emptyH"];

current_target_index = maintargets_list select current_counter;
current_counter = current_counter + 1;

#ifdef __DEBUG__
    hint localize "+++ x_createnexttarget.sqf started +++";
#endif


sleep 1.0123;
if (first_time_after_start) then {
/*
	// create special side misssion with base harrison and wait its completion
	// TODO: wait for base to be free of enemy
	_ret = [] execVM "scripts\AirbaseAssault.sqf";
	waitUntil { sleep 5; scriptDone _ret};
*/
	first_time_after_start = false;
	sleep 18.123;
};

update_target=false;
main_target_ready = false;
side_main_done = false;

_dummy = target_names select current_target_index;
_current_target_pos = _dummy select 0;
_current_target_radius = _dummy select 2;
check_trigger=createTrigger["EmptyDetector",_current_target_pos];
check_trigger setTriggerArea [(_current_target_radius max 300) + 20, (_current_target_radius max 300) + 20, 0, false];
check_trigger setTriggerActivation [d_enemy_side, "PRESENT", false];
check_trigger setTriggerStatements["(""Man"" countType thislist >= d_man_count_for_target_clear) && (""Tank"" countType thislist >= d_tank_count_for_target_clear) && (""Car"" countType thislist  >= d_car_count_for_target_clear)", "[""current_target_index"",current_target_index] call XSendNetVarClient;target_clear = false;update_target=true;[""update_target"",objNull] call XSendNetStartScriptClient;deleteVehicle check_trigger;", ""]; 

[_current_target_pos, _current_target_radius] execVM "x_scripts\x_createguardpatrolgroups.sqf";

while {!update_target} do {sleep 2.123};
current_trigger = createTrigger["EmptyDetector",_current_target_pos];
current_trigger setTriggerArea [(_current_target_radius max 300) + 50, (_current_target_radius max 300) + 50, 0, false];
current_trigger setTriggerActivation [d_enemy_side, "PRESENT", false];
current_trigger setTriggerStatements["mt_radio_down && side_main_done && (""Car"" countType thislist <= d_car_count_for_target_clear) && (""Tank"" countType thislist <= d_tank_count_for_target_clear) && (""Man"" countType thislist <= d_man_count_for_target_clear)", "xhandle = [] execVM ""x_scripts\x_target_clear.sqf""", ""];

_emptyH = "HeliHEmpty" createVehicle _current_target_pos;
_emptyH setPos _current_target_pos;
// dir 0 = normal, not recaptured
// dir > 350 = recaptured by enemy
_emptyH setDir 0;

[] execVM "GRU_scripts\GRUMissionSetup.sqf";

if (call SYG_getTargetTownName == "Rahmadi") then
{
 // todo: add island patrol on Rahmadi
};

#ifdef __DEBUG__
    hint localize "+++ x_createnexttarget.sqf completed +++";
#endif

[] spawn {
    if ( (count resolved_targets) < COUNT_DELAY) exitWith {}; // start on Nth town to clean it
    private ["_dummy","_target_pos","_target_radius","_list","_cnt"];
    sleep random 30;
    _this = resolved_targets select (current_counter - COUNT_DELAY); // index of town to clean;
    _dummy = target_names select _this;
    _target_pos = _dummy select 0;
    _target_radius = _dummy select 2;
    // find all dead bodies assuming than they always are long time dead
    _list = _target_pos nearObjects ["CAManBase", _target_radius + 50];
    sleep 1800; // wait for a while to remove old dead corpses
    _cnt = 0;
     {
        if ( !alive _x) then
        {
            if (!isNull _x) then
            {
                _x removeAllEventHandlers "killed";
                _x removeAllEventHandlers "hit";
                _x removeAllEventHandlers "damage"; //+++ Sygsky: just in case
                _x removeAllEventHandlers "getin"; //+++ Sygsky: just in case
                _x removeAllEventHandlers "getout"; //+++ Sygsky: just in case
                deleteVehicle _x;
                _cnt = _cnt + 1;
            };
        };
     } forEach _list;
#ifdef __DEBUG__
    hint localize format["x_createnexttarget.sqf. Old dead bodies cleaned in %3: found men %1, clean dead %2", count _list, _cnt, _dummy select 1];
#endif
     _list = nil;
     sleep 2.56;
};

if (true) exitWith {};
