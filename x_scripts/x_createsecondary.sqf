// by Xeno,
// x_createsecondary.sqf: creating secondary target for the city
//
private ["_man","_newgroup","_poss","_unit_array","_units","_vehicle","_wp_array","_truck","_the_officer", "_unit", "_pos"];
if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

#define __DEBUG_PRINT__
_wp_array = _this select 0;

sleep 35.120;
_xx_ran = (count _wp_array) call XfRandomFloor;
_poss = _wp_array select _xx_ran;
_wp_array set [_xx_ran, "X_RM_ME"];
_wp_array = _wp_array - ["X_RM_ME"];

sec_kind = (floor (random 7)) + 1; // (-1 value still not used,) 0 - for finished,  [1..7] - kind of current

//sec_kind = 1; // always governor for secondary target !!!
//sec_kind = 2; // always radar for main target !!!

//
// Sends message to connected clients about secondary completed and set sec_kind to zero
//
SYG_solvedMsg = 
{
	_this call XSendNetStartScriptClient;
	sec_kind = 0; // value will be sent to a client in jip procedure
	publicVariable "sec_kind";
};

__TargetInfo

_current_target_pos = _target_array2 select 0;
_current_target_radius = _target_array2 select 2;

#ifdef __DEBUG_PRINT__
hint localize format["+++ x_createsecondary.sqf: sec_kind = %1", sec_kind];
#endif

