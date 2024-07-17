// by Xeno: x_setupplayer.sqf, execVM on client computer only
private ["_p", "_pos", "_type", "_i", "_res", "_target_array", "_current_target_pos", "_target_name", "_no", "_color",
"_objstatus", "_xres", "_winner", "_target_array2", "_current_target_name", "_counterxx", "_marker_name", "_text",
"_box", "_xx", "_units", "_strp", "_artinum", "_vec", "_ari1", "_respawn_marker", "_s",
"_trigger", "_dbase_a", "_status", "_bravo", "_is_climber", "_types", "_action", "_ar", "_mcctypeaascript", "_num",
"_thefac", "_element", "_posf", "_facid", "_exit_it", "_boxname", "_dir", "_oldscore","_string_player","_local_msg_arr",
"_rad","_flare"];

if (!X_Client) exitWith {};
_time = time; // to log duration of base level of setup player procedure
sleep 1;

#include "x_setup.sqf"
#include "x_macros.sqf"

//#define __DEBUG_DOSAAF__
//#define __DEBUG__
//#define __DEBUG_JAIL__
//#define __DEBUG_SCORE__ 1500

#define __MISSION_START__

_p = player;
_pl_name = name player;
_pos = position _p;
_type = typeOf _p;
_string_player = format ["%1",_p];

//hint localize format["+++ x_setupplayer: _string_player ""%1"",  %2",_string_player, getPos AMMOLOAD];

#ifdef __RANKED__
d_sm_p_pos = nil;
#endif

#ifdef __TT__
d_own_side = (if (playerSide == resistance) then {"RACS"} else {"WEST"});
d_side_player_str = (
	switch (playerSide) do {
		case west: {"west"};
		case resistance: {"guerrila"};
	}
);
d_own_side_trigger = (
	if (playerSide == west) then {
		"WEST"
	} else {
		"GUER"
	}
);
if (d_own_side == "RACS") then {d_mg_nest = "WarfareBResistanceMGNest_M240";};
d_side_player = playerSide;
#endif

d_flag_vec = objNull;

if (X_InstalledECS) then {
	ECS_local set[2, false];            // Camera NVG turned off since it interferes with intro
	ECS_local set[4, 2];				// Maximum number of fired objects the object tracker will track simultaneously. Default 5 (may overload CPU)
	ECS_local set[6, false];            // Dynamic viewdistance OFF, use Domination menu instead
	ECS_local set[11, false];			// Birds Dynamic birds anim (sound)
	ECS_local set[12, false];			// Bugs Dynamic bugs anim (sound)
	ECS_local set[15, false];			// Dogs Dogs anim
	ECS_local set[17, false];			// Bistros Bistros anim
	ECS_local set[19, false];			// Transformers Transformers anim
	ECS_local set[21, false];			// Urbans Urbans anim
	ECS_local set[23, false];			// Farms Farms anim
	ECS_local set[27, false];			// Trashbin flies Trashbin flies anim
	ECS_local set[29, true];			// BoatStations Boatstations anim
	ECS_local set[51, [""]];            //Turns off our radiochatter. Enemy still has it though
	ECS_local set[63, [""]];            //Also prevent radiochatter from "undercover" vehicles borrowed from RACS
	ECS_local set[98, 120];             //AI Smokeshell timeout. Number of seconds before reuse
	ECS_local set[85, false];           //GPWS in aircrafts turned OFF. Does military aircraft have this anyway?
	ECS_local set[89, 25 /* 50 */];		// Max Data query Sets the maximum number of data the Control can process simultaneously
	ECS_local set[90, 60];              //AI remains in alert mode for 1 minute instead of 4. Domination players are impatient
	ECS_local set[93, 0.95];            //Chance of AI using flares
	ECS_local set[94, 1.00];            //Chance of AI having flares
	ECS_local set[95, 30];              //Flare timeout
	ECS_local set[96, true];            //Can AI use smokeshells
	ECS_local set[97, 0.50];            //Chance of AI using smokeshells
	ECS_local set[98, 60];              //Smokeshell timeout
	ECS_local set[100, 0.98];           //Chance of AI using supressive fires
	ECS_local set[101, 35];             //Supressive fire timeout
	ECS_local set[108, true];           //Can AI panic
	ECS_local set[109, 0.85];           //Chance of AI panicking
	ECS_local set[132,500 /* 800 */];	// ECS effect (general) Max distance Max view distance of observed effects (Prevents CPU overload)
	ECS_local set[133, 10 /* 15 */];	// ECS fires effect, Max fire Max number of fires runing simultaneous (Prevents CPU overload)
};

if (SYG_found_GL3) then {
    // TODO: tune local settings of GL3 addon here
    hint localize format["+++ GL3_Local[0]=",argp(GL3_Local,0)];
};
if ( SYG_found_ai_spotting) then {
    _sensitivity1  = getNumber(configFile >> "CfgVehicles" >> (typeOf player) >> "sensitivity");
    _sensitivity2  = getNumber(configFile >> "CfgVehicles" >> "SoldierWSniper" >> "sensitivity");
    hint localize format["+++ ai_spotting found, sensitivity: %1 = %2; %3  %4",(typeOf player),  _sensitivity1, "SoldierWSniper", _sensitivity2];
};


if (isNil "x_funcs2_compiled") then {
	call compile preprocessFileLineNumbers "x_scripts\x_funcs\x_functions2.sqf";
};
call compile preprocessFileLineNumbers "x_scripts\x_funcs\x_playerfuncs.sqf";
if (isNil "x_repall") then {
	call compile preprocessFileLineNumbers "x_scripts\x_funcs\x_commonfuncs.sqf";
};
call compile preprocessFileLineNumbers "x_scripts\x_funcs\x_clientfuncs.sqf";

[] execVM "x_scripts\x_setupplayer1.sqf";

d_player_old_score = 0;
d_player_old_rank = "PRIVATE";
d_player_pseudo_rank = d_player_old_rank;
d_rank_pic = d_player_old_rank call XGetRankPic;
/*
// FIXED: XPlayerRank now called from cycle for score changed only (see at end of file)
[] spawn {
	waitUntil {!d_still_in_intro};
	sleep 2;
	while {true} do {
		[] spawn XPlayerRank;
		sleep 5.0123;
	};
};
*/
#ifdef __ACE__
if (d_with_ace_map) then { "ACE_Map_Logic" createVehicleLocal [0,0,0]; };
#endif

