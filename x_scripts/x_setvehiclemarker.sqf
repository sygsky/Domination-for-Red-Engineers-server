// by Xeno, x_scripts/x_setvehiclemarker.sqf : for clients only
// Totally transparent color: "ACE_ColorTransparent"
private ["_ap","_as","_i","_marker","_p_marker_color"];
if (!X_Client) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

#define PLAYER_MARKERS_REFRESH_INTERVAL 10 // interval between player markers refresh
if (isNil "d_show_player_marker") then {d_show_player_marker = 0;};
sleep 1.012;

p_uncon = false; // TODO: works only for revive options, may be removed in the future

#ifndef __TT__
X_XMarkerVehicles = {
	private ["_i","_mdir"];
	
	for "_i" from 1 to 2 do {
		call compile format ["if (!(isNil ""MRR%1"") && !(isNull MRR%1)) then {if (d_v_marker_dirs) then {""mobilerespawn%1"" setMarkerDirLocal ((direction MRR%1)+90)};""mobilerespawn%1"" setMarkerPosLocal (position MRR%1);};",_i];
		sleep 0.11;
	};
	{
		call compile format["if (!(isNil ""%1"") && !(isNull %1)) then {""%2"" setMarkerPosLocal (position %1);if (d_v_marker_dirs) then {""%2"" setMarkerDirLocal ((direction %1)+90)};};",(_x select 0), (_x select 2)];
		sleep 0.11;
	} forEach d_choppers;
	for "_i" from 1 to 10 do {
		call compile format["if (!(isNil ""TR%1"") && !(isNull TR%1)) then {""truck%1"" setMarkerPosLocal (position TR%1);if (d_v_marker_dirs) then {""truck%1"" setMarkerDirLocal ((direction TR%1)+90)};};",_i];
		sleep 0.11;
	};
	if (!(isNil "MEDVEC") && !(isNull MEDVEC)) then {"medvec" setMarkerPosLocal (position MEDVEC);if (d_v_marker_dirs) then {"medvec" setMarkerDirLocal ((direction MEDVEC)+90)};};
	sleep 0.11;
};

SYG_markerRefreshTime = time;   // time to refresh player markers
SYG_activeMarkers = [];         // marker active during predefined interval
/**
 *
 * Draws all alive players markers on the client computer
 */
X_XMarkerPlayers = {
	private [ "_i", "_ap", "_as", "_text","_markers_changed" ];
	if (time < SYG_markerRefreshTime) exitWith // use existing markers, simply change their position
	{
	    _markers_changed = false;
	    {
            _as = d_player_entities select _x; // marker name (_x here is the index in whole array)
            _ap = call (SYG_players_arr select _x); // object (_x here is the index in whole array)
            if ( isPlayer _ap) then
            {
                if ( alive _ap ) then
                {
                    _as setMarkerPosLocal position _ap;
                    if (d_p_marker_dirs) then {
                        _as setMarkerDirLocal (direction ((vehicle _ap)+90));
                    };
                    _as setMarkerTypeLocal  d_p_marker;
                }
                else
                {
                    // this marker is dead
#ifdef __ACE__
                    _as setMarkerTypeLocal  "ACE_Icon_SoldierDead"; // mark dead player as skull
#else
                    _as setMarkerTypeLocal "DestroyedVehicle";  // mark to be abstractly dead
#endif
//                    SYG_activeMarkers set [SYG_activeMarkers find _x, "RM_ME"];
//                    _markers_changed = true;
                };
            }
            else
            {
                _as setMarkerTypeLocal d_p_marker;
                _as setMarkerPosLocal [0,0];
                _as setMarkerTextLocal "";
                SYG_activeMarkers set [SYG_activeMarkers find _x, "RM_ME"];
                _markers_changed = true;
            };
       		sleep 0.0123;
        }  forEach SYG_activeMarkers;

        // remove dead markers, new ones will draw after next predefined interval
        if ( _markers_changed ) then
        {
            SYG_activeMarkers = SYG_activeMarkers - ["RM_ME"];
        };
	};

	// it is time to refresh all players marker
	SYG_activeMarkers = []; // load new alive markers
	for "_i" from 0 to ((count d_player_entities) - 1) do
	{
        _as = d_player_entities select _i; // name
        _ap = call (SYG_players_arr select _i); // object
        if ( isPlayer _ap && alive _ap) then
        {
            _as setMarkerPosLocal position _ap;

            // 0 = player markers turned off
            // 1 = player markers with player names and healthess
            // 2 = player markers without player names
            // 3 = player markers with roles but no name
            // 4 = player markers with player health, no name
            _text = "?";
            switch (d_show_player_marker) do {
                case 1: { _text = if (damage _ap <= 0.049 ) then { ""} else {format["/%1",str((10 - round(10 * damage _ap)) mod 10)]}; _text = format["%1%2",name _ap, _text] };
                case 2: { _text =  "" };
                case 3: { _text = _as };
                case 4: { _text = format["h%1", str((10 - round(10 * damage _ap)) mod 10)] };
            };
            _as setMarkerTextLocal _text;
            _as setMarkerTypeLocal d_p_marker;
            if (d_p_marker_dirs) then {
                _as setMarkerDirLocal (direction ((vehicle _ap)+90));
            };
            SYG_activeMarkers set [count SYG_activeMarkers, _i ];
        } else {
//#ifdef __ACE__
//            _as setMarkerColorLocal "ACE_ColorTransparent"; // that's all for ACE
//#else
            _as setMarkerTypeLocal d_p_marker;
            _as setMarkerPosLocal [0,0];
            _as setMarkerTextLocal "";
//#endif
        };
		sleep 0.0123;
	};
//    hint localize format["+++ Active player markers: %1, time %2", SYG_activeMarkers, time];
    SYG_markerRefreshTime = time + PLAYER_MARKERS_REFRESH_INTERVAL; // next time to refresh
};

