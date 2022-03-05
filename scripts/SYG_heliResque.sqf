/**
 *
 * SYG_heliResque.sqf 
 *
 * 10-JUL-2015
 *
 * script handles with showdown helis spread along Sahrani islands during action of Xeno's Domination flow
 *
 * Still not finished
 *
 */
 
#include "x_macros.sqf"

#define __DEBUG__

#define ADD_TO_DEAD_LIST(a) (if(!((a)in _heli_dead_list))then{_heli_dead_list=_heli_dead_list+(a)})
#define ADD_TO_DOWN_LIST(a) (if(!((a)in _heli_down_list))then{_heli_down_list=_heli_down_list+(a)})
#define inc(x) (x=x+1)
#define arg(x) (_this select(x))
#define argopt(num,val) (if((count _this)<= (num))then{val}else{arg(num)})
#define argoptskip(num,defval,skipval) (if((count _this)<=(num))then{defval}else{if(arg(num)==(skipval))then{defval}else{arg(num)}})

if ( !isNil "SYG_HELI_RESQUE_STARTED" ) exitWith {hint "SYG_heliResque.sqf: acript alreay started!!!"};

// start the script as a singleton
SYG_HELI_RESQUE_STARTED = true;

_WRECK_LIST = ["Land_MAP_AH64_Wreck","BlackhawkWreck"];

#define SEARCH_PILOT_DISTANCE 4000

_heli_down_list = []; // downed but alive heli not at the base list
_heli_dead_list = []; // dead heli at the base list 

pilots_in_action = [];

// first let go to the night period in any case
_sleep_delay = (24 - (SYG_startNight + SYG_startMorning) + 0.5) * 3600.0; // how long is whole day at Sahrani

#ifndef __DEFAULT__

//+++ Sygsky: Paraiso airfield coordinates and its boundary rectangle box (semi-axis sizes)
d_base_array        = [[9821.47,9971.04,0], 600, 200, 0];
SYG_startNight = 19.75;
SYG_startMorning   = 4.6;

d_pilot_W = "ACE_SoldierWPilot_WDL";
X_MP = true;
XPlayersNumber = { sleep 1.5; floor (random 2) }; // from 0 to 1

#endif

_hijackHeli = {
	private ["_grp","_pos","_heli"];
	_grp  = arg(0);
	if ( {canMove _x} count _grp == 0 ) exitWith {/* No men for hijacking */};
	_pos  = arg(1);
	_heli = arg(2);
	sleep (10 + random 10);
	// create new group for pilots
	// TODO: remove heli and robbering pilots from the game
};

_time_to_wakeUp = SYG_startNight + 0.05;
 