if ( count resolved_targets > 0) then {
    hint localize format["+++ count resolved_targets %1 +++", resolved_targets];
#ifndef __TT__
    for "_i" from 0 to (count resolved_targets - 1) do {
        _res = resolved_targets select _i;
        _target_array = target_names select _res;
        _current_target_pos = _target_array select 0;
        _target_name = _target_array select 1;
        _obj_id = _target_array select 3;
        //hint localize format["+++ x_scripts/x_setupplayer.sqf: obj id %1",_obj_id];
        _rad = _target_array select 2; // #685: not use town radius as (rad max 300)
        _no = _current_target_pos nearestObject "HeliHEmpty";
        _color = "ColorGreenAlpha";
        _objstatus = "DONE";
        if (!isNull _no) then {
            if (direction _no > 355) then {
                _objstatus = "FAILED";
                _color = "ColorRedAlpha";
//                [_target_name, _current_target_pos,"ELLIPSE",_color,[_rad + 100,_rad + 100],"",0,"Marker","FDiagonal"] call XfCreateMarkerLocal; // Mark occupied town (red diagonal shading)
                [_target_name, _current_target_pos,"ELLIPSE",_color,[_rad, _rad],"",0,"Marker","FDiagonal"] call XfCreateMarkerLocal; // #685: mark occupied town (red diagonal shading)
            } else {
                [_target_name, _current_target_pos,"ELLIPSE",_color,[_rad,_rad]] call XfCreateMarkerLocal;
            };
        } else {
            [_target_name, _current_target_pos,"ELLIPSE",_color,[_rad,_rad]] call XfCreateMarkerLocal;
        };
        // if no resolved targets, "OBJ_1" objStatus "VISIBLE" executed
        call compile format ["""%1"" objStatus ""%2"";", _obj_id, _objstatus];
    };
#endif
#ifdef __TT__
    for "_i" from 0 to (count resolved_targets - 1) do {
        _xres = resolved_targets select _i;
        _res = _xres select 0;
        _winner = _xres select 1;
        _target_array = target_names select _res;
        _current_target_pos = _target_array select 0;
        _target_name = _target_array select 1;
        _color = (
            switch (_winner) do {
                case 1: {"ColorBlue"};
                case 2: {"ColorYellow"};
                case 3: {"ColorGreen"};
            }
        );
        _no = _current_target_pos nearestObject "HeliHEmpty";
        _objstatus = "DONE";
        if (!isNull _no) then {
            if (direction _no == 359) then {
                _objstatus = "FAILED";
                _color = "ColorRedAlpha";
                [_target_name, _current_target_pos,"ELLIPSE",_color,[300,300],"",0,"Marker","FDiagonal"] call XfCreateMarkerLocal;
            } else {
                [_target_name, _current_target_pos,"ELLIPSE",_color,[300,300]] call XfCreateMarkerLocal;
            };
        } else {
            [_target_name, _current_target_pos,"ELLIPSE",_color,[300,300]] call XfCreateMarkerLocal;
        };
        call compile format ["""%1"" objStatus ""VISIBLE"";""%1"" objStatus ""%2"";", _target_array select 3,_objstatus]; // FIXME: replace "VISIBLE" with "ACTVE" may be?
    };
#endif
};

if (current_target_index != -1 && !target_clear) then {
	_target_array2 = target_names select current_target_index;
	_current_target_pos = _target_array2 select 0;
	_current_target_name = _target_array2 select 1;
//	_rad = (_target_array2 select 2) max 300;
	_rad = _target_array2 select 2; // #685: draw zone with predefined radious
	_color = (if (current_target_index in resolved_targets) then {"ColorGreenAlpha"} else {"ColorRedAlpha"});
	[_current_target_name, _current_target_pos,"ELLIPSE",_color,[_rad,_rad]] call XfCreateMarkerLocal;
	"dummy_marker" setMarkerPosLocal _current_target_pos;
	"1" objStatus "DONE"; // airport at Paraiso
	call compile format ["""%1"" objStatus ""VISIBLE"";", _target_array2 select 3]; // FIXME: replace "VISIBLE" with "ACTVE" may be?
//	hint localize format["+++""%1"" objStatus ""VISIBLE"";", _target_array2 select 3]
};

{
	if (typeName _x == "ARRAY") then {
		[(_x select 0), (_x select 1),"ICON","ColorBlue",[1,1],format ["%1 wreck", (_x select 2)],0,"DestroyedVehicle"] call XfCreateMarkerLocal;
	};
} forEach d_wreck_marker;

execVM "x_scripts\x_vec_hud.sqf";

if (d_show_chopper_hud) then {execVM "x_scripts\x_chop_hud.sqf";};

execVM "x_scripts\x_playerammobox.sqf"; // personal player ammo box handling

_counterxx = 0;
{
	_pos = position _x;
	_marker_name = "";
	call compile format ["_marker_name = ""paraflag%1"";", _counterxx];
	[_marker_name, _pos,"ICON","ColorYellow",[0.5,0.5],"Parajump",0,"Flag1"] call XfCreateMarkerLocal;

	_counterxx = _counterxx + 1;
	if (d_jumpflag_vec == "") then {
		_x addAction [localize "STR_FLAG_6"/* "(Choose Parachute location)" */,"AAHALO\x_paraj.sqf"];
	} else {
		_text = format [localize "STR_FLAG_7"/* "(Create %1)" */,d_jumpflag_vec];
		_x addAction [_text,"x_scripts\x_bike.sqf",[d_jumpflag_vec,1]];
	};
	_x addAction [localize "STR_FLAG_5"/* "{Rumours}" */,"scripts\rumours.sqf",""];
#ifdef __ACE__
	if (d_jumpflag_vec == "") then {
		_box = "ACE_RuckBox" createVehicleLocal _pos;
		_box call SYG_clearAmmoBox;
		_box addWeaponCargo ["ACE_ParachutePack",50];
		_box addWeaponCargo ["ACE_ParachuteRoundPack",50]; // more parachute types, by Rokse request on 15-AUG-2022
	};
#endif
} forEach jump_flags;

if (!mt_radio_down) then {
	if (mt_radio_pos select 0 != 0) then {
	    /* "Radiotower" */
		["main_target_radiotower", mt_radio_pos,"ICON","ColorBlack",[0.5,0.5],localize "STR_SYS_317",0,"DOT"] call XfCreateMarkerLocal;
	};
};

// setDate date_str;

//#ifdef __DEBUG__
//hint localize format["x_setupplayer.sqf: time AFTER date setting %1", call SYG_nowTimeToStr];
//#endif

//Cloudcover descriptions will depend on cloud texture addon, but these are close enough for practical purposes.
if (fRainLess < 0.025) then {clouds1 = localize "STR_WET_1"}; // "ясно"
if (fRainLess >= 0.025 && fRainLess < 0.0375) then {clouds1 = localize "STR_WET_2"}; // "ясно, без осадков"
if (fRainLess >= 0.0375 && fRainLess < 0.050) then {clouds1 = localize "STR_WET_3"}; // "малооблачно"
if (fRainLess >= 0.050 && fRainLess < 0.0625) then {clouds1 = localize "STR_WET_4"}; // "переменная облачность с прояснениями"
if (fRainLess >= 0.0625 && fRainLess < 0.075) then {clouds1 = localize "STR_WET_5"}; // "переменная облачность"
if (fRainLess >= 0.075 && fRainLess < 0.100) then {clouds1 = localize "STR_WET_6"}; // "облачно"
if (fRainLess >= 0.100 && fRainLess < 0.175) then {clouds1 = localize "STR_WET_7"}; //

/*
if (fRainMore >= 0.175 && fRainMore < 0.225) then {clouds2 = "пасмурно"};
if (fRainMore >= 0.225 && fRainMore < 0.275) then {clouds2 = "пасмурно"};
if (fRainMore >= 0.275 && fRainMore < 0.320) then {clouds2 = "пасмурно и вероятность небольшого дождя"};
if (fRainMore >= 0.320 && fRainMore < 0.375) then {clouds2 = "пасмурно и вероятность сильного дождя"};
if (fRainMore >= 0.375) then {clouds2 = "пасмурно и вероятность сильного дождя с грозой"};
 */
if (fRainMore >= 0.175 && fRainMore < 0.225) then {clouds2 = localize "STR_WET_8"} else { // "пасмурно, с небольшими прояснениями"
	if (fRainMore >= 0.225 && fRainMore < 0.275) then {clouds2 = localize "STR_WET_9"} else { // "пасмурно"
		if (fRainMore >= 0.275 && fRainMore < 0.325) then {clouds2 = localize "STR_WET_10"} else { // "пасмурно и вероятность небольшого дождя"
			if (fRainMore >= 0.325 && fRainMore < 0.375) then {clouds2 = localize "STR_WET_11"} else { // "пасмурно и вероятность сильного дождя"
				clouds2 = localize "STR_WET_12"; // "пасмурно, вероятность сильного дождя с грозой"
			};
		};
	};
};
//Addons such as ACE will limit visibility below the description, which was never measured precisely anyway.
if (fFogLess < 0.0555) then {fog1 = localize "STR_WET_13"}; // "видимость не ограничена"
if (fFogLess >= 0.0555 && fFogLess < 0.111) then {fog1 = localize "STR_WET_14"}; //"видимость 10км"
if (fFogLess >= 0.111 && fFogLess < 0.166) then {fog1 = localize "STR_WET_15"}; //"видимость 5км"
if (fFogMore >= 0.1665 && fFogMore < 0.222) then {fog2 = localize "STR_WET_16"}; //"видимость 2км"
if (fFogMore >= 0.222 && fFogMore < 0.2775) then {fog2 = localize "STR_WET_17"}; //"видимость 1км"
if (fFogMore >= 0.2755 && fFogMore < 0.333) then {fog2 = localize "STR_WET_18"}; // "видимость 500м"
if (fFogMore >= 0.333 && fFogMore < 0.3885) then {fog2 = localize "STR_WET_19"}; //"видимость 350м"
if (fFogMore >= 0.3885) then {fog2 = localize "STR_WET_20"}; //"видимость менее 200м"

0 setOvercast fRainLess;
0 setFog fFogLess;

if (all_sm_res ) then {
	current_mission_text= localize "STR_SYS_121"; // "All missions resolved!";
} else {
    if (stop_sm) exitWith { current_mission_text= localize "STR_SYS_121_2"}; // "The enemy fled..."
	[false] execVM "x_missions\x_getsidemissionclient.sqf";
};

#ifndef __ACE__
if ( (daytime < SYG_startMorning) || (daytime > (SYG_startNight - 3)) ) then {
	_p action ["NVGoggles",_p];
};
#endif

if (__ReviveVer || __AIVer || !d_with_respawn_dialog_after_death) then {
    if (_string_player in d_can_use_artillery ) then  {// Only resque can't select resurrect place, but can hear music
    	hint localize "*** resque can't select resurrect place (but can hear death music)";
	    _p addEventHandler ["killed", {_this execVM "x_scripts\x_checkkill.sqf";_this execVM "scripts\deathSound.sqf";}];
    } else {
    	_p addEventHandler ["killed", {_this execVM "x_scripts\x_checkkill.sqf";_this execVM "dlg\open.sqf";}];
    };
} else {
#ifndef __TT__
	_p addEventHandler ["killed", {_this execVM "x_scripts\x_checkkill.sqf";_this execVM "dlg\open.sqf";}];
#else
	if (playerSide == west) then {
		_p addEventHandler ["killed", {_this execVM "x_scripts\x_checkkillwest.sqf";_this execVM "dlg\open.sqf";}];
	} else {
		_p addEventHandler ["killed", {_this execVM "x_scripts\x_checkkillracs.sqf";_this execVM "dlg\open.sqf";}];
	};
#endif
};
//_p addEventHandler ["animChanged", { AinvPknlMstpSlayWrflDnon_healed = _this select 1 } ];
//SYG_healAnimDoneHandler = compile preprocessFileLineNumbers "scripts\healAnimDone.sqf";
//_p addEventHandler ["animDone", {_this spawn SYG_healAnimDoneHandler} ];

d_chop_lift_list = [];
d_chop_wreck_lift_list = [];
d_chop_normal_list = [];
d_chop_all = [];
#ifndef __TT__
{
	_hindex = _x select 1;
	_hobj = call compile format ["%1", _x select 0];
	_hstr = _x select 0;
	if (!(isNil _hstr)) then {
		_hobj addAction [localize "STR_SYS_79_1","x_scripts\x_vecdialog.sqf",[],-1,false]; // "Меню вертолета"
		switch (_hindex) do {
			case 0: {
				_hobj addEventHandler ["getin", {[_this,0] execVM "x_scripts\x_checkhelipilot.sqf"}];
			};
			case 1: {
				_hobj addEventHandler ["getin", {_this execVM "x_scripts\x_checkhelipilot_wreck.sqf"}];
			};
			case 2: {
				_hobj addEventHandler ["getin", {[_this,1] execVM "x_scripts\x_checkhelipilot.sqf"}];
			};
		};
		_hobj addEventHandler ["getout", {_this execVM "x_scripts\x_checkhelipilotout.sqf"}];
	};
	switch (_hindex) do {
		case 0: {
			_hstr addPublicVariableEventHandler {
				(_this select 1) addAction [localize "STR_SYS_79_1","x_scripts\x_vecdialog.sqf",[],-1,false]; // "Меню вертолета"
				(_this select 1) addEventHandler ["getin", {[_this,0] execVM "x_scripts\x_checkhelipilot.sqf"}];
				(_this select 1) addEventHandler ["getout", {_this execVM "x_scripts\x_checkhelipilotout.sqf"}];
			};
			d_chop_lift_list = d_chop_lift_list + [_hstr];
		};
		case 1: {
			_hstr addPublicVariableEventHandler {
				(_this select 1) addAction [localize "STR_SYS_79_1","x_scripts\x_vecdialog.sqf",[],-1,false]; // "Меню вертолета"
				(_this select 1) addEventHandler ["getin", {_this execVM "x_scripts\x_checkhelipilot_wreck.sqf"}];
				(_this select 1) addEventHandler ["getout", {_this execVM "x_scripts\x_checkhelipilotout.sqf"}];
			};
			d_chop_wreck_lift_list set [count d_chop_wreck_lift_list, _hstr];
		};
		case 2: {
			_hstr addPublicVariableEventHandler {
				(_this select 1) addAction [localize "STR_SYS_79_1","x_scripts\x_vecdialog.sqf",[],-1,false]; // "Меню вертолета"
				(_this select 1) addEventHandler ["getin", {[_this,1] execVM "x_scripts\x_checkhelipilot.sqf"}];
			};
			d_chop_normal_list = d_chop_normal_list + [_hstr];
		};
	};
} forEach d_choppers;
#else
{
	_hindex = _x select 1;
	_hobj = call compile format ["%1", _x select 0];
	_hstr = _x select 0;
	if (!(isNil _hstr)) then {
		_hobj addAction ["Меню вертолета","x_scripts\x_vecdialog.sqf",[],-1,false];
		switch (_hindex) do {
			case 0: {
				_hobj addEventHandler ["getin", {[_this,0] execVM "x_scripts\x_checkhelipilot.sqf"}];
			};
			case 1: {
				_hobj addEventHandler ["getin", {_this execVM "x_scripts\x_checkhelipilot_wreck.sqf"}];
			};
			case 2: {
				_hobj addEventHandler ["getin", {[_this,1] execVM "x_scripts\x_checkhelipilot.sqf"}];
			};
		};
		_hobj addEventHandler ["getout", {_this execVM "x_scripts\x_checkhelipilotout.sqf"}];
		_hobj addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillwest.sqf"}];
	};
	switch (_hindex) do {
		case 0: {
			_hstr addPublicVariableEventHandler {
				(_this select 1) addAction [localize "STR_SYS_79_1","x_scripts\x_vecdialog.sqf",[],-1,false]; // "Меню вертолета"
				(_this select 1) addEventHandler ["getin", {[_this,0] execVM "x_scripts\x_checkhelipilot.sqf"}];
				(_this select 1) addEventHandler ["getout", {_this execVM "x_scripts\x_checkhelipilotout.sqf"}];
				(_this select 1) addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillwest.sqf"}];
			};
			d_chop_lift_list = d_chop_lift_list + [_hstr];
		};
		case 1: {
			_hstr addPublicVariableEventHandler {
				(_this select 1) addAction [localize "STR_SYS_79_1","x_scripts\x_vecdialog.sqf",[],-1,false]; //"Меню вертолета"
				(_this select 1) addEventHandler ["getin", {_this execVM "x_scripts\x_checkhelipilot_wreck.sqf"}];
				(_this select 1) addEventHandler ["getout", {_this execVM "x_scripts\x_checkhelipilotout.sqf"}];
				(_this select 1) addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillwest.sqf"}];
			};
			d_chop_wreck_lift_list set [count d_chop_wreck_lift_list, _hstr];
		};
		case 2: {
			_hstr addPublicVariableEventHandler {
				(_this select 1) addAction [localize "STR_SYS_79_1","x_scripts\x_vecdialog.sqf",[],-1,false]; //"Меню вертолета"
				(_this select 1) addEventHandler ["getin", {[_this,1] execVM "x_scripts\x_checkhelipilot.sqf"}];
				(_this select 1) addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillwest.sqf"}];
			};
			d_chop_normal_list set [count d_chop_normal_list, _hstr];
		};
	};
} forEach d_choppers_west;
{
	_hindex = _x select 1;
	_hobj = call compile format ["%1", _x select 0];
	_hstr = _x select 0;
	if (!(isNil _hstr)) then {
		_hobj addAction [localize "STR_SYS_79_1","x_scripts\x_vecdialog.sqf",[],-1,false]; // "Меню вертолета"
		switch (_hindex) do {
			case 0: {
				_hobj addEventHandler ["getin", {[_this,0] execVM "x_scripts\x_checkhelipilot.sqf"}];
			};
			case 1: {
				_hobj addEventHandler ["getin", {_this execVM "x_scripts\x_checkhelipilot_wreck.sqf"}];
			};
			case 2: {
				_hobj addEventHandler ["getin", {[_this,1] execVM "x_scripts\x_checkhelipilot.sqf"}];
			};
		};
		_hobj addEventHandler ["getout", {_this execVM "x_scripts\x_checkhelipilotout.sqf"}];
		_hobj addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillracs.sqf"}];
	};
	switch (_hindex) do {
		case 0: {
			_hstr addPublicVariableEventHandler {
				(_this select 1) addAction [localize "STR_SYS_79_1","x_scripts\x_vecdialog.sqf",[],-1,false]; // "Меню вертолета"
				(_this select 1) addEventHandler ["getin", {[_this,0] execVM "x_scripts\x_checkhelipilot.sqf"}];
				(_this select 1) addEventHandler ["getout", {_this execVM "x_scripts\x_checkhelipilotout.sqf"}];
				(_this select 1) addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillracs.sqf"}];
			};
			d_chop_lift_list set [count d_chop_lift_list, _hstr];
		};
		case 1: {
			_hstr addPublicVariableEventHandler {
				(_this select 1) addAction [localize "STR_SYS_79_1","x_scripts\x_vecdialog.sqf",[],-1,false]; // "Меню вертолета"
				(_this select 1) addEventHandler ["getin", {_this execVM "x_scripts\x_checkhelipilot_wreck.sqf"}];
				(_this select 1) addEventHandler ["getout", {_this execVM "x_scripts\x_checkhelipilotout.sqf"}];
				(_this select 1) addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillracs.sqf"}];
			};
			d_chop_wreck_lift_list set [count  d_chop_wreck_lift_list, _hstr];
		};
		case 2: {
			_hstr addPublicVariableEventHandler {
				(_this select 1) addAction [localize "STR_SYS_79_1","x_scripts\x_vecdialog.sqf",[],-1,false];
				(_this select 1) addEventHandler ["getin", {[_this,1] execVM "x_scripts\x_checkhelipilot.sqf"}];
				(_this select 1) addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillracs.sqf"}];
			};
			d_chop_normal_list set [count d_chop_normal_list, _hstr];
		};
	};
} forEach d_choppers_racs;
#endif
d_chop_all = d_chop_lift_list + d_chop_wreck_lift_list  + d_chop_normal_list;

#ifndef __TT__
for "_xx" from 1 to 2 do { // 'Menu MHQ'
	call compile format ["
		if (!(isNil 'MRR%1')) then {
			if (d_own_side == 'EAST') then { MRR%1 call SYG_reammoMHQ;};
			MRR%1 addAction [localize 'STR_SYS_79_2','x_scripts\x_vecdialog.sqf',[],-1,false];
			MRR%1 addEventHandler ['getin', {_this execVM 'x_scripts\x_checkdriver.sqf'}];
			MRR%1 addEventHandler ['getout', {_this execVM 'x_scripts\x_checkdriverout.sqf'}];
		};
		'MRR%1' addPublicVariableEventHandler {
			(_this select 1) addAction [localize 'STR_SYS_79_2','x_scripts\x_vecdialog.sqf',[],-1,false];
			(_this select 1) addEventHandler ['getin', {_this execVM 'x_scripts\x_checkdriver.sqf'}];
			(_this select 1) addEventHandler ['getout', {_this execVM 'x_scripts\x_checkdriverout.sqf'}];
		};

	", _xx];
};
#else
for "_xx" from 1 to 2 do { //// 'Меню MHQ'
	call compile format ["
		if (!(isNil 'MRR%1')) then {
			MRR%1 addAction [localize 'STR_SYS_79_2','x_scripts\x_vecdialog.sqf',[],-1,false];
			MRR%1 addEventHandler ['getin', {_this execVM 'x_scripts\x_checkdriver.sqf'}];
			MRR%1 addEventHandler ['getout', {_this execVM 'x_scripts\x_checkdriverout.sqf'}];
			MRR%1 addEventHandler ['killed', {_this execVM 'x_scripts\x_checkveckillwest.sqf'}];
		};
		'MRR%1' addPublicVariableEventHandler {
			(_this select 1) addAction [localize 'STR_SYS_79_2','x_scripts\x_vecdialog.sqf',[],-1,false];
			(_this select 1) addEventHandler ['getin', {_this execVM 'x_scripts\x_checkdriver.sqf'}];
			(_this select 1) addEventHandler ['getout', {_this execVM 'x_scripts\x_checkdriverout.sqf'}];
			(_this select 1) addEventHandler ['killed', {_this execVM 'x_scripts\x_checkveckillwest.sqf'}];
		};
	", _xx];
};

for "_xx" from 1 to 2 do { // 'Меню MHQ'
	call compile format ["
		if (!(isNil 'MRRR%1')) then {
			MRRR%1 addAction [localize 'STR_SYS_79_2','x_scripts\x_vecdialog.sqf',[],-1,false];
			MRRR%1 addEventHandler ['getin', {_this execVM 'x_scripts\x_checkdriver.sqf';}];
			MRRR%1 addEventHandler ['getout', {_this execVM 'x_scripts\x_checkdriverout.sqf';}];
			MRRR%1 addEventHandler ['killed', {_this execVM 'x_scripts\x_checkveckillracs.sqf';}];
		};
		'MRRR%1' addPublicVariableEventHandler {
			(_this select 1) addAction [localize 'STR_SYS_79_2','x_scripts\x_vecdialog.sqf',[],-1,false];
			(_this select 1) addEventHandler ['getin', {_this execVM 'x_scripts\x_checkdriver.sqf';}];
			(_this select 1) addEventHandler ['getout', {_this execVM 'x_scripts\x_checkdriverout.sqf';}];
			(_this select 1) addEventHandler ['killed', {_this execVM 'x_scripts\x_checkveckillracs.sqf';}];
		};
	", _xx];
};
#endif

_load_static = "scripts\load_static.sqf";
_unload_static = "scripts\unload_static.sqf";

#ifndef __TT__
_addStat = /*__AIVer || */(_string_player in d_is_engineer);
for "_xx" from 7 to 8 do { // 'Загрузить орудие', 'Разгрузить орудие'
	call compile format ["
		if (!(isNil 'TR%1')) then {
			if (_addStat) then {
				TR%1 addAction[localize 'STR_SYG_10','"+_load_static+"',[],-1,false];
				TR%1 addAction[localize 'STR_SYG_11','"+_unload_static+"',[],-1,false];
			} else {
				TR%1 addEventHandler ['getin', {_this execVM 'x_scripts\x_checktrucktrans.sqf';}];
			};
			TR%1 setAmmoCargo 0;
		};
		'TR%1' addPublicVariableEventHandler {
			if (str(player) in d_is_engineer) then {
				(_this select 1) addAction[localize 'STR_SYG_10','"+_load_static+"',[],-1,false];
				(_this select 1) addAction[localize 'STR_SYG_11','"+_unload_static+"',[],-1,false];
			} else {
				(_this select 1) addEventHandler ['getin', {_this execVM 'x_scripts\x_checktrucktrans.sqf';}];
			};
			(_this select 1) setAmmoCargo 0;
		};
	", _xx];
};
#else
if (!(isNil "TR4")) then {
	if ( (str(player) in d_is_engineer) && (playerSide == west)) then {
		TR4 addAction[localize "STR_SYG_10","scripts\load_static.sqf",[],-1,false]; // "Загрузить орудие"
		TR4 addAction[localize "STR_SYG_11","scripts\unload_static.sqf",[],-1,false]; // "Разгрузить орудие"
	};
	TR4 addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillwest.sqf";}];
	TR4 addEventHandler ["getin", {_this execVM "x_scripts\x_checktrucktrans.sqf";}];
	TR4 setAmmoCargo 0;
};
"TR4" addPublicVariableEventHandler {
	if ( (str(player) in d_is_engineer) && (playerSide == west)) then {
		(_this select 1) addAction[localize "STR_SYG_10","scripts\load_static.sqf",[],-1,false]; // "Загрузить орудие"
		(_this select 1) addAction[localize "STR_SYG_11","scripts\unload_static.sqf",[],-1,false]; //"Разгрузить орудие"
	};
	(_this select 1) addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillwest.sqf";}];
	(_this select 1) addEventHandler ["getin", {_this execVM "x_scripts\x_checktrucktrans.sqf";}];
	(_this select 1) setAmmoCargo 0;
};

if (!(isNil "TRR4")) then {
	if ( (str(player) in d_is_engineer) && (playerSide == resistance)) then {
		TRR4 addAction[localize "STR_SYG_10","scripts\load_static.sqf",[],-1,false]; // "Загрузить орудие"
		TRR4 addAction[localize "STR_SYG_11","scripts\unload_static.sqf",[],-1,false]; // "Разгрузить орудие"
	};
	TRR4 addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillracs.sqf";}];
	TRR4 addEventHandler ["getin", {_this execVM "x_scripts\x_checktrucktrans.sqf";}];
	TRR4 setAmmoCargo 0;
};
"TRR4" addPublicVariableEventHandler {
	if ( (str(player) in d_is_engineer) && (playerSide == resistance)) then {
		(_this select 1) addAction[localize "STR_SYG_10","scripts\load_static.sqf",[],-1,false];// "Загрузить орудие"
		(_this select 1) addAction[localize "STR_SYG_11","scripts\unload_static.sqf",[],-1,false]; // "Разгрузить орудие"
	};
	(_this select 1) addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillracs.sqf";}];
	(_this select 1) addEventHandler ["getin", {_this execVM "x_scripts\x_checktrucktrans.sqf";}];
	(_this select 1) setAmmoCargo 0;
};

if (!(isNil "MEDVEC")) then {
	MEDVEC addEventHandler ["getin", {_this execVM "x_scripts\x_checkenterer.sqf";}];
	MEDVEC addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillwest.sqf";}];
};
"MEDVEC" addPublicVariableEventHandler {
	(_this select 1) addEventHandler ["getin", {_this execVM "x_scripts\x_checkenterer.sqf";}];
	(_this select 1) addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillwest.sqf";}];
};
if (!(isNil "MEDVECR")) then {
	MEDVECR addEventHandler ["getin", {_this execVM "x_scripts\x_checkenterer.sqf";}];
	MEDVECR addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillracs.sqf";}];
};
"MEDVECR" addPublicVariableEventHandler {
	(_this select 1) addEventHandler ["getin", {_this execVM "x_scripts\x_checkenterer.sqf";}];
	(_this select 1) addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillracs.sqf";}];
};

for "_i" from 1 to 3 do {
	call compile format ["
		if (!(isNil 'TR%1')) then {
			TR%1 addEventHandler ['getin', {_this execVM 'x_scripts\x_checkenterer.sqf';}];
			TR%1 addEventHandler ['killed', {_this execVM 'x_scripts\x_checkveckillwest.sqf';}];
			TR%1 setAmmoCargo 0;
		};
		'TR%1' addPublicVariableEventHandler {
			(_this select 1) addEventHandler ['getin', {_this execVM 'x_scripts\x_checkenterer.sqf';}];
			(_this select 1) addEventHandler ['killed', {_this execVM 'x_scripts\x_checkveckillwest.sqf';}];
			(_this select 1) setAmmoCargo 0;
		};
		if (!(isNil 'TRR%1')) then {
			TRR%1 addEventHandler ['getin', {_this execVM 'x_scripts\x_checkenterer.sqf';}];
			TRR%1 addEventHandler ['killed', {_this execVM 'x_scripts\x_checkveckillracs.sqf';}];
			TRR%1 setAmmoCargo 0;
		};
		'TRR%1' addPublicVariableEventHandler {
			(_this select 1) addEventHandler ['getin', {_this execVM 'x_scripts\x_checkenterer.sqf';}];
			(_this select 1) addEventHandler ['killed', {_this execVM 'x_scripts\x_checkveckillracs.sqf';}];
			(_this select 1) setAmmoCargo 0;
		};
	", _i];
};
if (!(isNil "TR5")) then {
	TR5 addEventHandler ["getin", {_this execVM "x_scripts\x_checkenterer.sqf";}];
	TR5 addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillwest.sqf";}];
	TR5 setAmmoCargo 0;
};
"TR5" addPublicVariableEventHandler {
	(_this select 1) addEventHandler ["getin", {_this execVM "x_scripts\x_checkenterer.sqf";}];
	(_this select 1) addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillwest.sqf";}];
	(_this select 1) setAmmoCargo 0;
};
if (!(isNil "TRR5")) then {
	TRR5 addEventHandler ["getin", {_this execVM "x_scripts\x_checkenterer.sqf";}];
	TRR5 addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillracs.sqf";}];
	TRR5 setAmmoCargo 0;
};
"TRR5" addPublicVariableEventHandler {
	(_this select 1) addEventHandler ["getin", {_this execVM "x_scripts\x_checkenterer.sqf";}];
	(_this select 1) addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillracs.sqf";}];
	(_this select 1) setAmmoCargo 0;
};
#endif

if (count d_ammo_boxes > 0) then {
	private ["_the_box", "_box_pos", "_boxnew", "_boxscript"];
	_the_box = (
		switch (d_own_side) do {
			case "RACS": {"WeaponBoxGuer"};
			case "EAST": {"WeaponBoxEast"};
			case "WEST": {"WeaponBoxWest"};
		}
	);
	{
		if (typeName _x == "ARRAY") then {
			_box_pos = _x select 0;
			if ((_x select 1) != "") then {
				[(_x select 1), _box_pos,"ICON","ColorBlue",[0.5,0.5],"Ammo",0,"Marker"] call XfCreateMarkerLocal;
			};
			_boxnew = _the_box createVehicleLocal _box_pos;
			_boxnew setPos _box_pos;
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
#ifdef __ACE__
			[_boxnew, medbox] execVM _boxscript;
#else
			[_boxnew] execVM _boxscript;
#endif
			_boxnew addEventHandler ["killed",{["d_rem_box",position (_this select 0)] call XSendNetStartScriptServer;deleteVehicle (_this select 0)}];
		};
	} forEach d_ammo_boxes;
};

player_can_call_drop = false;
player_can_call_arti = false;

_local_msg_arr = [];

#ifdef __AI__

// add all user actions now
//_handle  = ["add_barracks_actions", AI_HUT, "AlarmBell"] execVM "scripts\barracks_add_actions.sqf";
_handle  = ["add_barracks_actions", AI_HUT] execVM "scripts\barracks_add_actions.sqf";
waitUntil { scriptDone _handle };

if ( isNil "AI_HUT" ) then {
    _local_msg_arr set [ count _local_msg_arr , localize "STR_SYS_1176"]; // "The barracks is destroyed, the military draft is cancelled"
} else {
    if ( !(_string_player in d_can_use_artillery) ) then {
        _local_msg_arr set [ count _local_msg_arr, localize "STR_SYS_1177"]; // "To call on the military service can only observer-rescue"
    };
};

if (_string_player in d_is_engineer) then { // only for engineers
    _local_msg_arr set [count _local_msg_arr, localize "STR_SYS_258_3"]; // "The engineer can locate and deactivate the mines"
} else {
// for NOT engineers
#ifdef __NON_ENGINEER_REPAIR_PENALTY__
	_local_msg_arr set [ count _local_msg_arr, format[localize "STR_SYS_258_2",__NON_ENGINEER_REPAIR_PENALTY__]]; // "You're not an engineer and can repair vehicle just with a loss of %1 point[s]"
#endif
};

if (!(__ACEVer)) then {
	ari1 = -8877;
	dropaction = -8878;
	player_can_call_arti = true;
	player_can_call_drop = true;
	if (player_can_call_arti) then {
		ari1 = _p addAction [localize "STR_SYS_98", "x_scripts\x_artillery.sqf",[],-1,false];//"Вызвать артиллерию"
	};
	if (player_can_call_drop) then {
		dropaction = _p addAction [localize "STR_SYS_99", "x_scripts\x_calldrop.sqf",[],-1,false]; // "Вызвать снабжение"
	};
} else {
	player_can_call_arti = false;
	player_can_call_drop = false;
	[1] execVM "x_scripts\x_artiradiocheck.sqf";
	execVM "x_scripts\x_dropradiocheck.sqf";

	if (_string_player in d_can_use_artillery) then {
		stop_arti_on_the_town = ""; // is dummy for all non-GRU roles
		d_arti_trigger = createTrigger["EmptyDetector" ,d_base_array select 0];
		d_arti_trigger setTriggerArea [d_base_array select 1, d_base_array select 2, d_base_array select 3, true];
		d_arti_trigger setTriggerActivation [d_own_side_trigger, "PRESENT", true];
		d_arti_trigger setTriggerStatements["stop_arti_on_the_town != ''", "stop_arti_on_the_town = ''; (localize 'STR_GRU_38_2') call XfGlobalChat;", ""]; // "Permission for an arti-strike has been granted again!"
	};

};
_p addRating 20000;
_units = units group player;
if (count _units > 1) then {
	{
		if (!(isPlayer _x)) then {
			if (vehicle _x != _x) then {
				unassignVehicle _x;
				_x setPos [0,0,0];
			};
			sleep 0.01;
			deleteVehicle _x;
		};
	} forEach _units;
};
#endif

#ifndef __AI__
if (_string_player in d_can_use_artillery) then {
	_strp = format ["%1",_p];
	if (!(__ACEVer)) then {
		if (_strp == "RESCUE") then {
			ari1 = -8877;
			player_can_call_arti = true;
			ari1 = _p addAction [localize "STR_SYS_98", "x_scripts\x_artillery.sqf",[],-1,false]; // "Вызвать артиллерию"
		};
		if (_strp == "RESCUE2") then {
			ari1 = -8877;
			player_can_call_arti = true;
			ari1 = _p addAction [localize "STR_SYS_98", "x_scripts\x_artillery2.sqf",[],-1,false]; //"Вызвать артиллерию"
		};
	} else {
		_artinum = 0;
		if (_strp == "RESCUE") then {
			_artinum = 1;
		};
		if (_strp == "RESCUE2") then {
			_artinum = 2;
		};
		if (_artinum == 0) exitWith {};
		[_artinum] execVM "x_scripts\x_artiradiocheck.sqf";
	};

	stop_arti_on_the_town = "";	// if set town name then arti is prohibited
	d_arti_trigger = createTrigger["EmptyDetector" ,d_base_array select 0];
	d_arti_trigger setTriggerArea [d_base_array select 1, d_base_array select 2, d_base_array select 3, true];
	d_arti_trigger setTriggerActivation [d_own_side_trigger, "PRESENT", true];
	d_arti_trigger setTriggerStatements["stop_arti_on_the_town != ''", "stop_arti_on_the_town = ''; (localize 'STR_GRU_38_2') call XfGlobalChat;", ""]; // "Permission for an arti-strike has been granted again!"

};
_strp = format ["%1",_p];
player_can_call_drop = _strp in d_can_call_drop;
if (player_can_call_drop) then {
	if (!(__ACEVer)) then {
		dropaction = -8878;
		dropaction = _p addAction [localize "STR_SYS_99", "x_scripts\x_calldrop.sqf",[],-1,false]; // "Вызвать снабжение"
	} else {
		execVM "x_scripts\x_dropradiocheck.sqf";
	};
};
#endif

// play with EditorUpdate_v102.pbo
if ( SYG_found_EditorUpdate_v102 ) then {_local_msg_arr set [ count _local_msg_arr,  localize "STR_SYS_258_4"]}
else { _local_msg_arr set [ count _local_msg_arr,  localize "STR_SYS_258_5"]};

#ifdef __SCUD__
if (SYG_found_SCUD ) then {
    "+++ SCUD addon gig_scud.sqf installed on client" call XfGlobalChat;
} else {
    "+++ SCUD addon gig_scud.sqf not installed on client!!! Must be present simultaneously on the server and client" call XfGlobalChat;
};
#endif

if (random 10 < 7) then {
    _local_msg_arr set [count _local_msg_arr, localize "STR_SYS_RUMORS"];
};

// send information about scores
_rank = (score player) call XGetRankIndexFromScore;
hint localize format["+++ setup info: player rank %1", _rank]; // DEBUG

if ( _rank < 6 ) then { // you are Major or lower, send info about ranks

	// "Ranks: %1(%2), %3(%4), %5(6), %7(%8), %9(%10), %11(%12), %13(%14) and further, Generals""
	_local_msg_arr set [count _local_msg_arr,
		format[ localize "STR_SYS_68_1",
			(d_rank_names select 0) call XGetRankStringLocalized, 0,
			(d_rank_names select 1) call XGetRankStringLocalized, d_points_needed select 0,
			(d_rank_names select 2) call XGetRankStringLocalized, d_points_needed select 1,
			(d_rank_names select 3) call XGetRankStringLocalized, d_points_needed select 2,
			(d_rank_names select 4) call XGetRankStringLocalized, d_points_needed select 3,
			(d_rank_names select 5) call XGetRankStringLocalized, d_points_needed select 4,
			(d_rank_names select 6) call XGetRankStringLocalized, d_points_needed select 5
		]
	];

	 // "Capabilities: repair(%1),BRDM/BMP(%2),tank(%3),attack helicopter(%4),airplane(%5)"
	_ranks = d_ranked_a select 8;
	_local_msg_arr set [count _local_msg_arr,
		format[ localize "STR_SYS_68_2",
			d_ranked_a select 0,
			(_ranks select 0) call XGetRankStringLocalized,
			(_ranks select 1) call XGetRankStringLocalized,
			(_ranks select 2) call XGetRankStringLocalized,
			(_ranks select 3) call XGetRankStringLocalized
		]
	];
	if ( (d_player_stuff select 3) != 0) then {
		// Output time of absence
		// TODO: #579 send a message about the time since the last login
		_delta = 0;
	};

};
//+++++++++++++++++++++++++++++++++++++++++++++++++++
//+ show all specific  messages for the player type +
//+++++++++++++++++++++++++++++++++++++++++++++++++++

_local_msg_arr spawn {

//	hint localize format["+++ _local_msg_arr count %1", count _this]; // DEBUG
    if (count _this > 0 ) then {
        sleep 55;
        {
             sleep 10;
             _x call XfGlobalChat;
        } forEach _this;
    };
    // West Germany
    if ( (toUpper _pl_name) in ["CERES-DE","CERES DE","CERES.","CERES"]) exitWith {
//        sleep 6;
        // "For numerous military services, the command and the grateful citizens declare you an honorary citizen of Sahrani Island."
        [
            "msg_to_user",
            "",
            [
			  ["Das Kommando lobt die Ausbildung der jungen Rekruten"], // "The command praises the training of young recruits"
              ["Für zahlreiche militärische Verdienste erklären das Kommando und die dankbaren Bürger Sie zum Ehrenbürger der Insel Sahrani." ], // "For numerous military services, the command and grateful citizens declare you an honorary citizen of Sahrani Island."
              ["Anfragen zum Einschalten des Servers sollten auf WhatsApp/Vyber/Telegram 8(916)136-2219 gesendet werden."], // "Requests to turn on the server should be sent to WhatsApp 8(916)136-2219."
              ["Groß-/Kleinschreibung beachten Skype-Anmeldung: sygsky"] //
            ],
            7, 6, false, "drum_fanfare"
        ] spawn SYG_msgToUserParser;
    };

    // Litva
    if ( (_pl_name) == "Rokse [LT]") exitWith {
//        sleep 6;
        [
            "msg_to_user",
            "",
            [ ["За заслуги в деле построения миссии главный инженер выносит Вам благодарность, за внимание и глубокий поиск ошибок!!!" ] ],
            0, 5, false, "drum_fanfare"
        ] spawn SYG_msgToUserParser;
    };

	// Khabarovsk: 2-feb is the Soviet aviation day
    if ( ((_pl_name) == "HRUN") && ( ((SYG_client_start select 1) == 2) && ((SYG_client_start select 2) == 9) ) ) exitWith {
//        sleep 6;
        [
            "msg_to_user",
            "",
            [ ["Командование ОК ГРУ поздравляет с профессиональным праздником, благодарит за верность долгу и храбрость в бою!" ] ],
            0, 5, false, "message_received"
        ] spawn SYG_msgToUserParser;
    };

	// Latvia
	if ( (_pl_name) == "Renton J. Junior" ) exitWith { // "Рентон! Не трожь СППМ! За это - расстрел! Но в будущем)))"
//		sleep 6;
		[
			"msg_to_user",
			"",
			[ ["Renton! Nepieskarieties СППМ! Tas ir nošaušanas komanda! Bet nākotnē)))))" ] ],
			0, 5, false, "armory4"
		] spawn SYG_msgToUserParser;
	};
    // Argentina
	if ( (_pl_name) == "lolport" ) exitWith {
//		sleep 6;
		[
			"msg_to_user",
			"",
			[ ["Recordamos al Che Guevara, ¡fue nuestro invitado una vez!" ] ],
			0, 5, false, "drum_fanfare"
		] spawn SYG_msgToUserParser;
	};

	// "АЛЕКС МЭЙСОН"
	if ( (toUpper _pl_name) in ["АЛЕКС МЭЙСОН","DAVID ARMSTRONG", "ALEX MASON"] ) exitWith {
//		sleep 6;
		[
			"msg_to_user",
			"",
			[ ["Боец! Командование местного отряда СпН ГРУ МО СССР предлагает сменить позывной с имени агента ЦРУ на более адекватный нашей задаче" ] ],
			0, 5, false, "losing_patience"
		] spawn SYG_msgToUserParser;
	};

	// "PLAYER 1"
	// check if name starts from "PLAYER #" ...
	if ((toUpper _pl_name) in ["PLAYER", "PLAYER1","PLAYER 1", "PLAYER2","PLAYER 2", "PLAYER3", "PLAYER 3", "ADMIN", "ADMINISTRATOR", "USER"] ) exitWith {
		_pl_name spawn {
			private ["_str"];
			// "Soldier %1! The HQ of the local detachment of the SpN GRU of the USSR Ministry of Defense offers you to change your call sign to a more human looking!"
			_str = format[ localize "STR_GREETING_WARN", _this ];
			while { true } do {
				// Each 20 seconds repeate message about login change from idiotic to normal
				[ "msg_to_user", "", [ [_str] ], 0, 20, false, "losing_patience" ] spawn SYG_msgToUserParser;
			};
		};
//		sleep 6;
	};

	// "Oberon"
	if ( (_pl_name) == "Oberon" ) exitWith {
//		sleep 6;
		[
			"msg_to_user",
			"",
			[ ["Мы построим лестницу до звёзд Мы пройдём сквозь чёрные циклоны От смоленских солнечных берёз До туманных далей Оберона." ] ],
			0, 5, false, "Oberon"
		] spawn SYG_msgToUserParser;
	};

//	hint localize format["+++ DEBUG: if ( ((name player) == ""EngineerACE:"")) == %1", ((name player) == "EngineerACE")];
//	if ( ((name player) == "EngineerACE")) exitWith {
	if ( ((_pl_name) == "SarDELKA122")) exitWith {
		private ["_date","_str","_sound","_hour","_week_day"];
		_date = + SYG_client_start; // real date+time
		_str = "Остров приветствует бойца Горьковского спецназа!";
		_sound = "drum_fanfare";
//		_date set [2, 26];
//		switch	( 8 ) do {
		switch	(_date select 1) do {
			case 8: { // August
				if ( (_date select 2) >= 25 ) then {
					_str = "Береги местные школы, они нужны детям островитян!";
					_sound = "return";
				};
			};
			case 9: { // September
				if ( (_date select 2) < 5 ) then {
					_str = "Островитяне поздравляют тебя с началом занятий в советской школе!";
					_sound = "school_ring";
				};
			}
		};
//		sleep 6;
		[
			"msg_to_user",
			"",
			[ [ _str ] ],
			0, 5, false, _sound
		] spawn SYG_msgToUserParser;
		_hour = _date select 3;
		_week_day = _date call SYG_weekDay; // Monday returns 0, for Sunday 6
		if ( ( (_week_day < 4) || (_week_day > 5) ) && (_hour < (SYG_nightSkipFrom - 10)) && (_hour >= 8) ) then { // Not week day and not night
//		if ( true ) then { // Not week day and not night
//			hint localize format["+++ sleep %1 to remind Sardelko that tomorrow is a school day!", (23 - daytime) * 3600];
			[] spawn {
				sleep (((SYG_nightSkipFrom - daytime) - 10) * 3600); // wait for the night skip to come
				[
					"msg_to_user",
					"",
					[ [ "Завтра в школу, завтра в школу, завтра в школу-у-у-у..." ] ],
					0, 5, false, "school_ring"
				] spawn SYG_msgToUserParser;
			};
		};
	};

	if ( (toUpper(_pl_name)) == "IHATELIFE" ) exitWith {
//		sleep 6;
		[
			"msg_to_user",
			"",
			[ ["Comrades say your nickname  should be IHitCircle!" ] ],
			0, 5, false, "message_received"
		] spawn SYG_msgToUserParser;

	};

    // if no special message, type common one
    //"For his services in developing our mission, the chief engineer extends his thanks to fighters Rokse and Ceres!!!"
//    sleep 10;
	[
		"msg_to_user",
		"",
		[ ["STR_GREETING_COMMON" ] ],
		0, 10, false, "drum_fanfare"
	] spawn SYG_msgToUserParser;
//	hint localize "+++ STR_GREETING_COMMON printed"; // DEBUG
};

#ifndef __REVIVE__
_respawn_marker = "";
//hint localize format["+++ d_own_side=%1",d_own_side];
switch (d_own_side) do {
	case "RACS": {
		_respawn_marker = "respawn_guerrila";
		deleteMarkerLocal "respawn_west";
		deleteMarkerLocal "respawn_east";
	};
	case "WEST": {
		_respawn_marker = "respawn_west";
		deleteMarkerLocal "respawn_guerrila";
		deleteMarkerLocal "respawn_east";
	};
	case "EAST": {
		_respawn_marker = "respawn_east";
		deleteMarkerLocal "respawn_west";
		deleteMarkerLocal "respawn_guerrila";
	};
};

if (__TTVer) then {
	if (playerSide == west) then {
		_respawn_marker setMarkerPosLocal markerPos "base_spawn_1";
	} else {
		_respawn_marker setMarkerPosLocal markerPos "base_spawn_r";
	};
} else {
	_respawn_marker setMarkerPosLocal markerPos "base_spawn_1";
};
#endif

ass = -8879;
ass = _p addAction [localize "STR_SYS_97"/*"СТАТУС"*/, "x_scripts\x_showstatus.sqf",[],-1.1,false];

pbp_id = -9999;
if (d_use_backpack) then {
	d_backpack_helper = [];
	prim_weap_player = primaryWeapon _p;
	_s = format ["%1 to Backpack", [prim_weap_player,1] call XfGetDisplayName];
	if (prim_weap_player != "" && prim_weap_player != " ") then {
		pbp_id = _p addAction [_s, "x_scripts\x_backpack.sqf",[],-1,false];
	};
	// No Weapon fix for backpack
	_trigger = createTrigger["EmptyDetector" ,_pos];
	_trigger setTriggerArea [0, 0, 0, false];
	_trigger setTriggerActivation ["NONE", "PRESENT", true];
	_trigger setTriggerStatements["primaryWeapon player != prim_weap_player && primaryWeapon player != ' '","prim_weap_player = primaryWeapon player;if (pbp_id != -9999 && count player_backpack == 0) then {player removeAction pbp_id;pbp_id = -9999;};if (pbp_id == -9999 && count player_backpack == 0 && prim_weap_player != '' && prim_weap_player != ' ') then {pbp_id = player addAction [format [localize 'STR_SYG_12', [prim_weap_player,1] call XfGetDisplayName], 'x_scripts\x_backpack.sqf',[],-1,false];};",""]; //'%1 в рюкзак'
};

#ifndef __NO_PARABUG_FIX__
// parabug
_trigger = createTrigger["EmptyDetector" ,_pos];
_trigger setTriggerArea [0, 0, 0, false];
_trigger setTriggerActivation ["NONE", "PRESENT", true];
switch (d_own_side) do {
	case "RACS": {_trigger setTriggerStatements["typeOf (vehicle player) == ""ParachuteG""", "", "if (alive player) then {player setPos [(position player select 0),(position player select 1),0];};"];};
	case "WEST": {_trigger setTriggerStatements["typeOf (vehicle player) == ""ParachuteWest""", "", "if (alive player) then {player setPos [(position player select 0),(position player select 1),0];};"];};
	case "EAST": {_trigger setTriggerStatements["typeOf (vehicle player) == ""ParachuteEast""", "", "if (alive player) then {player setPos [(position player select 0),(position player select 1),0];};"];};
};
#endif

