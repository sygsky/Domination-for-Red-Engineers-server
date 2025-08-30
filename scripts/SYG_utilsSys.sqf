//++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
// scripts\SYG_utilsSys.sqf:
//
// System methods created by Sygsky to handle with Xeno super-Domination internals
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++

#include "x_setup.sqf"
#include "x_macros.sqf"

//#define __DEBUG__

#define arg(x) (_this select(x))
#define argp(param,x) ((param)select(x))
#define argopt(num,val) (if(count _this<=(num))then{val}else{arg(num)})
#define RANDOM_ARR_ITEM(ARR) (ARR select(floor(random (count ARR))))


/*
 * Answer to initiation message sent from client as follow:
 * _name = name player;
 * ["d_p_varname",_name,str(player)<,"LANGUAGE">] call XSendNetStartScriptServer;
 */
SYG_d_p_varname =  {
	private ["_index","_parray", "_msg_arr","_name","_msg","_equip_empty","_equipment","_wpnArr","_settingsArr",
			 "_val","_date","_arr1","_arr2","_arr","_str"];
	_name = _this select 1;
	_index = d_player_array_names find _name;
	//hint localize format["***************** _index = %1 *********************", _index];
	_parray = [];
	if (_index >= 0) then {
		_parray = d_player_array_misc select _index;
		_parray set [4, (_this select 2)]; // set player role to the named entry
	};

	// Prepare 1st message for the new player

	if (isNil "d_connection_number") then {
		d_connection_number = 1;
		_msg_arr = [["STR_SYS_604_0"]]; // "You are the first [English speaking] warrior in this dangerous mission to liberate Sahrani!"
	} else {
		d_connection_number = d_connection_number + 1;
		_msg_arr = [["STR_SYS_604",d_connection_number]]; // "Sahrani People welcome the %1 of the warrior-internationalist in their troubled land"
	};
	// add user language specific message if available
	_msg = switch (_name) do {
		case "Comrad (LT)";
		case "Rokse [LT]" : {"Salos gyventojai sveikina tave tavo gimtaja kalba!"}; // Литовец!
		case "Aron"       : { "Ostrovania su radi, vitam vas vo svojom rodnom jazyku!" }; // Slovak };
		case "gyuri";
		case "Frosty";
		case "Petigp"     : { "Üdvözöljük az alap a 'Vörös mérnökök'!" }; // Hungarian // "A szigetlakok orommel udvozoljuk ont a sajat anyanyelven!";
		case "Marco"      : { "Marco, vehicles at the airbase are forbidden to destroy! Only you see this message :o)" };// // veh. killer
		case "ihatelife"  : { "Islanders welcome our man from Richmond!"}; // An American Negro?
		case "Shelter";
		case "Marcin"     : { "Nasz oddział spełnia polskiego brata!" }; // Poland
		case "Oberon";		// русский
		case "Axmed"      : { "Боец! Островитяне советуют: купи лицензионный ключ (копеек 50 на советские деньги). Этим ключом пользуешься не только ты." }; // Русский Ахмед
		case "Nushrok";
		case "Klich";
		case "dupa";
		case "GTX460"     : { "Островитяне: привет советскому разведчику! Мы свято сохраним тайну твоей Родины!" };
		case "nejcg";
		case "Nejc"       : { "Otočani vas z veseljem pozdravljajo v vašem maternem jeziku!" }; // Словенец
		case "Renton J. Junior" : {"Salinieki ir priecīgi sveikt Jūs savā dzimtajā valodā!"}; // Латыш
		case "R2D2";      // Le francais
		case "Lt. Jay"    :{"Les habitants de l'île sont heureux de vous accueillir dans votre langue maternelle !"}; // Le francais
		case "Elia";
		case "Moe"        : {"Gli isolani sono lieti di darvi il benvenuto nella loro lingua madre italiana !"}; // Italian language
		default           { "STR_SERVER_MOTD0" }; // "The islanders are happy to welcome you in your native language!"
	};

	_msg_arr set [ count _msg_arr, [_msg] ];

	if ( (_index < 0) && ( current_counter >= (floor(number_targets /2)) ) ) then {
		// first time entry after half of game
		_msg_arr set [ count _msg_arr, ["STR_SYS_604_1"] ]; // "Nearly half of Sahrani released, but the population Sahrani glad to any defender of true liberty"
	};

#ifdef __SIDE_MISSION_PER_MAIN_TARGET_COUNT__
	// info about side mission before next town
	if ( !call SYG_isMainTargetAllowed ) then {
		_msg_arr set [ count _msg_arr, ["STR_SYS_1151_1", current_mission_counter + 1] ]; // "Finish SM(%1)"
		[] spawn {
			// notice user 1 more time about side mission
			// ["msg_to_user",_player_name | "*" | "",[_msg1, ... _msgN]<,_delay_between_messages<,_initial_delay<,no_title_msg><,sound_name>>>>]
			["msg_to_user", _name, [ ["STR_SYS_1151_1", current_mission_counter + 1], ["STR_SYS_1151_1", current_mission_counter + 1]], 60, 60] call XSendNetStartScriptClient;
		};
	};
#endif

	_equip_empty = true;
	if ( count _parray >= 6 ) then {
		// ammunition is stored some time ago, restore it now
		_equipment = _parray select 5; // read string with equipment array
		if ( _equipment != "") then {
			_msg_arr set [ count _msg_arr, ["STR_SYS_612"] ]; // "Вам было выдано снаряжение с прошлого раза"
			_equip_empty = false;
			// check for distance view
			_wpnArr = _equipment call SYG_unpackEquipmentFromStr;
			if ( (count _wpnArr) >= 5 ) then {
				if ( typeName (_wpnArr select 4) == "SCALAR") then {
					// old variant
					_msg_arr set [ count _msg_arr, ["STR_SYS_618",_wpnArr select 4] ]; // "Viewdistance restore to %1 m."
				} else {
				    // TODO: implement code for parsing array of user settings
					if ( typeName (_wpnArr select 4) == "ARRAY") then {
						// new variant
						_settingsArr = _wpnArr select 4;
						_val = [_settingsArr, "VD"] call SYG_getParamFromSettingsArray;
						if ( _val >= 0) then {
							_msg_arr set [ count _msg_arr, ["STR_SYS_618",_val] ]; // "Viewdistance restore to %1 m."
						};
					};
				};
			};
		};
	};
	if ( _equip_empty  && (_index >= 0)) then {
		if ( (_parray select 3) > 0) then {
			// non-zero score? Report about record absence
			_msg_arr set [ count _msg_arr, ["STR_SYS_614"] ]; // ammunition record not found
		};
	};

	//hint localize format["+++ __HasGVar(INFILTRATION_TIME) = %1",__HasGVar(INFILTRATION_TIME)];
	if (__HasGVar(INFILTRATION_TIME)) then {
		_date = __GetGVar(INFILTRATION_TIME);
		if (typeName _date == "ARRAY") then {
			_msg_arr set [ count _msg_arr, ["STR_GRU_55", _date call SYG_dateToStr] ]; // "Last assault was at dd.MM.yyyy hh:mm:ss"
		};
		// __SetGVar(INFILTRATION_TIME,_date); // No need to send info to the new player as Arma do it itself
	};

	_arr1 = call SYG_lastTownsGet;
	_arr2 = call SYG_lastPlayersGet;
	if (((count _arr1) + (count _arr2)) > 0) then {
		// if any towns/players are counted, inform user about them
		_str = [_arr1, ", "] call SYG_joinArr;
		_arr = ["STR_GRU_56",_str];
		_str = [_arr2,", "] call SYG_joinArr;
		_arr set [ count _arr, _str ];
		_msg_arr set [ count _msg_arr, _arr ]; // "GRU: last towns%1,  last soldiers%2"
	};
	_name call SYG_lastPlayersAdd; // add player to linked list of entered ones

	// TODO: add here more messages for the 1st greeting to user

	["msg_to_user", _name, _msg_arr, 5, 10] call XSendNetStartScriptClient;
	sleep 1.0;
	["current_mission_counter",current_mission_counter] call XSendNetVarClient; // inform about side mission counter

	// log info  about logging
	hint localize format["+++ x_netinitserver.sqf: %1 User %2 (role %3) logged in", call SYG_missionTimeInfoStr, _name, (_this select 2) ];
};



