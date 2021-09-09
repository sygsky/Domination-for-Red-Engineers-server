// c, created by Xeno, run on server, receive client messages
#include "x_setup.sqf"
#include "x_macros.sqf"
#include "global_vars.sqf"

#define __PRINT__

"d_nv_client" addPublicVariableEventHandler {
	(_this select 1) call XHandleNetVar;
};

// this procedure parse and processs "msg_to_user" server command or compound client message
// In any message to user, param numbers are:
// Offsets:     0,                      1,                 2,                        3,              4,             5,             6
// ["msg_to_user",_player_name | "*" | "",[_msg1, ... _msgN]<,_delay_between_messages<,_initial_delay<,no_title_msg><,sound_name>>>>]
//
// Offset in command array are as follow:
// 0:"msg_to_user": the identifier for this command, must be present
// 1: player name or "" or "*" or vehicle to inform crew only, or array of players, or array of vehicles. Must be present!
// 2: array of each _msg format as is: [<"localize",>"STR_MSG_###"<,<"localize",>_str_format_param...>];. Must be present!
// 3: _delay_between_messages is seconds number to sleep between multiple messages;
// 4: _initial_delay is seconds before first message show;
// 5: no_title_msg if true - no title shown, else shown if false or "" empty string, or scalar <= 0;
// 6: sound_name is the name of the sound to play with first message show on 'say' command; no way to play sound on each message
//
// msg is displayed using titleText ["...", "PLAIN DOWN"] in common(blue)/vehicle(yellow) chat
// msg additionally displayed as title in the middle of the screen

SYG_msgToUserParser = {

    private [ "_msg_arr","_msg_fmt","_name","_np","_delay","_localize","_vehicle_chat","_print_title","_msg_formatted","_sound",
     "_msg_target_found","_ind","_SYG_processSingleStr","_str"];

    //
    // call as: _newStr = _str call _SYG_processSingleStr; // _str is localized or not localized depending on its value.
    //  if _str start with "STR" (case sensitive) it is localized in any case!!!
    //
    _SYG_processSingleStr = {
        private ["_str"];
        _str = toArray(toUpper(_this)); // e.g. [83,84,82,95,83,89,83,95,54,48,52] for  "STR_SYS_604"
        if ( count _str <= 4) exitWith {_this};
        // [83,84,82]
        if ( (_str select 0 == 83) && (_str select 1 == 84) && (_str select 2 == 82) ) exitWith {localize _this };
        _this
    };

    _name = _this select 1;
    _msg_target_found = false;
    _vehicle_chat = false;
    _np = name player;

    // hint localize format["msg_to_user ""%1"":%2", _name, _this select 2];
    if  (typeName _name == "ARRAY") then { // list of names is expected
        if ( count _name == 0) then {_name = "";} // all players are addressed
        else {
        	if (count _name == 2) then {
        		if (typeName (_name select 0) == "SCALAR") then { // special case: [_dist, _pos] as 2nd parameter
        			if (player distance (_name select 1) <= (_name select 0) ) then { // you are close enough to the designated position
        				_name = [_np];
        			};
        		};
        	};
            _ind = _name find (_np);
            if ( _ind >= 0) then {
                _name = _np;
                _msg_target_found = true;
            } else { // player name not found in the input array, verify player vehicle too
            	if ( (vehicle player) in _name ) then { _name = vehicle player } else {_name = _name select 0};
            };
        };
    };

    if (typeName _name == "OBJECT") then { // is msg is sent to the vehicle team only
        _msg_target_found = vehicle player == _name;
        _vehicle_chat = _msg_target_found;
    } else {
        _msg_target_found = _name in [_np, "", "*"," "];
    };

    if ( !_msg_target_found ) exitWith {}; // target for message not found

    // check for initial delay

    if ( (count _this) > 4) then {
        if ( (_this select 4) > 0 ) then {
            sleep ( _this select 4 );
        };
        // try to say sound on 1st text showing
        if ( (count _this) > 6 ) then {
            _sound = _this select 6;
            if ( typeName _sound == "STRING" ) then { playSound _sound };
        };
    };
    _delay = 4; // default delay between messages is 4 seconds
    if ( count _this > 3 ) then {
        if ( (_this select 3) > 0 ) then { _delay = (_this select 4) max 4}; // minimum delay is 4 seconds
    };

    _msg_arr = _this select 2;
#ifdef __PRINT__
    hint localize format["+++ SYG_msgToUserParser: %1", _this];
#endif

	if ( typeName (_msg_arr select 0) != "ARRAY") then { // allow to use single message without array envelope
		_msg_arr = [_msg_arr]
	};
	//
	{
        if (typeName _x == "STRING") then { // it is not array but single string, put it to array and process as usuall
            _x = [_x]; // emulate as array with single item
        };
        // all string are localized only if previous string is "localize" (is skipped from output) or is of format "STR..."
        _localize = false;
        _msg_fmt = [];
        {
            if ( _localize ) then {
                _msg_fmt set [count _msg_fmt, localize (_x)]; // localize this format item
                _localize = false;
            } else {
                if (typeName _x == "STRING" ) then {
                    if ( toLower(_x) == "localize") exitWith { _localize = true; }; // Let's localize next string if it will exists
                    _str = _x call _SYG_processSingleStr;
                    _msg_fmt set [ count _msg_fmt, _str ];
                } else {
                    _msg_fmt set [count _msg_fmt, _x]; // not localize this format item
                };
            };
        } forEach _x; // parse each format item. Any item MUST be an array (or single string without following parameters, or array with a single string, doesnt matter)

        _print_title = (count _this) < 6; // if no setting, let print title in screen middle, not only radio message at bottom
        if (!_print_title) then { // value detected in param array, read and parse it
            _print_title = _this select 5; // it may be boolean (true/false) or scalar (<=0 :false else true)
            if ( typeName _print_title == "SCALAR")  // number <= 0 (false); number > 0 (true)
            then {_print_title = _print_title <= 0} // print only if value set to false
            else {_print_title = !_print_title}; // parse as boolean value, print if value == false
        };

        _msg_formatted = format _msg_fmt; // whole message formatted
 //       hint localize format["+++ ""mag_to_user"": _x %1, _msg_fmt = %2", _x, _msg_fmt];
        if ( _print_title ) then { // no title text disable parameter
            titleText[ _msg_formatted, "PLAIN DOWN" ];
        };

        if (_vehicle_chat) then {
            [_name, _msg_formatted call XfRemoveLineBreak] call XfVehicleChat;
        } else {
            ( _msg_formatted call XfRemoveLineBreak) call XfGlobalChat;
        };

//					hint localize format["msg_to_user: format %1, titleText ""%2""", _msg_fmt, format _msg_fmt];
        if ( (_delay > 0) && ((count _msg_arr) > 1 )) then { sleep _delay; };
    } forEach _msg_arr; // for each messages: _x is format parameters array
};