//--------------------------------------------------------------------------------------------------------------+
// special triggers for engineers, before December of 2017 in AI version everybody can repair and flip vehicles |
//--------------------------------------------------------------------------------------------------------------+

//hint localize  format["__NON_ENGINEER_REPAIR_PENALTY__ = %1",__NON_ENGINEER_REPAIR_PENALTY__];
#ifndef __NON_ENGINEER_REPAIR_PENALTY__
if (_string_player in d_is_engineer /*|| __AIVer*/) then {
#else
hint localize "+++ __NON_ENGINEER_REPAIR_PENALTY__: everybody can repair with scores subtraction";
#endif
	d_eng_can_repfuel = true;

#ifndef __TT__
	d_engineer_trigger = createTrigger["EmptyDetector" ,d_base_array select 0];
	d_engineer_trigger setTriggerArea [d_base_array select 1, d_base_array select 2, d_base_array select 3, true];
#endif

#ifdef __TT__
	_dbase_a = (
		if (playerSide == west) then {
			d_base_array select 0
		} else {
			d_base_array select 1
		}
	);
	d_engineer_trigger = createTrigger["EmptyDetector" ,_dbase_a select 0];
	d_engineer_trigger setTriggerArea [_dbase_a select 1, _dbase_a select 2, 0, false];
#endif
	
	d_engineer_trigger setTriggerActivation [d_own_side_trigger, "PRESENT", true];
	d_engineer_trigger setTriggerStatements["!d_eng_can_repfuel && player in thislist", "d_eng_can_repfuel = true;(localize 'STR_SYS_229') call XfGlobalChat;", ""]; // "Engineer repair/refuel capability restored..."

#ifdef __RANKED__
	d_last_base_repair = -1;
#endif

#ifndef __NON_ENGINEER_REPAIR_PENALTY__
    if (_string_player in d_is_engineer) then  // only for engineers in any case !!!
    {
#endif
        _trigger = createTrigger["EmptyDetector" ,_pos];
        _trigger setTriggerArea [0, 0, 0, false];
        _trigger setTriggerActivation ["NONE", "PRESENT", true];
        _trigger setTriggerStatements["call x_ffunc", "actionID1=player addAction [localize 'STR_SYS_228', 'scripts\unflipVehicle.sqf',[objectID1],-1,false];", "player removeAction actionID1"]; // 'Поставить технику'
#ifndef __NON_ENGINEER_REPAIR_PENALTY__
    };
#endif

	_trigger = createTrigger["EmptyDetector" ,_pos];
	_trigger setTriggerArea [0, 0, 0, true];
	_trigger setTriggerActivation ["NONE", "PRESENT", true];
	// 'Analyze Vehicle', 'Repair/refill vehicle'
	_trigger setTriggerStatements["call x_sfunc", "actionID6 = player addAction [localize 'STR_INSPECT', 'x_scripts\x_repanalyze.sqf',[],-1,false];actionID2 = player addAction [localize 'STR_SYS_227', 'x_scripts\x_repengineer.sqf',[],-1,false]", "player removeAction actionID6;player removeAction actionID2"];

#ifndef __NON_ENGINEER_REPAIR_PENALTY__
};
#endif


