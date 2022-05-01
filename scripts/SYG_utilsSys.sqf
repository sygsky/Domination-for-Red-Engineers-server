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

#define DEFAULT_MAX_DISTANCE_TO_TARGET 1500
#define DEFAULT_MIN_GROUP_SIZE 5
#define MIN_POSSIBLE_GROUP_SIZE 2

/*
 * Answer to initiation message sent from client as follow:
 * _name = name player;
 * ["d_p_varname",_name,str(player)] call XSendNetStartScriptServer;
 */
SYG_d_p_varname =  {
	private ["_index","_parray", "_msg_arr","_name","_msg","_equip_empty","_equipment","_wpnArr","_settingsArr",
			 "_val","_date","_arr1","_arr2","_arr","_str"];
	_index = d_player_array_names find arg(1);
	//hint localize format["***************** _index = %1 *********************", _index];
	_parray = [];
	if (_index >= 0) then {
		_parray = d_player_array_misc select _index;
		_parray set [4, arg(2)]; // set player role to the named entry
	};

	// Prepare 1st message for the new player

	if (isNil "d_connection_number") then {
		d_connection_number = 1;
		_msg_arr = [["STR_SYS_604_0"]]; // "You are the first [English speaking] warrior in this dangerous mission to liberate Sahrani!"
	} else {
		d_connection_number = d_connection_number + 1;
		_msg_arr = [["STR_SYS_604",d_connection_number]]; // "Sahrani People welcome the %1 of the warrior-internationalist in their troubled land"
	};
	_name = _this select 1;
	// add user language specific message if available
	_msg = switch (_name) do {
		case "Comrad (LT)";
		case "Rokse [LT]" : {"Salos gyventojai sveikina tave tavo gimtaja kalba!"}; // Литовец!
		case "Aron"       : { "Ostrovania su radi, vitam vas vo svojom rodnom jazyku!" }; // Slovak };
		case "gyuri";
		case "Frosty";
		case "Petigp"     : { "Üdvözöljük az alap a 'Vörös mérnökök'!" }; // Hungarian // "A szigetlakok orommel udvozoljuk ont a sajat anyanyelven!";
		case "Marco"      : { "Marco, vehicles at the airbase are forbidden to destroy! Only you see this message :o)" };// // veh. killer
		case "Shelter";
		case "Marcin"     : { "Nasz oddział spełnia polskiego brata!" }; // Poland
		case "Nushrok";
		case "Klich";
		case "dupa";
		case "GTX460"     : { "Островитяне: привет советскому разведчику! Мы свято сохраним тайну твоей Родины!" };
		case "nejcg";
		case "Nejc"       : { "Otočani vas z veseljem pozdravljajo v vašem maternem jeziku!" }; // Словенец
		case "Renton J. Junior" : {"Salinieki ir priecīgi sveikt Jūs savā dzimtajā valodā!"}; // Латыш
		case "Lt. Jay"    :{"Les habitants de l'île sont heureux de vous accueillir dans votre langue maternelle !"}; // Le francais
		case "Elia";
		case "Moe"        : {"Gli isolani sono lieti di darvi il benvenuto nella loro lingua madre italiana !"}; // Italian language
		case "Oberon";		// русский
		case "Axmed"      : { "Ахмед! Островитяне, желая добра, советуют: купи лицензионный ключ (копеек 50 на советские деньги). Этим ключом пользуешься не только ты." }; // Русский Ахмед
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
				if ( typeName argp(_wpnArr,4) == "SCALAR") then {
					// old variant
					_msg_arr set [ count _msg_arr, ["STR_SYS_618",_wpnArr select 4] ]; // "Viewdistance restore to %1 m."
				} else {
				// TODO: implement code for parsing array of user settings
					if ( typeName argp(_wpnArr, 4) == "ARRAY") then {
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
		if ( argp(_parray,3) > 0) then {
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

	["msg_to_user", arg(1), _msg_arr, 5, 10] call XSendNetStartScriptClient;
	sleep 1.0;
	["current_mission_counter",current_mission_counter] call XSendNetVarClient; // inform about side mission counter

	// log info  about logging
	hint localize format["+++ x_netinitserver.sqf: %3 User %1 (role %2) logged in", arg(1), arg(2), call SYG_missionTimeInfoStr ];
};
