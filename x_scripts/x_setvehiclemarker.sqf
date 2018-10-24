// by Xeno, x_scripts/x_setvehiclemarker.sqf : for clients only
private ["_ap","_as","_i","_marker","_p_marker_color"];
if (!X_Client) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

if (isNil "d_show_player_marker") then {d_show_player_marker = 0;};
sleep 1.012;

p_uncon = false;

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

// prepare players variables to speed up marker drawing
SYG_players_arr = [{RESCUE},{RESCUE2},{alpha_1},{alpha_2},{alpha_3},{alpha_4},{alpha_5},{alpha_6},{alpha_7},{alpha_8},{bravo_1},{bravo_2},{bravo_3},{bravo_4},{bravo_5},{bravo_6},{bravo_7},{bravo_8},{charlie_1},{charlie_2},{charlie_3},{charlie_4},{charlie_5},{charlie_6},{charlie_7},{charlie_8},{charlie_9},{delta_1},{delta_2},{delta_3},{delta_4}];

// Draw all players markers on the client
X_XMarkerPlayers = {
	private [ "_i", "_ap", "_as", "_text" ];
	for "_i" from 0 to ((count d_player_entities) - 1) do
	{
        _as = d_player_entities select _i;
        _ap = call (SYG_players_arr select _i);
        //call compile format [ "_ap = %1;", _as ];
        if (alive _ap && isPlayer _ap) then {
            _as setMarkerPosLocal position _ap;

            // 0 = player markers turned off
            // 1 = player markers with player names and healthess
            // 2 = player markers without player names
            // 3 = player markers with roles but no name
            // 4 = player markers with player health, no name
            _text = "?";
            switch (d_show_player_marker) do {
                case 1: { _text = format["%1/%2",name _ap, str((10 - round(10 * damage _ap)) mod 10)] };
                case 2: { _text =  "" };
                case 3: { _text = _as };
                case 4: { _text = format["h%1", str((10 - round(10 * damage _ap)) mod 10)] };
            };
            _as setMarkerTextLocal _text;
            if (d_p_marker_dirs) then {
                _as setMarkerDirLocal (direction ((vehicle _ap)+90));
            };
        } else {
            _as setMarkerPosLocal [0,0];
            _as setMarkerTextLocal "";
        };
		sleep 0.0123;
	};
};

_p_marker_color = "";

/*
if (!d_dont_show_player_markers_at_all) then {
	_tmp_grpsm = [];
	_mindex = 0;
	_cindex = 0;
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
if (!d_dont_show_player_markers_at_all) then {
	_tmp_grpsm = [];
	_mindex = 0;
	_colarray = ["ColorBlue","ColorGreen","ColorBlack","ColorYellow","ColorRed","ColorRedAlpha","ColorGreenAlpha","ColorBlue","ColorGreen","ColorBlack","ColorYellow","ColorRed","ColorRedAlpha","ColorGreenAlpha","ColorBlue","ColorGreen","ColorBlack","ColorYellow","ColorRed","ColorRedAlpha","ColorGreenAlpha","ColorBlue","ColorGreen","ColorBlack","ColorYellow","ColorRed","ColorRedAlpha","ColorGreenAlpha","ColorBlue","ColorGreen"];
	for "_i" from 0 to ((count d_player_entities) - 1) do {
		call compile format ["
			_grpm = group %1;
			if (!(_grpm in _tmp_grpsm)) then {_tmp_grpsm = _tmp_grpsm + [_grpm];};
			_mindex = _tmp_grpsm find _grpm;			
			[""%1"", [0,0],""ICON"",(_colarray select _mindex),[0.4,0.4],"""",0,d_p_marker] call XfCreateMarkerLocal;
			if (player in (units _grpm)) then {_p_marker_color = _colarray select _mindex};
		", d_player_entities select _i];
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
				switch (d_show_player_marker) do {
					case 1: {(format[_mkname, _abcdef]) setMarkerTextLocal (str _abcdef)};
					case 2: {(format[_mkname, _abcdef]) setMarkerTextLocal ""};
					case 3: {(format[_mkname, _abcdef]) setMarkerTextLocal ""};
					case 4: {(format[_mkname, _abcdef]) setMarkerTextLocal format["Health: %1", str(9 - round(9 * damage _unit)) ]};
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