#ifndef __TT__
// Enemy at base: called from trigger, _this = [0, thislist]
XBaseEnemies = {
	switch ( _this select 0 ) do {
		case 0: {
			hint composeText[
				parseText("<t color='#f0ff0000' size='2'>" + (localize "STR_SYS_60")/* "DANGER:" */ + "</t>"), lineBreak,
				parseText("<t size='1'>" + (localize "STR_SYS_61")/* "Enemy troops on your base." */ + "</t>")
			];
//            hint localize format["+++ XBaseEnemies: %1", _this];
        	private ["_alarm_obj","_no","_thislist","_height","_x","_pos","_sound","_unit"];
//            hint localize format["+++ XBaseEnemies: %1", _this];
            _alarm_obj = FLAG_BASE;
            _height    = 250; // default flare start height
            if ( ( count _this ) >  1 ) then {
                _thislist = _this select 1;
//            	hint localize format["+++ XBaseEnemies: thislist count %1", count _thislist];
                if (typeName _thislist == "ARRAY") then {
                    // this is list of enemy intruders
                    {
                        if ( ((_x isKindOf 'LandVehicle') || ((_x isKindOf 'CAManBase') && ((name  _x) != 'Error: No unit'))) && (alive _x) ) exitWith {
                        	// we found one of the enemy on the base, it may be the single one
                            // find nearest to this object alive service
                            // find allowed objects on base to play sounds
                            _no = nearestObjects [
                            	_x,
                            	[ "WarfareBEastAircraftFactory", "WarfareBWestAircraftFactory", "FlagCarrier", "Land_Vysilac_FM", "Land_hlaska","Land_vez","Land_strazni_vez"],
                            	1000
                            ];
			            	hint localize format["+++ XBaseEnemies: nearestObjects count %1, thislist %2", count _no, count _thislist];
			            	_unit  = _x;
                            {
								_pos  = position _x;
                                if ( (typeName _x == "OBJECT") && (alive _x) && ((_pos select 2) > -10) ) exitWith {
                                	hint localize format["+++ XBaseEnemies: nearest alarm obj %1 (pos %2), enemy dist %3 m.", typeOf _x, getPos _x, _pos distance  _unit ];
                                	_alarm_obj = _x
                                };
                            } forEach _no;
                        };
                    } forEach _thislist;
                };
            };
            _sound = if ( (random 10) < 1 ) then { call SYG_getBaseAttackSound } else { "alarm" };
            if ( player call SYG_pointIsOnBase ) then { _alarm_obj say _sound } else { playSound _sound };
            // throw flare above alarm object
			// if ( count ( nearestObjects [ _alarm_obj, [ "F_40mm_Yellow" ], 400 ] ) == 0 ) then {
            if ( count ( _alarm_obj nearObjects ["F_40mm_Yellow", 400] ) == 0 ) then {
	            [_alarm_obj, _height, "YELLOW", 400] execVM "scripts\emulateFlareFired.sqf";
	           	hint localize format["+++ XBaseEnemies: throw yellow flare above %1, pos %2", typeOf _alarm_obj, getPos _alarm_obj ];
            } else { hint localize format["+++ XBaseEnemies: YELLOW flare near %1 already on", typeOf _alarm_obj]; };
		};
		case 1: {
			hint composeText[
				parseText("<t color='#f00000ff' size='2'>" + (localize "STR_SYS_62") /* "ОТБОЙ:" */ + "</t>"), lineBreak,
				parseText("<t size='1'>" + (localize "STR_SYS_63")/* "No more enemies in your base." */ + "</t>")
			];
		};
	};
};

