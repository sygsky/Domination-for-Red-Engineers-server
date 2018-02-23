// x_createnexttarget.sqf, by Xeno, server side

if (!isServer) exitWith{};

#include "x_setup.sqf"

#define __DEBUG__

#define COUNT_DELAY 4

#ifdef __DEBUG__
    hint localize "+++ x_createnexttarget.sqf started +++";
#endif

#ifdef __SIDE_MISSION_PER_MAIN_TARGET_COUNT__
private ["_time"];

hint localize format["x_scripts/x_createnexttarget.sqf: call SYG_isMainTargetAllowed( current_counter %1, current_mission_counter %2 )", current_counter, current_mission_counter];

_time = time;
if ( !( call SYG_isMainTargetAllowed ) ) then
{
    _msg = [ "localize", "STR_SYS_1151_1", current_mission_counter + 1 ]; // "Finish SM(%1)"
    ["msg_to_user", "*", [_msg], 0, 4] call XSendNetStartScriptClient;
    hint localize format["x_scripts/x_createnexttarget.sqf: call SYG_isMainTargetAllowed( current_counter %1, current_mission_counter %2 ) false", current_counter, current_mission_counter];
};

while { !(call SYG_isMainTargetAllowed) } do
{
	if (X_MP) then { if ((call XPlayersNumber) == 0) then {waitUntil { sleep 15; (call XPlayersNumber) > 0 }; } };
    sleep (4 + random 2);
};

if ( ((time - _time) > 60) ) then
{
    _msg = [ "localize", "STR_SYS_1152" ]; // "The people of Sahrani thank you for your liberation mission!"
    ["msg_to_user", "*", [_msg], 0, 4] call XSendNetStartScriptClient;
    hint localize format["x_scripts/x_createnexttarget.sqf: call SYG_isMainTargetAllowed( current_counter %1, current_mission_counter %2 ) true", current_counter, current_mission_counter];
};
#endif

private ["_current_target_pos","_current_target_radius","_dummy","_emptyH"];

current_target_index = maintargets_list select current_counter;

current_counter = current_counter + 1;

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
hint localize format["+++ x_createnexttarget.sqf (%1)completed +++", _dummy select 1];
#endif

[] spawn {
    if ( (count resolved_targets) < COUNT_DELAY) exitWith {}; // start on Nth town to clean it
    private ["_dummy","_target_pos","_target_radius","_list","_cnt", "_cnt1"];
    sleep random 30;
    _this = resolved_targets select (current_counter - COUNT_DELAY); // index of town to clean;
    _dummy = target_names select _this;
    _target_pos = _dummy select 0;
    _target_radius = _dummy select 2;
    // find all dead bodies assuming than they always are long time dead
    _list = _target_pos nearObjects ["CAManBase", _target_radius + 50];
    sleep 300; // wait for a while to remove old dead corpses
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
                sleep 0.01;
                _cnt = _cnt + 1;
            };
        };
     } forEach _list;
     // remove underwater weapon holders
    _list = _target_pos nearObjects ["WeaponHolder", _target_radius + 50];
    _cnt1 = 0;
     {
        if (surfaceIsWater (getPos _x)) then
        {
            deleteVehicle _x;
            sleep 0.01;
                _cnt1 = _cnt1 + 1;
        };
     } forEach _list;
#ifdef __DEBUG__
    hint localize format["x_createnexttarget.sqf: Old dead bodies cleaned in %3: found men %1, clean dead %2, in water weapon holders %4", count _list, _cnt, _dummy select 1, _cnt1];
#endif
     _list = nil;
     sleep 2.56;
};

#ifdef __AI__

// check for the AI_HUT to be alive
if (isNil "AI_HUT") exitWith {hint localize "--- x_scripts/x_createnexttarget.sqf: no AI_HUT detected"}; // no hut
if ( damage AI_HUT == 0) exitWith{};
if (damage AI_HUT < 1 ) exitWith {AI_HUT setDamage 0};

// AI_HUT is destroyed, lets restore it
_ruin = pos_ nearestObject "land_budova2_ruin";
if ( isNull _ruin) then
{
    hint localize "--- x_scripts/x_createnexttarget.sqf: try to repair, but no land_budova2_ruin found near";
    deleteVehicle _ruin;
    sleep 0.05;
};

AI_HUT setDamage 0;
AI_HUT setDir (d_pos_ai_hut select 1);
AI_HUT setPos (d_pos_ai_hut select 0);
sleep 0.1;
AI_HUT say "fanfare";
AI_HUT removeAllEventHandlers "hit";
AI_HUT removeAllEventHandlers "damage";
sleep 0.1;

AI_HUT addEventHandler ["hit", {(_this select 0) setDamage 0}];
AI_HUT addEventHandler ["damage", {(_this select 0) setDamage 0}];

// ADD_HIT_EH(AI_HUT)
// ADD_DAM_EH(AI_HUT)

publicVariable "AI_HUT";
hint localize "--- x_scripts/x_createnexttarget.sqf: AI_HUT resurrected";

#endif

if (true) exitWith {};