//
// _arr = [1,2,3];
// _add_arr = [4,5,6];
// _arr = [_arr, _add] call SYG_addArrayInPlace; // [1,2,3,4,5,6] and _arr is the same object as before addition!!!
//
SYG_addArrayInPlace = {
    private ["_arr","_x"];
    _arr = _this select 0;
    { _arr set [ count _arr, _x ] } forEach (_this select 1);
    _arr
};

// Remove all designated strings (e.g. "RM_ME") from input _arr not changing oreder of items
// call: _cleaned_arr = [_cleaned_arr,"RM_ME"] call SYG_clearArray;
// returns the same array without "RM_ME" items. Order of remained items in array NOT changed!!!
SYG_clearArrayA = {
	if ( (typeName _this) != "ARRAY") exitWith {[]};
	if ( count _this < 2) exitWith {[]};
	if ( (typeName (_this select 0) ) != "ARRAY") exitWith {[]};
	if ( (typeName (_this select 1) ) != "STRING") exitWith {_this select 0};

	private ["_dst","_src","_arr","_rm","_cnt","_notRM_ME","_item"];
	_arr = _this select 0;	// array of any items with possible "RM_ME" items inclusion!
	_rm  = _this select 1; // must be string! E.g. "RM_ME"
	_dst = _arr find _rm;	// find first item to remove if available
	if (_dst < 0) exitWith{ _arr }; // nothing to remove, return to the caller
	_src = _dst + 1;
	_cnt = count _arr;
//	hint localize "+";
//	hint localize format["+++ orig: %1, _dst %2, _src %3", _arr, _dst, _src];
	while { _src < _cnt } do {
		_item = _arr select _src;
		_notRM_ME = if ( typeName _item == "STRING" ) then { _item != _rm } else { true };
		if ( _notRM_ME ) then {
			_arr set [ _dst, _item ];
			_dst = _dst + 1;
		};
//		hint localize format["+++ _arr: %1, _src %2", _arr, _src];
		_src = _src + 1;
	};
	_arr resize _dst;
	_arr
};
SYG_cleanArrayA = SYG_clearArrayA;