XHandleNetStartScriptClient = {
	private ["_this"];
	//__DEBUG_NET("x_netinitclient.sqf XHandleNetStartScriptClient",_this)
	switch (_this select 0) do {

		case "ari1msg": {
			#ifdef __TT__
			__isWest
			if (format ["%1",player] == (d_can_use_artillery select 0) || player distance (call compile format ["%1",(d_can_use_artillery select 0)]) <= 15) then {
			#else
			if (!(__AIVer) && (format ["%1",player] == (d_can_use_artillery select 0) || player distance (call compile format ["%1",(d_can_use_artillery select 0)]) <= 15)) then {
			#endif
			private ["_msg","_name"];
			_name = localize "STR_SYS_402";
			_msg = (
				switch (_this select 1) do {
					case 0: {format[localize "STR_SYS_260", _name,_this select 2]}; // "%1 арт.батарея, залпов выпущено: %2, ожидайте, прием."
					case 1: {format[localize "STR_SYS_261", _name, _this select 2]}; // "%1 арт.батарея, заряжаем %2, прием."
					case 2: {format[localize "STR_SYS_262", _name]}; // "%1 арт.батарея, перезарядка орудий, прием."
					case 3: {format[localize "STR_SYS_263", _name]}; //"%1 арт.батарея, обстрел закончили, прием."
					case 4: {format[localize "STR_SYS_264", _this select 2,_this select 3, _this select 4, _this select 5]}; // "Запрашиваю арт.удар боеприпасами (%1), залпов: %2, по следующим координатам: %3 - %4."
					case 5: {format[localize "STR_SYS_265", localize "STR_SYS_404"]}; // "Говорит %1 арт.батарея, вас понял, прием."
					case 6: {format[localize "STR_SYS_266", _name, _this select 2,_this select 3]}; // "%1 арт.батарея, выполнили: боеприпасами %2, залпов: %3."
				}
			);
			_msg call XfHQChat;
			#ifdef __TT__
			};
			#endif
			};
			if (count _this == 4) then {
				if (_this select 3 == 0) then {
					if (player distance AriTarget < 1000) then {AriTarget say "Ari";};
				};
			};
		};
		case "ari2msg": {
			#ifdef __TT__
			__isRacs
			if (format ["%1",player] == (d_can_use_artillery select 1) || player distance (call compile format ["%1",(d_can_use_artillery select 1)]) <= 15) then {
			#else
			if (!(__AIVer) && (format ["%1",player] == (d_can_use_artillery select 1) || player distance (call compile format ["%1",(d_can_use_artillery select 1)]) <= 15)) then {
			#endif
			private ["_msg","_name"];
			_name = localize "STR_SYS_403";
			_msg = (
				switch (_this select 1) do {
					case 0: {format[localize "STR_SYS_260", _name,_this select 2]}; // "%1 арт.батарея, залпов выпущено: %2, ожидайте, прием."
					case 1: {format[localize "STR_SYS_261", _name, _this select 2]}; // "%1 арт.батарея, заряжаем %2, прием."
					case 2: {format[localize "STR_SYS_262", _name]}; // "%1 арт.батарея, перезарядка орудий, прием."
					case 3: {format[localize "STR_SYS_263", _name]}; //"%1 арт.батарея, обстрел закончили, прием."
					case 4: {format[localize "STR_SYS_264", _this select 2,_this select 3, _this select 4, _this select 5]}; // "Запрашиваю арт.удар боеприпасами (%1), залпов: %2, по следующим координатам: %3 - %4."
					case 5: {format[localize "STR_SYS_265", localize "STR_SYS_405"]}; // "Говорит %1 арт.батарея, вас понял, прием."
					case 6: {format[localize "STR_SYS_266", _name, _this select 2,_this select 3]}; // "%1 арт.батарея, выполнили: боеприпасами %2, залпов: %3."
				}
			);
			_msg call XfHQChat;
			#ifdef __TT__
			};
			#endif
			};
			if (count _this == 4) then {
				if (_this select 3 == 0) then {
					if (player distance AriTarget2 < 1000) then {AriTarget2 say "Ari";};
				};
			};
		};
		case "ari_available": {
			__compile_to_var
			#ifndef __TT__
			private ["_name"];
			_name = localize "STR_SYS_402";
			if (ari_available) then {playSound "tune"; format[localize "STR_SYS_267", _name] call XfHQChat;}; // "%1 арт.батарея доступна!"
			if (!ari_available) then {format[localize "STR_SYS_268", _name] call XfHQChat;}; // "%1 арт.батарея будет доступна через несколько минут!"
			#else
			__isWest
				if (ari_available) then {playSound "tune";"Artillery available" call XfHQChat;};
				if (!ari_available) then {"Artillery available again in a few minutes" call XfHQChat;};
			};
			#endif
		};
		case "ari2_available": {
			__compile_to_var
			#ifndef __TT__
			private ["_name"];
			_name = localize "STR_SYS_403";
			if (ari_available) then {playSound "tune"; format[localize "STR_SYS_267", _name] call XfHQChat;}; // "%1 арт.батарея доступна!"
			if (!ari_available) then {format[localize "STR_SYS_268", _name] call XfHQChat;}; // "%1 арт.батарея будет доступна через несколько минут!"
			#else
			__isRacs
				if (ari2_available) then {playSound "tune";"Artillery available" call XfHQChat;};
				if (!ari2_available) then {"Artillery available again in a few minutes" call XfHQChat;};
			};
			#endif
		};
		case "d_parti_add": {
			if (str(player) == (_this select 1) && ((_this select 2) != 0 )) then {
				//player addScore (_this select 2)
				(_this select 2) call SYG_addBonusScore
			};

		};
		case "d_create_box": {
			private ["_the_box", "_box", "_boxscript"];
			_the_box = (
				switch (d_own_side) do {
					case "RACS": {"WeaponBoxGuer"};
					case "EAST": {"WeaponBoxEast"};
					case "WEST": {"WeaponBoxWest"};
				}
			);
			_box = _the_box createVehicleLocal (_this select 1);
			_box setPos (_this select 1);
			#ifdef __RANKED__
			_boxscript = (
					if (__CSLAVer) then {
						"x_scripts\x_weaponcargor_csla.sqf"
				} else {
					if (__ACEVer) then {
						"x_scripts\x_weaponcargor_ace.sqf"
					} else {
						if (__P85Ver) then {
							"x_scripts\x_weaponcargor_p85.sqf"
						} else {
							"x_scripts\x_weaponcargor.sqf"
						}
					}
				}
			);
			#else
			_boxscript = (
				if (__CSLAVer) then {
					"x_scripts\x_weaponcargo_csla.sqf"
				} else {
					if (__ACEVer) then {
						"x_scripts\x_weaponcargo_ace.sqf"
					} else {
						if (__P85Ver) then {
							"x_scripts\x_weaponcargo_p85.sqf"
						} else {
							"x_scripts\x_weaponcargo.sqf"
						}
					}
				}
			);
			#endif
			[_box] execVM _boxscript;
			_box addEventHandler ["killed",{["d_rem_box", position (_this select 0)] call XSendNetStartScriptServer;deleteVehicle (_this select 0)}];
		};
		case "d_rem_box": {
			private ["_the_box", "_nobjs", "_box"];
			_the_box = (
				switch (d_own_side) do {
					case "RACS": {"WeaponBoxGuer"};
					case "EAST": {"WeaponBoxEast"};
					case "WEST": {"WeaponBoxWest"};
				}
			);
			_nobjs = nearestObjects [(_this select 1), [_the_box], 10];
			if (count _nobjs > 0) then {
				_box = _nobjs select 0;
				deleteVehicle _box;
			};
		};
		case "d_air_box": {
			private ["_the_box", "_box", "_boxscript"];
			_the_box = (
				switch (d_own_side) do {
					case "RACS": {"WeaponBoxGuer"};
					case "EAST": {"WeaponBoxEast"};
					case "WEST": {"WeaponBoxWest"};
				}
			);
			_box = _the_box createVehicleLocal (_this select 1);
			_box setPos [(_this select 1) select 0,(_this select 1) select 1,0];
			_boxscript = "x_scripts\x_weaponcargo.sqf";
			if (__CSLAVer) then {
				_boxscript = "x_scripts\x_weaponcargo_csla.sqf";
			} else {
				if (__ACEVer) then {
					_boxscript = "x_scripts\x_weaponcargo_ace.sqf";
				} else {
					if (__P85Ver) then {
						_boxscript = "x_scripts\x_weaponcargo_p85.sqf";
					};
				};
			};
			[_box] execVM _boxscript;
			_box addEventHandler ["killed",{deleteVehicle (_this select 0)}];
		};
		case "sm_res_client": {
			playSound "tune";
			side_mission_winner = (_this select 1);
			bonus_number = (_this select 2);
			#ifdef __RANKED__
			d_sm_running = false;
			#endif
			execVM "x_scripts\x_sidemissionwinner.sqf";
		};
		case "an_countera": {
			[_this select 1] execVM "x_scripts\x_counterattackclient.sqf";
		};
		case "sec_kind": {
			__compile_to_var
			execVM "x_scripts\x_showsecondary.sqf";
		};
		case "sec_solved": {
			_this execVM "x_scripts\x_secsolved.sqf";
		};

		// call: ["target_clear",target_clear, extra_bonus_number, _counterattack_occurred<, _town_player_bonus_arr>] call XSendNetStartScriptClient;
		case "target_clear": {
			hint localize format["+++ client event ""target_clear"": %1", _this];
			// playSound "USSR"; // dont play sound as it is already played from town flag
			private ["_arr","_ind","_bon"];
			target_clear = (_this select 1);
			extra_bonus_number = (_this select 2); // index in the bonus vehicle list
			_arr = []; // set default bonus score array empty
			_bon = -1;// default value as if no bonus info sent from server
			if ( count _this > 4 ) then {
				_arr = _this select 4;// bonus score array [_names_arr, _bonus_arr], if current player is in the _names_arr he receives a bonus award, else not
				_ind = ( _arr select 0 ) find ( name player );
				if (_ind >= 0) then { // Informing the server that the player is online
					((_ind * 0.2) max 0.1) spawn {
						// send confirmation of bonus score received and added
						sleep _this; // sleep different time for each client to ensure smooth execution of corresponding events on server
						["d_ad_sc", name player] call XSendNetStartScriptServer;
					};
					_bon = round( ( (_arr select 1) select _ind )  * (d_ranked_a select 9) ); // // Bonus scores here are coefficients for the unknown on server max score values
				} else { _bon = 0 };
			};
			
			// inform player about counter attack state (param 0) and town bonus (or its absence) (param 1)
			[(_this select 3), _bon, _arr] execVM "x_scripts\x_target_clear_client.sqf"; // set counterattack state ias 1st parameter for execVM, set players bonus score is 2nd one
			call SYG_townStatInit; // reset split score statistics for the next town

		};

		//+++ Sygsky: added for airbase take mission (before any towns)
		case "airbase_clear": { // signal about airbase taken
		    // TODO: enable fanfares after airbase realization, now it is commented
		    hint "airbase cleared after initial battle on it";
			//playSound "fanfare";
			//execVM "x_scripts\x_target_clear_client.sqf";
		}; // "airbase_clear"
		case "take_airbase": { // signal about take airbase started
			playSound "Alarm";
    		hint "take Airbase before start to free Island";
			//execVM "x_scripts\x_target_clear_client.sqf";
		};
		//--- Sygsky: added for airbase take mission (before any towns)

        case "update_fires": {
            hint localize "+++ x_netinitclient.sqf: ""update_fires"" received on client";
            call SYG_firesService;
        };
		case "update_target": {
			//playSound "tune";
			// playMusic "invasion"; // now music is played from lower script run
			execVM "x_scripts\x_createnexttargetclient.sqf";
		};

		// обновление информации о сторонней миссии и инициализация новой миссии на клиенте
		case "update_mission": {
			current_mission_index = _this select 1;
			if ( count _this > 2 ) then {
				current_mission_counter = _this select 2;
			};
			if ( count _this > 3 ) then {// if first point coordinates were changed with some purpose
				x_sm_pos set [0, _this select 3];
			};
			[true] execVM "x_missions\x_getsidemissionclient.sqf";
		};
		case "all_sm_res": {
			__compile_to_var
			current_mission_text = localize "STR_SYS_121"; // "All missions resolved!"
			playSound "fanfare";
			hint current_mission_resolved_text;
		};
		case "stop_sm": {
			current_mission_text = localize "STR_SYS_121_2"; // "The enemy has fled! Forget about his sorties!"
		    [ "msg_to_user", "*", [ [ "STR_SYS_121_1" ] ], 0, 2, false, "fanfare" ] call SYG_msgToUserParser; // The enemy escaped! ..."
		    hint localize "+++ stop_sm == true. No more SM allowed";
		};
		#ifndef __TT__
		// creates markers for jump flags (it is possible to create them on server of course. But this is the decision of Xeno)
		// call as: ["new_jump_flag",_flag, false] call XSendNetStartScriptClient;
		case "new_jump_flag": {
			if (!d_no_para_at_all) then {
				__compile_to_var
				_this execVM "x_scripts\x_newflagclient.sqf";
			};
		};
		#endif

		// this message sent on main tower down. Params are: ["mt_radio_down", mt_radio_down (true or false),name_of_person_killed_tower]]
		case "mt_radio_down": {
			__compile_to_var
			private ["_msg","_name"];
			if (mt_radio_down && ( argp(mt_radio_pos,0) != 0)) then {
				private ["_msg","_ind"];
//				_msg = [localize "STR_SYS_300",localize "STR_SYS_301",localize "STR_SYS_302",localize "STR_SYS_303",localize "STR_SYS_303"] call XfRandomArrayVal;
                _msg = "STR_MAIN_COMPLETED_NUM" call SYG_getLocalizedRandomText; // _msg must be localized
                #ifdef __RANKED__
                if ( (count _this) > 2) then {
                    _name = arg(2);
                    if (typeName (arg(2)) == "STRING") then {
                        private ["_score"];
                        _score =  round(argp(d_ranked_a,9)/2); // lower the points for main target
                        if ( (name player) == _name) then {
                            _msg = format["%1 (+%2)! %3",localize "STR_MAIN_COMPLETED_BY_YOU", _score, _msg ];
                            //player addScore ( _score );
                            _score call SYG_addBonusScore;
                        } else {
                            // inform about new hero
                            if (_name == "" || _name == "Error: No unit") then {
                                _msg = format["(%1)! %2", localize "STR_MAIN_COMPLETED_BY_UNKNOWN", _msg ];
                            } else {
                                _msg = format["(%1)! %2", _name, _msg ];
                            };
                        };
                    };
                };
                #endif
//				call compile format["_ind = floor (random %1);", localize "STR_MAIN_COMPLETED_NUM"];
//				call compile format["_msg = localize ""STR_MAIN_COMPLETED_%1"";", _ind];
				deleteMarkerLocal "main_target_radiotower";
				[ format[localize "STR_SYS_311", _msg], "HQ"] call XHintChatMsg; //"Радиовышка уничтожена... %1"
			};
		};
		case "mt_radio": {
			mt_radio_down = _this select 1;
			mt_radio_pos = _this select 2;
			if (mt_radio_pos select 0 != 0) then {
				["main_target_radiotower", mt_radio_pos,"ICON","ColorBlack",[0.5,0.5],localize "STR_SYS_317" /* "Радиобашня" */,0,"DOT"] call XfCreateMarkerLocal;
				[localize "STR_SYS_310", "HQ"] call XHintChatMsg; //"Приоритетная цель: радиовышка. Задача: уничтожить ее, лишив врага доступа к Интернет."
			};
		};
		case "update_observers": {
			__compile_to_var
			if (update_observers != -1) then {
				if ( count ("NO_DEBUG" call SYG_getTargetTown) == 0) then {	// still no town defined at this moment, skip town name usage
					[format [localize "STR_SYS_40_0",(_this select 1)], "HQ"] call XHintChatMsg; // "Warning! On island discovered presence of enemy spotters, in total %1 men."
				}
				else {
					[format [localize "STR_SYS_40",call SYG_getTargetTownName, (_this select 1)], "HQ"] call XHintChatMsg; // /* "Warning! In the %1 discovered the presence of enemy spotters, in total %2 men." */
				};
			} else {
				hint localize "STR_SYS_41"/* "All enemy spotters are killed..." */;
			};
			playSound "no_more_waiting";
		};
		// ["o_arti",_pos_enemy,_radius] ...
		case "o_arti": {
			[_this select 1, _this select 2] spawn Xoartimsg;
		};
		#ifndef __TT__
		case "d_jet_service_fac": {
			__compile_to_var
			if (!isNull (_this select 1)) then {
				// "Был уничтожен сервис по обслуживанию самолетов. Просите инженеров отремонтировать его ..." call XfHQChat;
				format[localize "STR_SYS_223",localize "STR_SYS_220"] call XfHQChat;
#ifndef __REP_SERVICE_FROM_ENGINEERING_FUND__
                private ["_str_p"];
				_str_p = format ["%1", player];
				if (_str_p in d_is_engineer /*|| __AIVer*/) then {
#endif
					[0] spawn XFacAction;
					hint localize "+++ XFacAction d_jet_service_fac";
#ifndef __REP_SERVICE_FROM_ENGINEERING_FUND__
				};
#endif
			} else {
				//"Сервис по обслуживанию самолетов доступен" call XfHQChat;
				format[localize "STR_SYS_224",localize "STR_SYS_220"] call XfHQChat;
			};
		};
		case "d_chopper_service_fac": {
			__compile_to_var
			if (!isNull (_this select 1)) then {
				//"Был уничтожен сервис по обслуживанию вертолетов. Просите инженеров отремонтировать его..." call XfHQChat;
				format[localize "STR_SYS_223",localize "STR_SYS_221"] call XfHQChat;
#ifndef __REP_SERVICE_FROM_ENGINEERING_FUND__
                private ["_str_p"];
				_str_p = format ["%1", player];
				if (_str_p in d_is_engineer /*|| __AIVer*/) then {
#endif
					[1] spawn XFacAction;
					hint localize "+++ XFacAction d_chopper_service_fac";
#ifndef __REP_SERVICE_FROM_ENGINEERING_FUND__
				};
#endif
			} else {
				//"Сервис по обслуживанию вертолетов доступен" call XfHQChat;
				format[localize "STR_SYS_224",localize "STR_SYS_221"] call XfHQChat;
			};
		};
		case "d_wreck_repair_fac": {
			__compile_to_var
			if (!isNull (_this select 1)) then {
				//"Был уничтожен сервис по восстановлению техники. Просите инженеров отремонтировать его..." call XfHQChat;
				format[localize "STR_SYS_223",localize "STR_SYS_222"] call XfHQChat;
#ifndef __REP_SERVICE_FROM_ENGINEERING_FUND__
                private ["_str_p"];
				_str_p = format ["%1", player];
				if (_str_p in d_is_engineer /*|| __AIVer*/) then {
#endif
					[2] spawn XFacAction;
					hint localize "+++ XFacAction d_wreck_repair_fac";
#ifndef __REP_SERVICE_FROM_ENGINEERING_FUND__
				};
#endif
			} else {
				//"Сервис по восстановлению техники доступен" call XfHQChat;
				format[localize "STR_SYS_224",localize "STR_SYS_222"] call XfHQChat;
			};
		};
		#endif
		#ifdef __MANDO__
		case "d_message": {
			(_this select 1) call XfHQChat;
		};
		#endif
		#ifndef __TT__
		//
		//_unit_killer = [name _killer, name _killed, _killer];
        // ["unit_killer",_unit_killer] call XSendNetStartScriptClient;
		//
		case "unit_killer": { // TODO: lower rank of the killer in the future
			[format [localize "STR_SYS_605"/* %1 killed %2 and looses %3 scores" */, (_this select 1) select 0, (_this select 1) select 1,d_sub_tk_points], "GLOBAL"] call XHintChatMsg;
			if (player == ((_this select 1) select 2)) then {
				// player addScore (d_sub_tk_points * -1)
				(d_sub_tk_points * -1) call SYG_addBonusScore;
			};
		};
		#else
		case "points_array": {
			points_west = (_this select 1) select 0;
			points_racs = (_this select 1) select 1;
			kill_points_west = (_this select 1) select 2;
			kill_points_racs = (_this select 1) select 3;
		};
		case "vec_killer": {
			[format ["%1 destroyed a %2 vehicle. The %1 team looses 20 kill points.", (_this select 1) select 0, (_this select 1) select 1], "GLOBAL"] call XHintChatMsg;
		};
		case "unit_killer": {
			[format ["The %3 player %1 has killed the %4 player %2. The %3 team looses 30 kill points.", (_this select 1) select 0, (_this select 1) select 1, (_this select 1) select 2, (_this select 1) select 3], "GLOBAL"] call XHintChatMsg;
		};
		case "mt_radio_tower_kill": {
			_killedby = (
				switch ((_this select 1)) do {
					case west: {"US"};
					case resistance: {"RACS"};
				}
			);
			hint format ["The %1 team destroyed the main target radio tower and gets 4 points.", _killedby];
		};
		case "mt_sm_over": {
			_killedby2 = (
				switch ((_this select 1)) do {
					case west: {"US"};
					case resistance: {"RACS"};
				}
			);
			hint format ["The %1 team solved the main target mission and gets 3 points.", _killedby2];
		};
		#endif

		// _this = ["make_ai_friendly",_unit_arr]
		case "make_ai_friendly": { // [previous name was "make_ai_captive"
			private ["_arr"];
			_arr = _this select 1;
			if ( typeName _arr == "GROUP" ) then { _arr = units _arr } else {
				if ( typeName _arr != "ARRAY" ) then { _arr = [_arr] };
			};
			{
				_x setCaptive true; if ((rating _x) < 0) then {_x addRating (2500 - (rating _x))};
			} forEach _arr;

		};
		case "mr1_in_air": {
			__compile_to_var
			#ifdef __TT__
			__isWest
			#endif
			if ((_this select 1)) then {(format [localize "STR_SYS_32",d_own_side,1]) call XfHQChat;}; // "%1 мобильный респаун %2 транспортируется по воздуху"
			if (!(_this select 1)) then {(format [localize "STR_SYS_33",d_own_side,1]) call XfHQChat;}; // "%1 мобильный респаун 1 доступен"
			#ifdef __TT__
			};
			#endif
		};
		case "mr2_in_air": {
			__compile_to_var
			#ifdef __TT__
			__isWest
			#endif
			if ((_this select 1)) then {(format [localize "STR_SYS_32",d_own_side,2]) call XfHQChat;}; //"%1 мобильный респаун 2 транспортируется по воздуху"
			if (!(_this select 1)) then {(format [localize "STR_SYS_33",d_own_side,2]) call XfHQChat;}; //"%1 мобильный респаун 2 доступен"
			#ifdef __TT__
			};
			#endif
		};
		#ifdef __TT__
		case "mrr1_in_air": {
			__compile_to_var
			__isRacs
				if ((_this select 1)) then {(format [localize "STR_SYS_32",d_own_side,1]) call XfHQChat;}; // "%1 мобильный респаун %2 транспортируется по воздуху"
				if (!(_this select 1)) then {(format [localize "STR_SYS_33",d_own_side,1]) call XfHQChat;}; // "%1 мобильный респаун 1 доступен"
			};
		};
		case "mrr2_in_air": {
			__compile_to_var
			__isRacs
				if ((_this select 1)) then {(format [localize "STR_SYS_32",d_own_side,2]) call XfHQChat;};  //"%1 Respawn %2 is transported by airlift"
				if (!(_this select 1)) then {(format [localize "STR_SYS_33",d_own_side,2]) call XfHQChat;}; // "%1 Respawn %2 is available"
			};
		};
		#endif

		case "x_wreck_repair": {
			__compile_to_var
			// x_wreck_repair = [_type_name, _name, 0, _player ];  if start wreck repair or
			// x_wreck_repair = [_type_name, _name, 1]; if end of wreck repair
			switch (x_wreck_repair select 2) do {
				case 0: { // start of restore procedure
					//	x_wreck_repair = [_type_name, _name, 0, name _player ];
					if ((name player) == (x_wreck_repair select 3)) then {
						(format [localize "STR_SYS_269_1", x_wreck_repair select 0, localize (x_wreck_repair select 1), d_ranked_a select 29]) call XfHQChat; // "Restoring %1 at %2, your score (+%3). This will take some time..."
						playSound "good_news";
						//player addScore (d_ranked_a select 29);
						(d_ranked_a select 29) call SYG_addBonusScore;
					} else {
						private ["_str"];
						if ( (x_wreck_repair select 3) != "" ) then {
							 _str = format[" (%1)", (x_wreck_repair select 3) ];
						} else {
							 _str = "";
						};
						(format [localize "STR_SYS_269", x_wreck_repair select 0, localize (x_wreck_repair select 1), _str]) call XfHQChat; // "Restoring %1 at %2 (%3), this will take some time..."
					};
				};
				case 1: {
					(format [localize "STR_SYS_270", x_wreck_repair select 0, localize (x_wreck_repair select 1)]) call XfHQChat; // "%1 ready at %2"
				};
			};
		};

		case "recaptured": {
			[(_this select 1),(_this select 2)] spawn XRecapturedUpdate;
		};
		case "mt_spotted": {
		    private ["_townArr","_musicName"];
			localize "STR_SYS_65" call XfHQChat; // "The enemy revealed you..."
			if ( !(call SYG_playExtraSounds) ) exitWith{};
            _townArr  = "NO_DEBUG" call SYG_getTargetTown;
            if (count _townArr == 0) exitWith{};
            _townName = _townArr select 1;
            _musicName = "";
            _musicName = call SYG_getTargetTownDetectedSound;
            if (_musicName != "" ) then {playMusic _musicName};
		};
		#ifdef __AI__
		case "d_ataxi": {
			if (player == (_this select 2)) then {
				switch (_this select 1) do {
					case 0: {(localize "STR_SYS_1182") call XfHQChat}; // "Air taxi is on the way... hold your position!!!"
					case 1: {(localize "STR_SYS_1183") call XfHQChat; d_heli_taxi_available = true}; // "Air taxi canceled, you've died !!!"
					case 2: {(localize "STR_SYS_1184") call XfHQChat; d_heli_taxi_available = true}; // "Air taxi damaged or destroyed !!!"
					case 3: { (localize "STR_SYS_1185") call XfHQChat}; // "Air taxi heading to base in a few seconds !!!"
					case 4: {(localize "STR_SYS_1186") call XfHQChat; d_heli_taxi_available = true}; // "Air taxi leaving now, have a nice day !!!"
				};
			};
		};
		case "d_ai_kill": { // TODO: check killer to be vehicle
			if ((_this select 1) in (units (group player))) then {
				if (player == leader (group player)) then {
					//player addScore (_this select 2);
					(_this select 2) call SYG_addBonusScore;
				};
			};
		};
		#endif
		// [ "syg_observer_kill", _killer, primaryWeapon _observer, _observer] call XSendNetStartScriptClient;
		case "syg_observer_kill" : {
            private ["_score","_str","_sound_obj","_killer"];
            _score = argp( d_ranked_a, 27 );
            _killer = arg(1);
		    if( isNull _killer ) then { // killer unknown
                _sound_obj = arg(3); // play sound at observer position
                (format[localize "STR_SYS_1162","STR_SYS_COR_NUM" call SYG_getLocalizedRandomText]) call XfHQChat; // "Spotter died..."
		    } else {
                _sound_obj = _killer; // play sound on sutable position
                if ( str(_killer) == str(player) ) exitWith  { // killer is this player
                    // add scores
                    //player addScore _score;
                    _score call SYG_addBonusScore;
                	_str  = if (count _this > 2) then { format[" (%1)", arg(2)]} else { (" (no WPN)"); };
                    _str1 = if (count _this > 3) then { format[ localize "STR_SYS_1163", round( _killer distance (_this select 3)) ] } else { "" }; // " from a distance of %1 m."
                    hint localize format["+++ x_netinitclient.sqf: Observer%1 killed by you%2", _str, _str1 ];
                    (format[localize "STR_SYS_1160", _score + 1, _str1]) call XfHQChat; // T'was a spotter (+%1%2)!
                };
               	// Other player/AI killed an observer
				if (side _killer != d_side_player) exitWith {
					(format[localize "STR_SYS_1162",localize "STR_SYS_COR_5"]) call XfHQChat; //  "Spotter died... in an accident"};
				};
				// TODO: check if killer is AI assigned to the one of players
				(format[localize "STR_SYS_1161", name _killer, _score + 1]) call XfHQChat; // Spotter killed by %1 (+%2)!
		    };
            // common code
            //playSound "no_more_waiting";
            ["say_sound", _sound_obj, "no_more_waiting"] call XHandleNetStartScriptClient; // inform me/all about next observer death
            // show message
		};
		// to inform player about his server stored data
		// sent as follows: ["d_player_stuff", _staff, SYG_dateStart, _sound, _index] call XSendNetStartScriptClient;
		case "d_player_stuff": {
		    private ["_pname"];
		    _pname = argp(arg(1),2);
			if (name player == _pname) then {
				__compile_to_var
				SYG_dateStart = arg(2); // set server start date
				if (count _this > 3) then {SYG_suicideScreamSound = arg(3)}; // suicide sound sent to player
				SYG_playerID = if (count _this > 4) then {_this select 4} else {-1}; // // index in player list on server
				hint localize format["+++ x_netinitclient.sqf: ""d_player_stuff"", SYG_dateStart = %1, SYG_suicideScreamSound %2, SYG_playerID %3",
				SYG_dateStart,
				call SYG_getSuicideScreamSound,
				SYG_playerID];
				if (SYG_playerID == 0) then { // Im FIRST player in the game
					SYG_townMaxScore = (d_ranked_a select 9); // 02-APR-2021 value was +40
					publicVariable "SYG_townMaxScore"; // set public variable with the maximum scores bonus per town
				};
			};
		};
		case "d_hq_sm_msg": {
			private ["_msg"];
			_msg = (
				switch (_this select 1) do {
					case 0: {format [localize "STR_SYS_182", 10]}; //"The enemy troops will be at place in less than %1 minutes"
					case 1: {format [localize "STR_SYS_182", 5]};
					case 2:  {format [localize "STR_SYS_182", 2]};
				}
			);
			_msg call XfHQChat;
		};
		case "MHQ_respawned": {
			sleep 1.0; // wait for variable to be initialized
			if ( !isNil (_this select 1) ) then
			{
				call compile format ["%1 call SYG_reammoMHQ;", _this select 1 ];
//#ifdef __PRINT__
//				hint localize format["+++ 'MHQ_respawned' is called with var '%1'", _this select 1];
//#endif
//			} else {
//#ifdef __PRINT__
//				hint localize format["--- 'MHQ_respawned' called with NIL variable %1 ", _this select 1];
//#endif
			};	
		};
		case "flare_launched":	{ // add flare light for client
			(_this select 1) execVM "scripts\emulateFlareFiredLocal.sqf";
		};


        // this command is received and processed ONLY on clients, just if started on client too
        // some message to user, params:
        //              1,                      2,                 3,                       4,              5,            6,           7
        // ["msg_to_user",_player_name | "*" | "",[_msg1, ... _msgN]<,_delay_between_messages<,_initial_delay<,no_title_msg><,sound_name>>>>]
        // each _msg format is: [<"localize",>"STR_MSG_###"<,<"localize",>_str_format_param...>];
        // _delay_between_messages is seconds number to sleep between multiple messages
        // _initial_delay is seconds before first message show
        // no_title_msg if true - no title shown, else shown if false or "" empty string
        // sound_name is the name of the sound to play with first message show on 'say' command
        //
        // msg is displayed using titleText ["...", "PLAIN DOWN"] in common(blue)/vehicle(yellow) chat
        // msg additionally displayed as title in the middle of the screen

		case "msg_to_user":	{
		    _this call SYG_msgToUserParser;
		}; // case "msg_to_user"

