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

_ctrl = _XD_display displayCtrl 11021;  // secondary mission title (including current SM number)
_ctrl ctrlSetText format[localize "STR_SYS_58", current_mission_counter];

_ctrl = _XD_display displayCtrl 11002;  // secondary mission text control
_s = current_mission_text;

//+++ Sygsky: added more info about hostages, officer, snipers etc
if (!((current_mission_text == localize "STR_SYS_120") || all_sm_res || stop_sm) ) then {
	_pos = markerPos format["XMISSIONM%1", current_mission_index + 1]; // Find marker position
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
				_units = nearestObjects [_pos, ["Civilian"], 300];
				_cnt = count _units;
				if ( _cnt == 0 ) exitWith {_str = format[localize "STR_SM_30_1", 500]}; // "GRU: civilians not found in radius %1 m."
				for "_i" from 0 to (_cnt - 1) do {
				    _x = _units select 0;
                    _dist = format["%1 %2", [ [_x, _pos ] call SYG_distance2D, 10] call SYG_roundTo, localize "STR_SM_30_4"];
                    if (alive _x) then {
                        if ( damage _x < 0.01 ) then {
                            _str = format["%1 %2", localize "STR_MIS_ALIVE", _dist]; // "alive"
                        } else {
                            _str = format["%1 %2", localize "STR_MIS_WOUNDED", _dist]; // "wounded"
                        };
                    } else {
                        _str = format["%1 %2", localize "STR_MIS_DEAD", _dist]; // "dead"
                    };
                    _units set [_i, _str];
				};
				_str = [_units, ","] call SYG_joinArr;
				_str = format[ localize "STR_SM_30_2", 300, _str]; // "GRU: searching for civilians within a radius of %1 m gives the following: %2"
			} else { _str = localize "STR_SM_30_3"}; // "GRU: no data about the position of the search!"
			if (_str != "") then {_s = _s + "\n" + _str};

		};
		case 40;
		case 41: {// hostages
			// Check leader and civilians at Side Mission marker or player position

			// Finds leader of the group and max distance from the designated position to any of civ group units
			// Call: _ret = [_marker_pos, _dist] call _get_info;
			// _ret => [_leader, _rad, _whole_cnt, _alive_cnt]; // Where leader == civilians leader, _rad == radius of the outermost civilian positions
			// _ret => [] if no civilians detected at designated radius
			_get_info = { // Get info about civilians and their leader near designated point)
				private ["_pos", "_dist", "_units", "_unit", "_cnt", "_alive_cnt", "_leader", "_i"];
				_pos = (_this select 0) call SYG_getPos;
				if ( (_pos distance [0,0,0]) < 1 ) exitWith { [] }; // No point/marker detected
				_dist = _this select 1;
				_units = nearestObjects [ _pos, ["Civilian"], _dist ];
				_cnt = count _units;
				if ( _cnt == 0 ) exitWith { [] };

				for "_i" from 0 to _cnt - 1 do {
					_x = _units select _i;
					if ( !alive _x ) then { _units set [ _i, "RM_ME" ] };
				};
				_units call SYG_clearArray;
				_alive_cnt = count _units;
				if ( _alive_cnt == 0 ) exitWith { [] }; // No alive civilians - exit without result
				_unit = _units select ( (count _units) -1 ); // Use last man ib the list sorted by distance from position (see nearestObjects description)
				_dist = _unit distance _pos;
				_unit = _units select  0;	// Use man nearest to the designated position
				_leader =  leader group _unit;
				if (isNull _leader) then {sleep 0.3; _leader =  group _unit}; // Try after small delay
				[_leader, _dist, _cnt, _alive_cnt]
			};
			// First check around SM marker position
			_msg = "";
			_ret = [_pos, 1500] call _get_info;
			if (count _ret > 0) then {
                if ((_ret select 1) > 0)  then { // Some civilians (with or without leader) are near SM center
                    _msg = "STR_SYS_117"; // "The Hostages (alive %1 of %2) are within a %3 m radius from the center of side mission. %4"
                };
			};
			if (_msg == "") then {
				_ret = [player, 1500] call _get_info;
				if (count _ret > 0) then {
                    if ((_ret select 1) > 0) then { // Some civilians (with or without leader) are near player
                        _msg = "STR_SYS_117_P"; // "The Hostages (alive %1 of %2) are within a %3 m radius from the... " "SM marker" or "your GLONASS position"
                    };
				};
			};

			if (_msg != "") then {
				_s1 = if (alive (_ret select 0)) then {
					format[localize "STR_SYS_117_1", [(_ret select 0), 50] call SYG_MsgOnPos0] // "Their leader is %1"
				} else {localize "STR_SYS_117_0"}; // "But the leader of this group of civilians has not been located"
				_s = _s + "\n" + format[ localize _msg, _ret select 3 /*_alive_cnt*/, _ret select 2 /*_whole_cnt*/, round( _ret select 1 /*_dist*/), _s1 ];
			} else {
                // Nothing detected around SM center and your postion, try again from other point
                _s  = _s + "\n" + format[localize "STR_SYS_117_ABSENCE", 1500]; // "No civilians have been detected within %1 meter of the mission marker and your GLONASS position. Continue searching!"
			};
		};
		//case 25; Officer on Isla da Voda and isla da Vassal
		case 42; // officer arrest
		case 49; // officer Grant
		case 55: {// officer arrest
			_s1 = localize "STR_SYS_135"; //"Side Mission marker is absent"  - default message
			// find side mission marker and its coordinates
			if ( (_pos distance [0,0,0] ) > 1) then {
				// find officer. He must be alive or rarely may be dead
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
					_angle  = [ _pos, _leader ] call XfDirToObj;
					_s1     = format[ localize "STR_SYS_131", _dist, (ceil(_angle/10))*10, _s1 ]; // Is at dist %1 and angle %2 from %3
				} else { _s1 = format[localize "STR_SYS_134", 1500]; }; // "The officer was not detected neither at Side Mission point nor near Your Glonass-Position ((%1 m.)"
				_units = nil;
			};
			_s = _s + "\n" + _s1;
		};
