// x_scripts/x_showstatus.sqf, by Xeno
private ["_ctrl","_current_target_name","_ok","_s","_target_array2","_XD_display","_center","_angle","_pos",
		"_units","_cnt","_i","_alive_cnt","_dist","_dist1","_leader","_s1","_color"];
if (!X_Client) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

//#define __DEBUG__

_ok = createDialog "XD_StatusDialog";

_XD_display = findDisplay 11001;

_target_array2 = [];
_current_target_name = "";

if (current_target_index == -1) then {// before 1st town or current town cleared
    if (client_target_counter < number_targets ) then {
        _current_target_name = localize "STR_SYS_208"; // "No target"
    };
#ifdef __SIDE_MISSION_PER_MAIN_TARGET_COUNT__
    if ( call SYG_isMainTargetAllowed ) then {
#endif
        _target_array2 = d_base_array;
        _current_target_name = localize "STR_SYS_215"; //"Airbase";
#ifdef __SIDE_MISSION_PER_MAIN_TARGET_COUNT__
    } else {
        _current_target_name = format[localize "STR_SYS_1151", current_mission_counter + 1 ]; // "Finish SM(%1)"
    };
#endif
} else {// next target town ready
    if (client_target_counter < number_targets ) then {
        __TargetInfo
    } else {
        _current_target_name = localize "STR_SYS_208"; // "No target"
    };
};


#ifdef __TT__
_ctrl = _XD_display displayCtrl 11011;
_color = [];
if (points_west > points_racs) then {
	_color = [0,0,1,1];
} else {
	if (points_racs > points_west) then {
		_color = [1,1,0,1];
	} else {
		if (points_racs == points_west) then {
			_color = [0,1,0,1];
		};
	};
};
_ctrl ctrlSetTextColor _color;
_s = format ["%1 : %2", points_west, points_racs];
_ctrl ctrlSetText _s;

_ctrl = _XD_display displayCtrl 11012;
if (kill_points_west > kill_points_racs) then {
	_color = [0,0,1,1];
} else {
	if (kill_points_racs > kill_points_west) then {
		_color = [1,1,0,1];
	} else {
		if (kill_points_racs == kill_points_west) then {
			_color = [0,1,0,1];
		};
	};
};
_ctrl ctrlSetTextColor _color;
_s = format ["%1 : %2", kill_points_west, kill_points_racs];
_ctrl ctrlSetText _s;
#endif

_ctrl = _XD_display displayCtrl 11002;  // secondary mission text control
_s = current_mission_text;