//		case "GRU_msg_patrol_killed":
//		{
//			__SetGVar(PATROL_COUNT, __GetGVar(PATROL_COUNT)-1 max 0);
//		}; // TODO: message about patrol killed
		case "GRU_msg_patrol_detected"; // TODO: check new patrol in the future, now simply inform player about
		case "GRU_msg": {
			hint localize format["+++ x_netinitclient.sqf: ""GRU_msg"" params %1", _this ];
			if (arg(0) == "GRU_msg_patrol_detected") then
			{
//			    if ( __HasGVar(PATROL_COUNT) ) then
//			    {
//			        _cnt = __GetGVar(PATROL_COUNT);
//        			//hint localize format["Patrol count is %1", _cnt ];
//				};
                _this set[0, "GRU_msg"];
			};
			_this call GRU_procClientMsg;
		};
/* Comment not developed options
		// SPPM event handler on client (receive messages from server)
		case "SPPM": {

		};

		case "syg_plants_restored": { // message about restore result to subtract corresponding scores from user
		// params are: ["syg_plants_restored", _name, _pos, _radious, _score] call XSendNetStartScriptClient;
		    private ["_score"];
            _score = [arg(2),arg(3)] call SYG_restoreIslandItems; // restore items on all client to show result for players
			if ( arg(1) == (name player)) then // this player name!!!
			{
    		    hint localize format["+++ Client received msg: %1",_this];
                _score = arg(4);
                //player addScore -_score; // subract score by number of resurrected items
                (-_score) call SYG_addBonusScore;
                format[localize "STR_RESTORE_DLG_7", _score] call XfGlobalChat; // "scores subtracted %1"
			};
		};
*/
		//
		// say user sound from predefined vehicle/unit ["say_sound",_object | [x,y,z],_sound, [,"-",_player_name]] or
		//                                             ["say_sound","LIST", _arr, [,"-",_player_name]]  where _arr is array of [_object, _sound, sleep time]
        case "say_sound": {

			//
			// call as: [_x, _sound, _sleep <,"-",_name>] spawn say_proc;
			//
			_say_proc = {
				private ["_obj","_pos","_nil","_sound"];
			    if ( ( argopt( 3, "" ) == "-" ) && ( argopt( 4, "" ) == ( name player ) ) ) exitWith {}; // This player not assigned to play this this sound
				_obj = _this select 0;
				if ((_obj distance player) > 1000 ) exitWith{}; // too far from sound source
				_pos = [];
				if (typeName _obj == "ARRAY") then {_pos = _obj} // position designated
				else {  // it is position: e.g. player is dead but body  has position or position of teleport etc
					if ( typeName _obj == "OBJECT") then {
						if (_obj isKindOf "CAManBase") then  {
							 if ( !(alive _obj) ) then { _pos = position _obj };
						};
					};
				};

				if ( count _pos > 0 ) then { // emulate object to say sound
					sleep (0.01 max (_this select 2));
					_nil = "Logic" createVehicleLocal _pos; // use temp object to play sound
					_nil say (_x select 1);
					hint localize format["+++ say_sound ""%1""", (_this select 1)];
					sleep 0.01;
					_sound = nearestObject [position _nil, "#soundonvehicle"];
					if (isNull _sound) then {
						sleep 20; // sleep longer than known max sound length (10 seconds)
					} else {
						waitUntil {isNull _sound};
					};
					deleteVehicle _nil;
				} else {
					sleep (_this select 2);
					_obj say (_this select 1); // this is done on the client only you remember?
					hint localize format["+++ say_sound ""%1""", (_this select 1)];
				};
			};

		    private ["_nil","_obj","_sound","_exit","_pos","_arr"];
		    // hint localize format["+++ open.sqf _sound %1, player %2", _sound, player];

		    _arr = [];

		    if ( typeName (_this select 1) != "STRING") then {
		    	_arr = [[_this select 1, _this select 2, 0, argopt(3,""), argopt(4,"")]]; // array of 1 item
		    } else {
		    	_arr = _this select 2
		    };

		    {
		    	_x spawn _say_proc;
		    }forEach _arr;
		};

		case "play_music": { // FIXME: is it called anywhere? Yes, in king quest (hotel SM)
		    switch (_this select 1) do {
		        case "forecast_change" : {call SYG_playWeatherForecastMusic};
		        case "OFP";
		        default { call SYG_playRandomOFPTrack};
		        hint localize "+++ king escape music played";
		    };
		}; // case "play_misic"

		// adds all user actions on barracks created
        case "add_barracks_actions": {
		    [arg(2)] execVM "scripts\barracks_add_actions.sqf"; // do this on clients only
		};

		// somebody requested GRU score
		// ["GRU_event_scores", _id, _score, _playerName] call XSendNetStartScriptClient;
		case "GRU_event_scores": {
			hint localize format["+++ Client ""GRU_event_scores"" event with %1", _this];
            private [/*"GRU_event_scores",*/"_score","_id","_playerName"];
            _id = argopt(1, -1);
            if ( _id < 0) exitWith{(hint localize "--- GRU_event_scores error id: ")  + _id}; // error parameter
            _score = argopt(2,0);
            if ( _score > 0 ) then {
                _playerName = argopt(3, "" );
                if ( _playerName == (name player)) then {
                    //player addScore _score;
                    _score call SYG_addBonusScore;
                    format[localize argp(GRU_specialBonusStrArr,_id),_score] call XfGlobalChat; // "you've got a prize for your observation/curiosity"
                    ["say_sound", player, "no_more_waiting"] call XSendNetStartScriptClientAll;
                    // playSound "no_more_waiting";
                };
            };
            GRU_specialBonusArr set [ _id, 0 ]; // never more this event could occure
		};

        // [ "sub_fac_score", _str, _param1, _param2 ]
        case "sub_fac_score": {
            [ "msg_to_user", name player, [ [ _this select 1, _this select 2, _this select 3 ] ] ] call SYG_msgToUserParser;
            if (name player == _this select 3) then {
                _score = (d_ranked_a select 20);
                if ( _score > 0 ) then { _score = - _score };
                //player addScore _score;
                _score call SYG_addBonusScore;
            };
        };
        // [ "shortnight", _command<, _param<s>_for_command> ]
        case "shortnight": {
            switch (_this select 1) do {
                case "skip": { // skip some time
                    private ["_time2skip"];
                    _time2skip = (_this select 2); // hours to skip
                    if ( typeName _time2skip ==  "ARRAY") then { _time2skip = _time2skip select 0};
                    hint localize format["+++ shortnight skip:: daytime %1, skiptime %2, time %3, date %4;", daytime, _time2skip, time, date];
                    skipTime _time2skip;
                    hint localize format["+++ shortnight skip: after skip daytime %1, time %2, date %3;", daytime, time, date];
                };
                case "info": { // print info on day/night time
                    private ["_id","_str", "_playSound"];
                    _id = _this select 2; // message id to be printed about day time begin
                    if ( typeName _id ==  "ARRAY") then { _id = _id select 0};

                    sleep  (random 60);
                    _str = localize (format["STR_TIME_%1",_id]);
                    hint localize format["+++ [""shortnight"",""info""]:time %1, date %2, str %3;", time, date, _str ];
                    titleText [ _str, "PLAIN"];

                    //+++++++++++++++++++++++++++++++++++++++++++++++++++++
                    // say something on a next period of day coming if player not in a vehicle with engine on (too noisy to listen music)
                    _playSound = vehicle player == player;
                    if (!_playSound) then {_playSound = ! (isEngineOn  (vehicle player) ) };

                    if (_playSound ) then {
                        _str = _id call SYG_getDayTimeIdRandomSound;
                        if ( _str != "" ) then {playSound _str};
                    };
                    if (_id == 0) then {	// night detected, run lighthouse hawler
						// TODO: #450: add lighthouse night hawler sounds
						//[] execVM "\nothing.sqf";
                    };
                    //-------------------------------------------------------
                };
            };
        };
        // mark user as participant of SM
        case "was_at_sm" : {
            if (count _this < 2) exitWith {hint localize ["--- x_netinitclient.sqf: %1", _this];};
            private ["_val"];
            _val =  _this select 1;
            if ( typeName ( _val ) != "ARRAY" ) then {
                if ( typeName ( _val ) != "STRING" ) then { _val  = str (_val); };
                _val = [_val];
            };
//          hint localize ["+++ %1 : %2", x_netinitclient.sqf];
            if ( (name player) in (_val) ) then { d_was_at_sm = true; playSound "good_news" };
        };

        // response from server to confirm you request on illumination of base: [ "illum_over_base", _player_name]
        case "illum_over_base" : {
            if (name player == _this select 1) exitWith {
            #ifdef __RANKED__
                private ["_score","_rank_id"];
                // inform player about his illumination and consume scores
                _rank_id = player call XGetRankIndexFromScore; // rank index in any case (extended system (may returns value > 6 (colonel rank index)) or not)
                _score = (_rank_id max 1)* 10; // How costs the illumination above base, for Private as for Corporal
                // "Over the base, a regular launch of flares began. Points taken: -%1"
                [ "msg_to_user", "",  [ ["STR_ILLUM_3", _score ] ], 0, 2, false, "good_news" ] call SYG_msgToUserParser;
                //player addScore -_score;
                (-_score) call SYG_addBonusScore;
            #else
                // "Over the base, a regular launch of flares began"
                [ "msg_to_user", "",  [ ["STR_ILLUM_3_1" ] ], 0, 2, false, "good_news" ] call SYG_msgToUserParser;
            #endif
            };
            // inform others about illumination start
            // "%1 provided regular launch of flares over our base"
            [ "msg_to_user", "",  [ [ "STR_ILLUM_3_0", _this select 1 ] ], 0, 2, false, "message_received" ] call SYG_msgToUserParser;
        };

        // Change score of the player
        // [ "change_score", "" || "*" || "name" || [ _name1, _name2..., _nameN ], _score_to_subtract<, _msg_parser_arr> ] execVM...
        case "change_score" : {
        	private [ "_name", "_found" ];
        	hint localize format["*** change_score _this: %1", _this];
        	_name = _this select 1;
        	_found = if ( typeName _name == "ARRAY" ) then { ( name player ) in _name; } else { _name in [ "", "*", name player ] };
        	if ( _found ) then {
        		//player addScore ( _this select 2 );
        		( _this select 2 ) call SYG_addBonusScore;
        	};
			if ( ( count _this ) > 3 ) exitWith { ( _this select 3 ) call SYG_msgToUserParser}; // try to print message if exists
        };

/*
         // reveal vehicle (MHQ in main) to all players
        case "revealVehicle":
        {
            player reveal (_this select 1);
        };
*/

//========================================================================================================== END OF CASES

        default {
            hint localize format["--- x_netinitclient.sqf: unknown command detected: %1", _this];
        };


	}; //switch (_this select 0) do {
}; // XHandleNetStartScriptClient = {

 "d_ns_client" addPublicVariableEventHandler {
	(_this select 1) spawn XHandleNetStartScriptClient;
};       