"enemy_base" setMarkerPosLocal (d_base_array select 0);
_trigger = createTrigger["EmptyDetector" ,d_base_array select 0];
_trigger setTriggerArea [d_base_array select 1, d_base_array select 2, 0, true];
_trigger setTriggerActivation [d_enemy_side, "PRESENT", true];
_trigger setTriggerStatements["{ _x isKindOf 'LandVehicle' || ((_x isKindOf 'CAManBase') && ((name  _x) != 'Error: No unit')) } count thislist > 0", "[0, thislist] call XBaseEnemies;'enemy_base' setMarkerSizeLocal [d_base_array select 1,d_base_array select 2];", "[1] call XBaseEnemies;'enemy_base' setMarkerSizeLocal [0,0];"];
#endif

if (d_weather) then {execVM "scripts\weather\weatherrec2.sqf";};

// Teamstatus vehicle trigger, add action to player
vec_ass = -8876;
_trigger = createTrigger["EmptyDetector" ,_pos];
_trigger setTriggerArea [0, 0, 0, false];
_trigger setTriggerActivation ["NONE", "PRESENT", true];
#ifndef __ACE__
_trigger setTriggerStatements["vehicle player != player", "ts_vehicle = vehicle player;if (vec_ass == -8876) then {vec_ass = ts_vehicle addAction [localize 'STR_SYS_97', 'x_scripts\x_showstatus.sqf',[],-1,false]}", "if (vec_ass != -8876) then {ts_vehicle removeAction vec_ass;vec_ass = -8876}"]; // 'СТАТУС'
#endif
#ifdef __ACE__
_trigger setTriggerStatements["vehicle player != player && !((vehicle player) isKindOf 'ParachuteBase')", "ts_vehicle = vehicle player;if (vec_ass == -8876) then {vec_ass = ts_vehicle addAction [localize 'STR_SYS_97', 'x_scripts\x_showstatus.sqf',[],-1,false]}", "if (vec_ass != -8876) then {ts_vehicle removeAction vec_ass;vec_ass = -8876}"]; // 'СТАТУС'
#endif