_p_marker_color = "";

/*
if (!d_dont_show_player_markers_at_all) then {
	_tmp_grpsm = [];
	_mindex = 0;
	_colarray = ["ColorBlue","ColorGreen","ColorBlack","ColorRed","ColorRedAlpha","ColorGreenAlpha","ColorOrange", "ColorPink","ColorBrown", "ColorKhaki"];
	
    for "_i" from 0 to ((count d_player_entities) - 1) do {
		call compile format ["
			_grpm = group %1;
			if (!(_grpm in _tmp_grpsm)) then {_tmp_grpsm = _tmp_grpsm + [_grpm];};
			_mindex = _tmp_grpsm find _grpm;			
			_col = _colarray select (_mindex % (count _colarray));
			[""%1"", [0,0],""ICON"",_col,[0.4,0.4],"""",0,d_p_marker] call XfCreateMarkerLocal;
			if (player in (units _grpm)) then {_p_marker_color = _col};
		", d_player_entities select _i];
		sleep 0.01;
	};

	_tmp_grpsm = nil;
	_colarray = nil;
	_mindex = nil;
*/
/**
 * Markers for player creation
 *
 */
if (!d_dont_show_player_markers_at_all) then {
	_tmp_grpsm = [];
	_mindex = 0;
	_colarray = ["ColorBlue","ColorGreen","ColorBlack","ColorYellow","ColorRed","ColorRedAlpha","ColorGreenAlpha","ColorBlue","ColorGreen","ColorBlack","ColorYellow","ColorRed","ColorRedAlpha","ColorGreenAlpha","ColorBlue","ColorGreen","ColorBlack","ColorYellow","ColorRed","ColorRedAlpha","ColorGreenAlpha","ColorBlue","ColorGreen","ColorBlack","ColorYellow","ColorRed","ColorRedAlpha","ColorGreenAlpha","ColorBlue","ColorGreen"];
	for "_i" from 0 to ((count d_player_entities) - 1) do {
	    _as = d_player_entities select _i; // name of a player
	    _ap = call (SYG_players_arr select _i);   // player itself
        _grpm = group _ap;
        if (!(_grpm in _tmp_grpsm)) then {_tmp_grpsm = _tmp_grpsm + [_grpm];};
        _mindex = _tmp_grpsm find _grpm;
        [_as, [0,0],"ICON",(_colarray select _mindex),[0.4,0.4],"",0,d_p_marker] call XfCreateMarkerLocal;
        if (player in (units _grpm)) then {_p_marker_color = _colarray select _mindex};
/*
		call compile format ["
			_grpm = group %1;
			if (!(_grpm in _tmp_grpsm)) then {_tmp_grpsm = _tmp_grpsm + [_grpm];};
			_mindex = _tmp_grpsm find _grpm;			
			[""%1"", [0,0],""ICON"",(_colarray select _mindex),[0.4,0.4],"""",0,d_p_marker] call XfCreateMarkerLocal;
			if (player in (units _grpm)) then {_p_marker_color = _colarray select _mindex};
		", d_player_entities select _i];
*/
		sleep 0.01;
	};

	_tmp_grpsm = nil;
	_colarray = nil;
	_mindex = nil;
};
#endif