governor = nil;
switch (sec_kind) do {
	case 1: { // Governor
		__WaitForGroup
		__GetEGrp(_newgroup)
#ifdef __ACE__
		_the_officer = (if (d_enemy_side == "EAST") then {"ACE_OfficerE"} else {"ACE_OfficerW"});
#else		
		_the_officer = (if (d_enemy_side == "EAST") then {"OfficerE"} else {"OfficerW"});
#endif		
		_man = _newgroup createUnit [_the_officer, _poss, [], 0, "FORM"];
		governor = _man;
		publicVariable "governor";
		[_man] join _newgroup;
		_man setRank "COLONEL";
		_man setSkill 1.0;
		//+++ Sygsky: ream governor as a bonus for lucky player
		_man call SYG_rearmGovernor;
		//--- Sygsky
#ifndef __TT__
		_man addEventHandler ["killed", {[_this select 0] call XAddDead;side_main_done = true;_sec_solved = "sec_over";if (side (_this select 1) == d_side_player) then {_sec_solved = "gov_dead";};governor = nil; publicVariable governor; ["sec_solved",_sec_solved,name (_this select 1)] call SYG_solvedMsg;}];
#endif
		// run check procedure for governor mission, dead or out of big enough circle (2000 m)
		[_man, 2000, _poss] spawn {
			private ["_center","_searchDist","_target_array2","_current_target_name","_grp","_man","_pos"];
			_man = _this select 0;
			_searchDist = _this select 1;
			__TargetInfo
			_center = _target_array2 select 0; // center of curent town
#ifdef __DEBUG_PRINT__
            hint localize format["+++ x_createsecondry.sqf->spawn: target center %1, governor %2, dist %3 m.", _center, _man, round(_center distance _man)];
#endif
			if ( count _this > 2) then {_pos = _this select 2} else { _pos = _center};
			waitUntil { sleep 5.174; mt_radio_down }; // wint until radio tower is down
			while { !side_main_done } do {// check governor be in circle 2000 m.
				if ( isNull _man ) exitWith { // strange but man is already absent in game
					side_main_done = true;
					["sec_solved", "gov_out"] call SYG_solvedMsg;
				}; // he is out in some manner
				if ( not alive _man ) exitWith  {// man is dead
					_man call XAddDead;	side_main_done = true; ["sec_solved", "sec_over"] call SYG_solvedMsg;
				}; // he is dead without event processing!
				if ( (_man distance _center) >= _searchDist ) exitWith  {// man is alive but out of circle
					_grp = group _man;
					if ( !isNull _grp ) then {
						_grp setCombatMode "YELLOW";
						_grp setSpeedMode "FULL";
						_grp setBehaviour "SAFE";
						_grp move _pos;
					};
					governor = nil;
					side_main_done = true;["sec_solved", "gov_out"] call SYG_solvedMsg;
				};
				sleep 10.147; // each 10 seconds
			};
		};
		
		#ifdef __TT__
		_man addEventHandler ["killed", {[_this select 0] call XAddDead;side_main_done = true;_sec_solved = "sec_over";if (side (_this select 1) in [west,resistance]) then {_sec_solved = "gov_dead";};["sec_solved",_sec_solved] call SYG_solvedMsg;}];
		_man addEventHandler ["killed", {[1,_this select 1] call XAddKills;[3,_this select 1] call XAddPoints;_mt_sm_over = (_this select 1);["mt_sm_over",_mt_sm_over] call SYG_solvedMsg;}];
		#endif
		#ifdef __AI__
		if (__RankedVer) then {
			_man addEventHandler ["killed", {[1,_this select 1] call XAddKillsAI}];
		};
		#endif
		sleep 1.0112;
		_unit_array = ["specops", d_enemy_side] call x_getunitliste;
		_units = [_poss, (_unit_array select 0), _newgroup,true] call x_makemgroup;
		//+++ Sygsky: rearm governor guards as a bonus for player
		[_units, 1.0,0.9] call SYG_rearmSpecopsGroupA;
		//--- Sygsky
		_unit_array = nil;
		sleep 1.0112;
		_newgroup allowFleeing 0.2;
		_newgroup call XGuardWP; // XGovernorWP ???
	};
	case 2: { // radar
		_poss = [_target_array2 select 0, _target_array2 select 2] call XfGetRanPointCircleBig;
		while {count _poss == 0} do {
			_poss = [_target_array2 select 0, _target_array2 select 2] call XfGetRanPointCircleBig;
			sleep 0.04;
		};
		_vehicle = "Land_vysilac_FM2" createVehicle (_poss);
		_vehicle setVectorUp [0,0,1];
		_ACE =
#ifdef __ACE__
        true;
#else
        false;
#endif
		#ifndef __TT__
		_vehicle addEventHandler ["killed", {_sec_solved = "sec_over";side_main_done = true;if (side (_this select 1) == d_side_player) then {_sec_solved = "radar_down";};["sec_solved",_sec_solved,name (_this select 1)] call SYG_solvedMsg;_this spawn x_removevehiextra;}];

        _posCnt = _vehicle call SYG_housePosCount;
		_cnt = floor (random (3 min _posCnt));    // add guard[s] on the top of radar
		if (_cnt > 0) then
		{
//		    hint localize format["x_scripts/x_createsecondary.sqf: %1 unit[s] guards secondary target", _cnt];
            _types =
            if ( _ACE) then
            {
                ["ACE_SoldierWSniper2_WDL","ACE_SoldierWMG_A"]
            }
            else
            {
                ["SoldierWSniper","SoldierWMG"];
            };
            __WaitForGroup
            __GetEGrp(_newgroup)
            for "_i" from 0 to _cnt - 1 do
            {
                _type = _types call XfRandomArrayVal;
                _unit = _newgroup createUnit [ _type, _poss, [], 0, "FORM"];
                [_unit] join _newgroup;
                _pos = _vehicle buildingPos _i;
                hint localize format["+++ x_createsecondary.sqf: creating guard %5 (grp %6) on top of tower, %1 at pos %2(%3) of max %4", _type, _pos, _i, _cnt, _unit, _newgroup];
                _unit disableAI "MOVE";
                _unit setBehaviour "SAFE";
                _unit setPos _pos;
                _unit setSkill 1.0;
                _unit addEventHandler ["killed", {[_this select 0] call XAddDead;}];
            };
		}
		else {  hint localize format["x_scripts/x_createsecondary.sqf: secondary target is unguarded", _cnt];};
		#endif
		#ifdef __TT__
		_vehicle addEventHandler ["killed", {_sec_solved = "sec_over";side_main_done = true;if (side (_this select 1) in [west,resistance]) then {_sec_solved = "radar_down";};["sec_solved",_sec_solved] call SYG_solvedMsg;_this spawn x_removevehiextra;}];
		_vehicle addEventHandler ["killed", {[3,_this select 1] call XAddPoints;}];
		#endif
	};
	case 3: { // ammo truck
		_truck = (if (d_enemy_side == "EAST") then {"UralReammo"} else {"Truck5tReammo"});
		_vehicle = _truck createVehicle (_poss);
		_vehicle setDir (floor random 360);
		_vehicle lock true;
		#ifndef __TT__
		_vehicle addEventHandler ["killed", {_sec_solved = "sec_over";side_main_done = true;if (side (_this select 1) == d_side_player) then {_sec_solved = "ammo_down";};["sec_solved",_sec_solved,name (_this select 1)] call SYG_solvedMsg;_this spawn x_removevehiextra;}];
		#endif
		#ifdef __TT__
		_vehicle addEventHandler ["killed", {_sec_solved = "sec_over";side_main_done = true;if (side (_this select 1) in [west,resistance]) then {_sec_solved = "ammo_down";};["sec_solved",_sec_solved] call SYG_solvedMsg;_this spawn x_removevehiextra;}];
		_vehicle addEventHandler ["killed", {[3,_this select 1] call XAddPoints;}];
		#endif
	};
	case 4: { // battle control station disguised as an ambulance
		_truck = (if (d_enemy_side == "EAST") then {"ACE_BMP2_Ambul"} else {"ACE_M113_Ambul"});
		_vehicle = _truck createVehicle (_poss);
		_vehicle setDir (floor random 360);
		_vehicle lock true;
		
		#ifndef __TT__
		_vehicle addEventHandler ["killed", {_sec_solved = "sec_over";side_main_done = true;if (side (_this select 1) == d_side_player) then {_sec_solved = "apc_down";};["sec_solved",_sec_solved,name (_this select 1)] call SYG_solvedMsg;_this spawn x_removevehiextra;}];
		#endif
		#ifdef __TT__
		_vehicle addEventHandler ["killed", {_sec_solved = "sec_over";side_main_done = true;if (side (_this select 1) in [west,resistance]) then {_sec_solved = "apc_down";};["sec_solved",_sec_solved] call SYG_solvedMsg;_this spawn x_removevehiextra;}];
		_vehicle addEventHandler ["killed", {[3,_this select 1] call XAddPoints;}];
		#endif

		//+++Sygsky: add one more medical BMP here
		if ( (random 1.0) < 0.66 ) then // create additional false BMP not each time
		{
			_xx_ran = (count _wp_array) call XfRandomFloor;
			_poss = _wp_array select _xx_ran;
			_wp_array set [_xx_ran, "X_RM_ME"];
			_wp_array = _wp_array - ["X_RM_ME"];

			_vehicle = _truck createVehicle (_poss);
			_vehicle setDir (floor random 360);
#ifdef __OLD__
            //_this call SYG_assignVecToSmokeOnHit; // set smoking function on hit if smoke device is available
			if (_vehicle isKindOf "Tank") then
			{
				if (!d_found_gdtmodtracked) then {[_vehicle] spawn XGDTTracked};
				if (!(_vehiclename in x_heli_wreck_lift_types)) then
				{
					_vehicle addEventHandler ["killed", {_this spawn x_removevehi}];
	        		[_vehicle] call XAddCheckDead;
                };
			} 
			else 
			{
/*
				if (d_smoke) then {
					if (_vehicle isKindOf "StrykerBase" || _vehicle isKindOf "BRDM2") then {_vehicle setVariable ["D_SMOKE_SHELLS",2]};
				};
*/
				if (!(_vehiclename in x_heli_wreck_lift_types)) then
				{
					if (!(_vehicle isKindOf "StrykerBase") && !(_vehicle isKindOf "BRDM2")) then
					{
						__addRemoveVehi(_vehicle)
					}
					else
					{
						_vehicle addEventHandler [ "killed", {_this spawn x_removevehi} ];
					};
        			[_vehicle] call XAddCheckDead;
				};
			};
#else
			[_vehicle] call SYG_addEventsAndDispose;
#endif
		};
		//---Sygsky: add one more medical BMP here
		
	};
	case 5: { // todo: MHQ folded/unfolded
		_poss = [_target_array2 select 0, _target_array2 select 2] call XfGetRanPointCircleBig;
		while {count _poss == 0} do {
			_poss = [_target_array2 select 0, _target_array2 select 2] call XfGetRanPointCircleBig;
			sleep 0.04;
		};
		_truck = (if (d_enemy_side == "EAST") then {"BMP2_MHQ_unfolded"} else {"M113_MHQ_unfolded"});
		_vehicle = _truck createVehicle (_poss);
		_vehicle setDir (floor random 360);
		_vehicle lock true;
		#ifndef __TT__
		_vehicle addEventHandler ["killed", {_sec_solved = "sec_over";side_main_done = true;if (side (_this select 1) == d_side_player) then {_sec_solved = "hq_down";};["sec_solved",_sec_solved,name (_this select 1)] call SYG_solvedMsg;_this spawn x_removevehiextra;}];
		#endif
		#ifdef __TT__
		_vehicle addEventHandler ["killed", {_sec_solved = "sec_over";side_main_done = true;if (side (_this select 1) in [west,resistance]) then {_sec_solved = "hq_down";};["sec_solved",_sec_solved] call SYG_solvedMsg;_this spawn x_removevehiextra;}];
		_vehicle addEventHandler ["killed", {[3,_this select 1] call XAddPoints;}];
		#endif
	};
	case 6: { // light factory
		_poss = [_target_array2 select 0, _target_array2 select 2] call XfGetRanPointCircleBig;
		while {count _poss == 0} do {
			_poss = [_target_array2 select 0, _target_array2 select 2] call XfGetRanPointCircleBig;
			sleep 0.04;
		};
		_vehicle = "WarfareBLightFactory" createVehicle (_poss);
		_vehicle setDir (floor random 360);
		#ifndef __TT__
		_vehicle addEventHandler ["killed", {_sec_solved = "sec_over";side_main_done = true;if (side (_this select 1) == d_side_player) then {_sec_solved = "light_down";};["sec_solved",_sec_solved,name (_this select 1)] call SYG_solvedMsg;_this spawn x_removevehiextra;}];
		#endif
		#ifdef __TT__
		_vehicle addEventHandler ["killed", {_sec_solved = "sec_over";side_main_done = true;if ((side (_this select 1)) in [west,resistance]) then {_sec_solved = "light_down";};["sec_solved",_sec_solved] call SYG_solvedMsg;_this spawn x_removevehiextra;}];
		_vehicle addEventHandler ["killed", {[3,_this select 1] call XAddPoints;}];
		#endif
	};
	case 7: { // heavy factory
		_poss = [_target_array2 select 0, _target_array2 select 2] call XfGetRanPointCircleBig;
		while {count _poss == 0} do {
			_poss = [_target_array2 select 0, _target_array2 select 2] call XfGetRanPointCircleBig;
			sleep 0.04;
		};
		_vehicle = "WarfareBHeavyFactory" createVehicle (_poss);
		_vehicle setDir (floor random 360);
		#ifndef __TT__
		_vehicle addEventHandler ["killed", {_sec_solved = "sec_over";side_main_done = true;if (side (_this select 1) == d_side_player) then {_sec_solved = "heavy_down";};["sec_solved",_sec_solved,name (_this select 1)] call SYG_solvedMsg;_this spawn x_removevehiextra;}];
		#endif
		#ifdef __TT__
		_vehicle addEventHandler ["killed", {_sec_solved = "sec_over";side_main_done = true;if (side (_this select 1) in [west,resistance]) then {_sec_solved = "heavy_down";};["sec_solved",_sec_solved] call SYG_solvedMsg;_this spawn x_removevehiextra;}];
		_vehicle addEventHandler ["killed", {[3,_this select 1] call XAddPoints;}];
		#endif
	};
};