// Remove all strings "RM_ME" from input _arr not changing oreder of items
// call: _cleaned_arr = _cleaned_arr call SYG_clearArrayB;
// returns the same array without "RM_ME" items. Order of remained items in array NOT changed!!!
SYG_clearArrayB = {
	[_this, "RM_ME"] call SYG_clearArrayA
};
SYG_cleanArrayB = SYG_clearArrayB;
SYG_clearArray  = SYG_cleanArrayB;
SYG_cleanArray  = SYG_cleanArrayB;

//
// _arr = [1,2,3,4];
// _arr = [_arr, 2] call SYG_removeFromArrayByIndex; // returns [1,3,4] and _arr is the same object as before subtraction!!!
//
SYG_removeFromArrayByIndex = {
	private [ "_arr", "_ind", "_i" ];
	_arr = _this select 0;
	if (typeName _arr != "ARRAY") exitWith {[]};
	_ind = _this select 1;
	if (_ind < 0) exitWith { _arr};            // out of bounds
	if (_ind >= (count _arr)) exitWith {_arr}; // out of bounds
	for "_i" from _ind  to (count _arr) - 2 do { _arr set [_i, _arr select (_i + 1)]; };
	_arr resize (count _arr) - 1;
	_arr
};

//
// _arr = [_obj1,_obj2,_obj3,_obj4];
// _arr = [_arr, _obj2] call SYG_removeFromArrayByIndex; // returns [_obj1,_obj3,_obj4] and _arr is the same object as before subtraction!!!
//
SYG_removeObjectFromArray = {
	private [ "_arr", "_ind", "_i" ];
	_arr = _this select 0;
	if (typeName _arr != "ARRAY") exitWith {[]};
	_ind = _arr find (_this select 1);
	if (_ind >= 0 ) exitWith {
		_this set [1, _ind];
		_this call SYG_removeFromArrayByIndex;
	};
	_arr
};

/**
 * Rounds number to the nearest boundary of designated value
 * call as: _roundedValue = [_value, BOUNDARY] call SYG_roundTo;
 * e.g. [12.49, 5] call SYG_SYG_roundTo =  10
 *      [12.51, 5] call SYG_SYG_roundTo =  15
 *      [15.7,  5] call SYG_SYG_roundTo =  15
 *      [17.51, 5] call SYG_SYG_roundTo =  20
 */
SYG_roundTo = {
    private ["_bound"];
    _bound = _this select 1;
    (round((_this select 0)/_bound)) * _bound
};

SYG_distRoundTo = {
    private ["_dist","_bound"];
    _dist = _this select 0;
    _bound = _this select 1;
    if ( _dist < _bound) exitWith { round _dist }; // Return meters if distance less then bound size
    (round( _dist /_bound)) * _bound
};

/**
 * Added on 22-11-2022 by Rokse [LT] request
 * Handles with waypoints, call it on the client ONLY:
 * to set WP: ["SET", getPos AISPAWN<,"WP description">] call SYG_handleWP;
 * to remove WP: "REMOVE" call SYG_handleWP;
 * to get WP count: "COUNT" call SYG_handleWP;
 *
 */
