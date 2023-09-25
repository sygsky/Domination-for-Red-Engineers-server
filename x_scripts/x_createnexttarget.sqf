// x_createnexttarget.sqf, by Xeno, server side

if (!isServer) exitWith{};

#include "x_setup.sqf"

#define __DEBUG__

#define COUNT_DELAY 4

private ["_current_target_pos","_current_target_radius","_emptyH","_dummy"];

/**
if (current_counter > 0) then {
    // at last first town is already completed
    _dummy = target_names select (maintargets_list select (current_counter - 1));
    (_dummy select 1) call SYG_townScoresPrint; // print common statistics on finished town
};
*/

#ifdef __SIDE_MISSION_PER_MAIN_TARGET_COUNT__
private ["_time","_msg"];

hint localize format["+++ x_scripts/x_createnexttarget.sqf: call SYG_isMainTargetAllowed( current_counter %1, current_mission_counter %2 )", current_counter, current_mission_counter];

_time = time;
if ( !( call SYG_isMainTargetAllowed ) ) then {
    _msg = [ "localize", "STR_SYS_1151_1", current_mission_counter  +1 ]; // The Resistance of Sahrani asks you to complete the next side mission (# %1)
    ["msg_to_user", "*", [_msg], 0, 4] call XSendNetStartScriptClient;
    hint localize format["+++ x_scripts/x_createnexttarget.sqf: call SYG_isMainTargetAllowed( current_counter %1, current_mission_counter %2 ) false", current_counter, current_mission_counter];

while { !(call SYG_isMainTargetAllowed) } do {
		if (X_MP) then { if ((call XPlayersNumber) == 0) then {waitUntil { sleep 15; (call XPlayersNumber) > 0 }; } };
		sleep (4 + random 2);
};

if ( ((time - _time) > 60) ) then {
		_msg = [ "localize", "STR_SYS_1152" ]; // "The people of Sahrani thank you for your liberation mission!"
		["msg_to_user", "*", [_msg], 0, 4] call XSendNetStartScriptClient;
		hint localize format["+++ x_scripts/x_createnexttarget.sqf: call SYG_isMainTargetAllowed( current_counter %1, current_mission_counter %2 ) true", current_counter, current_mission_counter];
	};
};

#endif

current_target_index = maintargets_list select current_counter;

current_counter = current_counter + 1;

sleep 1.0123;
if (current_counter <= 1) then { // first time after start
/*
	// create special side misssion with base harrison and wait its completion
	// TODO: wait for base to be free of enemy
	_ret = [] execVM "scripts\AirbaseAssault.sqf";
	waitUntil { sleep 5; scriptDone _ret};
*/
	sleep 18.123;
};

update_target=false;
main_target_ready = false;
side_main_done = false;

_dummy = target_names select current_target_index;
_current_target_pos = _dummy select 0;
_current_target_radius = _dummy select 2;

hint localize format[ "+++ x_scripts/x_createnexttarget.sqf: current_target_index = %1 (%2), current_counter = %3", current_target_index, _dummy select 1, current_counter ];

// #437 - count number of new ruins during siege processs
initial_ruins_count = count (_current_target_pos nearObjects ["Ruins", _current_target_radius]);

check_trigger=createTrigger["EmptyDetector",_current_target_pos];
check_trigger setTriggerArea [(_current_target_radius max 300) + 20, (_current_target_radius max 300) + 20, 0, false];
check_trigger setTriggerActivation [d_enemy_side, "PRESENT", false];

// Static objects not used in lower conditions (""Static"" countType thislist >= d_static_count_for_target_clear)
#ifdef __TOWN_WEAK_DEFENCE__
// checks only for men in town, not cars and tanks (they are absent at all)
check_trigger setTriggerStatements["(""Man"" countType thislist >= d_man_count_for_target_clear) ", "[""current_target_index"",current_target_index] call XSendNetVarClient;target_clear = false;update_target=true;[""update_target"",objNull] call XSendNetStartScriptClient;deleteVehicle check_trigger;", ""];
#else
check_trigger setTriggerStatements["(""Man"" countType thislist >= d_man_count_for_target_clear) && (""Tank"" countType thislist >= d_tank_count_for_target_clear) && (""Car"" countType thislist  >= d_car_count_for_target_clear)", "[""current_target_index"",current_target_index] call XSendNetVarClient;target_clear = false;update_target=true;[""update_target"",objNull] call XSendNetStartScriptClient;deleteVehicle check_trigger;", ""];
#endif

(_dummy select 1) call SYG_lastTownsAdd;   // add town name to queue to inform about last towns on OPC event
(_dummy select 1) call SYG_townScoresInit; // start score statistics for this town


