// flaresoverbase.sqf: by Sygsky
// script to shoot flares above base from wounded sabotages. Runs only on server!!
// Example:
// [] execVM "scripts\flaresoverbase.sqf";
//
// script uses global variable d_on_base_groups as array of sabotage groups sent to blow base
//
#include "x_setup.sqf"
#include "x_macros.sqf"

if (!isServer) exitWith{};

// comment next line to not create debug messages
//#define __DEBUG__
//#define __PRINT__

#define MAX_FLARE_NUMBER 2

#ifdef __DEBUG__
// delay between flares 
#define INTERFLARE_DELAY 20
#define CYCLE_DELAY 10
#define START_DELAY  10
#define WAIT_FOR_SABOTAGE_DELAY 60
#else
// delay between flares 
#define INTERFLARE_DELAY 60
// 5 mins timeout will be good
#define CYCLE_DELAY 300
#define START_DELAY  5000
#define WAIT_FOR_SABOTAGE_DELAY 1600
#endif

#define inc(val) ((val)=(val)+1)
#define TIMEOUT(addval) (time+(addval))
#define ROUND0(val) (round(val))
#define ROUND2(val) (floor((val)*100.0)/100.0)
#define ROUND1(val) (floor((val)*10.0)/10.0)

#define arg(num) (_this select(num))
#define argp(arr,num) ((arr)select(num))
#define argopt(num,val) (if((count _this)<=(num))then{val}else{arg(num)})

//
// =======================================================================================
//
_illumination = {
	private ["_trg_center","_radius","_height","_type","_pos"];
	
	_trg_center = _this select 0;
	_radius     = _this select 1;
	_height     = argopt(2,250); // default 250
	_type       = argopt(3,"F_40mm_Red"); // default is "F_40mm_Red"
#ifdef __PRINT__
	//player groupChat format[ "flaresoverbase.sqf: [%1,%2,%3,%4] call _illumination ", _trg_center, _radius, _height, _type];
	hint localize    format[ "flaresoverbase.sqf: [%1,%2,%3,%4] call _illumination ", _trg_center, _radius, _height, _type];
#endif				

	_pos = [_trg_center, _radius] call SYG_rndPointInRad;
	_pos set [2, 0];
	[ _pos, _height, "Red", 400/* player distance _trg_center */] execVM "scripts\emulateFlareFired.sqf";
};

_wounded = []; // array to accumulate wounded units
_on_base_groups = []; // array of active groups on base

//player groupChat "flaresoverbase.sqf: ENTERED";

#ifdef __PRINT__
if ( isNil "d_on_base_groups" ) then {
	hint localize "flaresoverbase.sqf: d_on_base_groups is Nil";
};
#endif
waitUntil {sleep 30.0; !(isNil "d_on_base_groups")}; // wait until global variable is initiated

#ifdef __PRINT__
_delay = START_DELAY + random (START_DELAY/10);
//player groupChat format["flaresoverbase.sqf:  d_on_base_groups %1, start delay %2 secs", d_on_base_groups, ROUND0(_delay)];
hint localize format["flaresoverbase.sqf:  d_on_base_groups %1, start delay %2 secs", d_on_base_groups, ROUND0(_delay)];
#else
_delay = START_DELAY + random 1200;
#endif	

sleep _delay;
#ifdef __DEBUG__
//player groupChat "flaresoverbase.sqf: awakened";
//hint localize  "flaresoverbase.sqf: awakened";
_first_time = true;
#endif

_flare_launched   = false;
_wounded_found = false;