while {true} do
{
	if ( (daytime < _time_to_wakeUp) &&  (daytime > SYG_startMorning) ) then
	{
		sleep (_time_to_wakeUp - daytime); // wake up at the night beginning
	};
	// process previously prepared down list
	if ( (count _heli_down_list) > 0 ) then // play with lists of downed heli collected from last time (one full day e.g.)
	{
#ifdef __DEBUG__
	hint localize format["%1 SYG_heliresque.sqf: processing %2 downed heli", call SYG_missionTimeInfoStr, count _heli_down_list];
#endif	
		for "_i" from 0 to count _heli_down_list - 1 do
		{
			if (daytime > SYG_startNight) &&  (daytime > SYG_startNight) exitWith {}; // end of night cycle
			scopeName "main_loop";
			for "_temp" from 0 to 0 do
			{
				_heli = _heli_down_list select _i;
				if ( isNull _heli OR (!(_heli isKindOf "Air" )) ) exitWith { _heli_down_list set [_i, "RM_ME"]; };

				_pos = getPos _heli;
				if ( (!alive _heli) OR (_heli in _WRECK_LIST)) exitWith // remove it if in boundaries of airbase only
				{
					if ( [_pos,d_base_array] call SYG_pointInRect ) then // remove in any case if on base
					{
						ADD_TO_DEAD_LIST(_heli); //if  ! (_heli in _heli_dead_list) then {_heli_dead_list = _heli_dead_list + [_heli];};
					};
					_heli_down_list set [_i, "RM_ME"];
					breakTo "main_loop";
				};
				//================================
				//= We are here if heli is alive =
				//================================
				// 1. Find alive pilots nearby: withing 3-5 km and on the same island part
				_cnt = if ( _x isKindof "AH1W" || _x isKindOf "UH60MG" || _x isKindOf "ACE_AH64_AGM_HE" ) then {2} else {1};
				if ( !(_heli isKindOf "Plane") ) then // planes still not supported
				{
					sleep 0.5;
					_pilots    = nearestObjects [ _pos, "SoldierWPilot" , SEARCH_PILOT_DISTANCE];
					_cnt       = count _pilots min _cnt; // how many pilot to send for hijacking
					_hj_pilots = [];
					if ( count _pilots ) > 0 then
					{
						{
							if ( count _hj_pilots >= _cnt ) exitWith {}; // enough pilots are selected
							if ( (!isNull _x) AND (canMove _x) AND (!(_x in pilots_in_action))  ) then
							{
								_hj_pilots = _hj_pilots + [_x];
								pilots_in_action = pilots_in_action + [_x];
							};
						} forEach _pilots;
				
						if ( count _hj_pilots > 0) then 
						{
							_pos = getPos _heli;
							// 2.1. check if players are on map
							if (X_MP AND ((call XPlayersNumber) > 0)) then
							{
								if ( count _hj_pilots > 0 ) then // there is at least one pilot nerby this heli
								{
									sleep random 3.0;
									// 2. send pilots to heli
									// 3. hijack heli to the ocean
									[_hj_pilots, _pos, _heli] spawn _hijackHeli;
								};
							}
							else // no players, so steal heli silently with pre-selected pilots too
							{
								deleteVehicle _heli;
								sleep 1.0;
								pilots_in_action = pilots_in_action - _hj_pilots;
								{ deleteVehicle _x; sleep 1.0;} forEach _hj_pilots;
								// set roadcone at the steal place
								createVehicle ["RoadCone", _pos, [], 0, "CAN_COLLIDE"]; // let it be monument to this robbery
							};
						};
					}; //if ( count _pilots ) > 0 then
				}; // if ( !(_heli isKindOf "Plane") ) then
				
			}; // for "_temp" from 0 to 0 do
			sleep 10.0;
		}; //for "_i" from 0 to count _heli_down_list - 1 do
		
	}; //if ( count _heli_down_list > 0 )
	_heli_down_list = _heli_down_list - ["RM_ME"];
	
	if ( count _heli_dead_list > 0 ) then
	{
#ifdef __DEBUG__
	hint localize format["%1 SYG_heliresque.sqf: deleting %2 dead heli on airbase", call SYG_missionTimeInfoStr, count _heli_down_list];
#endif	
		{
			deleteVehicle _x;
			sleep 1 + (random 5);
		} forEach _heli_dead_list;
		_heli_dead_list = [];
	};
	
	// collect new downed or dead vehicles into internal lists
	_temp = + s_down_heli_arr;
	s_down_heli_arr = [];
	{
		// put any heli not dead and out of eastern base to the list of future hijacking
		if ( (alive _x) AND ((count crew _x) == 0) AND (!(_x call SYG_pointIsOnBase) ) then {
#ifdef __DEBUG__
	hint localize format["%1 SYG_heliresque.sqf: put %2 near %3 to down list", call SYG_missionTimeInfoStr, typeOf _x, (getPos _x) call SYG_nearestSettlement];
#endif	
			ADD_TO_DOWN_LIST(_x)/* _heli_down_list = _heli_down_list + [_x] */ 
		};
	}forEach _temp;
	
	// find any non-restorable heli wrecks on the air-base
	// search all non-alive heli at the airbase territory
	_pos = argp(d_base_array,0); // center of rectangle
	// calc radious for whole area
	_w = argp(d_base_array,1);
	_h = argp(d_base_array,2);
	_hipo = sqrt(_w*_w + _h*_h);
	_helis = nearestObjects [_pos, ["Air"] + _WRECK_LIST, _hipo];
	{
		// filter for only western helis of Domination
		if (
			((_x in _WRECK_LIST )		
			OR
			( 
			 (!alive _x)
              AND
             (_x isKindof "AV8B" OR _x isKindof "A10" OR _x isKindOf "AH6" OR _x isKindof "AH1W" OR _x isKindOf "UH60MG" OR _x isKindOf "ACE_AH64_AGM_HE")
			))
			AND (_x call SYG_pointIsOnBase)
			//AND  (!(_x in _heli_dead_list))
		   )
		then
		{
#ifdef __DEBUG__
	hint localize format["%1 SYG_heliresque.sqf: put dead %2 at base to the dead list", call SYG_missionTimeInfoStr, typeOf _x];
#endif	
			ADD_TO_DEAD_LIST(_x); //_heli_dead_list = _heli_dead_list + [_x]; // bye up to for the next day wake-up of this procedure
		};
	} forEach _helis;
	
//	sleep (82800 + random 5400); // average day duration
};

if (true) exitWith {};