//+++ Sygsky: added more info about hostages, officer, snipers etc
if (!((current_mission_text == localize "STR_SYS_120") || all_sm_res || stop_sm) ) then {
	call compile format ["_pos = markerPos ""XMISSIONM%1"";", current_mission_index + 1];
	switch current_mission_index do {
		case 5: {// king in hotel
			if (! isNil "king" ) then {

				if ( alive king ) then {

					_dist = _pos distance king;
					if ( _dist > 100 ) then {
						 // "Locals %1 claim that the king is hiding at %2 meters away!!!"
						_s = _s + "\n" + format[localize "STR_SYS_524", localize (call SYG_getLocalMenRandomName), (round (_dist / 100)) * 100];
					} else { _s = _s + "\n" + localize "STR_SYS_526"}; // "The locals think that the king is in the hotel or its surroundings."

				} else {_s = _s + "\n" + localize "STR_SYS_527"}; // "The locals believe that the king has already died"

			} else { _s = _s + "\n" + localize "STR_SYS_525"}; // "The locals don't know anything about the king's location!!!"
		};
		case 30: {// scientist on Asharan
			// find side mission marker and its coordinates
			_str = "";
			if (format ["%1",_pos] != "[0,0,0]") then {
				// find civilians
				_units = nearestObjects [_pos, ["Civilian"], 500];
				_cnt = count _units;
				if ( _cnt == 0 ) exitwith {_str = format[localize "STR_SM_30_1", 500]};
				for "_i" from 0 to (_cnt - 1) do {
				    _x = _units select 0;
                    _dist = format["%1 m", [ [_x, _pos ] call SYG_distance2D, 10] call SYG_roundTo];
                    if (alive _x) then {
                        if ( damage _x < 0.01 ) then {
                            _str = format["%1 %2", localize "STR_MIS_ALIVE", _dist];
                        } else {
                            _str = format["%1 %2", localize "STR_MIS_WOUNDED", _dist];
                        };
                    } else {
                        _str = format["%1 %2", localize "STR_MIS_DEAD", _dist];
                    };
                    _units set [_i, _str];
				};
				_str = [_units, ","] call SYG_joinArr;
				_str = format[ localize "STR_SM_30_2", 500, _str];
			} else { _str = localize "STR_SM_30_3"};
			if (_str != "") then {_s = _s + "\n" + _str};

		};
		case 40;
		case 41: {// hostages
			// find side mission marker and its coordinates
			if (format ["%1",_pos] != "[0,0,0]") then {
				// find civilians
				_units = nearestObjects [_pos, ["Civilian"], 1000];
				_cnt = count _units;
				if ( _cnt > 0 ) then {
					for "_i" from 0 to _cnt - 1 do {
						_x = _units select _i; 
						if (!alive _x) then {_units set [_i, "RM_ME"]};
					};
					_units = _units - ["RM_ME"];
					_alive_cnt = count _units;
					_dist = -1;
					_s1 = localize "STR_SYS_123"; // "Лидер не обнаружен"
					if (_alive_cnt > 0) then {
						_dist   = _pos distance(_units select(_alive_cnt-1));
						_dist   = (ceil(_dist/50))*50;
						_leader = leader (group(_units select 0));
						_s1     = format[localize "STR_SYS_124",(ceil((_leader distance _pos)/10))*10]; //"Лидер примерно на расстоянии %1 м"
					};
					//"Заложники (в живых %1 из %2) находятся в примерном радиусе %3 м от точки задания. %4"
					_s = _s + format["\n" + localize "STR_SYS_117", _alive_cnt, _cnt, _dist, _s1 ];
				}
				else {	_s = _s + "\n" + (localize "STR_SYS_122");}; //"Заложники не обнаружены"
				_units = nil;
			};
		};
		//case 25; Officer on Isla da Voda and isla da Vassal
		case 42;
		case 49; // officer Grant
		case 55: {// officer arrest
			_s1 = localize "STR_SYS_135"; //"Side Mission marker is absent"  - default message
			// find side mission marker and its coordinates
			if (format["%1",_pos] != "[0,0,0]") then {
				// find officer. He must be alone or rarely may be dead
				_units = nearestObjects [_pos, ["ACE_USMC0302"], 500];
				if ( count _units > 0 ) then {
					_s1 = localize "STR_SYS_133"; // "точки задания"
				} else {
				    // search around player
				    _pos = getPos player;
					_units = nearestObjects [_pos, ["ACE_USMC0302"], 1500];
					if ( count _units > 0 ) then {
						_s1 = localize "STR_SYS_132"; // "вашей Глонасс-позицией"
					};
				}; // Not found near side mission position
				if ( count _units > 0 ) then {
					_leader = _units select 0;
					_dist   = _pos distance _leader;
					_dist   = (ceil(_dist/50))*50;
					_angle  = [_pos, _leader] call XfDirToObj;
					_s1     = format[ localize "STR_SYS_131", _dist, (ceil(_angle/10))*10, _s1 ]; // Is at dist %1 and angle %2 from %3
				} else {_s1 = format[localize "STR_SYS_134", 1500];}; // "Офицер не обнаружен ни у точки задания, ни рядом с вашей Глонасс-позицией"
				_units = nil;
			};
			_s = _s + "\n" + _s1;
		};
	};
    // check for big gun at one of the snipers of side mission team
    if (!isNil "SM_HeavySniperCnt") then {
//        hint localize format["SM_HeavySniperCnt = %1", SM_HeavySniperCnt];
        if (SM_HeavySniperCnt > 0) then {
            switch (SM_HeavySniperCnt) do {
                case 1: { _s = _s + "\n" + localize "STR_GRU_49";}; // "У врагов тут можно разжиться трофеем"
                default { _s = _s + "\n" + localize "STR_GRU_49_1";}; // "У врагов здесь можно разжиться несколькими трофеями"
            };
        };
    };
};
//--- Sygsky

_ctrl ctrlSetText _s; // secondary mission text

// Current/last main target name
_s = _current_target_name;