#ifdef __TT__
_mrname = "mobilerespawn";
_medname = "medvec";
_trname = "truck";
_cservicename = "chopper_service";
_wrepname = "wreck_service";
_telename = "teleporter";
_jetservicename = "aircraft_service";
_bonusairname = "bonus_air";
_bonusvecname = "bonus_vehicles";
_ammoload = "Ammobox Reload";
if (playerSide == west) then {
	_mrname = "mobilerespawnR";
	_medname = "medvecR";
	_trname = "truckR";
	_cservicename = "chopper_serviceR";
	_wrepname = "wreck_serviceR";
	_telename = "teleporterR";
	_jetservicename = "aircraft_serviceR";
	_bonusairname = "bonus_airR";
	_bonusvecname = "bonus_vehiclesR";
	_ammoload = "Ammobox ReloadR";
	{
		deleteMarkerLocal (_x select 2);
	} forEach d_choppers_racs;
} else {
	{
			deleteMarkerLocal (_x select 2);
	} forEach d_choppers_west;
};
for "_i" from 1 to 2 do {
	_mname = _mrname + format ["%1",_i];
	deleteMarkerLocal _mname;
};
deleteMarkerLocal _medname;
for "_i" from 1 to 5 do {
	_mname = _trname + format ["%1",_i];
	deleteMarkerLocal _mname;
};
deleteMarkerLocal _cservicename;
deleteMarkerLocal _wrepname;
deleteMarkerLocal _telename;
deleteMarkerLocal _jetservicename;
deleteMarkerLocal _bonusairname;
deleteMarkerLocal _bonusvecname;
deleteMarkerLocal _ammoload;

_cname = nil;
_mrname = nil;
_medname = nil;
_trname = nil;
_cservicename = nil;
_wrepname = nil;
_telename = nil;
_jetservicename = nil;
_bonusairname = nil;
_bonusvecname = nil;

X_XMarkerVehicles = {
	private ["_i"];
	if (playerSide == west) then {
		for "_i" from 1 to 2 do {
			call compile format ["if (!(isNil ""MRR%1"") && !(isNull MRR%1)) then {if (d_v_marker_dirs) then {""mobilerespawn%1"" setMarkerDirLocal (direction MRR%1)};""mobilerespawn%1"" setMarkerPosLocal (position MRR%1);};",_i];
			sleep 0.11;
		};
		{
			call compile format["if (!(isNil ""%1"") && !(isNull %1)) then {""%2"" setMarkerPosLocal (position %1);if (d_v_marker_dirs) then {""%2"" setMarkerDirLocal (direction %1)};};",(_x select 0), (_x select 2)];
			sleep 0.11;
		} forEach d_choppers_west;
		for "_i" from 1 to 5 do {
			call compile format["if (!(isNil ""TR%1"") && !(isNull TR%1)) then {""truck%1"" setMarkerPosLocal (position TR%1);if (d_v_marker_dirs) then {""truck%1"" setMarkerDirLocal (direction TR%1)};};",_i];
			sleep 0.11;
		};
		if (!(isNil "MEDVEC") && !(isNull MEDVEC)) then {"medvec" setMarkerPosLocal (position MEDVEC);if (d_v_marker_dirs) then {"medvec" setMarkerDirLocal (direction MEDVEC)};};
	} else {
		for "_i" from 1 to 2 do {
			call compile format ["if (!(isNil ""MRRR%1"") && !(isNull MRRR%1)) then {if (d_v_marker_dirs) then {""mobilerespawnR%1"" setMarkerDirLocal (direction MRRR%1)};""mobilerespawnR%1"" setMarkerPosLocal (position MRRR%1);};",_i];
			sleep 0.11;
		};
		{
			call compile format["if (!(isNil ""%1"") && !(isNull %1)) then {""%2"" setMarkerPosLocal (position %1);if (d_v_marker_dirs) then {""%2"" setMarkerDirLocal (direction %1)};};",(_x select 0), (_x select 2)];
			sleep 0.11;
		} forEach d_choppers_racs;
		for "_i" from 1 to 5 do {
			call compile format["if (!(isNil ""TRR%1"") && !(isNull TRR%1)) then {""truckR%1"" setMarkerPosLocal (position TRR%1);if (d_v_marker_dirs) then {""truckR%1"" setMarkerDirLocal (direction TRR%1)};};",_i];
			sleep 0.11;
		};
		if (!(isNil "MEDVECR") && !(isNull MEDVECR)) then {"medvecR" setMarkerPosLocal (position MEDVECR);if (d_v_marker_dirs) then {"medvecR" setMarkerDirLocal (direction MEDVECR)};};
	};
	sleep 0.11;
};

d_entities_tt = (
	if (playerSide == west) then {
		["RESCUE","west_1","west_2","west_3","west_4","west_5","west_6","west_7","west_8","west_9","west_10","west_11","west_12","west_13","west_14"]
	} else {
		["RESCUE2","racs_1","racs_2","racs_3","racs_4","racs_5","racs_6","racs_7","racs_8","racs_9","racs_10","racs_11","racs_12","racs_13","racs_14"]
	}
);

