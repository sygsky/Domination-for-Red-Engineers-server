// by Xeno, x_scripts/x_boatrespawn.sqf.
// modified by EngineerACE to work correctly
private ["_boats_a", "_i", "_one_boat", "_boat_a", "_boat", "_empty", "_disabled"];

#include "x_macros.sqf"

//#define __DEBUG__

if (!isServer) exitWith{};

#define inc(x) (x=x+1)
#define arg(x) (_this select(x))
#define argp(a,x) ((a)select(x))

#ifdef __DEBUG__
#define CHECK_DELAY 60
#else
#define CHECK_DELAY 1800 // 30 minutes interval
#endif

hint localize format["x_boatrespawn.sqf: CHECK_DELAY set to %1 seconds",CHECK_DELAY];

#define DIST_TO_BE_OUT 5
#define DIST_TO_OWN_TO_PLAYER 50

_boats_a = [];
for "_i" from 1 to 40 do { // set max counter to value more or equal max boat index. 15-AUG-2020 ther are 35 separate boats in the mission
	call compile format ["
	if (!isNil ""boat%1"") then {
		_one_boat = [boat%1, position boat%1, direction boat%1,[]];
		_boats_a set [count _boats_a, _one_boat];
	};
	",_i]
};

if ( count _boats_a == 0 ) exitWith {hint localize "x_boatrespawn.sqf: no boats detected in mission, exit"};

#define IND_BOAT 0
#define IND_POS  1
#define IND_DIR  2
#define IND_NEW_POS 3

#define GET_BOAT_DESCR(ind)  (argp(_boats_a,ind))
#define GET_BOAT(descr) (argp(descr,IND_BOAT))
#define GET_BOAT_POS(descr) (argp(descr,IND_POS))
#define GET_BOAT_DIR(descr) (argp(descr,IND_DIR))
#define GET_BOAT_NEW_POS(descr) (argp(descr,IND_NEW_POS))
#define SET_NEW_BOAT(descr,boat) (descr set[IND_BOAT,boat])
#define SET_NEW_POS(descr,pos) (descr set[IND_NEW_POS,pos])

#define IS_DESCR_CHANGED(ind) ((count argp(GET_BOAT_DESCR,IND_NEW_POS))>0)
#define IS_BOAT_CHANGED(boat_descr) ((count argp(boat_descr,IND_NEW_POS))>0)
#define IS_BOAT_EMPTY(boat) (({alive _x}count(crew boat))==0)
#define CLEAR_CHANGE(descr) (descr set [IND_NEW_POS,[]])

#ifdef __DEBUG__
sleep 60;
#else
sleep 300;
#endif

// call: _descr call _restore_boat;
_restore_boat = {
	private ["_boat","_type"];
	//_this = GET_BOAT_DESCR(_this);
	_boat  = GET_BOAT(_this);
	_type = typeOf _boat;
	deleteVehicle _boat;
	_boat = objNull;
	sleep 0.5;
	_boat = _type createVehicle [0,0,0];
	_boat setdir (GET_BOAT_DIR(_this));
	_boat setPos (GET_BOAT_POS(_this));
	SET_NEW_BOAT(_this,_boat);
	CLEAR_CHANGE(_descr);
#ifdef __DEBUG__
	hint localize format["x_boatrespawn.sqf: boat %1 restored",_boat];
#endif	
};

_player_side = if (d_own_side == "EAST") then {east} else {west};

while {true} do {
	if (X_MP) then {
		waitUntil {sleep (20.012 + random 1);(call XPlayersNumber) > 0};
	};
	__DEBUG_NET("x_boatrespawn.sqf",(call XPlayersNumber))
	
	sleep ((CHECK_DELAY/2) + (random CHECK_DELAY));
	
	// loop to check boat marked to be changed by position or state (fuel, damage)
	_change_cnt = 0;
	for "_i" from 0 to count _boats_a - 1 do {
		_descr = GET_BOAT_DESCR(_i);
		_boat  = GET_BOAT(_descr);
		
		if (IS_BOAT_CHANGED(_descr)) then {
#ifdef __DEBUG__
	hint localize format["x_boatrespawn.sqf: boat %1 (%2) is marked to restore",_boat, _i];
#endif	
			// restore or repair on place
			_change_cnt = _change_cnt + 1;
			if ( !alive _boat ) then {
				_descr call _restore_boat;
			} else { // for alive boat
				if ( IS_BOAT_EMPTY(_boat) ) then {
					_pos = position _boat; // current pos
					_old_pos = GET_BOAT_NEW_POS(_descr);
					if (([_pos, _old_pos] call SYG_distance2D) > DIST_TO_BE_OUT) then {
						// boat moved from new position, set new pos and remain boat to the next loop
						SET_NEW_POS(_descr,_pos);
					} else {// empty, alive, not moved from previous place during check period
						if ( ([_pos, GET_BOAT_POS(_descr)] call SYG_distance2D) < DIST_TO_BE_OUT) then {
							// as boat is near birth place, simply restore fuel and damage
							_boat setFuel 1;
							_boat setDamage 0;
							CLEAR_CHANGE(_descr);
						} else {
							// check players near boat
							_man_arr = _pos nearObjects ["CAManBase", DIST_TO_OWN_TO_PLAYER];
							_is_owned = false;
#ifdef __DEBUG__
							_vec = objNull;
#endif
							{
								if ((side _x) == _player_side) exitWith {
									_is_owned = true;
#ifdef __DEBUG__
									_vec = _x;
#endif
								};
							} forEach _man_arr;
							
							if (! _is_owned) then {
								_descr call _restore_boat;
								_cnt = _cnt + 1;
							}
#ifdef __DEBUG__
							else {
								hint localize format["x_boatrespawn.sqf: boat %1 is near %2 vehicle, restore skipped", _boat, typeOf _vec];
							}
#endif
							;
						}
					};
				};
			};
		} else {// if (IS_BOAT_CHANGED(_descr)) then
			// boat was not changed at last loop, check it at this one
			if ( (!alive _boat) OR ((getDammage _boat) > 0.9)) then {
#ifdef	__DEBUG__
				hint localize format["x_boatrespawn.sqf: boat %1 (#%2) is dead, marked for restore", _boat,_i];
#endif
				SET_NEW_POS(_descr,getPos _boat);
			} else {
				_new_pos = position _boat;
				if ( IS_BOAT_EMPTY(_boat) && (([_new_pos, GET_BOAT_POS(_descr)] call SYG_distance2D) > DIST_TO_BE_OUT)) then {
#ifdef	__DEBUG__
				hint localize format["x_boatrespawn.sqf: boat %1 (%2) changed its position, marked for restore", _boat,_i];
#endif
				SET_NEW_POS(_descr,_new_pos);
				};
			};
		};
	}; // for "_i" from 0 to count _boats_a do
#ifdef	__DEBUG__
	hint localize format["x_boatrespawn.sqf: time %3. Boats changed %2 from %1", count _boats_a, _change_cnt, floor(time)];
#endif
}; // while {true} do 