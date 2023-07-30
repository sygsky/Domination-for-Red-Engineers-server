/*
	scripts\intro\SYG_aborigenAction.sqf: on clent computer only
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

#define POS_BICYCLE [17401,17980,0]
#define ABO_BOAT_MARKER "aborigen_boat"
#define __DEBUG__

#include "camel_setup.sqf"

#include "x_setup.sqf"

_search_list = ["Motorcycle","hilux1_civil_1_open","LandroverMG","SkodaBase","ACE_UAZ"/*,"DATSUN_PK1","HILUX_PK1"*/,"ACE_HMMWV","tractor"];
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
				_p1   = _x select (_i - 1);
				_p2   = _x select _i;
				_pos  = [_p1, _p2, _size] call SYG_elongate2;
				hint localize format["+++ BOAT: create pnt near Antigua - line len %1, rnd %2, line %3, vertex %4, pos %5", _sum, _rnd, _i, _size, _pos ];
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

_abo_dir = getDir aborigen;
if (isNil "_abo_dir") then {_abo_dir = 0};
// Rotate aborigen to player, try server command
if ( !(_arg in ["GO"])) then {
	aborigen doWatch player;
	_dir = [aborigen, player] call XfDirToObj; // wanted direction of aborigen view to the player
	if ((abs(_dir - _abo_dir)) > 2) then { // change direction only if needed
		if (!local aborigen) then {
			["remote_execute", format ["aborigen setDir %1;", _dir]] call XSendNetStartScriptServer;
		} else { aborigen setDir _dir };
		aborigen setVariable ["ABO_DIR", _dir];
	};
};
aborigen say (["surprize","disagreement","disagreement_tongue","horks_and_spits"] call XfRandomArrayVal);

