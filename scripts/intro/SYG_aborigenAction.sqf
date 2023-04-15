/*
	scripts\intro\SYG_aborigenAction.sqf
	author: Sygsky
	description:
		Parameters array passed to the script upon activation in _this variable is: [target, caller, ID, arguments]
		target (_this select 0): Object - the object which the action is assigned to
		caller (_this select 1): Object - the unit that activated the action
		ID (_this select 2): Number - ID of the activated action (same as ID returned by addAction)
		arguments (_this select 3): Anything - arguments given to the script if you are using the extended syntax
									may be "BOAT", "CAR", "WEAPON", "MEN", "RUMORS"
	returns: nothing
*/

#include "x_setup.sqf"

if (typeName _this != "ARRAY") exitWith {hint localize format["--- SYG_aborigenAction.sqf: unknown _this = %1", _this]};

if (!alive aborigen) exitWith {localize "STR_ABORIGEN_KILLED"}; // "Dead Aborigen... what bastard killed our informant?"
// create point in the water near Antigus
_create_water_point_near_Antigua = {
	private ["_lines","_sum","_cnt","_rnd","_len","_pos","_i","_p1","_p2","_x"];
	_lines = [
		[[17092,18177],[17255,18131],[17215,18047],[17093,17698]],	// line1
		[[17154,17661],[17355,17819],[17447,17827]],				// line2
		[[17795,17796],[17789,17881],[17845,17855],[17959,17715]]	// line3
	];

	_sum = 0; // common length of all lines
	{
		_cnt = count _x; // point count
		for "_i" from 1 to (_cnt - 1) do {
			_sum = _sum + ( (_x select (_i-1)) distance (_x select _i) );
		};
	} forEach _lines;
	_rnd  = random _sum;
	_len = 0;
	_pos = [];
	{

		_cnt = count _x;
		for "_i" from 1 to (_cnt - 1) do {
			_len = _len + ( (_x select (_i-1)) distance (_x select _i) );
			if (_len >= _rnd) exitWith { // line segment with point found
				_size = _rnd - _len;
				hint localize format["+++ boat moved to the Antigua: line len %1, rnd %2, line %3, vertex %4", _sum, _rnd, _i, _size ];
				_p1   = _x select (_i - 1);
				_p2   = _x select _i;
				_pos  = [_p1, _p2, _size] call SYG_elongate2;
			};
		};
		if ((count _pos) > 0) exitWith{};
	} forEach _lines;
	_pos
};
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+                       START HERE                          +
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
_arg = toUpper(_this select 3);
_isle = SYG_SahraniIsletCircles select 3; // Antigua enveloped circle descr
_isle_pos = _isle select 1; // isle center
_rad = _isle select 2;

// Rotate aborigen to player, try server command
if ( !(_arg in ["GO"])) then {
	aborigen doWatch player;
	if (!local aborigen) then {
		["remote_execute", format ["aborigen setDir %1;", ([aborigen, player] call XfDirToObj)]] call XSendNetStartScriptServer;
	} else { aborigen setDir ([aborigen, player] call XfDirToObj) };
};