X_XMarkerPlayers = {
	private ["_i"];
	for "_i" from 0 to ((count d_entities_tt) - 1) do {
		call compile format ["
			_ap = %1;
			_as = ""%1"";
			if (alive _ap && isPlayer _ap) then {
				_as setMarkerPosLocal position _ap;
				switch (d_show_player_marker) do {
					case 1: {_as setMarkerTextLocal name _ap};
					case 2: {_as setMarkerTextLocal """"};
					case 3: {_as setMarkerTextLocal (d_player_roles select _i)};
					case 4: {_as setMarkerTextLocal ""Health: "" + str(9 - round(9 * damage _ap))};
				};
				if (d_p_marker_dirs) then {
					if (vehicle _ap == _ap) then {
						_as setMarkerDirLocal (direction _ap);
					} else {
						_as setMarkerDirLocal (direction (vehicle _ap));
					};
				};
			} else {
				_as setMarkerPosLocal [0,0];
				_as setMarkerTextLocal """";
			};
		", d_entities_tt select _i];
		sleep 0.0123;
	};
};

_p_marker_color = "";
if (!d_dont_show_player_markers_at_all) then {
	_tmp_grpsm = [];
	_mindex = 0;
	_colarray = ["ColorBlue","ColorGreen","ColorBlack","ColorYellow","ColorRed","ColorRedAlpha","ColorGreenAlpha","ColorBlue","ColorGreen","ColorBlack","ColorYellow","ColorRed","ColorRedAlpha","ColorGreenAlpha","ColorBlue","ColorGreen","ColorBlack","ColorYellow","ColorRed","ColorRedAlpha","ColorGreenAlpha","ColorBlue","ColorGreen","ColorBlack","ColorYellow","ColorRed","ColorRedAlpha","ColorGreenAlpha","ColorBlue","ColorGreen"];
	for "_i" from 0 to ((count d_entities_tt) - 1) do {
		call compile format ["
			_grpm = group %1;
			if (!(_grpm in _tmp_grpsm)) then {_tmp_grpsm = _tmp_grpsm + [_grpm];};
			_mindex = _tmp_grpsm find _grpm;
			[""%1"", [0,0],""ICON"",(_colarray select _mindex),[0.4,0.4],"""",0,d_p_marker] call XfCreateMarkerLocal;
			if (player in (units _grpm)) then {_p_marker_color = _colarray select _mindex};
		", d_entities_tt select _i];
		sleep 0.01;
	};

	_tmp_grpsm = nil;
	_colarray = nil;
	_mindex = nil;
};
#endif

#ifdef __AI__
for "_abcdef" from 0 to 31 do {
	call compile format ["
		[""AI_X%1"", [0,0],""ICON"",_p_marker_color,[0.4,0.4],"""",0,d_p_marker] call XfCreateMarkerLocal;
	", _abcdef];
};

X_XAI_Markers = {
	_units = _this;
	_mkname = "AI_X%1";
	for "_abcdef" from 0 to 31 do {
		if (_abcdef < count _units - 1) then {
			_unit = _units select _abcdef;
			if (alive _unit) then {
				(format[_mkname, _abcdef]) setMarkerPosLocal position _unit;

                // 0 = player markers turned off
                // 1 = player markers with player names and healthess
                // 2 = player markers without player names
                // 3 = player markers with roles but no name
                // 4 = player markers with player health, no name

				switch (d_show_player_marker) do {
				    case 3;
					case 1: {(format[_mkname, _abcdef]) setMarkerTextLocal (str _abcdef)};
					case 2: {(format[_mkname, _abcdef]) setMarkerTextLocal ""};
//					case 3: {(format[_mkname, _abcdef]) setMarkerTextLocal ""};
					case 4: {(format[_mkname, _abcdef]) setMarkerTextLocal format["h%1", str((10 - round(10 * damage _unit)) mod 10)]};
				};
			} else {
				(format[_mkname, _abcdef]) setMarkerPosLocal [0,0];
				(format[_mkname, _abcdef]) setMarkerTextLocal "";
			};
		} else {
			(format[_mkname, _abcdef]) setMarkerPosLocal [0,0];
			(format[_mkname, _abcdef]) setMarkerTextLocal "";
		};
		sleep 0.013;
	};
};
#endif

sleep 0.01;

[] spawn {
	while {true} do {
		[] spawn X_XMarkerVehicles;
		sleep 0.01;
		if (d_show_player_marker > 0) then {
			[] spawn X_XMarkerPlayers;
			#ifdef __AI__
			_grppl = group player;
			_units = units _grppl - [player];
			_units spawn X_XAI_Markers;
			#endif
			sleep 0.01;
		};
		if (d_weather) then {[] spawn XWeatherLoop;};
			
		sleep 2.12;
	};
};

if (true) exitWith {};