SYG_handleWP = {
//	if (isServer) exitWith {"--- SYG_handleWP: called on server, exit"};
	if (!X_Client) exitWith { hint localize "--- SYG_handleWP: called not on client, exit" };
	private ["_cmd","_wpa","_wp","_grp","_str","_last"];
	_cmd = _this;
//	hint localize format["+++ SYG_handleWP: cmd = ""%1""", _cmd];
	if (typeName _cmd == "ARRAY") then {
		if (count _cmd == 0) exitWith {hint localize "--- SYG_handleWP: expected parameters array size 1 or 2, detected 0"};
		if ( (toUpper(_cmd select 0)) in ["REMOVE","COUNT"]) then {_cmd = _cmd select 0};
	};

	if ((typeName _cmd) == "STRING") exitWith {
		if ( !((toUpper _cmd) in ["REMOVE","COUNT"]) ) exitWith {
			hint localize format["--- SYG_handleWP: expected ""REMOVE"" or ""COUNT"" parameter, detected ""%1""", _cmd];
		};
		_grp = group player;
		_wpa = waypoints _grp;
		if ((toUpper _cmd) == "COUNT") exitWith {
//			player groupChat format["+++ Waypoints count = %1", count _wpa];
			count _wpa; // Count of waypoints returned
		};
		// "REMOVE" detected
		if (count _wpa > 0) then {
			_wp = _wpa select 0;
//			hint localize format["+++ SYG_handleWP: REMOVE, wp = %1", _wp];
			_grp setCurrentWaypoint _wp;
			_wp setWPPos (getPos player);
			sleep 0.5;
			deleteWaypoint _wp;
		} else {
			hint localize "*** SYG_handleWP: no waypoint to  REMOVE";
		};
	};
	if (typeName _cmd == "ARRAY") exitWith {
		if (count _cmd < 2) exitWith { hint localize (format["--- SYG_handleWP: expected parameters array size 2, detected %1", count _cmd]) };
		_str = _cmd select 0;
		if ((typeName _str) != "STRING") exitWith { hint localize (format["--- SYG_handleWP: expected [STRING, ...], found [%1, ...]", typeName _str]) };
		if (count _cmd < 2) exitWith { hint localize (format["--- SYG_handleWP: expected SET command array size 2 or 3, detected %1", count _cmd ]) };
		private ["_pos","_i","_x"];
		_pos = _cmd select 1; // Position where to assign WP
		if ((toUpper _str) != "SET") exitWith { hint localize (format["--- SYG_handleWP: expected ['SET', ...] found %1", _cmd]) };
		_grp = group player;
		_wpa = waypoints _grp;
//		hint localize format["+++ SYG_handleWP: SET, wpa = %1", _wpa];
		_last = count _wpa - 1;
		for "_i" from 0 to _last do {
			deleteWaypoint (_wpa select _i);
		};
		_wp = _grp addWaypoint [_pos, 0];
//		hint localize format["+++ SYG_handleWP: wp = %1",  _wp];
//		_wp setWaypointPosition [ _pos, 0];
		_wp setWaypointType "MOVE";
		_grp setCurrentWaypoint _wp;
		if (count _cmd > 2) then {
			_wp setWaypointDescription (_cmd select 2);
		}
	};
};

//
// Shows destination point after intro until player is not landed on base
// Spawn as: [] spawn SYG_showDestinationWPUntilOnBase;
//
SYG_showDestWPIfNotOnBase = {
	private ["_pos","_str"];
	_pos = getPos AISPAWN;
	["SET", _pos] call SYG_handleWP; // set intitial destiantion point
	hint localize "+++ SYG_showDestWPIfNotOnBase: first WP created";
	_str = localize "STR_SYS_70"; // "Base"
	while { base_visit_session < 1 }  do { // player stil not visited base, so check WP existance
	 	// each 10 seconds check if WP is wiped out by some circumstances
		sleep 10;
		if (alive player) then { // check only for alive player
			// update WP just in case
			["SET", _pos, _str] call SYG_handleWP; // set intitial destiantion point
			// print information about WP creaed
			// hint localize "+++ SYG_showDestWPIfNotOnBase: refresh WP";
		};
	};
	"REMOVE" call SYG_handleWP; // set intitial destiantion point
	hint localize "+++ SYG_showDestWPIfNotOnBase: WP removed";
};