//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
[_current_target_pos, _current_target_radius, _dummy select 1] execVM "x_scripts\x_createguardpatrolgroups.sqf";
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

while {!update_target} do {sleep 2.123};
current_trigger = createTrigger["EmptyDetector",_current_target_pos];
current_trigger setTriggerArea [(_current_target_radius max 300) + 50, (_current_target_radius max 300) + 50, 0, false];
current_trigger setTriggerActivation [d_enemy_side, "PRESENT", false];
#ifdef __TOWN_WEAK_DEFENCE__
// chack only for men
current_trigger setTriggerStatements["mt_radio_down && side_main_done && (""Man"" countType thislist <= d_man_count_for_target_clear)", "xhandle = [thislist] execVM ""x_scripts\x_target_clear.sqf""", ""];
#else
current_trigger setTriggerStatements["mt_radio_down && side_main_done && (""Car"" countType thislist <= d_car_count_for_target_clear) && (""Tank"" countType thislist <= d_tank_count_for_target_clear) && (""Man"" countType thislist <= d_man_count_for_target_clear)", "xhandle = [thislist] execVM ""x_scripts\x_target_clear.sqf""", ""];
#endif

_emptyH = "HeliHEmpty" createVehicle _current_target_pos;
_emptyH setPos _current_target_pos;
// dir 0 = normal, not recaptured
// dir > 350 = recaptured by enemy
_emptyH setDir 0;

[] execVM "GRU_scripts\GRUMissionSetup.sqf";

if (call SYG_getTargetTownName == "Rahmadi") then { /* TODO: add island patrol on Rahmadi */ };

[] spawn {
    if ( (count resolved_targets) < COUNT_DELAY) exitWith {}; // start on Nth town to clean it
    private [ "_dummy", "_target_pos", "_target_radius", "_list", "_man_cnt", "_cnt", "_acnt", "_ecnt", "_cnt1", "_var" ];
    sleep random 30;
    _this = resolved_targets select ((current_counter - 1) - COUNT_DELAY); // index of town to clean; current_counter is already bumped by +1
    _dummy = target_names select _this;
    _target_pos = _dummy select 0;
    _target_radius = _dummy select 2;

    // find all dead bodies assuming than they always are long time dead

    _list = _target_pos nearObjects ["CAManBase", _target_radius + 50];
    _man_cnt = count _list;
    sleep 300; // wait for a while to remove old dead corpses
    _cnt = 0;
    _acnt = 0;
    _ecnt  = 0;
    {
        if ( !alive _x) then {
            if (!isNull _x) then {
                _x removeAllEventHandlers "killed";
                _x removeAllEventHandlers "hit";
                _x removeAllEventHandlers "dammaged"; //+++ Sygsky: just in case
                _x removeAllEventHandlers "getin";  //+++ Sygsky: just in case
                _x removeAllEventHandlers "getout"; //+++ Sygsky: just in case
                deleteVehicle _x;
                sleep 0.01;
                _cnt = _cnt + 1;
            };
        } else {
            _acnt = _acnt + 1;
            if ( side _x == east) then {_ecnt = _ecnt + 1;}
        };
    } forEach _list;
     // remove underwater weapon holders
    _list = _target_pos nearObjects ["WeaponHolder", _target_radius + 50];
    _cnt1 = 0;
     {
        if (surfaceIsWater (getPos _x)) then {
            deleteVehicle _x;
            sleep 0.01;
            _cnt1 = _cnt1 + 1;
        };
     } forEach _list;
#ifdef __DEBUG__
    hint localize format[ "+++ x_createnexttarget.sqf: Bodies cleaned in %1: men %2 (alive %3, east %4, dead %5), holders %6(water %7)", _dummy select 1, _man_cnt, _acnt, _ecnt, _cnt, count _list, _cnt1 ];
#endif
	// #598: remove town's Mash if found
    _list = _target_pos nearObjects ["MASH", _target_radius + 50];
    _cnt = 0;
    {
    	_var = _x getVariable "TOWN";
    	if (!isNil "_var") then {
    		if (_var) then {
				["say_sound", getPos _x, "steal"] call XSendNetStartScriptClientAll; // play steal sound on mash removing
				deleteVehicle _x;
				sleep 1;
				_cnt = _cnt + 1;
    		};
    	};
    } forEach _list;
#ifdef __DEBUG__
    hint localize format[ "+++ x_createnexttarget.sqf: MASH removing. Found %1, detected as TOWN mash and removed %2", count _list, _cnt ];
#endif

    _list = nil;
    sleep 2.56;
};

#ifdef __AI__
execVM "scripts\restore_barracks.sqf";
#endif

if (true) exitWith {};