#ifndef __AI__
_bravo = ["bravo_1","bravo_2","bravo_3","bravo_4","bravo_5","bravo_6","bravo_7","bravo_8"];
if (__TTVer) then {
	_bravo = ["racs_11","racs_12","west_11","west_12"];
};
_strp = format ["%1",_p];
_is_climber = false;
if (!(__ACEVer)) then {
	{
		if (_strp == _x) exitWith {
			_is_climber = true;
		};
	} forEach _bravo;
};
if (_is_climber) then {
	execVM "scripts\KRON_STRINGS.sqf";
	d_wires = [" pletivo_wired.p3d", " dd_pletivo.p3d", " plot_provizorni.p3d", " plot_rust_draty.p3d"," plot_green_draty.p3d", " pletivo.p3d", " zidka01.p3d", " zabradli_pruhovane_stred.p3d", " zed_kamenna.p3d", " newplot2.p3d", " afnewplot2.p3d", " plot_zed-drevo1.p3d", " zed.p3d", " plot_istan1b.p3d", " plot_vlnplech2.p3d", " plot_vinice.p3d", " plot_istan1_rovny.p3d", " svodidla_5m.p3d", " pletivo_wired_hole.p3d", " plot_bambus.p3d", " plot_vlnplech1.p3d", " plot_istan3.p3d", " plot_istan3_sloupek.p3d", " plot_wood1.p3d", " plot_istan2.p3d", " zed_kamenna_desert.p3d", " plot_wood_sloupek.p3d", " zed_desert.p3d"];

	[]spawn {
		while {true} do {
			while {!call XFindObstacle} do {sleep (0.341 + random 0.2)};
			obstID = player addAction [localize "STR_SYS_99_1", "x_scripts\x_climb.sqf"]; // "Перелезть через препятствие"
			while {call XFindObstacle} do {sleep (0.341 + random 0.2)};
			player removeAction obstID;
		};
	};
};
#endif
#ifdef __AI__
if (!(__ACEVer)) then {
	execVM "scripts\KRON_STRINGS.sqf";
	d_wires = [" pletivo_wired.p3d", " dd_pletivo.p3d", " plot_provizorni.p3d", " plot_rust_draty.p3d"," plot_green_draty.p3d", " pletivo.p3d", " zidka01.p3d", " zabradli_pruhovane_stred.p3d", " zed_kamenna.p3d", " newplot2.p3d", " afnewplot2.p3d", " plot_zed-drevo1.p3d", " zed.p3d", " plot_istan1b.p3d", " plot_vlnplech2.p3d", " plot_vinice.p3d", " plot_istan1_rovny.p3d", " svodidla_5m.p3d", " pletivo_wired_hole.p3d", " plot_bambus.p3d", " plot_vlnplech1.p3d", " plot_istan3.p3d", " plot_istan3_sloupek.p3d", " plot_wood1.p3d", " plot_istan2.p3d", " zed_kamenna_desert.p3d", " plot_wood_sloupek.p3d", " zed_desert.p3d"];

	[]spawn {
		while {true} do {
			waitUntil {sleep (0.341 + random 0.2);call XFindObstacle};
			obstID = player addAction [localize "STR_SYS_99_1", "x_scripts\x_climb.sqf"]; // "Перелезть через препятствие"
			waitUntil {sleep (0.341 + random 0.2);!(call XFindObstacle)};
			player removeAction obstID;
		};
	};
};
#endif

// everytime a new player connects time gets synced
"d_vars_array" addPublicVariableEventHandler {
	setDate ((_this select 1) select 1);
};

//player_is_medic = false;
//medicaction = -3333;
//if (_string_player in d_is_medic) then {
//	player_is_medic = true;
//	medicaction = _p addAction ["Мед.палатка", "x_scripts\x_mash.sqf",[],-1,false];
//	d_medtent = [];
//};

player_can_build_mgnest = false;
mgnestaction = -11111;
if (d_with_mgnest) then {
	if (_string_player in d_can_use_mgnests) then {
		player_can_build_mgnest = true;
		d_mgnest_pos = [];
		mgnestaction = _p addAction [localize "STR_SYS_2", "x_scripts\x_mgnest.sqf",[],-1,false]; // "Пулеметное гнездо"
	};
};

execVM "x_scripts\x_setvehiclemarker.sqf";

if (count d_action_menus_type > 0) then {
	{
		_types = _x select 0;
		if (count _types > 0) then {
			if (_type in _types) then {
				_action = _p addAction [_x select 1,_x select 2,[],-1,false];
				_x set [3, _action];
			};
		} else {
			_action = _p addAction [_x select 1,_x select 2,[],-1,false];
			_x set [3, _action];
		};
	} forEach d_action_menus_type;
};

