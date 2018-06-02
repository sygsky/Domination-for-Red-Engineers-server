// x_netinitclient.sqf, created by Xeno, run on server, receive client messages
#include "x_setup.sqf"
#include "x_macros.sqf"
#include "global_vars.sqf"

//#define __PRINT__

"d_nv_client" addPublicVariableEventHandler {
	(_this select 1) call XHandleNetVar;
};

XHandleNetStartScriptClient = {
	private ["_this"];
	__DEBUG_NET("x_netinitclient.sqf XHandleNetStartScriptClient",_this)
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
					case 0: {format [localize "STR_SYS_260", _name,_this select 2]}; // "%1 арт.батарея, залпов выпущено: %2, ожидайте, прием."
					case 1: {format [localize "STR_SYS_261", _name, _this select 2]}; // "%1 арт.батарея, заряжаем %2, прием."
					case 2: {format [localize "STR_SYS_262", _name]}; // "%1 арт.батарея, перезарядка орудий, прием."
					case 3: {format [localize "STR_SYS_263", _name]}; //"%1 арт.батарея, обстрел закончили, прием."
					case 4: {format [localize "STR_SYS_264", _this select 2,_this select 3, _this select 4, _this select 5]}; // "Запрашиваю арт.удар боеприпасами (%1), залпов: %2, по следующим координатам: %3 - %4."
					case 5: {format[localize "STR_SYS_265", localize "STR_SYS_404"]}; // "Говорит %1 арт.батарея, вас понял, прием."
					case 6: {format [localize "STR_SYS_266", _name, _this select 2,_this select 3]}; // "%1 арт.батарея, выполнили: боеприпасами %2, залпов: %3."
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
					case 0: {format [localize "STR_SYS_260", _name,_this select 2]}; // "%1 арт.батарея, залпов выпущено: %2, ожидайте, прием."
					case 1: {format [localize "STR_SYS_261", _name, _this select 2]}; // "%1 арт.батарея, заряжаем %2, прием."
					case 2: {format [localize "STR_SYS_262", _name]}; // "%1 арт.батарея, перезарядка орудий, прием."
					case 3: {format [localize "STR_SYS_263", _name]}; //"%1 арт.батарея, обстрел закончили, прием."
					case 4: {format [localize "STR_SYS_264", _this select 2,_this select 3, _this select 4, _this select 5]}; // "Запрашиваю арт.удар боеприпасами (%1), залпов: %2, по следующим координатам: %3 - %4."
					case 5: {format[localize "STR_SYS_265", localize "STR_SYS_405"]}; // "Говорит %1 арт.батарея, вас понял, прием."
					case 6: {format [localize "STR_SYS_266", _name, _this select 2,_this select 3]}; // "%1 арт.батарея, выполнили: боеприпасами %2, залпов: %3."
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
			if (str(player) == (_this select 1)) then {player addScore (_this select 2)};
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
			_box addEventHandler ["killed",{["d_rem_box",position _this select 0] call XSendNetStartScriptServer;deleteVehicle (_this select 0)}];
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
		// last target town cleared, no more target remained !!!
		case "target_clear": {
			playSound "fanfare";
			target_clear = (_this select 1);
			extra_bonus_number = (_this select 2);
			execVM "x_scripts\x_target_clear_client.sqf";
		};

		//+++ Sygsky: added for airbase take mission (before any towns)
		case "airbase_clear": { // signal about airbase taken
		    // TODO: enable fanfares after airbase realization, now it is commented
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
            hint localize "x_scripts/x_funcs/x_netinitclient.sqf: ""update_fires"" received on client";
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
			if ( count _this > 2 ) then
			{
				current_mission_counter = _this select 2;
			};
			if ( count _this > 3 ) then // if first point coordinates were changed with some purpose
			{
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
		#ifndef __TT__
		case "new_jump_flag": {
			if (!d_no_para_at_all) then {
				__compile_to_var
				execVM "x_scripts\x_newflagclient.sqf";
			};
		};
		#endif
		// this message sent on main tower down. Params are: ["mt_radio_down", mt_radio_down (true or false),name_of_person_killed_tower]]
		case "mt_radio_down": {
			__compile_to_var
			if (mt_radio_down && ( argp(mt_radio_pos,0) != 0)) then
			{
				private ["_msg","_ind"];
//				_msg = [localize "STR_SYS_300",localize "STR_SYS_301",localize "STR_SYS_302",localize "STR_SYS_303",localize "STR_SYS_303"] call XfRandomArrayVal;
                _msg = "STR_MAIN_COMPLETED_NUM" call SYG_getLocalizedRandomText; // _msg must be localized
                #ifdef __RANKED__
                if ( (count _this) > 2) then
                {
                    _name = arg(2);
                    if (typeName (arg(2)) == "STRING") then
                    {
                        _score =  argp(d_ranked_a,9);
                        if ( (name player) == _name) then
                        {
                            _msg = format["%1 (+%2)! %3",localize "STR_MAIN_COMPLETED_BY_YOU", _score, _msg ];
                            player addScore ( _score );
                        }
                        else
                        {
                            // inform about new hero
                            if (_name == "") then
                            {
                                _msg = format["(%1)! %2", localize "STR_MAIN_COMPLETED_BY_UNKNOWN", _msg ];
                            }
                            else
                            {
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
				[format [localize "STR_SYS_40"/* "Внимание! В городе обнаружено присутствие вражеских корректировщиков, всего %1 чел." */,(_this select 1)], "HQ"] call XHintChatMsg;
			} else {
				hint localize "STR_SYS_41"/* "Все вражеские корректировщики уничтожены..." */;
			};
		};
		case "o_arti": {
			(_this select 1) spawn Xoartimsg;
		};
		#ifndef __TT__
		case "d_jet_service_fac": {
			__compile_to_var
			if (!isNull (_this select 1)) then {
				// "Был уничтожен сервис по обслуживанию самолетов. Просите инженеров отремонтировать его ..." call XfHQChat;
				format[localize "STR_SYS_223",localize "STR_SYS_220"] call XfHQChat;
				_str_p = format ["%1", player];
				if (_str_p in d_is_engineer /*|| __AIVer*/) then {
					[0] spawn XFacAction;
				};
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
				_str_p = format ["%1", player];
				if (_str_p in d_is_engineer /*|| __AIVer*/) then {
					[1] spawn XFacAction;
				};
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
				_str_p = format ["%1", player];
				if (_str_p in d_is_engineer /*|| __AIVer*/) then {
					[2] spawn XFacAction;
				};
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
		case "unit_killer": { // TODO: lower rank of thee killer in the future
			[format [localize "STR_SYS_605"/* "%1 убил %2. %1 наказан на %3 очков!" */, (_this select 1) select 0, (_this select 1) select 1,d_sub_tk_points], "GLOBAL"] call XHintChatMsg;
			if (player == ((_this select 1) select 2)) then {player addScore (d_sub_tk_points * -1)};
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
		case "make_ai_captive": {
			(_this select 1) setCaptive true;
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
				if ((_this select 1)) then {(format [localize "STR_SYS_32",d_own_side,2]) call XfHQChat;}; //"%1 мобильный респаун 2 транспортируется по воздуху"
				if (!(_this select 1)) then {(format [localize "STR_SYS_33",d_own_side,2]) call XfHQChat;}; //"%1 мобильный респаун 2 доступен"
			};
		};
		#endif
		case "x_wreck_repair": {
			__compile_to_var
			switch (x_wreck_repair select 2) do {
				case 0: {
					(format [localize "STR_SYS_269", x_wreck_repair select 0, localize (x_wreck_repair select 1)]) call XfHQChat; // "%2, восстанавливается %1. Это потребует времени..."
				};
				case 1: {
					(format [localize "STR_SYS_270", x_wreck_repair select 0, localize (x_wreck_repair select 1)]) call XfHQChat; // "%2 завершил работу над  %1"
				};
			};
		};
		case "recaptured": {
			[(_this select 1),(_this select 2)] spawn XRecapturedUpdate;
		};
		case "mt_spotted": {
			localize "STR_SYS_65" /* "Враг обнаружил вас..." */ call XfHQChat;
		};
		#ifdef __AI__
		case "d_ataxi": {
			if (player == (_this select 2)) then {
				switch (_this select 1) do {
					case 0: {(localize "STR_SYS_1182") call XfHQChat}; // "Air taxi is on the way... hold your position!!!"
					case 1: {(localize "STR_SYS_1183") call XfHQChat;d_heli_taxi_available = true}; // "Air taxi canceled, you've died !!!"
					case 2: {(localize "STR_SYS_1184") call XfHQChat;d_heli_taxi_available = true}; // "Air taxi damaged or destroyed !!!"
					case 3: { (localize "STR_SYS_1185") call XfHQChat}; // "Air taxi heading to base in a few seconds !!!"
					case 4: {(localize "STR_SYS_1186") call XfHQChat;d_heli_taxi_available = true}; // "Air taxi leaving now, have a nice day !!!"
				};
			};
		};
		case "d_ai_kill": { // TODO: check killer to be vehicle
			if ((_this select 1) in (units (group player))) then {
				if (player == leader (group player)) then {
					player addScore (_this select 2);
				};
			};
		};
		#endif
		case "syg_observer_kill" : {
            if (str(arg(1)) == str(player)) then
            {
                hint localize format["x_netinitclient.sqf: Observer killed by %1", name player];
                // add scores
                player addScore argp( d_ranked_a, 27 );
                // play music
                playSound "no_more_waiting";
                // show message
                (localize "STR_SYS_1160") call XfHQChat; // "Twas observer
            };
		};
		// to inform player about his server stored data
		case "d_player_stuff": {
		    _pname = argp(arg(1),2);
			if (name player == _pname) then {
				__compile_to_var
				SYG_dateStart = arg(2); // set server start date
				hint localize format["d_player_stuff: SYG_dateStart = %1", SYG_dateStart];
			};
		};
		case "d_hq_sm_msg": {
			private ["_msg"];
			_msg = (
				switch (_this select 1) do {
					case 0: {format [localize "STR_SYS_182", 10]}; //"Вражеские войска будут на месте крушения менее чем через %1 минут"
					case 1: {format [localize "STR_SYS_182", 5]}; //"Вражеские войска будут на месте крушения менее чем через %1 минут"
					case 2:  {format [localize "STR_SYS_182", 2]}; //"Вражеские войска будут на месте крушения менее чем через %1 минуты"
				}
			);
			_msg call XfHQChat;
		};
		case "MHQ_respawned": {
			sleep 1.0; // wait for variable to be initialized
			if ( !isNil (_this select 1) ) then
			{
				call compile format ["%1 call SYG_reammoMHQ;", _this select 1 ];
#ifdef __PRINT__
				hint localize format["'MHQ_respawned' is called with var '%1'", _this select 1];
#endif		
			}
			else
			{
#ifdef __PRINT__
				hint localize format["'MHQ_respawned' called with NIL variable %1 ", _this select 1];
#endif		
			};	
		};
		case "flare_launched":	{ // add flare light for client
			(_this select 1) execVM "scripts\emulateFlareFiredLocal.sqf";
		};

		 // some message to user, params: ["msg_to_user",_player_name,[_msg1, ... _msgN]<,_delay_between_messages<,_initial_delay>>]
		 // each _msg format is: [<"localize",>"STR_MSG_###"<,<"localize",>_str_format_param...>];
		 // msg is displayed using titleText ["...", "PLAIN DOWN"];
		case "msg_to_user":	{
			private [ "_msg_arr","_msg_res","_name","_delay","_localize" ];
/*
			if ((_this select 0) == "msg_about_new_patrol") then
			{
				__SetGVar(PATROL_COUNT,(__GetGVar(PATROL_COUNT)+1) min 5);
			};
*/
			_name = _this select 1;
			// hint localize format["msg_to_user ""%1"":%2", _name, _this select 2];
			if  (typeName _name == "ARRAY") then
			{
			    if ( count _name == 0) then {_name = "";}
			    else
			    {
			        _ind = _name find (name player);
			        if ( _ind >= 0) then
			        {
			            _name = name player;
			        }
			        else
			        {
			            _name = _name select 0;
			        };
			    };
			};
			if ((_name == name player) || (_name == "") || (_name == "*")) then // msg to this player || any
			{
				// check for initial delay
				if ( (count _this) > 4) then
				{
					if ((_this select 4) > 0) then {sleep (_this select 4);};
				};
				_delay = 4; // default delay between messages is 4 seconds
				if ( count _this > 3) then
				{
					if ((_this select 3) > 0) then { _delay = (_this select 4);};
				};

				_msg_arr = _this select 2;
#ifdef __PRINT__
				hint localize format["x_netinitclient.sqf: ""msg_to_user"" params [%1,[%2 item(s)]]", _name, count _msg_arr ];
#endif		
				// all string are localized only if previous string is "localize" (is skipped from output)
				{
					_localize = false;
					_msg_res = [];
					{
						if ( _localize ) then
						{
							_msg_res set [count _msg_res, localize (_x)]; // localize this format item
							_localize = false;
						}
						else
						{
							if (typeName _x == "STRING" ) then 
							{
								if ( toLower(_x) == "localize") then
								{_localize = true;}
								else
								{
									_str = toArray(toUpper(_x)); // e.g. [83,84,82,95,83,89,83,95,54,48,52] for  "STR_SYS_604"
                					// [83,84,82]
                					if ( count _str > 3) then
                					{
                                        if ( (_str select 0 == 83) && (_str select 1 == 84) && (_str select 2 == 82) ) then
                                        { _msg_res set [count _msg_res, localize (_x)] }
                                        else
                                        { _msg_res set [count _msg_res, _x]; };
									} else {_msg_res set [count _msg_res, _x];};
								};
							} 
							else
							{
								_msg_res set [count _msg_res, _x]; // not localize this format item

							};
						};
					} forEach _x; // for each format item
					titleText[ format _msg_res, "PLAIN DOWN" ];
					((format _msg_res) call XfRemoveLineBreak) call XfGlobalChat;

//					hint localize format["msg_to_user: format %1, titleText ""%2""", _msg_res, format _msg_res];
					if (_delay > 0) then { sleep _delay; };
				} forEach _msg_arr; // for each messages: _x is format parameters array
			};
		}; // case "msg_to_user"

//		case "GRU_msg_patrol_killed":
//		{
//			__SetGVar(PATROL_COUNT, __GetGVar(PATROL_COUNT)-1 max 0);
//		}; // TODO: message about patrol killed
		case "GRU_msg_patrol_detected"; // TODO: check new patrol in the future, now simply inform player about
		case "GRU_msg": {
			hint localize format["x_netinitclient.sqf: ""GRU_msg"" params %1", _this ];
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

		case "syg_plants_restored": { // message about restore result to subtract corresponding scores from user
		// params are: ["syg_plants_restored", _name, _pos, _radious, _score] call XSendNetStartScriptClient;
            _score = [arg(2),arg(3)] call SYG_restoreIslandItems; // restore items on all client to show result for players
			if ( arg(1) == (name player)) then // this player name!!!
			{
    		    hint localize format["+++ Client received msg: %1",_this];
                _score = arg(4);
                player addScore -_score; // subract score by number of resurrected items
                format[localize "STR_RESTORE_DLG_7", _score] call XfGlobalChat; // "scores subtracted %1"
			};
		};

        case "say_sound": // say user sound from predefined vehicle/unit
		{
		    arg(1) say arg(2); // do this on clients only
		};

		case "play_music": { // FIXME: is it called anywhere?
		    switch (_this select 1) do
		    {
		        case "OFP";
		        default { call SYG_playRandomOFPTrack};
		        hint localize "+++ king escape music played";
		    };
		}; // case "play_misic"


		// ["add_barracks_actions", AI_HUT, "AlarmBell"] call XSendNetStartScriptServer;
        case "add_barracks_actions": // adds all user actions on barracks created
		{
		    [arg(2)] execVM "scripts\barracks_add_actions.sqf"; // do this on clients only
		};

		// somebody requested GRU score
		// ["GRU_event_scorаes", _score, _id, ""] call XSendNetStartScriptClient;

		case "GRU_event_scores":
		{
            _id = argopt(1, -1);
            if ( _id < 0) exitWith{(hint localize "--- GRU_event_scores error id: ")  + _id}; // error parameter
            _score = argopt(2,0);
            if ( _score != 0 ) then
            {
                _playerName = argopt(3, "" );
                if ( _playerName == (name player)) then
                {
                    player addScore _score;
                    format[localize argp(GRU_specialBonusStrArr,_id),_score] call XfGlobalChat; // "you've got a prize for your observation/curiosity"
                    playSound "no_more_waiting";
                };
            };
            GRU_specialBonusArr set [ _id, 0 ]; // no more this event could occure
		};

	}; //switch (_this select 0) do {
}; // XHandleNetStartScriptClient = {

 "d_ns_client" addPublicVariableEventHandler {
	(_this select 1) spawn XHandleNetStartScriptClient;
};