["sec_kind",sec_kind] call XSendNetStartScriptClient;

sleep 11.0123;
//+++ Sygsky: try to build tower not very close to the edge of town circle, but near to center
_tower_build_radius = (_current_target_radius / 2);
//_poss = [_target_array2 select 0, _target_array2 select 2] call XfGetRanPointCircleBig;
_poss = [];

while {count _poss == 0} do {
	_poss = [_current_target_pos, _tower_build_radius] call XfGetRanPointCircleBig;
	sleep 0.04;
};
_vehicle = "Land_telek1" createVehicle (_poss);
_vehicle setVectorUp [0,0,1];
[_vehicle] spawn XCheckMTHardTarget;
mt_radio_down = false; // set radio tower to alive status
mt_radio_pos = _poss;
["mt_radio",mt_radio_down,mt_radio_pos] call XSendNetStartScriptClient;

createGuardedPoint[d_side_enemy,position _vehicle, -1, _vehicle];
// TODO: set some waypoints for any group[s] with "GUARD" waypoint type:
// TODO: _wp = _grp addWaypoint [_pos, 10];
// TODO: _wp setWaypointType "GUARD";

mt_spotted = false; // set player status  as 'not spotted'

// add guard group for tower position

_posCnt = _vehicle call SYG_housePosCount;
_cnt = floor (random (3 min _posCnt));    // add max 3 guard[s] on the top of radar
if (_cnt > 0) then
{
    __WaitForGroup
    __GetEGrp(_newgroup)
    sleep 0.1;
    if ( !isNull _newgroup) then
    {
        _types =
#ifdef __ACE__
            ["ACE_SoldierWAR_A","ACE_SoldierWMG_A"];
#else
            ["SoldierWSniper","SoldierWMG"];
#endif
        for "_i" from 0 to _cnt - 1 do
        {
            _pos = _vehicle buildingPos _i;
            _type = _types call XfRandomArrayVal;
            _unit = _newgroup createUnit [_type, [0,0,0], [], 0, "FORM"];
            if ( !isNull _unit) then
            {
                [_unit] join _newgroup;
#ifdef __DEBUG_PRINT__
                hint localize format["+++ x_createsecondary.sqf: guard %1 (grp %2) on top of main tower at pos %3[%4/%5]", _type, _newgroup, _pos, _i, _cnt];
#endif
                _unit setPos _pos;
                _unit setSkill 1.0;
                //_unit setBehaviour "SAFE";
                _unit disableAI "MOVE";
                _unit addEventHandler ["killed", {[_this select 0] call XAddDead;}];
            }
            else
            {
                hint localize format["--- x_createsecondary.sqf: guard of type %1 created (group %2) on top of a main tower is NULL", _type, _newgroup];
            };
            _newgroup call XGuardWP;
        };

        // TODO: add more units to the group to guard the tower
#ifdef __FUTURE__
    [ "basic", [getPos _vehicle], getPos _vehicle, 0, "guardvehicle", d_enemy_side, _newgroup, -1.111 /*, [_trg_center, _radius] */] execVM "x_scripts\x_makegroup.sqf";
    hint localize format["+++ x_createsecondary.sqf: tower guard group of %1 men (%2) created", count _newgroup, "basic" ];
#endif

    }
    else
    {
        hint localize "-- x_createsecondary.sqf: group created for a tower guard[s] is NULL";
    };
}
#ifdef __DEBUG_PRINT__
else
{
    hint localize "+++ x_createsecondary.sqf: no guard on top of the main tower was created";
}
#endif
;

