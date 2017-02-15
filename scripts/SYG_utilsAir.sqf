/**
 *
 * SYG_utilsAir.sqf
 *
 */
 
#include "x_macros.sqf"

#define inc(x) (x=x+1)
#define arg(x) (_this select (x))
#define argopt(num,val) (if ( count _this <= (num) ) then {val} else { arg(num) })
#define argoptskip(num,defval,skipval) (if ( count _this <= (num) ) then { defval } else { if (arg(num) == (skipval)) then {defval} else {arg(num)} })

#define _MAX_CNT 

 _grpIsEmpty = {
	( { !isNull _x AND canMove _x} count (units _this)) == 0;
 };
 
 _grpIsNotEmpty = { 
	!(_this call _grpIsEmpty)
};

/**
 * Let group find and steal empty heli
 *
 * returns true is heli is stealed and removed from game, false if it is not possible to steal any helicopter in designated range
 */
SYG_repairVehicle = {

#define _VEHICLE_IS_USABLE(x) ((!isNull x) AND (alive x) AND ((count crew x) == 0))

#define _GRP_IS_EMPTY (({ !isNull _x AND canMove _x} count (units _grp)) == 0)
 
#define _GRP_NOT_EMPTY (({ !isNull _x AND canMove _x} count (units _grp)) > 0)

#define _CAN_MOVE(x) ((!isNull x) AND (canMove x))

	_grp = arg(0);
	_dist = arg(1);
	_veh_list = arg(2);
	_search_types =  argoptskip(3, ["Helicopter","Plane"],[]); // optional but defult always used
	_fail_plan = toUpper(agroptskip(4,"JOIN_ANY_GROUP","")); // or "DEFEND_NEAREST_BUILDING", optional
	_final_plan = toUpper(agroptskip(5,"ESCAPE","")); // "FIGHT"
	_escape_wp = agropt(6,[]); // waypoint[s] for escape plan, optional 
	_units = []; // array of unwanted units
	// 0.1 set optimal group behaviour (stealth etc)
	while { _GRP_NOT_EMPTY } do
	{
		// 1. Find all nearest landed heli big enough to fit crew
		_empty_vehicles = nearestObjects [leader _grp, _search_types, _dist];
			// 1.1. find suitable one
		_vehicle = objNull;
		{
			if ( _VEHICLE_IS_USABLE(_x) AND _x in _veh_list) exitWith {_vehicle = _x} ;
		} forEach _empty_vehicles;
		
		if ( _VEHICLE_IS_USABLE(_vehicle)) then { // empty heli is found
			_dist2heli = leader _grp distance _vehicle;
			_max_cnt = ceil _dist2heli;
			// 2. Try to repair item
			// 2.0 come to the heli 
			(units _grp) doMove (getPos _vehicle);
			_cnt = 0;
			_last_pos = getPos (leader _grp);
			while { _VEHICLE_IS_USABLE(_vehicle) AND _GRP_NOT_EMPTY AND (((position leader _grp) distance _vehicle) > 10) AND (_cnt < _max_cnt) } do
			{
				sleep 1;
				inc(_cnt);
			};
			if ( _VEHICLE_IS_USABLE(_vehicle) AND _GRP_NOT_EMPTY AND _cnt < _max_cnt ) then {
				while {_GRP_NOT_EMPTY} do {
					// 2.1 select pilot to repair, preferrably not to be leader
					_engineer = leader _grp;
					{ 
						if (_x != _engineer AND _CAN_MOVE(_x)) exitWith { _engineer = _x; };
					} forEach units _grp;
					
					// 2.2 get in to animate operation for observing players
					_unit2 assignAsGunner _vehicle;_unit2 moveInGunner _vehicle;
					_engineer assignAsDriver _vehicle;_engineer moveInDriver _vehicle;
					waitUntil { sleep 0.05; (!_CAN_MOVE(_engineer)) OR (!(_VEHICLE_IS_USABLE(_vehicle))) OR (driver _vehicle ==_engineer) };
					if ( driver _vehicle == _engineer ) then { _engineer action["eject", _vehicle]; };
					sleep 0.3;
					// 2.3 animate repairing
					_engineer playMove "AinvPknlMstpSlayWrflDnon_medic";
					sleep 3.0;
					waitUntil {animationState _engineer != "AinvPknlMstpSlayWrflDnon_medic"};
					_vehicle setDammage 0;
					_vehicle setFuel 1.0;
					if ( _GRP_NOT_EMPTY AND _VEHICLE_IS_USABLE(_vehicle)) then {
						// 2.4 load group into heli
						_units = units _grp;
						_leader = leader _grp;
						_units = _units - [_leader];
						_leader assignAsDriver _vehicle; _leader moveInDriver _vehicle;
						_filledCnt = 0;
						for "_i" from 0 to ((count _units)- 1) do
						{
							_unit = _units select _i;
							if _CAN_MOVE(_unit) then {
								switch _filledCnt  do
								{
									case 0: {
										if ( _vehicle emptyPositions "Commander"  > 0 ) then {
											_unit assignAsCommander _vehicle; _unit moveInCommander _vehicle;
											_units set [_i, "RM_ME" ];
											inc(_filledCnt);
											sleep 0.03;
										};
									};
									case 1: {
										if ( _vehicle emptyPositions "Gunner"  > 0 ) then {
											_unit assignAsGunner _vehicle; _unit moveInGunner _vehicle;
											_units set [_i, "RM_ME" ];
											inc(_filledCnt);
											sleep 0.03;
										};
									};
									default { 
										if ( _vehicle emptyPositions "Cargo"  > 0 ) then {
											_unit assignAsCargo _vehicle; _unit moveInCargo _vehicle;
											_units set [_i, "RM_ME" ];
											inc(_filledCnt);
											sleep 0.03;
										};
									};
								};
							};
						}; // for "_i" from 0 to ((count _units)- 1) do
						_units = _units - [ "RM_ME" ];
						// 3. Try to steal heli and draw to the ocean, kill any crew member not fit into new heli
						if ( _vehicle isKindOf "Air" ) then { _vehicle flyInHeight (190 + random 20);	};
						_vehicle setSpeedMode "FULL";
						_grp doMove 
					};
				}; //while {_GRP_NOT_EMPTY} do
			}; //if ( _VEHICLE_IS_USABLE(_vehicle) AND _GRP_NOT_EMPTY AND _cnt < _max_cnt) then
		} //if ( _VEHICLE_IS_USABLE(_vehicle)) then
		else { // no empty heli found, lets simply join crew to the nearest frendly group (or order to defence near building)
			// find group
			// join crew to group or 
			// kill whole crew if no group found
		};
	}; //	while { _GRP_NOT_EMPTY } do
	
	// forEach units _grp;
	{
		if (!isNull _x ) then {
			_x setDammage 1.1;
			[_x] call XAddDead;
		};
	} forEach _units;
};