// if town is big type info about it
if ( current_target_index >= 0 && (client_target_counter < number_targets)) then {

#ifdef __SIDE_MISSION_PER_MAIN_TARGET_COUNT__
    if (! call SYG_isMainTargetAllowed) then { // show some special info
        _s = localize "STR_SYS_59_3"; // You are Asked to complete next SM!
    } else {
#endif
        _s1 = "";
        if ( (_target_array2 select 2) >= big_town_radious) then { // big town
            _s1 = localize "STR_SYS_59_1";
        };
        if (client_target_counter == number_targets-1) then { // last town
            if ( _s1 != "" ) then {_s1 = _s1 + ",";};
            _s1 = _s1 + localize "STR_SYS_59_2";
        };
        if ( _s1 != "" ) then { _s1 = format["(%1)",_s1]; };
        _s = format["%1%2", _s, _s1];
#ifdef __SIDE_MISSION_PER_MAIN_TARGET_COUNT__
    };
#endif
}
else{
    if ( client_target_counter >= number_targets) then { // all towns are done!
        _s = localize "STR_SYS_216"; // "occupied town" TODO: click should move to occupied town
    };
};

_ctrl = _XD_display displayCtrl 11003;
_ctrl ctrlSetText _s;

// Current count/Whole main target numbers
_cnt = client_target_counter;
if ( client_target_counter < number_targets ) then {_cnt = _cnt + 1;};
_s = format ["%1/%2", _cnt, number_targets];
_ctrl = _XD_display displayCtrl 11006;
_ctrl ctrlSetText _s;

//+++ Sygsky: set fatigue info
if ( !isNil "ACE_FV") then {
	_ctrl = _XD_display displayCtrl 11016;
	_s = (round(ACE_FV/1.3))/10;
	_color = [0,1,0,1];
	if ( _s >= 3 ) then {_color = [1,1,0,1];};
	if ( _s >= 7 ) then {_color = [1,0,0,1];};
	_ctrl ctrlSetTextColor _color;
	_ctrl ctrlSetText format[localize "STR_SYS_11_1", _s];// "Усталость %1"
};
//+++ Sygsky: set health status
_ctrl = _XD_display displayCtrl 11015;
_s = (round((1.0-(damage player))*100))/10;
_color = [0,1,0,1];
if ( _s <= 9.0 ) then {_color = [1,1,0,1];};
if ( _s <= 7.0 ) then {_color = [1,0,0,1];};
_ctrl ctrlSetTextColor _color;
_ctrl ctrlSetText format[localize "STR_SYS_11", _s];// "Здоровье: %1"
//--- Sygsky
_wind = round ( ( wind distance [0,0,0] ) * 10) / 10; // wind speed
_dir = if (_wind == 0) then {"-"} else {round ([[0,0,0], wind] call XfDirToObj)}; // wind dir
_s = if(d_weather_sandstorm) then {
	format [localize "STR_SYS_230",clouds1,fog1,"%", _dir, _wind]; // "Non-marked zones has %1 and %2. Areas marked as sandstorm has degraded visibility.\nWind %3 deg, %4 m/s"
}
else {
	format [localize "STR_SYS_231",clouds1,fog1,clouds2,fog2, _dir, _wind]; // "Погода вне помеченных зон: %1, %2.\nВ помеченных зонах: с осадками и облачностью %3, с туманом %4."
};
if (!d_weather) then { _s = format [localize "STR_SYS_232", round(overcast*100), round(fog*100), "%", _dir, _wind]; }; // "Domination dynamic weather system not used, but still mission starts randomly on the nice side. Current cloud level is %1 %3. Current fog level is %2 %3.\nWind dir. %4 deg, spd. %5 m/s"
_ctrl = _XD_display displayCtrl 11013;
_ctrl ctrlSetText _s;

_ctrl = _XD_display displayCtrl 11009;
if (!d_use_teamstatusdialog) then {
	_ctrl ctrlShow false;
} else {
	if (vehicle player == player) then {
		_ctrl ctrlSetText localize "STR_TSD9_01"; //"Vehicle status";
	} else {
		_ctrl ctrlSetText localize "STR_SYS_07"; //"Статус ТС";
	};
};