//hint localize format["+++ ABORIGEN STAT: aborigen locality %1", local (_this select 0)];
switch ( _arg ) do {

	//++++++++++++++++++++++++++++++++++++++++++++++++++++
	//                    B O A T
	//++++++++++++++++++++++++++++++++++++++++++++++++++++
	case "BOAT": { // ask about boats
		if (base_visit_mission > 0) exitWith {player groupChat (localize "STR_ABORIGEN_BOAT_INFO_0")}; // "Boats? There are a lot of them... on every kilometer of the coast of the Main Sahrani."

		//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		// find distance to the boat type "Zodiac" ( small boats )
		//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		_boat = objNull;
		_arr = nearestObjects [ _isle_pos, ["Zodiac"], _rad ];
		// Check nearest boats to be out of "boats13" marker
		_pos13 = markerPos "boats13";

/**
#ifdef __DEBUG__
		_arr1 = _pos13 nearObjects [ "Zodiac", 150 ];
		for "_i" from 0 to ( (count _arr1) -1 ) do {
			_arr1 set [ _i, str (_arr1 select _i) ];
		};
		hint localize format[ "+++ Boat: found at Antigua on marker ""boats13"" follow boats %1", _arr1 ];
#endif
*/
		_marker = "";  // It will be marker of selected boat
		{
			if (alive _x) then {
				if ( ( _x distance _pos13 ) > 100 ) exitWith {
					_boat = _x;
					hint localize format["+++ Boat: free one found at Antigua, dist to marker ""boats13"" = %1 m.", round(_x distance _pos13)];
				};
			};
			if (alive _boat) exitWith {};
		} forEach _arr;

		//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		// Search boat on boat markers, last one will be Antigua's "boats13"
		//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		if ( !alive _boat ) then { // Assign boat among boat markers groups containing  more than 1 boat
			_marker_arr = [];
			_exit = false;
			for "_i" from 1 to 100 do {
				if (_i != 13) then { // skip boats on Antigua from calculations
					_marker = format["boats%1", _i];
					if ( (markerType _marker) == "" ) exitWith {}; // try last one
					_arr = (markerPos _marker) nearObjects ["Zodiac", 50];
					if ({(alive _x) && (({alive _x} count crew _x) == 0) } count _arr > 1) exitWith {
						_marker_arr set [count _marker_arr, _marker];
					};
				};
				if ( (markerType _marker) == "" ) exitWith {}; // No more boat markers found
			};
			sleep 0.1;
			hint localize format["+++ Boat: last used marker %1, group cnt %2", _marker, count _arr];
			// find random alive empty boat from group of boats near any boat marker
			_marker = _marker_arr call XfRandomArrayVal;
			_arr = (markerPos _marker) nearObjects ["Zodiac", 50];
			_boat = _arr select 0;
			hint localize format["+++ Boat: found on marker %1[%2 boats], pos %3", _marker, count _arr, [(markerPos _marker),10] call SYG_MsgOnPosE0];
		} else {
			hint localize "+++ Boat: free boat found near Antigua (not boats near marker13!)";
		}; // use nearest marker on Antigua to get marker type

        if (!(alive _boat)) exitWith {
			_arr = _pos13 nearObjects [ "Zodiac", 75 ];
			{
				if ((alive _x) && (!locked _x)) exitWith { _boat = _x };
			} forEach _arr;
			if (alive _boat) exitWith {
	        	player groupChat (localize "STR_ABORIGEN_BOAT_INFO_1"); // "Boats? They're all gone all of a sudden. But look, honey, at the boat marker off Antigua."
				hint localize "+++ Boat: last boat found at Antigua, on marker ""boats13""!";
			};

        	// Time to check boats on marker "boats13" near island!
			hint localize "--- Boat: no good markered boat groups found at all, skip player request...";
        	player groupChat (localize "STR_ABORIGEN_BOAT_NONE"); // "All the boats are taken apart, I don't know what to do!"
        };

        _pnt = getPos _boat; // Not reset this value as it allows to point where boat was at this check!
        if ( (_boat distance _isle_pos) > _rad) then {
			_pnt = call _create_water_point_near_Antigua;
			_cnt = 10;
			while { (!(surfaceIsWater _pnt)) && (_cnt > 0)} do {
				_pnt = call _create_water_point_near_Antigua;
				_cnt = _cnt - 1;
			};
			_boat setDir (random 360);
			_boat setPos _pnt;
			sleep 0.1;
			_pnt = getPos _boat;
			_boat say "return";
			hint localize format[ "+++ Boat: found out of Antigua at %1, dist to dest pnt %2 m!", _boat call SYG_MsgOnPosE0, round (_pnt distance _boat) ];
        };
		player groupChat format[localize "STR_ABORIGEN_BOAT_INFO", // "The nearest boat (%1) is %2 m away direction %3"
			typeOf _boat,
			(round((player distance _boat)/10)) * 10,
			([player, _boat] call XfDirToObj) call SYG_getDirName
		];
		//++++++++++++++++++++++++++++++++++++++++++++++++++
        //       Set marker for the detected boat
        //++++++++++++++++++++++++++++++++++++++++++++++++++
		_boat_marker_type =  getMarkerType _marker; // Mission boat marker, use it for Antigua (""aborigen_boat"")
		_marker = ABO_BOAT_MARKER;	// Antigua boat marker name (not type)
		if ( (getMarkerType _marker) == "" ) then { // Antigua boat marker is absent, create it now
			_marker = createMarkerLocal[_marker, getPosASL _boat];
			_marker setMarkerTypeLocal _boat_marker_type;
			_marker setMarkerColorLocal "ColorGreen";
			_marker setMarkerSizeLocal [0.7,0.7];
			hint localize format["+++ Boat: new marker %1 created", _boat_marker_type];
		} else {
			hint localize format["+++ Boat: existed marker %1 found near Antigua", _boat_marker_type];
		};
		hint localize format["+++ Boat: marker %1(type %2) set to the point near Antigua at %3", _marker, _boat_marker_type, (getPos _boat) call SYG_MsgOnPosE0];
		_marker setMarkerPosLocal (getPosASL _boat);

		//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		//        Let's control on boat prepared for this player, or previous one
		//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		if (isNil "BOAT_MARKER_CHECK_ON") then {
			BOAT_MARKER_CHECK_ON = true;
			hint localize "+++ BOAT: run BOAT_MARKER_CHECK_ON run first time.";
			// move marker with boat and remove it on boat kill or leaving Antigua area
			[_boat, _marker, _isle_pos, _rad] spawn {
				private ["_boat","_marker","_area_center","_area_rad","_boat_pos","_delay","_dist","_do_it","_empty_time"];
				_boat  = _this select 0; _marker = _this select 1; _area_center = _this select 2; _area_rad = _this select 3;
				_boat_pos  = getPosASL _boat;
				_marker setMarkerPosLocal _boat_pos;
				_delay = 15;
				_do_it = true;
				_empty_time = 0;
				while { (alive _boat) && (_empty_time < 300)} do {
					sleep _delay;
					if ( ({alive _x} count (crew _boat) == 0 ) ) then {_empty_time = _empty_time + _delay} else {_empty_time = 0;}; // check if boat is empty more than 5 mins
					_dist = [_boat, _boat_pos] call SYG_distance2D;
					if ( _dist > 25 ) then {
						_boat_pos = getPosASL _boat;
						_marker setMarkerPosLocal _boat_pos;
						if ( !([_boat_pos, _area_center, _area_rad] call SYG_pointInCircle) && _do_it) exitWith {
							// Information about going out of bounds
							if ( (_boat_pos distance _area_center) > 1000 ) then { // boat is returned to the marker
								playSound "losing_patience"; // sound about boat leaving Antigua
								player groupChat localize "STR_ABORIGEN_BOAT_RETURNED"; // "The boat off Antigua seems to have disappeared somewhere"
							} else { // boat out of Antigua area
								playSound (["fish_man_song","under_water_2"] call XfRandomArrayVal); // sound about boat leaving Antigua
								player groupChat localize "STR_ABORIGEN_BOAT_DISTOUT"; // "You are leaving Antigua territorial waters"
							};
							_do_it = false;
						};
					};
					if ( _dist < 2.5 ) then { _delay = 15 } else { _delay = ((25 / _dist) max 3) min 15; };
				};
				deleteMarkerLocal _marker; // remove boat marker if dead or out of aquatory
				BOAT_MARKER_CHECK_ON = nil;
				hint localize "+++ BOAT: run BOAT_MARKER_CHECK_ON stopped for next time...";
			};
		} else { hint localize "+++ BOAT: BOAT_MARKER_CHECK_ON already run, marker exists and is under control"};

	};

	//++++++++++++++++++++++++++++++++++++++++++++++++++++
	case "CAR": { // ask about cars/motorcycles
		if (base_visit_mission > 0) exitWith {player groupChat (localize ("STR_ABORIGEN_CAR_NONE_NUM" call SYG_getRandomText))}; // "Sorry. I don't know anything about cars. We live here."}; // "Boats? There are a lot of them... on every kilometer of the coast of the Main Sahrani."

//		player groupChat format[localize "STR_ABORIGEN_CAR_NONE"]; // "Sorry. I don't know anything about cars. We live here."
//		if (true) exitWith{};

		private ["_veh", "_marker_veh"];
		
		// find best vehicle to mark it for this player
		_veh = objNull;
		_marker = "antigua_veh_marker"; // Well known marker name
		if ( (markerType _marker) != "") then {
			// TODO: print info on marker
			hint localize format["+++ Aborigen: car marker found"];
			_vehs = nearestObjects [getMarkerPos _marker, _search_list, 50];
			{
				if (alive _x) exitWith {
					_veh = _x;
					_veh setDamage 0;
					_veh setFuel ((fuel _veh) max 0.5);
					hint localize format["+++ Aborigen: car (%1) found near car marker", typeOf _veh];
				};
			} forEach _vehs;
		};
		if (alive _veh) exitWith { // Veh found near marker, angrily declare about it
		    player groupChat (localize "STR_ABORIGEN_CAR_INFO_1"); // "A car? Why did I put a marker on your map? Uh, you have geographical cretinism)))"
		    if ( locked _veh ) then {
		        (localize "STR_ABORIGEN_CAR_UNLOCK_1") spawn {player groupChat _this}; "... when you find it, unlock it!"
		    } else {
		        (localize "STR_ABORIGEN_CAR_UNLOCK_3") spawn {player groupChat _this}; // "... it doesn't seem to be blocked"
		    };
		};

		// Vehicle not found near main marker or marker in absent. So get all vehicles near transparent markers now and select random one
		_arr = [];
		for "_i" from 1 to 100 do { // for each antigua arrival markers...
			_marker_veh = format["antigua_veh%1",_i];
			if (markerType _marker_veh == "") exitWith {/* hint localize format ["+++ ABORIGEN CAR: stop moto count on id %1", _i]*/}; // no more markers in sqm
			_vehs = nearestObjects [ getMarkerPos _marker_veh, _search_list, 50 ];
			{
				if (alive _x) exitWith {
					_veh = _x;
					_veh setDamage 0;
					_veh setFuel ((fuel _veh) max 0.5);
					hint localize format[ "+++ Aborigen: car (marker %1 type %2) found near car marker", _marker_veh, typeOf _veh ];
				};t
			} forEach _vehs;

			if (alive _veh) then { // add found vehicle to the found list
				_arr set [count _arr, _veh];
				_veh setDamage 0;
			} else { hint localize format [ "+++ ABORIGEN CAR: moto id %1 not found at marker", _i ] };
		};

		hint localize format["+++ ABORIGEN CAR: found %1 vehs at markers", count _arr];
		if ( (count _arr) > 0) exitWith {
			_veh = _arr call XfRandomArrayVal;
			_marker_type = _veh call SYG_getVehicleMarkerType;
			hint localize format["+++ +++ ABORIGEN CAR: selected veh %1, its marker type %2", typeOf _veh, _marker_type];
			if ( (markerType _marker) != _marker_type) then { // Create new marker at found vehicle place
				deleteMarkerLocal _marker;
				_marker = createMarkerLocal[_marker, getPos _veh];
				_marker setMarkerTypeLocal _marker_type;
				_marker setMarkerColorLocal "ColorGreen";
			} else {
				_marker setMarkerPosLocal (getPos _veh);
			};
			hint localize format["+++ +++ ABORIGEN CAR: marker %1(%2) created near %3", _marker, _marker_type, (markerPos _marker) call SYG_nearestSettlementName]; // SYG_nearest
			player groupChat format[localize "STR_ABORIGEN_CAR_INFO_2", _veh call SYG_nearestLocationName]; // "The car? So... here I'm drawing you a green marker on the map where there's something similar. It's about %1."
			if (!locked _veh) then {
//			    _veh lock true;
//			    _veh addAction [localize "STR_ABORIGEN_CAR_UNLOCK","scripts\intro\unlock_veh.sqf"]; // "Unlock"
			} else {
			    [] spawn {sleep 5; player groupChat (localize "STR_ABORIGEN_CAR_UNLOCK_1")}; // "When you find it, unblock it!"
			};
		};
		// remove main marker as nothing to mark with it
		deleteMarkerLocal _marker;
		// Inform about failure to find vehicle on place
		player groupChat (localize ("STR_ABORIGEN_CAR_NONE_NUM" call SYG_getRandomText)); // "Sorry. I don't know anything about cars. We live here."
	};

	case "PLANE" : { // ask about plane
		// check if plane is on place
		_ask_server = isNil "aborigen_plane";
		if ( !_ask_server ) then{ _ask_server = !alive aborigen_plane; };
		if ( _ask_server ) then {
			["remote_execute","[] execVM ""scripts\intro\camel.sqf"""] call XSendNetStartScriptServer;
			_time = time + 5;
			while {(isNil "aborigen_plane") && ( time < _time)} do { sleep 0.25 }; // wait max 5 seconds
			if (isNil "aborigen_plane") exitWIth {
				player groupChat (localize "STR_ABORIGEN_PLANE_UNKNOWN"); // "An airplane? А... No, it's not here, maybe it'll come later?"
				hint localize "--- ABO PLANE: biplan isNil 5 seconds later after call to camel.sqf on server, so exit"
			};
			hint localize "+++ ABO PLANE: server request completed, plane found";
		};

		_exit = false;
		_dist = [aborigen_plane, PLANE_POS] call SYG_distance2D;
		hint localize format["+++ ABO PLANE: plane dist to the main point is %1, allowed 20 m.", round _dist];
		if ( _dist > 20) then { // plane not on place
			// plane must be not occupied by player and be on base - in this case we can move it to island
			_plane_busy = alive (driver aborigen_plane);
			if ( _plane_busy ) then { // pilot is in plane
				if (isPLayer (driver aborigen_plane)) exitWith {
					// Is plane standing on base ?
					if ( ( ((velocity aborigen_plane) distance [0,0,0]) < 5 ) && (((getPos aborigen_plane) select 2) < 3) && (aborigen_plane call SYG_pointIsOnBase) ) exitWIth {
						// player in plane and is on ground of base, eject it now
						(driver aborigen_plane) action["Eject", aborigen_plane];
						sleep 0.5;
						_plane_busy = false;
					};
					// not on base or not on ground, so plane is busy by some player
				};
				// plane is not occupied by player, so eject pilot out in any case
				(driver aborigen_plane) action["Eject", aborigen_plane];
				sleep 0.5;
				_plane_busy = false;
			};
			if (_plane_busy) exitWith {
				player groupChat (format[localize "STR_ABORIGEN_PLANE_BUSY", name (driver aborigen_plane)]); // "The plane flew away, with the pilot '%1'."
				playSound "losing_patience";
				hint localize format["+++ ABO PLANE: plane is occupied by %1, exit!!!", name (driver aborigen_plane)];
				_exit = true;
			};
			// Plane is free and can be moved to the Antigua airstrip
			["say_sound", aborigen_plane, "steal"] call XSendNetStartScriptClientAll;
			sleep 0.5;
			aborigen_plane setVelocity [0,0,0];
			aborigen_plane setDir PLANE_DIR;
//			aborigen_plane setVehiclePosition [PLANE_POS,[], 0, "CAN_COLLIDE"];
			aborigen_plane setPos PLANE_POS;
			["say_sound", aborigen_plane, "return"] call XSendNetStartScriptClientAll;
			hint localize format["+++ ABO PLANE: positioned on the place. Pos %1, dist %2", getPos aborigen_plane, round(aborigen_plane distance PLANE_POS) ];
		};
		if (_exit) exitWith {};

#ifdef __ACE__
		// #624: Bicycle request joined with plane one.
		// check if bicycle is near tent
		hint localize "+++ ABO PLANE: bicycle search";
		_bicycle = nearestObject [spawn_tent,"ACE_Bicycle"];
		_sound = "";
		if (!(isNull _bicycle)) then { // Found bicycle
			if (alive _bicycle) then { // Alive bicycle
				hint localize format["+++ ABO PLANE: ALIVE (damage %1) bicycle found near spawn_tent ", damage _bicycle];
				_msg = if ((_bicycle distance aborigen) < 15) then {"STR_ABORIGEN_BICYCLE_1_1"} // "Ride my bike (there it is, there) to get to the plane... Don't fall down (with a kind smile)"
						else {"STR_ABORIGEN_BICYCLE_1"}; // "Use the bike to get to the plane. It's somewhere near the tent...".
				player groupChat ( localize _msg );
			} else {
				hint localize "+++ ABO PLANE: DEAD bicycle found near spawn_tent";
				player groupChat (localize "STR_ABORIGEN_BICYCLE_2"); // "Walk to the plane. My bicycle is broken..."
			};
		} else {
			hint localize "+++ ABO PLANE: near spawn_tent bicycle NOT found, search on whole islet";
			_arr = nearestObjects [aborigen, ["ACE_Bicycle"],2000];
			if (count _arr > 0) then { // some bicycle found on island
				// find nearest alive bicycle and move it to the tent if needed
				_bicycle = objNull;
				{	// find nearest alive bicycle without driver
					if ((alive _x) && (isNull driver _x)) exitWith { _bicycle = _x };
				} forEach _arr;
				if (alive _bicycle) then { // Empty bicycle found, try to move close to the tent
					hint localize "+++ ABO PLANE: bicycle alive found, check if need to move it to the spawn_tent position";
					if ((_bicycle distance aborigen) < 15) then {
						hint localize "+++ ABO PLANE: bicycle alive found near aborigen no need to move it to the spawn_tent position";
						player groupChat ( localize "STR_ABORIGEN_BICYCLE_1_1"); // "Ride my bike (there it is, there) to get to the plane... Don't fall down (with a kind smile)"
					} else {
						if ( (_bicycle distance POS_BICYCLE) > 5) then {
							_bicycle setPos POS_BICYCLE;
							sleep 0.2;
							_sound = "return";
						};
						if ( (_bicycle distance POS_BICYCLE) < 5) then {
							_msg = if ((_bicycle distance aborigen) < 15) then {"STR_ABORIGEN_BICYCLE_1_1"} // "Ride my bike (there it is, there) to get to the plane... Don't fall down (with a kind smile)"
									else {"STR_ABORIGEN_BICYCLE_1"}; // "Use the bike to get to the plane. It's somewhere near the tent...".
							player groupChat (localize _msg); // ???
						} else {
							hint localize "--- ABO PLANE: bicycle cant' be moved to the pos near spawn_tent";
							player groupChat (localize "STR_ABORIGEN_BICYCLE_3"); // "Walk to the plane. Someone stole my bicycle that my grandfather gave me..."
						};
					};
				} else {
					hint localize "--- ABO PLANE: bicycle alive NOT found on island";
					player groupChat (localize "STR_ABORIGEN_BICYCLE_3"); // "Walk to the plane. Someone stole my bicycle that my grandfather gave me..."
				};
			} else {
				hint localize "--- ABO PLANE: bicycle (alive or dead) NOT FOUND on Antigua, that is very strange!!!";
				player groupChat (localize "STR_ABORIGEN_BICYCLE_3"); // "Walk to the plane. Someone stole my bicycle that my grandfather gave me..."
			};
		};
		// Repair and say sound if needed
		if (alive _bicycle) then {
			if (damage _bicycle > 0.01) then {
				_bicycle setDamage 0; // Repair the bicycle, play heal sound
				if (_sound == "") then { _sound = "healing";};
			};
			if (_sound != "") then {_bicycle say _sound;};
		};
#endif
		player groupChat (localize "STR_ABORIGEN_PLANE_INFO"); // "An airplane? There's a Sopwich (WWI) standing on the runway. I don't know about the fuel or the pilot..."
	};
	//++++++++++++++++++++++++++++++++++++++++++++++++++++
	case "WEAPON": { // ask about weapon box

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
		player groupChat format[localize "STR_ABORIGEN_NAME_2", name player]; // "You answered angrily: my name is %1."
	};
	default {
		format[localize "STR_ABORIGEN_UNKNOWN", _arg] call XfGroupChat;
		playSound "losing_patience";
	};
};
sleep 10;
aborigen doWatch objNull;