_wp_array = nil;

sleep 10.234;
/* _dummy = target_names select current_target_index;
_current_target_pos = _dummy select 0;
_current_target_radius = _dummy select 2;
 */
_act2 = d_enemy_side + " D";
d_f_check_trigger2 = objNull;
d_f_check_trigger = createTrigger["EmptyDetector",_current_target_pos];
d_f_check_trigger setTriggerArea [_current_target_radius + 1000, _current_target_radius + 1000, 0, false]; // increased by 200 m. from 300
d_f_check_trigger setTriggerActivation [d_own_side_trigger, _act2, false];
d_f_check_trigger setTriggerStatements["this", "xhandle = [] spawn {if (!create_new_paras) then {create_new_paras = true;[] execVM ""x_scripts\x_parahandler.sqf"";};mt_spotted = true;[""mt_spotted""] call XSendNetStartScriptClient;sleep 5;deleteVehicle d_f_check_trigger;if (!isNull d_f_check_trigger2) then {deleteVehicle d_f_check_trigger2}}", ""];

#ifdef __TT__
d_f_check_trigger2 = createTrigger["EmptyDetector",_current_target_pos];
d_f_check_trigger2 setTriggerArea [_current_target_radius + 1000, _current_target_radius + 1000, 0, false];
d_f_check_trigger2 setTriggerActivation ["GUER", _act2, false];
d_f_check_trigger2 setTriggerStatements["this", "xhandle = [] spawn {if (!create_new_paras) then {create_new_paras = true;[] execVM ""x_scripts\x_parahandler.sqf"";};mt_spotted = true;[""mt_spotted""] call XSendNetStartScriptClient;sleep 5;deleteVehicle d_f_check_trigger2;if (!isNull d_f_check_trigger) then {deleteVehicle d_f_check_trigger}}", ""];
#endif

sleep 10.213;
main_target_ready = true;  // main target scripting completed

if (true) exitWith {};