// Pilots rescue (sideevac) sidemission
		case 51;	//  heli crash at Hunapu
		case 52;	// heli crash at Bagango
		case 54: {	// heli crash at Mataredo
			_town_name = switch ( current_mission_index ) do {
				case 52: {"Hunapu"};
				case 52: {"Bagango"};
				case 54: {"Mataredo"};
				default  {"<unknown>"};
			};
			_s1 = localize "STR_SYS_135"; // "Side Mission marker is absent from map!!!"  - default message
			// find side mission marker and its coordinates
#ifdef __OWN_SIDE_EAST__
			_pilottype = d_pilot_E;
#else
			_pilottype = d_pilot_W;
#endif
			if (format["%1",_pos] != "[0,0,0]") then { // _pos is a mission marker position
				// find pilots. They would be alive and rarely dead
				_units = nearestObjects [_pos, [_pilottype], 500];
				_near = objNull;
				{
					_var = _x getVariable "SIDEMISSION";
					if ( (alive _x) && (!isNil "_var" ) ) exitWith {
						_near = _x;
						_s1 = localize "STR_SYS_133"; // "точки задания"
					};
				} forEach _units;
				if ( isNull _near ) then { // search around player
				    _pos = getPos player;
					_units = nearestObjects [_pos, [_pilottype], 1500];
					{
						_var = _x getVariable "SIDEMISSION";
						if ( (alive _x) && (!isNil "_var" ) ) exitWith {
							_near = _x;
							_s1 = localize "STR_SYS_132"; // "вашей Глонасс-позицией"
						};
					} forEach _units;
				}; // Not found near side mission position
				if ( !isNull _near ) then {
					_dist   = _pos distance _near;
					_dist   = (ceil(_dist/50))*50;
					_angle  = [ _pos, _near ] call XfDirToObj;
					_s1     = format[ localize "STR_SYS_131_1", _dist, (ceil(_angle/10))*10, _s1 ]; // "Pilot[s] about %1 m. of %3, azimuth search %2 gr. "
				} else { _s1 = format[localize "STR_SYS_134_1", 1500]; }; // "There are no pilots at either the mission point or near your Glonass position (%1 m)."
				_units = nil;
			};
			_s = _s + "\n" + _s1;
		};
		// GRU radar mast deliverance and installation
		case 56: {
			if (!alive d_radar) then {
				_s = _s + "\n" + (localize "STR_RADAR_FAILED0")  // "No relay must found - no help from GRU!"
			} else {
				// It is first touch of the mast: "Look for a replacement radio mast in one of the settlements closest to the base"
				if ( ([0,0,1] distance (vectorUp d_radar)) > 0.1 ) then { _s = _s + "\n" + (localize "STR_RADAR_INIT") };
			};
			if (!alive d_radar_truck) then {
				_s = _s + "\n" + (localize "STR_RADAR_TRUCK_WAIT")  // "We have to look for a new truck. But where?"
			} else {
				if (locked d_radar_truck) then {
//					_name = text(d_radar_truck call SYG_nearestLocation);
//					_s = _s + "\n" + (format[localize "STR_RADAR_TRUCK_INFO", _name]); // "Look for the blue truck in the '%1' area"
					// "Look for a blue truck to transport relay mast in one of the settlements near the base"
					_s = _s + "\n" + localize "STR_RADAR_INIT2";
				};
			};
			if (sideradio_status == 1) then { _s = _s + "\n" + (localize "STR_RADAR_TASK1") } else { // "Return the truck to the GRU PC!"
				if (sideradio_status == 2) then { _s = _s + "\n" + (localize "STR_RADAR_TASK2") }; // "The side mission is practically done! Wait for the task to be completed!"
			};
			_s = _s + "\n" + localize "STR_RADAR_FAILURE_CONDITION";
		};

	};
    // check for big gun at one of the snipers of side mission teMam
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
} else {
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
			_s = format ["%1\n",format [localize "STR_SEC_1", _current_target_name]]; //"Найти в %1 и устранить местного губернатора.\n"
#ifdef __SYG_GOVERNOR_INFO__

			private ["_center","_list", "_unit","_str","_searchDist","_the_officer"];
			_center = _target_array2 select 0; // center of curent town
			_searchDist = 5000;
			#ifdef __ACE__
          		_the_officer = (if (d_enemy_side == "EAST") then {"ACE_OfficerE"} else {"ACE_OfficerW"});
            #else
           		_the_officer = (if (d_enemy_side == "EAST") then {"OfficerE"} else {"OfficerW"});
            #endif

			_list = _center nearObjects [ _the_officer, _searchDist ]; // search any officer (may be not nearest!) unit around
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
		case 2; //"Найти вышку связи в %1 и уничтожить её.\n"
		case 3; //"Найти и уничтожить в %1 грузовик с боезапасом.\n"
		case 4; //"Найти в %1 командный штаб (замаскирован под медицинскую бронемашину) и уничтожить его.\n"
		case 5; //"Найти и уничтожить в %1 командный пункт противника.\n"
		case 6; //"Найти и уничтожить в %1 лабораторию по производству героина.\n"
		case 7:{ _s = format ["%1\n",format [localize (format["STR_SEC_%1", sec_kind]), _current_target_name] ] };//"Найти и уничтожить в %1 большой завод по производству героина.\n"
		case 8: { // find in town the ammo box with diversant stash
			_s = format ["%1",format [localize (format["STR_SEC_%1", sec_kind]), _current_target_name] ]; // Find and destroy a sabotage stash in %1.
			// if player is in vehicle, no info on distance
			if (vehicle player != player) exitWith  {_s = format["%1\n%2",_s, format[ localize "STR_SEC_8_13", typeOf (vehicle player) ]];}; // "You feel that inside %1 your intuition isn't working for some reason."

			_center = _target_array2 select 0; // center of curent town
			_searchDist = _target_array2 select 2;
			#ifdef __OWN_SIDE_EAST__
			_box  = "WeaponBoxWest";
			#endif
			#ifdef __OWN_SIDE_WEST__
			_box  = "WeaponBoxEast";
			#endif
			_list = _center nearObjects [ _box, _searchDist ]; // search outside box, not inside one (see such in the base)
			_s1 = if (count _list == 0 ) then {
				localize "STR_SEC_8_0" // 0 - in the buildings
			} else { localize "STR_SEC_8_1" }; // 1 - out of the building
			_s = format["%1\n%2", _s, _s1];
//			_max_dist = 200; // for outdoor stash
			_max_dist = 100; // for indoor stash
			if (count _list == 0 ) then { // it must be indoor box, specify its correct type
				_box_west =
				#ifdef __ACE__
					"ACE_AmmoBox_West";
				#else
					"AmmoBoxWest";
				#endif
				_box_east =
				#ifdef __ACE__
					"ACE_AmmoBox_East";
				#else
					"AmmoBoxEast";
				#endif
				#ifdef __OWN_SIDE_EAST__
				_box  = _box_west;
				#endif
				#ifdef __OWN_SIDE_WEST__
				_box  = _box_east;
				#endif
			};
			// search for the box near player
			_list = player nearObjects [ _box, 300 ];
			if ( count _list == 0 ) then { _s1 = localize "STR_SEC_8_14" } // "Where is the damn stash?"
			else {
				// add more info on stash (approximate) distance
				#ifdef __OLD__
				_rank_id = (player call XGetRankIndexFromScoreExt) max 1; // rank index with min value of 1
				#endif
				_rank = player call XGetRankStringLocalized; // localized rank name
//				if (_rank_id == 0) exitWith { _s1 = format[localize "STR_SEC_8_10", _rank]; }; // "As a ranking private, you're sure you don't understand anything."
				// print extended info
				_s1   = if ( (random 2) < 1 ) then {"STR_SEC_8_11"} else {"STR_SEC_8_12"};
				// make artificially approximate distance by rank
				_dist = round( ( _list select 0 ) distance player);
				#ifdef __OLD__
				_step = round( _max_dist / _rank_id ); // accuracy step
				_dist = _dist - (_dist mod _step) +  _step; // show distance never less than accuracy step size
//				hint localize format["+++ STASH info: _dist %1, _step %2, _rank_id %3", _dist, _step, _rank_id];
				#else
				_dist =  _dist - (_dist mod _max_dist) + _max_dist; // distance is always on the boundary of granularity value
				#endif
				_s1   = format[ localize _s1, _rank, _dist ]; // "As %1, you are almost certain that stash at a distance of no more than %2 m. (you don't know more accurately)."
			};
			_s = format["%1\n%2",_s, _s1 ]; // add extended info to the result one
		};
		default {}; // may bу negative value too
		case 0: { _s = localize "STR_SYS_199";};  //"Secondary target not available..."
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
_ctrl = _XD_display displayCtrl 11020;
#ifdef __SPPM__
if (vehicle player == player) then { // player is not in vehicle
	_ctrl  ctrlSetText (localize "STR_SPPM_CHECK");
} else { // player is in vehicle
	_ctrl  ctrlSetText (localize "STR_SPPM_ADD");
};
//#else
//_ctrl ctrlShow false; // hide button from user
#endif

//-------------------------------------------------------

waitUntil {!dialog || !alive player};

if (!alive player) then {
	closeDialog 11001;
};

if (true) exitWith {};