//hint localize format["+++ ABORIGEN STAT: aborigen locality %1", local (_this select 0)];
switch ( _arg ) do {

	//++++++++++++++++++++++++++++++++++++++++++++++++++++
	case "BOAT": { // ask about boats
		if (base_visit_mission > 0) exitWith {player groupChat (localize "STR_ABORIGEN_BOAT_INFO_0")}; // "Boats? There are a lot of them... on every kilometer of the coast of the Main Sahrani."
		// find distance to the boat type "Zodiac" ( small boats )
		_boat = objNull;
		_arr = nearestObjects [_isle_pos, ["Zodiac"], _rad];
		// Check nearest boats to be out of "boats13" marker
		_pos = markerPos "boats13";
		_marker = "";  // It will be marker of selected boat
		{
			if (alive _x) then {
				if ( ( _x distance _pos ) > 50 ) then {
					_boat = _x;
					hint localize format["+++ Boat: found at Antigua, pos %1", getPos _x];
				};
			};
			if (alive _boat) exitWith {};
		} forEach _arr;

		if (!alive _boat) then { // Find a boat from a group of more than 1 boats, near any of the boats markers
			_marker_arr = [];
			_exit = false;
			for "_i" from 1 to 100 do {
				if (_i != 13) then { // skip boats on Antigua from calculations
					_marker = format["boats%1", _i];
					if ( (markerType _marker) == "") exitWith {_exit = true; _marker = format["boats%1",_i-1]};
					_arr = (markerPos _marker) nearObjects ["Zodiac", 50];
					if ({(alive _x) && (({alive _x} count crew _x) == 0) } count _arr > 1) exitWith {
						_marker_arr set [count _marker_arr, _marker];
					};
				};
				if (_exit) exitWith {};
			};
			sleep 0.1;
			hint localize format["+++ Boat: last existed marker %1, group cnt %2", _marker, count _arr];
			// find random alive empty boat from group of boats near any boat marker
			_marker = _marker_arr call XfRandomArrayVal;
			_arr = (markerPos _marker) nearObjects ["Zodiac", 50];
			_boat = _arr select 0;
			hint localize format["+++ Boat: found on marker %1[%2], pos %3", _marker, count _arr, (markerPos _marker) call SYG_MsgOnPosE0];
		} else {_marker = "boats13"}; // use nearest marker to get marker type

        if (!(alive _boat)) exitWith {
        	player groupChat (localize "STR_ABORIGEN_BOAT_NONE"); // "All the boats are taken apart, I don't know what to do!"
			hint localize "--- Boat: no good markered boat groups found at all, skip...";
        };

        _pnt = getPos _boat; // Not reset this value as it allows to point where boat was at this check!
        if ( (_boat distance _isle_pos) > _rad) then {
			_pnt = call _create_water_point_near_Antigua;
			_boat setDir (random 360);
			_boat setPos _pnt;
			_boat say "return";
			hint localize format["+++ Boat: moved to the point near Antigua %1 !", getPos _boat];
        };
		player groupChat format[localize "STR_ABORIGEN_BOAT_INFO", // "The nearest boat (%1) is %2 m away direction %3"
			typeOf _boat,
			(round((player distance _boat)/10)) * 10,
			([player, _boat] call XfDirToObj) call SYG_getDirName
		];
        // Set marker for the detected boat
		_boat_marker_type =  getMarkerType _marker; // mission boat marker, use it for antigua
		_marker = "aborigen_boat";	// Antigua boat marker name (not type)
		if ( (getMarkerType _marker) == "" ) then { // Antigua boat marker is absent, create it now
			_marker = createMarkerLocal[_marker, getPosASL _boat];
			_marker setMarkerTypeLocal _boat_marker_type;
			_marker setMarkerColorLocal "ColorGreen";
			_marker setMarkerSizeLocal [0.7,0.7];
			hint localize format["+++ Boat: new marker created %1", _boat_marker_type];
		} else {
			hint localize format["+++ Boat: existed marker %1 found near Antigua", _boat_marker_type];
		};
		hint localize format["+++ Boat: marker %1(type %2) set to the point near Antigua %3", _marker, _boat_marker_type, (getPos _boat) call SYG_MsgOnPosE0];
		_marker setMarkerPosLocal (getPosASL _boat);

		if (isNil "BOAT_MARKER_CHECK_ON") then {
			BOAT_MARKER_CHECK_ON = true;
			hint localize "+++ BOAT: run BOAT_MARKER_CHECK_ON run first time.";
			// move marker with boat and remove it on boat kill or leaving Antigua area
			[_boat, _marker, _isle_pos, _rad] spawn {
				private ["_boat","_marker","_area_center","_area_rad","_boat_pos","_delay","_dist","_do_it"];
				_boat  = _this select 0; _marker = _this select 1; _area_center = _this select 2; _area_rad = _this select 3;
				_boat_pos  = getPosASL _boat;
				_marker setMarkerPosLocal _boat_pos;
				_delay = 10;
				_do_it = true;
				while { (alive _boat) && _do_it } do {
					sleep _delay;
					_dist = [_boat, _boat_pos] call SYG_distance2D;
					if ( _dist > 25 ) then {
						_boat_pos = getPosASL _boat;
						_marker setMarkerPosLocal _boat_pos;
						if ( !([_boat, _area_center, _area_rad] call SYG_pointInCircle) ) exitWith {
							// Information about going out of bounds
							playSound (["fish_man_song","under_water_2"] call XfRandomArrayVal); // sound about leaving Antigua
							player groupChat localize "STR_ABORIGEN_BOAT_DISTOUT"; // "You are leaving Antigua territorial waters"
							_do_it = false;
						};
					};
					if ( _dist < 2.5 ) then { _delay = 10 } else { _delay = ((25 / _dist) max 3) min 10; };
				};
				deleteMarkerLocal _marker; // remove boat marker if dead or out of aquatory
				BOAT_MARKER_CHECK_ON = nil;
				hint localize "+++ BOAT: run BOAT_MARKER_CHECK_ON stopped for next time...";
			};
		} else { hint localize "+++ BOAT: BOAT_MARKER_CHECK_ON already run, not start it again."};

	};

	//++++++++++++++++++++++++++++++++++++++++++++++++++++
	case "CAR": { // ask about boats
		if (base_visit_mission > 0) exitWith {player groupChat (localize ("STR_ABORIGEN_CAR_NONE_NUM" call SYG_getRandomText))}; // "Sorry. I don't know anything about cars. We live here."}; // "Boats? There are a lot of them... on every kilometer of the coast of the Main Sahrani."

//		player groupChat format[localize "STR_ABORIGEN_CAR_NONE"]; // "Sorry. I don't know anything about cars. We live here."
//		if (true) exitWith{};

		private ["_veh", "_marker_veh"];
		
		// find best vehicle to mark it for this player
		_veh = objNull;
		_marker = "antigua_veh_marker"; // Well known marker name
		if ( (markerType _marker) != "") then {
			// TODO: print info on marker
			_veh = nearestObject [getMarkerPos _marker, "Motorcycle"];
			if (alive _veh) then {
				_veh setDamage 0;
				hint localize format["+++ Aborigen: car (%1) found near car marker", typeOf _veh];
			};
		};
		if (alive _veh) exitWith { // Veh found near marker, say info outrageously
		    player groupChat (localize "STR_ABORIGEN_CAR_INFO_1"); // "A car? Why did I put a marker on your map? Uh, you have geographical cretinism)))"
		    if ( locked _veh ) then {
		        (localize "STR_ABORIGEN_CAR_UNLOCK_1") spawn {player groupChat _this}; "... when you find it, unblock it!"
		    } else {
		        (localize "STR_ABORIGEN_CAR_UNLOCK_3") spawn {player groupChat _this}; // "... it doesn't seem to be blocked"
		    };
		};

		// Vehicle not found near main marker or marker in absent. So find all vehicles near transparent markers now and select random one
		_arr = [];
		for "_i" from 1 to 100 do {
			_marker_veh = format["antigua_veh%1",_i];
			if (markerType _marker_veh == "") exitWith {/* hint localize format ["+++ ABORIGEN CAR: stop moto count on id %1", _i]*/}; // no more markers in sqm
			_obj = nearestObject [getMarkerPos _marker_veh, "Motorcycle"];
			if (alive _obj) then { // add found vehicle to the found list
				_arr set [count _arr, _obj];
				_obj setDamage 0;
			} else { hint localize format ["+++ ABORIGEN CAR: moto id %1 not found at marker", _i] };
		};

		hint localize format["+++ ABORIGEN CAR: found %1 vehs at markers", count _arr];
		if ( (count _arr) > 0) exitWith {
			_veh = _arr call XfRandomArrayVal;
			if ( (markerType _marker) == "") then { // Create new marker at found vehicle place
				_marker = createMarkerLocal[_marker, getPos _veh];
				#ifdef __ACE__
				_marker setMarkerTypeLocal "ACE_Icon_Motorbike";
				#else
				_marker setMarkerTypeLocal  "Vehicle";
				#endif
				_marker setMarkerColorLocal "ColorGreen";
			} else {
				_marker setMarkerPosLocal (getPos _veh);
			};
			player groupChat format[localize "STR_ABORIGEN_CAR_INFO_2", _veh call SYG_nearestLocationName]; // "The car? So... here I'm drawing you a green marker on the map where there's something similar. It's about %1."
			if (locked _veh) then {
//			    _veh lock true;
//			    _veh addAction [localize "STR_ABORIGEN_CAR_UNLOCK","scripts\intro\unlock_veh.sqf"]; // "Unlock"
			};
		    [] spawn {sleep 5; player groupChat (localize "STR_ABORIGEN_CAR_UNLOCK_1")}; // "When you find it, unblock it!"
		};
		// remove main marker as nothing to mark with it
		deleteMarkerLocal _marker;
		// Inform about failure to find vehicle on place
		player groupChat (localize ("STR_ABORIGEN_CAR_NONE_NUM" call SYG_getRandomText)); // "Sorry. I don't know anything about cars. We live here."
	};

	//++++++++++++++++++++++++++++++++++++++++++++++++++++
	case "WEAPON": { // ask about weapon box

//		_arr = nearestObjects [ player, ["WeaponHolder","AmmoBoxWest","WeaponBoxWest","SpecialBoxWest","AmmoBoxEast","WeaponBoxEast","SpecialBoxEast","AmmoBoxGuer"], 2000 ];
		_arr = nearestObjects [ player, ["ReammoBox"], 2500 ];
		if ( (count _arr) == 0) exitWith {
			[player, (localize "STR_ABORIGEN_WEAPON_NONE")] call XfGroupChat; // "Looks like there aren't any guns here, hehe"
		};
		_txt = format[ localize "STR_ABORIGEN_WEAPON_INFO", // I saw some kind of weapon at %1 m towards %2%3
               				(round (([player,_arr select 0] call SYG_distance2D) / 10)) * 10,
               				([player, _arr select 0] call XfDirToObj) call SYG_getDirName,
               				if ((_arr select 0) isKindOf "WeaponHolder") then {localize "STR_ABORIGEN_WEAPON_INFO_HOLDER"} else {localize "STR_ABORIGEN_WEAPON_INFO_BOX"}];

               				hint localize format["+++ WEAPON: %1", _txt];
		player groupChat _txt; // "I saw some kind of weapon at %1 m towards %2%3"
	};

	//++++++++++++++++++++++++++++++++++++++++++++++++++++
	case "MEN": { // ask about men
		_arr = _isle_pos nearObjects ["CAManBase", _rad];
		_civcnt = 0; _eastcnt = 0; _westcnt = 0; _dead = 0; _other = 0;
		{

			if (! alive _x) then {_dead = _dead + 1} else {
				if (side _x == west) exitWith {_westcnt = _westcnt + 1};
				if (side _x == east) exitWith {_eastcnt = _eastcnt + 1};
				if (side _x == civilian) exitWith {_civcnt = _civcnt + 1};
				_other = _other + 1;
			};
		} forEach _arr;
		if  ( (_civcnt + _westcnt + _eastcnt + _other) == 2) then {
			player groupChat (localize format["STR_ABORIGEN_MEN_NONE", if (_dead > 0) then { localize format["STR_ABORIGEN_MEN_DEAD", _dead ] } else { ""}]);
		} else   {
			player groupChat (format[localize "STR_ABORIGEN_MEN_INFO",
				_civcnt, _westcnt,
				_eastcnt, _other, _dead ]); // "There are some people! Our %1, the Americans %2, Soviets %3, unknown %4. So what?"
			};
	};
	//++++++++++++++++++++++++++++++++++++++++++++++++++++
	case "RUMORS": { // ask about rumors
		[] execVM "scripts\rumours.sqf";
	};
	case "GO" : {
		hint localize "+++ Aborigen GO!!!";
		player groupChat (localize "STR_SYS_400_1"); // "Yes"
		aborigen say "hisp3"; // "Bolo" ?
		if (local aborigen) then {
			player execVM "scripts\intro\follow.sqf";
		} else {
			["remote_execute", format ["%1 execVM ""scripts\intro\follow.sqf""", str(player)]] call XSendNetStartScriptServer;
//			["remote_execute", format ["aborigen doWatch %1;", str(player)]] call XSendNetStartScriptServer;
		};
	};
	case "NAME": {
		_name = name aborigen;
		if (_name in [ "Error: No unit", "" ]) then { _name = localize "STR_ABORIGEN_NAME_UNKNOWN"; }; // "doesn't matter"
		player groupChat format[localize "STR_ABORIGEN_NAME_1", _name]; // "My name %1. What's yours?"
	};
	default {
		format[localize "STR_ABORIGEN_UNKNOWN", _arg] call XfGroupChat;
		playSound "losing_patience";
	};
};
sleep 10;
aborigen doWatch objNull;

