// Xeno, x_scripts\x_funcs\x_netinitserver.sqf, on server only
#include "x_setup.sqf"
#include "x_macros.sqf"
#include "global_vars.sqf"

//#define __DEBUG_BONUS__

"d_nv_serv" addPublicVariableEventHandler {
	(_this select 1) call XHandleNetVar;
};
// Yeti has variable time offset, so I commented him
SYG_userNames  = ["EngineerACE","HE_MACTEP","Snooper","yeti","Rokse [LT]","Ceres-de","CERES de","Ceres.","CERES","gyuri", "Frosty", "Aron","White Jaguar"];
SYG_localZones = [            0,          0,        0,    -4,           0,        +1,        +1,      +1,     +1,     +1,       +1,     +1,            -4 ];

XHandleNetStartScriptServer = {
	private ["_this","_params"];
	__DEBUG_NET("x_netinitserver.sqf XHandleNetStartScriptServer _this",_this)
	switch (_this select 0) do {
#ifdef __DEBUG_BONUS__
	    case "getbonus": {
	        hint localize "+++ x_netinitserver.sqf: [] execVM ""x_scripts\x_getbonus.sqf""";
	        side_mission_winner = 1;
			[] execVM "x_scripts\x_getbonus.sqf";
	    };
#endif
		case "ari_type": {
			__compile_to_var
			ari_salvos = (_this select 2);
			(_this select 3) execVM "x_scripts\x_arifire.sqf";
		};
		case "ari_type2": {
			__compile_to_var
			ari_salvos2 = (_this select 2);
			(_this select 3) execVM "x_scripts\x_arifire2.sqf";
		};
		case "d_create_box": {
			if (!d_old_ammobox_handling) then {
				(_this select 1) spawn XCreateDroppedBox;
			} else {
				[_this select 1, _this select 2] spawn XCreateDroppedBox;
			};
		};
#ifndef __TT__
		case "d_fac_ruins_pos": {
			[(_this select 1) select 0,(_this select 1) select 1] spawn XFacRebuild;
		};
#endif
#ifdef __TT__
		case "add_kills_racs": {
			kill_points_racs = kill_points_racs + (_this select 1);
		};
		case "add_kills_west": {
			kill_points_west = kill_points_west + (_this select 1);
		};
#endif
		case "mr1_in_air": {
			__compile_to_var
		};
		case "mr2_in_air": {
			__compile_to_var
		};
#ifdef __TT__
		case "mrr1_in_air": {
			__compile_to_var
		};
		case "mrr2_in_air": {
			__compile_to_var
		};
#endif
		case "mr1_lift_chopper": {
			__compile_to_var
			if (!isNull mr1_lift_chopper) then {[mr1_lift_chopper] spawn x_checktransport;};
		};
		case "mr2_lift_chopper": {
			__compile_to_var
			if (!isNull mr2_lift_chopper) then {[mr2_lift_chopper] spawn x_checktransport;};
		};
#ifdef __TT__
		case "mrr1_lift_chopper": {
			__compile_to_var
			if (!isNull mrr1_lift_chopper) then {[mrr1_lift_chopper] spawn x_checktransport2;};
		};
		case "mrr2_lift_chopper": {
			__compile_to_var
			if (!isNull mrr2_lift_chopper) then {[mrr2_lift_chopper] spawn x_checktransport2;};
		};
#endif
		case "x_drop_type": {
			[(_this select 1),(_this select 2)] execVM "x_scripts\x_createdrop.sqf";
		};
		case "d_placed_obj_add": {
			d_placed_objs = d_placed_objs + [(_this select 1)];
		};
		case "d_air_taxi": {
			(_this select 1) execVM "x_scripts\x_airtaxiserver.sqf";
		};
		case "d_rem_box": {
			private ["_i", "_box_a", "_pos"];
			for "_i" from 0 to (count d_ammo_boxes - 1) do {
				_box_a = d_ammo_boxes select _i;
				_pos = _box_a select 0;
				if (_pos distance (_this select 1) < 5) exitWith {
					_box_a set [0,[]];
				};
			};
		};
		case "d_flag_vec": {
			(_this select 1) setVariable ["d_end_time", (time + d_remove_mhq_vec_time + 60)];
			[(_this select 1)] call XAddCheckDead;
		};
		// store currect player score
		case "d_ad_sc": {
			[(_this select 1),(_this select 2)] spawn XAddPlayerScore;
		};
		// store player weapon list on server
		// params: ["d_ad_wp", _player_name,_player_weapon_str_array]
		case "d_ad_wp": {
			[(_this select 1),(_this select 2)] spawn SYG_storePlayerEquipmentAsStr;
		};

		// info from user about his name and missionStart value
		// Example: ["d_p_a", name player<, missionStart<,"RUSSIAN">>]
		case "d_p_a": {
            // store server time directly now for better accuracy
            SYG_server_time  = time;       // current server time at the synchonizaton moment

			arg(1) spawn XGetPlayerPoints; // response with user scores, equipment, viewdistance, suicide sound...
			if ( count _this > 2) then {// missionStart received
			    private ["_userLogin", "_ind"];
			    _userLogin = arg(1);
			    _ind = SYG_userNames find _userLogin;
				private ["_localDate", "_timeOffset"];
				_localDate  = arg(2);
			    if (_ind >= 0 ) then {
			        _timeOffset = SYG_localZones select _ind;

			        // store real time or the server (MSK must be guarantied)
			        // and local time to help know real time through whole mission during being suspend/resume in virtual machines
			        // TODO: надо как то 
                    SYG_client_start = [_localDate, _timeOffset] call SYG_bumpDateByHours; // current time on last connected client
                    hint localize format["+++ x_netinitserver.sqf: ""d_p_a"", missionStart from known timezone (%1) client was accepted !!!",
                        if (_timeOffset >= 0) then {format["+%1",_timeOffset ]} else {_timeOffset}];
			    } else {
			        if ( isNil "SYG_client_start") then {
                        // unknown client started server, let get time from it in any case
                        SYG_client_start = _localDate; // current time on first and unknown connected client
                        hint localize "+++ x_netinitserver.sqf: ""d_p_a"", missionStart from client started server without known timezone was accepted !!!";
			        } else {
                        hint localize "+++ x_netinitserver.sqf: ""d_p_a"", missionStart from client with unknown timezone wasn't accepted !!!";
			        };
			    };
			    hint localize format[ "+++ x_netinitserver.sqf: %1 ""d_p_a"", %2, %3", argopt(3,"<NO_LANG>"), _userLogin, arg(2) ];
			};
		};
		/*
		 * Answer to initiation message sent from client as follow:
		 * _name = name player;
		 * ["d_p_varname",_name,str(player)] call XSendNetStartScriptServer;
		 */
		case "d_p_varname": {
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
            // add language specific message if available
//            if (localize "STR_LANGUAGE" != "RUSSIAN") then {
                _msg = switch (_name) do {
                	case "Comrad (LT)":
                    case "Rokse [LT]" : {"Salos malonu pasveikinti jus į savo gimtąja kalba!"}; // Литовец!
                    case "Aron"       : { "Ostrovania su radi, vitam vas vo svojom rodnom jazyku!" }; // Slovak };
                    case "gyuri";
                    case "Frosty";
                    case "Petigp"     : { "Üdvözöljük az alap a 'Vörös mérnökök'!" }; // Hungarian // "A szigetlakok orommel udvozoljuk ont a sajat anyanyelven!";
                    case "Marco"      : { "Marco, vehicles at the airbase are forbidden to destroy! Only you see this message :o)" };// // veh. killer
                    case "Shelter";
                    case "Marcin"     : { "Nasz oddział spełnia polskiego brata!" }; // Poland
                    case "Nushrok";
                    case "Klich";
                    case "GTX460"     : { "Островитяне: привет советскому разведчику! Мы свято сохраним тайну твоей Родины!" };
                    case "nejcg";
                    case "Nejc"       : { "Otočani vas z veseljem pozdravljajo v vašem maternem jeziku!" }; // Словенец
					case "Renton J. Junior" : {"Salinieki ir priecīgi sveikt Jūs savā dzimtajā valodā!"}; // Латыш
                    default             { "STR_SERVER_MOTD0" }; // "The islanders are happy to welcome you in your native language!"
                };

                _msg_arr set [ count _msg_arr, [_msg] ];
//  			};

			if ( (_index < 0) && ( current_counter >= (floor(number_targets /2)) ) ) then {
    			// first time entry after half of game
				_msg_arr set [ count _msg_arr, ["STR_SYS_604_1"] ]; // "Nearly half of Sahrani released, but the population Sahrani glad to any defender of true liberty"
			};

#ifdef __SIDE_MISSION_PER_MAIN_TARGET_COUNT__
			// info about side mission before next town
			if ( !call SYG_isMainTargetAllowed ) then {
				_msg_arr set [ count _msg_arr, ["STR_SYS_1151_1", current_mission_counter + 1] ]; // "Finish SM(%1)"
			};
#endif

			_equip_empty = true;
            if ( count _parray >= 6 ) then
            {
                // ammunition is stored some time ago, restore it now
                _equipment = _parray select 5; // read string with equipment array
                if ( _equipment != "") then
                {
                    _msg_arr set [ count _msg_arr, ["STR_SYS_612"] ]; // "Вам было выдано снаряжение с прошлого раза"
                    _equip_empty = false;
                    // check for distance view
                    _wpnArr = _equipment call SYG_unpackEquipmentFromStr;
                    if ( (count _wpnArr) >= 5 ) then {
                        if ( typeName argp(_wpnArr,4) == "SCALAR") then {
                            // old variant
                            _msg_arr set [ count _msg_arr, ["STR_SYS_618",_wpnArr select 4] ]; // "Viewdistance restore to %1 m."
                        }
                        else {
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
			if (__HasGVar(INFILTRATION_TIME)) then
			{
			    _date = __GetGVar(INFILTRATION_TIME);
			    if (typeName _date == "ARRAY") then
			    {
                    _msg_arr set [ count _msg_arr, ["STR_GRU_55", _date call SYG_dateToStr] ]; // "Last assault was at dd.MM.yyyy hh:mm:ss"
			    };
			    __SetGVar(INFILTRATION_TIME,_date); // send info to this client too
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
			hint localize format["x_netinitserver.sqf: %3 User %1 (role %2) logged in", arg(1), arg(2), call SYG_missionTimeInfoStr ];
		};
		case "GRU_msg": {
			_this call GRU_procServerMsg;
		};

		// SPPM event handler on server (receive messages from client)
		case "SPPM": {
			switch (arg(1)) do {

				// format: ["SPPM","ADD", _pos, player_name]
				case "ADD": { // add SPPM at designated position by known player
					hint localize format["+++ SPPM ADD: pos %1 (%2), player ""%3""",
						arg(2),
						[arg(2),"%1 m. to %2 from %3",10] call SYG_MsgOnPosE,
						arg(3)
						];
					private [ "_msg_arr" ];
					_msg_arr = arg(2) call SYG_addSPPMMarker; // returns message about results
					if (typeName _msg_arr == "STRING") then {_msg_arr = [_msg_arr]};
					[ "msg_to_user", arg(3), [_msg_arr], 5, random 4, false, "set_marker" ] call XSendNetStartScriptClient; // corresponding message after procedure execution
				};

				// format: ["SPPM","UPDATE", player_name<,send_answer>]
				case "UPDATE" : { // update all SPPM available
					hint localize format["+++ SPPM UPDATE (ALL): player ""%1""", arg(2)];
					private ["_cnt","_arr", "_send"];
					_cnt = count SYG_SPPMArr;
					_send = if (count _this > 3) then { _this select 3 } else {true};
					if ( _cnt == 0) exitWith {
						if (_send) then {
							["msg_to_user", "*", [["STR_SPPM_0"]], 5, 0, false, "losing_patience"] call XSendNetStartScriptClient; // "SPPM markers not found on map"
							}
					}; //

					_arr = call SYG_updateAllSPPMMarkers;
					if (_send) then {
						["msg_to_user", "*", [["STR_SPPM_1", arg(2), _cnt, _arr select 0, _arr select 1]], 5, 4, false, "message_received"] call XSendNetStartScriptClient; // "All SPPM markers have been updated"
					}
				};

				default {hint localize format["--- bad SPPM params: %1", _this];};
			};
		};

        // ["syg_plants_restore", _player_name, _restore_center_pos, _restore_radious] call XSendNetStartScriptServer;
/**
        // REMOVED as non workable correctly in Arma-1. Vegetation can't be restored as no synchronization betweeen server and client about it.
        case "syg_plants_restore": // restore plants and fences
		{
		    hint localize format["+++ Server received msg: %1",_this];
            _score = [arg(2),arg(3)] call SYG_restoreIslandItems;
            ["syg_plants_restored", arg(1), arg(2), arg(3), _score] call XSendNetStartScriptClient;
		    hint localize format["+++ Server send msg: %1", ["syg_plants_restored", arg(1), arg(2), arg(3)]];
		};
*/
/** Not used at all
        case "say_sound": // say user sound from predefined vehicle/unit
		{
		    private ["_vehicle","_sound"];
		    _vehicle = argopt(1, objNull);   // vehicle to play sound on it
		    if ( isNull _vehicle ) exitWith {hint localize "--- ""say_sound"" _vehicle is null";};
		    _sound   = argopt(2, "");        // sound to play
		    if ( _sound == "" ) exitWith {hint localize "--- ""say_sound"" _vehicle sound is empty";};
		    hint localize format["server ""say_sound"" (%1, %2)", typeOf _vehicle, _sound];
		    _this call XSendNetStartScriptClientAll; // resend to all clients
//		    _vehicle say _sound; // do this on clients only
		};
*/
		// ["GRU_event_scores",_score_id, name player] call XSendNetStartScriptServer;
		case "GRU_event_scores": {
		    private ["_id","_playerName","_score"];
            _id = argopt(1, -1);
            if ( _id < 0) exitWith{(hint localize "--- GRU_event_scores error id: ")  + _id}; // error parameter
            _playerName = argopt(2, "" );
            if (_playerName == "") exitWith{hint localize "--- GRU_event_scores error id: empty or absent player name"};
            _score = argpopt( GRU_specialBonusArr, _id, 0 ); // check for score available
            if( _score > 0 ) then { // this event score is available, clear it now
                GRU_specialBonusArr set [ _id, 0 ]; // use it now
                ["GRU_event_scores", _id, _score, _playerName] call XSendNetStartScriptClient;
            } else {
                ["GRU_event_scores", _id, _score, ""] call XSendNetStartScriptClient;
            };
		};

		// add vehicle to the group
		case "addVehicle": {
		    (_this select 1) addVehicle (_this select 2); // (group player) addVehicle _veh;
		};

        // information about battle air vehicle activity
		case "veh_info": {
		    private ["_veh","_cmd","_cnt"];
		    _params = (_this select 1); // parameters array of this command
		    _veh    = _params select 0; // vehicle
		    _cmd    = _params select 1; // "on"/"off"
		    switch (toLower _cmd) do {
		        case "on"  : {
		            if (!(_veh isKindOf "Air") ) exitWith {
		                _cnt = count SYG_owner_active_air_vehicles_arr;
		                hint localize format["--- ""veh_info"": attempt to add illegal param %1 to the list[%2]", typeOf _veh, _cnt];
		            };
		            if (_veh in SYG_owner_active_air_vehicles_arr) exitWith {};  // already in
		            SYG_owner_active_air_vehicles_arr = SYG_owner_active_air_vehicles_arr + [ _veh ]; // add new vehicle
		            _cnt = count SYG_owner_active_air_vehicles_arr;
		            hint localize format["+++ ""veh_info"": %1 added to list[%2]", typeOf _veh, _cnt];
		        };
		        // remove vehicle
		        case "off" : {
		            SYG_owner_active_air_vehicles_arr = SYG_owner_active_air_vehicles_arr - [ _veh ];
		            _cnt = count SYG_owner_active_air_vehicles_arr;
		            hint localize format["+++ ""veh_info"": %1 removed from list[%2]", typeOf _veh, _cnt];
		        };
		        default {hint localize format["--- ""veh_info"": illegal params %1", _params]};
		    }
		};

        // request to run illum over base, params: [ "illum_over_base", _player_name]
        case "illum_over_base" : {
            // define object to be center of illumination zone (base flag)

            // script will remove all found objects that are closer (in 2D dist) than 10 meters to these poins
            [   _this select 1,
            #ifndef __TT__
                FLAG_BASE // [ flare lunching player name, central object of illumination zone]
            #else
                if (d_own_side == "WEST") then { WFLAG_BASE } else { RFLAG_BASE  }
            #endif
            ] execVM "scripts\baseillum\illumination_full.sqf"
        };

        // ["log2server", _player_name,"literal_message_not_STR_NNN"]...
        case "log2server": {
            hint localize format["+++ Log from ""%1"": %2", _this select 1, _this select 2];
        };

//========================================================================================================== END OF CASES

        default
        {
            hint localize format["--- x_netinitserver.sqf: unknown command detected: %1", _this];
        };
	}; // switch (_this select 0) do
}; // XHandleNetStartScriptServer = {
 
 "d_ns_serv" addPublicVariableEventHandler {
	(_this select 1) spawn XHandleNetStartScriptServer;
};