while { true } do {
#ifdef __DEBUG__
	if ( _first_time ) then {
//		player groupChat "flaresoverbase.sqf: entering main loop";
		hint localize  "flaresoverbase.sqf: entering main loop";
		_first_time = false;
	};
#endif

	if ( X_MP && ((call XPlayersNumber) == 0) ) then {
#ifdef __PRINT__
//		player groupChat "flaresoverbase.sqf: waits for player";
		hint localize  "flaresoverbase.sqf: waits for player";
#endif			
		waitUntil {sleep (random CYCLE_DELAY);(call XPlayersNumber) > 0};
#ifdef __PRINT__
//		player groupChat "flaresoverbase.sqf: player entered";
		hint localize  "flaresoverbase.sqf: player entered";
#endif			
	} else {
#ifdef __DEBUG__
//		player groupChat "flaresoverbase.sqf: player entered";
		_delay = random INTERFLARE_DELAY;
//		player groupChat format["flaresoverbase.sqf: sleep %1", _delay];
		hint localize format["flaresoverbase.sqf: sleep %1", _delay];
		sleep _delay;
#else
		sleep random INTERFLARE_DELAY;
#endif
	};
	
	// first check wounded list. If it is not empty, launch illumination
	_flare_launched = 0;
	if ( count _wounded > 0 ) then {
		for "_i" from 0 to count _wounded - 1 do {
			if (_flare_launched >= MAX_FLARE_NUMBER ) exitWith { /* Exit from flare loop */ };
			_unit = _wounded select _i;
			if ( alive _unit ) then {
				_unc = (damage _unit) >= 0.7; // TODO: lets try (!canStand _unit)
#ifdef __ACE__
				if (format["%1",_unit getVariable "ACE_unconscious"] != "<null>") then { _unc = _unit getVariable "ACE_unconscious"; };
#endif
				if ( _unc ) then {
					[ getPos _unit, 20 * (damage _unit), 150, "Red"/* "F_40mm_Red" */ ] call _illumination;
					sleep random INTERFLARE_DELAY; 
					_flare_launched = _flare_launched + 1;
				} else {
#ifdef __DEBUG__
//		player groupChat "flaresoverbase.sqf: wounded is in conscious";
		hint localize "flaresoverbase.sqf: wounded is in conscious";
#endif			
					_wounded set [_i, "RM_ME"];
				};
			} else {
				_wounded set [_i, "RM_ME"];
			};
		};
		_wounded = _wounded - ["RM_ME"];
#ifdef __PRINT__
		//player groupChat format["flaresoverbase.sqf: at check time wounded list cnt %1, flares launched %2", count _wounded, _flare_launched];
		hint localize format["flaresoverbase.sqf: at check time wounded list cnt %1, flares launched %2", count _wounded, _flare_launched];
#endif			
	} else {
#ifdef __DEBUG__
//		player groupChat "flaresoverbase.sqf: wounded list is empty, seek for more";
		hint localize "flaresoverbase.sqf: wounded list is empty, seek for more";
#endif			
	};
	
	_wounded_found = false;
	if ( _flare_launched < MAX_FLARE_NUMBER ) then { // few flares launched, check for more unconscious
		// move outer groups into internal pool for check
		_base_groups = [] + d_on_base_groups;
		if ( count _base_groups > 0 ) then {
#ifdef __DEBUG__
			hint localize    format[ "flaresoverbase.sqf: check loop on %1 groups on base", count _base_groups ];
#endif			
			for "_i" from 0 to count _base_groups - 1 do {
				_grp = argp(_base_groups,_i);
				// check group for wounded unconscious men
				if ( !isNull _grp ) then {
					if ( (typeName _grp) != "STRING" ) then { // item is not marked for remove
						if ( ({alive _x} count units _grp) > 0 ) then {
							if ( !(_grp in _on_base_groups) ) then {
								_on_base_groups = _on_base_groups + [_grp ];
							};
						};
					} else {
#ifdef __PRINT__
						//player groupChat format[ "flaresoverbase.sqf: typeName _grp %1 == ""STRING""", _i ];
						hint localize    format[ "--- flaresoverbase.sqf: typeName _grp %1 == ""STRING"" ---", _i ];
#endif				
					};
				} //if ( typeName _grp != "STRING" ) then // item is not marked for remove
				else {
				};
			}; //for "_i" from 0 to count d_on_base_groups - 1 do
		} 	// if ( count _base_groups > 0 ) then
		else {
#ifdef __DEBUG__
//					player groupChat "flaresoverbase.sqf: no groups at base";
					hint localize    "flaresoverbase.sqf: no groups at base";
#endif				
		};
		
		// check for one more wounded
		if ( count _on_base_groups > 0 ) then {
			_empty_grp = true;
			for "_i" from 0 to count _on_base_groups - 1 do {
				_grp = _on_base_groups select _i;
				if ( isNull _grp ) then {
					_on_base_groups set [_i, "RM_ME"];
				} else {
					{ // forEach units _grp;
						_unc = false;
						if ( !isNull _x ) then {
							if ( alive _x ) then {
								_empty_grp = false;
								_unc = (damage _x)  >= 0.8;
								if ( format["%1",_x getVariable "ACE_unconscious"] != "<null>" ) then { _unc = _x getVariable "ACE_unconscious"; };
							};
						};
						if ( _unc ) exitWith { // wounded man found, add it to list ans exit
							// launch flare now
							if ( ! (_x in _wounded) ) then {
								_wounded = _wounded + [ _x ];
								_wounded_found = true;
							};
						};
					} forEach units _grp;
#ifdef __PRINT__
					if ( _wounded_found ) then {
						//player groupChat format[ "flaresoverbase.sqf: group %1, new wounded found", _i ];
						hint localize    format[ "flaresoverbase.sqf: group %1, new wounded added to flare launch queue", _i ];
					};
#endif			
					sleep 0.1;
				};
			}; // for "_i" from 0 to count _on_base_groups - 1 do
			_on_base_groups = _on_base_groups - [ "RM_ME" ];
			sleep random 20;
		}; // if ( count d_on_base_groups > 0 ) then
#ifdef __DEBUG__
		if ( !_wounded_found ) then {
//			player groupChat "flaresoverbase.sqf: no new wounded found";
			hint localize    "flaresoverbase.sqf: no new wounded found";
		};
#endif			
	};
	
	if ( (_flare_launched == 0 ) && ( count _on_base_groups == 0 ) ) then {
#ifdef __DEBUG__
//		player groupChat "flaresoverbase.sqf: no groups on base, wait for more";
		hint localize    "flaresoverbase.sqf: no groups on base, wait for more";
#endif			
		sleep (random WAIT_FOR_SABOTAGE_DELAY); // wait for next group infiltrated
	}; // nothing to do, wait for a long time
}; // while {true} do

#ifdef __PRINT__
//	player groupChat "flaresoverbase.sqf: EXIT";
	hint localize    "flaresoverbase.sqf: EXIT";
#endif			
 
if true exitWith{true};