_s = "";
if (current_target_index != -1) then {
	switch (sec_kind) do {
		case 1: {
			_s = format ["%1\n",format [localize "STR_SYS_200", _current_target_name]]; //"Найти в %1 и устранить местного губернатора.\n"
#ifdef __SYG_GOVERNOR_INFO__

			private ["_center","_list", "_unit","_str","_searchDist"];
			_center = _target_array2 select 0; // center of curent town
			_searchDist = 5000;
			_list = _center nearObjects [ "ACE_OfficerW", _searchDist]; // search any officer (may be not nearest!) unit around
			if ( count _list == 0 )	then {
				_s = _s + format[localize "STR_SYS_113", "ACE_OfficerW", _searchDist]; //"Губернатор (%1) не обнаружен в радиусе %2м.!"
			} else {
			    _ind = 0;
				_unit = _list select _ind;
                _dist = [_center distance _unit, 25] call SYG_roundTo;
                _dir  = [[_center,_unit] call XfDirToObj,5] call SYG_roundTo;
				if (!alive _unit) then {
				    if (_dist > 0) then {
				        _s = _s + format[ localize "STR_SYS_115", _dist, _dir]; // "Some corpse in the uniform of the Governor is lying in %1 m from the center of the red zone. Direction %2 gr."
				    } else {
           				_s = _s + localize "STR_SYS_115_0"; // "Some corpse in the uniform of the Governor is found at the center of the red zone"
				    };
				} else {
                    _str = if ((damage _unit) > 0.3) then { "STR_SYS_115_3" }
                           else {
                               if ((damage _unit) > 0.1) then { "STR_SYS_115_2" }
                               else { "STR_SYS_115_1" }
                           };
                    _str = format ["%1 %2 %3", name _unit, localize "STR_SYS_114", localize _str]; // "Juan/Julio/etc alive/but wounded/but seriously wounded"
				    if (_dist == 0) then {
    				    _s = _s + format[ localize "STR_SYS_116_0", _str]; //"Partisans inform: Governor %1, at center of red zone"
    				} else {
    				    _s = _s + format[ localize "STR_SYS_116", _str, _dist, _dir]; //"Partisans inform: Governor %1, dist. %2 m., dir. %3 deg. from the centre of the red zone"
    				}
				};
			};
#endif	
		}; 
		case 2;//: {_s = format ["%1\n",format [localize "STR_SYS_201", _current_target_name]];}; //"Найти вышку связи в %1 и уничтожить её.\n"
		case 3;//: {_s = format ["%1\n",format [localize "STR_SYS_202", _current_target_name]];}; //"Найти и уничтожить в %1 грузовик с боезапасом.\n"
		case 4;//: {_s = format ["%1\n",format [localize "STR_SYS_203", _current_target_name]];};//"Найти в %1 командный штаб (замаскирован под медицинскую бронемашину) и уничтожить его.\n"
		case 5;//: {_s = format ["%1\n",format [localize "STR_SYS_204", _current_target_name]];};//"Найти и уничтожить в %1 командный пункт противника.\n"
		case 6;//: {_s = format ["%1\n",format [localize "STR_SYS_205", _current_target_name]];};//"Найти и уничтожить в %1 лабораторию по производству героина.\n"
		case 7: {_s = format ["%1\n",format [localize (format["STR_SYS_20%1", (sec_kind - 1)]), _current_target_name]];};//"Найти и уничтожить в %1 большой завод по производству героина.\n"
		default {}; // may bу negative value too
		case 0: { _s = localize "STR_SYS_207";};  //"Второстепенная задача недоступна..."
	};
} else {
	_s = localize "STR_SYS_209";//"No secondary main target mission available..."
};

_ctrl = _XD_display displayCtrl 11007;
_ctrl ctrlSetText _s;

_ctrl = _XD_display displayCtrl 12010; // Rank/Звание
_ctrl ctrlSetText d_rank_pic;

_ctrl = _XD_display displayCtrl 11014;
_ctrl ctrlSetText ((rank player) call XGetRankStringLocalized);

#ifdef __ACE__
if (d_with_ace_map) then {  // Карта A.C.E.
	_map_on = call XCheckForMap;
	_ctrl = _XD_display displayCtrl 11010;
	_ctrl ctrlShow _map_on;
	_ctrl = _XD_display displayCtrl 111111;
	_ctrl ctrlShow (!_map_on);
} else {
	_ctrl = _XD_display displayCtrl 111111;
	_ctrl ctrlShow false;
};
#endif

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++
// SPPM handling: starts working only if player is in vehicle
#ifndef __SPPM__
_ctrl = _XD_display displayCtrl 11020;
_ctrl ctrlShow false;
#endif

//-------------------------------------------------------

waitUntil {!dialog || !alive player};

if (!alive player) then {
	closeDialog 11001;
};

if (true) exitWith {};