if (count d_action_menus_unit > 0) then {
	{
		_types = _x select 0;
		_ar = _x;
		if (count _types > 0) then {
			{
				call compile format ["
					if (_p ==  %1) exitWith {
						_action = _p addAction [_ar select 1,_ar select 2,[],-1,false];
						_ar set [3, _action];
					};
				", _x];
			} forEach _types
		} else {
			_action = _p addAction [_x select 1,_x select 2,[],-1,false];
			_x set [3, _action];
		};
	} forEach d_action_menus_unit;
};

execVM "x_scripts\x_playerspawn.sqf";

//#ifndef __ACE__
execVM "x_scripts\x_water.sqf";
//#endif

if (count d_action_menus_vehicle > 0) then {execVM "x_scripts\x_vecmenus.sqf";};

#ifdef __MANDO__
// Checks if you have a laser designator to provide corresponding actions
[]execVM "mando_missiles\units\mando_haveialaser.sqf";

if (d_enemy_side == "EAST") then {
	// AA cameras for pilots
	// cameras setup (2 AIM9)
	_mcctypeaascript = "mando_missiles\tv\tv_types\mando_tv_aim9.sqs";
	[d_aa_camera, 2, 2, ["Air"], "IRST", _mcctypeaascript, [-4,2,-2], [0.7,5.8,.5,0,80], 0, 0, 0, [], 0.5, -3]execVM"mando_missiles\mcc\mando_mccallow_by_type.sqf";

	// Hellfire cameras setup (onboard hellfires)
	_mcctypeaascript = "mando_missiles\tv\tv_types\mando_tv_hellfire.sqs";
	[d_hellfire_camera, 0, 0, ["Vehicles"], "Hellfire Camera", _mcctypeaascript, [-3,2,-2], [0,6.2,-0.5,0,181], 1, 0, -4, [], 1, -3]execVM"mando_missiles\mcc\mando_mccallow_by_type.sqf";

	// AH1-Z cameras setup (scripted gun AG mode)
	_mcctypeaascript = "mando_missiles\tv\tv_types\mando_tv_gun.sqs";
	[d_ah1w_gun_camera, 99, 99, ["Vehicles"], "Gun Cam Ground mode", _mcctypeaascript, [0,6.2,-1,3], [0,6.2,-0.5,0,70], 1, 0, 1, [1,0,0,0.1], 0.2, 0]execVM"mando_missiles\mcc\mando_mccallow_by_type.sqf";

	// AH1-Z cameras setup (scripted gun AA mode)
	_mcctypeaascript = "mando_missiles\tv\tv_types\mando_tv_gun.sqs";
	[d_ah1w_gun_camera, 99, 99, ["Air"], "Gun Cam Air mode", _mcctypeaascript, [0,6.2,-1,3], [0,6.2,-0.5,0,70], 1, 0, 1, [0,0,1,0.1], 0.2, 0]execVM"mando_missiles\mcc\mando_mccallow_by_type.sqf";

	// LGB cameras setup (onboard LGBs)
	_mcctypeaascript = "mando_missiles\tv\tv_types\mando_tv_lgb.sqs";
	[d_lgb_camera, 0, 0, ["Vehicles"], "LGB Camera", _mcctypeaascript, [-3,2,-2], [0,2.6,-1.8,0,181], 0, 0, -1, [], 1, -3]execVM"mando_missiles\mcc\mando_mccallow_by_type.sqf";

	// Maverick cameras setup (onboard Mavericks)
	_mcctypeaascript = "mando_missiles\tv\tv_types\mando_tv_agm65.sqs";
	[d_maverick_camera, 0, 0, ["Vehicles"], "Maverick Camera", _mcctypeaascript, [-3,2,-2], [0.7,5.8,.5,0,30], 0, 0, -2, [], 1, -3]execVM"mando_missiles\mcc\mando_mccallow_by_type.sqf";
} else {
	// AA cameras for pilots
	// cameras setup (2 R73)
	_mcctypeaascript = "mando_missiles\tv\tv_types\mando_tv_r73.sqs";
	[d_aa_camera, 2, 2, ["Air"], "IRST", _mcctypeaascript, [-4,2,-2], [0.7,5.8,.5,0,80], 0, 0, 0, [], 0.5, -3]execVM"mando_missiles\mcc\mando_mccallow_by_type.sqf";

	// CH29 cameras setup (onboard CH29)
	_mcctypeaascript = "mando_missiles\tv\tv_types\mando_tv_ch29.sqs";
	[d_ch29_camera, 0, 0, ["Vehicles"], "CH29 Camera", _mcctypeaascript, [-3,2,-2], [0,6.2,-0.5,0,181], 1, 0, -4, [], 1, -3]execVM"mando_missiles\mcc\mando_mccallow_by_type.sqf";

	// KA50 cameras setup (scripted gun AG mode)
	_mcctypeaascript = "mando_missiles\tv\tv_types\mando_tv_gun.sqs";
	[d_ka50_gun_camera, 99, 99, ["Vehicles"], "Gun Cam Ground mode", _mcctypeaascript, [0,6.2,-1,3], [0,6.2,-0.5,0,70], 1, 0, 1, [1,0,0,0.1], 0.2, 0]execVM"mando_missiles\mcc\mando_mccallow_by_type.sqf";

	// KA50 cameras setup (scripted gun AA mode)
	_mcctypeaascript = "mando_missiles\tv\tv_types\mando_tv_gun.sqs";
	[d_ka50_gun_camera, 99, 99, ["Air"], "Gun Cam Air mode", _mcctypeaascript, [0,6.2,-1,3], [0,6.2,-0.5,0,70], 1, 0, 1, [0,0,1,0.1], 0.2, 0]execVM"mando_missiles\mcc\mando_mccallow_by_type.sqf";
};

//adds flares only
[d_flares_only, 0, "", [0,0], [0,0], 10, 10, "mando_missiles\units\mando_missilevehicle2.sqf", true, false, true, true, [2,0,-2], "mando_missiles\units\keysets\mando_airtorpedo_keys.sqf", 5, 5, 2, 0, false, 1]execVm"mando_missiles\units\mando_assignvehicle_by_type.sqf";

// Stryker_TOW units will be Patriots for players as gunners (missile idx 0)
_mcctypeaascript = "mando_missiles\mcc\mcc_types\mando_missilecontrolon_scud.sqs";
[d_patriot_missiles, 8, 8, [], "Lance Console", _mcctypeaascript, [0,0,0,2], [0,1,0.25], 1, -1, 0, [], 3]execVM"mando_missiles\mcc\mando_mccallow_by_type.sqf";

// Vulcan will have 0 flares and 12 AA missiles gunner (missile idx 0 and 1)
[d_aa_vehicles, 1, "M168", [12,0], [12,0], 0, 0, "mando_missiles\units\mando_missilevehicle2.sqf", false, true, false, false, [0,0,0,2], "mando_missiles\units\keysets\mando_shilka_keys2.sqf", 5, 5, 2, 0, false, 2]execVm"mando_missiles\units\mando_assignvehicle_by_type.sqf";

//provides ammo trucks with ability to reload mando flares and missiles to units
[d_reload_flares, 15]execVM"mando_missiles\units\mando_flaresreloadallow.sqf";
[d_reload_missiles, 15]execVM"mando_missiles\units\mando_missilereloadallow.sqf";
#endif

#ifndef __TT__
XFacAction = {
	private ["_num","_thefac","_element","_posf","_facid","_exit_it"];
	_num = _this select 0;
	_thefac = (
		switch (_num) do {
			case 0: {d_jet_service_fac};
			case 1: {d_chopper_service_fac};
			case 2: {d_wreck_repair_fac};
		}
	);
	waitUntil { (sleep (1.521 + (random 0.3))); !isNull _thefac};
	_element = d_aircraft_facs select _num;
	_posf = _element select 0;
	sleep 0.543;
	_facid = -1;
	_exit_it = false;
	while {!_exit_it} do {
		sleep 0.432;
		switch (_num) do {
			case 0: {if (d_jet_service_fac_rebuilding) then {_exit_it = true;};};
			case 1: {if (d_chopper_service_fac_rebuilding) then {_exit_it = true;};};
			case 2: {if (d_wreck_repair_fac_rebuilding) then {_exit_it = true;};};
		};

		if (!_exit_it) then {
			if (player distance _posf < 14 && !isNull _thefac && _facid == -1) then {
				if (alive player) then {
					_facid = player addAction [localize "STR_SYS_225","x_scripts\x_rebuildsupport.sqf",_thefac]; // "Починить здание техсервиса"
				};
			} else {
				if (_facid != -1) then {
					if (player distance _posf > 13 || isNull _thefac) then {
						player removeAction _facid;
						_facid = -1;
					};
				};
			};
		} else {
			if (_facid != -1) then {
				player removeAction _facid;
			};
		};
	};
};

#ifndef __REP_SERVICE_FROM_ENGINEERING_FUND__
if (_string_player in d_is_engineer /*|| __AIVer*/) then {
#endif
	if (!isNull d_jet_service_fac && !d_jet_service_fac_rebuilding) then {
		[0] spawn XFacAction;
	};
	if (!isNull d_chopper_service_fac && !d_chopper_service_fac_rebuilding) then {
		[1] spawn XFacAction;
	};
	if (!isNull d_wreck_repair_fac && !d_wreck_repair_fac_rebuilding) then {
		[2] spawn XFacAction;
	};
#ifndef __REP_SERVICE_FROM_ENGINEERING_FUND__
};
#endif

if (!isNull d_jet_service_fac && !d_jet_service_fac_rebuilding) then {
	_element = d_aircraft_facs select 0;
	_pos = _element select 0;
	_dir = _element select 1;
	_fac = "Land_budova2_ruins" createVehicleLocal _pos ;
	_fac setDir _dir;
};
if (!isNull d_chopper_service_fac && !d_chopper_service_fac_rebuilding) then {
	_element = d_aircraft_facs select 1;
	_pos = _element select 0;
	_dir = _element select 1;
	_fac = "Land_budova2_ruins" createVehicleLocal _pos ;
	_fac setDir _dir;
};
if (!isNull d_wreck_repair_fac && !d_wreck_repair_fac_rebuilding) then {
	_element = d_aircraft_facs select 2;
	_pos = _element select 0;
	_dir = _element select 1;
	_fac = "Land_budova2_ruins" createVehicleLocal _pos ;
	_fac setDir _dir;
};
#endif

#ifndef __ACE__
execVM "x_scripts\x_tanksmoke.sqf"; // add menu for some vehicles to make smoke curtains
#endif

#ifndef __MANDO__
if (!(__ACEVer)) then {execVM "x_scripts\x_airincoming.sqf";};
#endif

if (d_no_para_at_all) then {
	d_para_at_base = false;
};

#ifndef __TT__
FLAG_BASE addAction [localize "STR_FLAG_0","dlg\teleport.sqf"];
//FLAG_BASE addAction ["За допку","test.sqf"];
//FLAG_BASE addAction ["За город","test2.sqf"];
if (__AIVer || d_para_at_base) then {
	FLAG_BASE addAction [localize "STR_FLAG_1","AAHALO\x_paraj.sqf"]; // "(Choose Parachute location)"
	FLAG_BASE addAction [localize "STR_FLAG_8","AAHALO\SYG_parap.sqf"]; // "Practice parajump)"
};
#endif

#ifdef __DEBUG_DOSAAF__
FLAG_BASE addAction [">>> Бонус", "scripts\testbonus.sqf"];
#endif
#ifdef __DEBUG_SCORE__
if ( ((_pl_name) == "EngineerACE") && ((score player) < __DEBUG_SCORE__)) then { player addScore (__DEBUG_SCORE__ - (score player)) };
#endif

#ifdef __DEBUG_FLARE__
FLAG_BASE addAction [">>> Client  flare", "scripts\testflareclient.sqf"];
FLAG_BASE addAction [">>> Server flare", "scripts\testflareserver.sqf"];
#endif

#ifdef __TT__
if (d_own_side == "WEST") then {
	WFLAG_BASE addAction [localize "STR_FLAG_0","dlg\teleport.sqf"];
} else {
	RFLAG_BASE addAction [localize "STR_FLAG_0","dlg\teleport.sqf"];
};
#endif

//#define __TEST_PLAY_MUSIC__
#ifdef __TEST_PLAY_MUSIC__
FLAG_BASE addAction [">>> Music test", "scripts\testPlayMusic.sqf"];
#endif

//+++ Sygsky: add bar gates functionality
#ifdef 	__BARGATE_ANIM__
// find all bargates
_arr = nearestObjects[[9621,9874,0],["ZavoraAnim"],300];
hint localize format["x_setupplayer.sqf: found bar gates on base %1", count _arr];
FLAG_BASE addAction [localize "STR_FLAG_3"/* "Open gates" */,"scripts\controlgates.sqf", [0, _arr]];
FLAG_BASE addAction [localize "STR_FLAG_4"/* "Close gates" */,"scripts\controlgates.sqf", [1, _arr]];
#endif

#ifdef __STORE_EQUIPMENT__
FLAG_BASE addAction [localize "STR_FLAG_2" /* "Store equipment" */,"scripts\storeequipment.sqf","S"];
#endif

FLAG_BASE addAction [localize "STR_FLAG_5" /*"Rumours"*/,"scripts\rumours.sqf","",-1.2];
//--- Sygsky

if (!d_para_at_base) then {
	"teleporter" setMarkerTextLocal (localize "STR_FLAG_0"); //"Teleporter";
};

#ifdef __ACE__
// create additional boxes (rucksack, HuntIR etc)
hint localize format["+++ d_ace_boxes = %1",d_ace_boxes ];
for "_i" from 0 to (count d_ace_boxes) - 1 do {
	_element = d_ace_boxes select _i;
	_box = (_element select 0) createVehicleLocal (_element select 1);
	_box setDir (_element select 2);
	_box setPos (_element select 1);
	[_box, (_element select 1), (_element select 2), (_element select 0)] spawn {
		private ["_box","_boxname","_pos","_dir"];
		_box = _this select 0;
		_pos = _this select 1;
		_dir = _this select 2;
		_boxname = _this select 3;
		while {true} do {
			sleep (1500 + (random 500));
			if (!isNull _box) then {deleteVehicle _box};
			_box = _boxname createVehicleLocal _pos;
			_box setDir _dir;
			_box setPos _pos;
		};
	};
};
d_ace_boxes = nil;
#endif

if (!d_old_ammobox_handling) then {
	execVM "x_scripts\x_ammoload.sqf";
};

#ifndef __RANKED__
if (d_player_air_autokick > 0) then {
	execVM "x_scripts\x_autokick.sqf";
};
#else
	execVM "x_scripts\x_playerveccheck.sqf"; // Prevents player from entering vehicles not allowed by his rank (or weapon).
//	if (_string_player in d_is_medic) then {
	execVM "x_scripts\x_mediccheck.sqf"; // allows little medicine help for any player
//	};
	execVM "x_scripts\x_playervectrans.sqf"; // allows check for other players transportations score
#endif

/*
	if score changed, send info about it to the server
*/
[_pl_name] spawn {
	waitUntil {sleep 5; !d_still_in_intro};
	private ["_oldscore","_newscore","_mtkills","_oldkills","_newkills","_player","_pl_name"];
	_pl_name = _this select  0;
#ifdef __SPPM__
	hint localize "+++ SPPM UPDATE initiated for markers";
	["SPPM", "UPDATE", _pl_name, false] call XSendNetStartScriptServer; // allow SPPM markers visibility at the start
#endif
	_oldscore  = 0;
	_oldkills = (score player) - SYG_bonusScore + SYG_deathCount;
	call SYG_townStatInit; // init town kills stat for the player on connection
	while { true } do {
		sleep 4.5; // Xeno value was(3 + random 3); // Lets test  to change sleep delay to the period 4.5 seconds
		_newscore = score player;
		if (_oldscore != _newscore) then {
			_newkills = _newscore - SYG_bonusScore + SYG_deathCount; // find pure kills in the current town boundaries
			// real player kills in the town
			_mtkills = if (call SYG_playerIsAtTown) then { _newkills - _oldkills } else { -1 };
			// send full score (_newscore), in town real kills score (_mtkills)
			_player = if (SYG_playerID < 0) then {_pl_name} else {SYG_playerID};
			["d_ad_sc", _player, _newscore, _mtkills] call XSendNetStartScriptServer;

//			hint localize format["+++ send %1, bon %2, ded %3", ["d_ad_sc", _player, _newscore, _mtkills], SYG_bonusScore, SYG_deathCount];

			[] spawn XPlayerRank; // detect if new rank is reached and inform player about

			if ( rating player < 0  ) then { // prevent player from being enemy to AI
			    hint localize format["--- Your rating is below zero (%1), up it now", rating player];
			    player addRating (100 -(rating player));
			};

#ifdef __JAIL_MAX_SCORE__
//    	    hint localize format[ "--- oldscore %1, newscore %2", _oldscore, _newscore ];
			// Jail is assigned if score are negative enough (-15) and lowered by more then -1 value (not personal death occured)
			if ( (_oldscore <= __JAIL_MAX_SCORE__) && (_newscore < (_oldscore - 1)) ) then {
			    ["NEGATIVE"] execVM "scripts\jail.sqf"; // Send him to jail for (_newscore + 60) seconds
			};
#endif
			_oldscore = _newscore;
			_oldkills = _newkills;
		};
	};
};

#ifdef __AI__
d_heli_taxi_available = true;
_trigger = createTrigger ["EmptyDetector", _pos];
_trigger setTriggerText (localize "STR_AI_0"); // "Call in Air Taxi"
_trigger setTriggerActivation ["HOTEL", "PRESENT", true];
_trigger setTriggerStatements ["this", "xhandle = [] execVM ""x_scripts\x_airtaxi.sqf""",""];
#endif

d_vec_end_time = -1;

if (d_with_repstations) then {
	[] spawn {
		private ["_vec", "_nobs"];
		while {true} do {
			waitUntil {sleep (1 + (random 0.2)); vehicle player != player};
			_vec = vehicle player;
			while {vehicle player != player && alive player && alive _vec} do {
				if (player == driver _vec) then {
					_nobs = nearestObjects [position _vec,["Land_repair_center"],15];
					if (count _nobs > 0) then {
						if (damage _vec > 0) then {
							_vec setDamage 0;
							_vec vehicleChat format[localize "STR_SYS_64", typeOf _vec]; // "Your transport (%1) is refurbished by technical service..."
						};
					};
				};
				sleep 0.78;
			};
			if (!alive player) then {waitUntil {alive player}};
			sleep 2;
		};
	};
};

player call SYG_handlePlayerDammage; // handle hit events

//+++ Sygsky: Targets/GRU computer etc. All objects are on base
[] spawn {
	private ["_name"/* , "_identity" */, "_pos", "_target", "_targets","_var","_comp","_cnt"];
	sleep random 2;
	_name = name player;
	["d_p_varname",_name,str(player), localize "STR_LANG"] call XSendNetStartScriptServer;

/*
	// try to set russian identity
	if ( localize "STR_LANG" == "RUSSIAN") then
	{
		_identity = ["Rus1","Rus2","Rus3","Rus4","Rus5"] call XfRandomArrayVal;
		//player setIdentity _identity;
	};
*/
#ifdef __DEFAULT__
    //+++ Sygsky: here process some additional objects added to the gameplay, e.g. informational targets for fire ranges,GRU computer etc.
    //            Bar gates are processed somewhere in upper lines
    [] spawn {
        sleep 5;
        _targets = [];
        {
            _pos = _x select 0; // position
            _target = "TargetEpopup" createVehicleLocal _pos; // create target at pos
            if ( count _x > 1) then { _target setDir (_x select 1);}; // set target direction if designated
            if ( _pos select 2 != 0) then { _target setPos _pos;}; // set target height, may  be this is not needed
            _targets = _targets + [_target];
        }forEach [
            // south from flag between airstrip and courtyard
            [[9663, 9958, 0], 180] /* nearest to flag*/,[[9663, 9894.2, 0], 180]/*middle*/,[[9651.7, 9829.25, 4],180 ]/* fathest from flag to south on the roof of courtyard house */,
            [[9700.05,10190.07,0]], // north from flag on other side of airstrip
            [[10397.581,10003.883, 0], 90] // east from flag at the end of airstrip
        ];
        _targets execVM "scripts\fireRange.sqf";
        #ifdef __LH_HOWLER__
        [SYG_startNight, SYG_startMorning] execVM "scripts\SYG_lighthouses.sqf";
        #endif
        #ifdef __DOSAAF_BONUS__
        execVM "scripts\bonus\bonus_client.sqf";
        #endif
    };
#endif

    //+++ Sygsky: GRU computer handling - add action if found
	_comp = call SYG_getGRUComp;
#ifdef __DEBUG__
	hint localize format["x_setupplayer.sqf: GRU PC == %1",_comp];
#endif

	if ( !isNull _comp ) then{
		// check if action not added
//		hint localize format["x_setupplayer.sqf: Action adding to GRU PC, %1 == %2",COMPUTER_ACTION_ID_NAME,_var];
		if (format["%1",_comp getVariable COMPUTER_ACTION_ID_NAME] == "<null>") then {
//			playSound "ACE_VERSION_DING"; // inform about computer creation
			// add action
//			hint localize format["x_setupplayer.sqf: Action (%1) added to GRU PC", call SYG_getGRUCompScript];
			_comp addAction [ localize (call SYG_getGRUCompActionTextId), call SYG_getGRUCompScript, []];
			_comp setVariable [COMPUTER_ACTION_ID_NAME,true];
			//hint localize format["x_setupplayer.sqf: %1. Action added to GRU PC", call SYG_nowTimeToStr];
    		_comp addAction [localize "STR_COMP_ILLUM", "scripts\baseillum\illum_start.sqf"];
		}
#ifdef __DEBUG__
		else {
			hint localize "+++ x_setupplayer.sqf: Action on GRU PC is set already!!!";
		}
#endif
		;
	}
#ifdef __DEBUG__
	else { hint localize "+++ x_setupplayer.sqf: GRU PC isNull"; }
#endif
	;
	// Play about all fires
	sleep 5;
	if (SYG_firesAreCreated) then {
	    call SYG_firesService
	} else {
	    hint localize "*** x_setupplayer.sqf: SYG_firesAreCreated == false"
	};
	// play with map if exists
    _pos = call SYG_mapPos;
    _map = nearestObjects [_pos, ["Wallmap","RahmadiMap"], 100];
    if ( count _map > 0) then {
        _map = _map select 0;
        _id = _map addAction [localize "STR_CHECK_ITEM","GRU_scripts\mapAction.sqf", typeOf _map]; // "Изучить"
        hint localize format["+++ x_setupserver.sqf: addAction == %1 added to the map of %2", _id, typeOf _map];
    } else {
        hint localize format["+++ x_setupserver.sqf:  GRU map object not detected near pos %1", _pos];
    };
    // make the load on the Mi-17 less
    _cnt = 0;
    {
        [_x,2] call SYG_setHeliParaCargo;
        sleep 0.05;
        _cnt = _cnt + 1;
    }    forEach [	HR1, HR2, HR3, HR4];
    //hint localize format["+++ SYG_setHeliParaCargo called for %1 Mi-17 at base", _cnt];
    _common_boxes = [box1, box2, box3, box4, box5, grubox];
    {
        if ( !( (isNil str( _x ) ) || ( ! alive _x ) ) ) then {
            _x addAction [ localize "STR_CHECK_ITEM", "scripts\info_ammobox.sqf", format[localize format["STR_SYS_%1", toUpper str(_x)], localize "STR_SYS_BOX" ]];
        } else {
            hint localize format["--- Error: variable ""%1"" not found/not alive", str(_x)];
        };
    }   forEach _common_boxes;
//    hint localize format["*** getVectoDirAndUp (box5) = [%1,%2]", vectorDir box5, vectorUp box5];
#ifdef __ACE__
    _personal_boxes = ["ACE_RuckBox", "ACE_HuntIRBox", "ACE_WeaponBox_East","WeaponBoxEast","WeaponBoxWest"/*,"ACE_MedicBox"*/];
    _personal_boxes = nearestObjects [FLAG_BASE, _personal_boxes, 30]  - _common_boxes;
    _arr1 = _personal_boxes call SYG_vehToType;
    _action_arr = [ localize "STR_CHECK_ITEM", "scripts\info_ammobox.sqf", "STR_SYS_MAINBOX" ];
    _box addAction _action_arr;
    _box setVariable ["ACTION_ARR", _action_arr];
    {
        _x addAction _action_arr;
        _x setVariable ["ACTION_ARR", _action_arr];
    }   forEach _personal_boxes;
    hint localize format["+++ ammoboxes on base: arr = %1 ", _arr1];
#endif
};

#ifdef __MISSION_START__
//hint localize format["x_setupplayer.sqf: time BEFORE date setting %1", call SYG_nowTimeToStr];
waitUntil {time > 0};
SYG_client_start = missionStart;
//["set_mission_start", missionStart] call XSendNetStartScriptServer;
#endif

#ifdef __DEBUG_JAIL__
if (localize "STR_LANGUAGE" == "RUSSIAN") then {
    FLAG_BASE addAction ["В тюрьму!", "scripts\jail.sqf", "TEST" ];
};
player addAction["score -15","scripts\addScore.sqf",-15];
#endif

//#define __DEBUG_ADD_VEHICLES__

#ifdef __DEBUG_ADD_VEHICLES__
if (_pl_name == "EngineerACE") then {
    // teleport player to the hills above Bagango valley
    hint localize format["+++ x_setupplayer.sqf: EngineerACE (score %1) && __DEBUG_ADD_VEHICLES__", score player];
    //player setPos [14531,9930,0];
    //player setPos [9763, 11145, 0]; // near Rashidan dock
    // player setPos [16545,12875,0];
    // MRR1 setPos [9407,5260,0]; // move teleport to the position at SM #40 (hostages in Tiberis)
    waitUntil { sleep 0.5; (!isNil "d_player_stuff")};
    if ( (score player) < 1500 ) then { player addScore (1500 - (score player) ) };
    hint localize format["+++ x_setupplayer.sqf: EngineerACE score %1", score player];
    _arr = FLAG_BASE nearObjects ["HMMWV50", 100];
    {
    	_x addAction ["Check SPPM", "scripts\debug\debug_SMPP.sqf", "CHECK" ];
    } forEach _arr;
    hint localize format["+++ x_setupplayer.sqf: added ""Check SPPM"" action to %1 veh[s][", count _arr];
};
#else
    hint localize "+++ x_setupplayer.sqf: __DEBUG_ADD_VEHICLES__ not defined";
#endif

#ifdef __SCUD__
if (_pl_name == "HE_MACTEP") then {
    hint localize "+++ x_setupplayer.sqf: __SCUD__";
    waitUntil { sleep 0.5;(!isNil "d_player_stuff")};
    if ( score player < 1000 ) then { player addScore (1000 - (score player) ) };
};
#endif

SYG_client_start execVM "scripts\new_year_check.sqf";

if (true) exitWith { hint localize format["+++ x_setupplayer.sqf: finished in %1 seconds", time - _time]};
