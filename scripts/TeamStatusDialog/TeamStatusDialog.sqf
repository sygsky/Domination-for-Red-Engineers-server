// Desc: Team Status Dialog
// Features: Group joining, Team Leader selection, statistics for team/group/vehicle/opposition
// By: Dr Eyeball
// Version: 1.3 (November 2008)
//-----------------------------------------------------------------------------
// Dialog is now dependent on STR_TSD9_ entries which must be #include'd in stringtable.csv
//-----------------------------------------------------------------------------
// Search for comments labelled "DEV:", which allow the mission developer to 
// modify the behaviour of this script with subtle code changes. These options 
// may become parameters in future.
//-----------------------------------------------------------------------------
// Constants
//-----------------------------------------------------------------------------
// The following variables should match their equivalents for the dialog (from description.ext or included file)
#define TSD9_IDD_TeamStatusDialog 385

//#define TSD9_IDC_Progress 99
#define TSD9_IDC_CloseButton 100
#define TSD9_IDC_MyTeamButton 103
#define TSD9_IDC_MyGroupButton 104
#define TSD9_IDC_VehicleButton 105
#define TSD9_IDC_OppositionButton 106
#define TSD9_IDC_FrameCaption 107
#define TSD9_IDC_CollapseAllButton 108
#define TSD9_IDC_ExpandAllButton 109

#define TSD9_ROWS 43
//-----------------------------------------------------------------------------
#define TSD9_color_white [1.0, 1.0, 1.0, 1.0]
#define TSD9_color_black [0.0, 0.0, 0.0, 1.0]
#define TSD9_color_maroon [0.5, 0.0, 0.2, 1.0]
#define TSD9_color_red [1.0, 0.0, 0.0, 1.0]
#define TSD9_color_green [0.0, 1.0, 0.0, 1.0]
#define TSD9_color_blue [0.0, 0.0, 1.0, 1.0]
#define TSD9_color_orange [0.8, 0.2, 0.1, 1.0]
#define TSD9_color_yellow [.85, .85, 0.0, 1.0]
#define TSD9_color_ltPurple [0.7, 0.7, 1.0, 1.0]
#define TSD9_color_paleYellow [.35, .35, 0.0, 1]
#define TSD9_color_paleGreen [0.33, 0.73, 0.49, 0.5]
#define TSD9_color_paleBlue [0.3, 0.3, 0.7, 0.5]
#define TSD9_color_paleBlue2 [0, 0.4, 0.7, 1]
#define TSD9_color_paleRed [0.7, 0.3, 0.3, 0.7]
#define TSD9_color_Gray_10 [0.1, 0.1, 0.1, 1]
#define TSD9_color_Gray_20 [0.2, 0.2, 0.2, 1]
#define TSD9_color_Gray_30 [0.3, 0.3, 0.3, 1]
#define TSD9_color_Gray_40 [0.4, 0.4, 0.4, 1]
#define TSD9_color_Gray_50 [0.5, 0.5, 0.5, 1]

#define TSD9_AltBGDiff 0.02
#define TSD9_ColorScheme_DialogBackground 0x29/256, 0x37/256, 0x46/256 // dark blue
#define TSD9_ColorScheme_CaptionBackground 0x3E/256, 0x74/256, 0x58/256 // dark green
#define TSD9_ColorScheme_3DControlBackground 0x7D/256, 0x77/256, 0x66/256 // pale brown grey
#define TSD9_ColorScheme_3DControlBackgroundAlt (0x7D/256)-TSD9_AltBGDiff, (0x77/256)-TSD9_AltBGDiff, (0x66/256)-TSD9_AltBGDiff // pale brown grey
#define TSD9_ColorScheme_HighlightBackground 0x99/256, 0x8C/256, 0x58/256 // tan

#define TSD9_color_default [-1.0, -1.0, -1.0, -1.0]
#define TSD9_color_textFG TSD9_color_white
#define TSD9_color_groupBG [TSD9_ColorScheme_CaptionBackground, 1]
#define TSD9_color_playerBG [TSD9_ColorScheme_HighlightBackground, 1]
#define TSD9_color_cellABG [TSD9_ColorScheme_3DControlBackgroundAlt, 1]
#define TSD9_color_cellBBG [TSD9_ColorScheme_3DControlBackground, 1]
//#define TSD9_color_voidBG [TSD9_ColorScheme_DialogBackground, 0.1]

//#define TSD9_hightlight_text_code "%$Highlight$%"

//-----------------------------------------------------------------------------
TSD9_GridRefCoords = if (isNil "ICE_GridRefCoords") then {
	compile preprocessFileLineNumbers "Scripts\TeamStatusDialog\pos2grid.cpp";
} else {
	ICE_GridRefCoords;
};
//-----------------------------------------------------------------------------
TSD9_groupChat = {
	// this simple version does not broadcast the chat to all clients in group
	(_this select 0) groupChat (_this select 1);
};
if !(isNil "ICE_groupChat") then {
	// this version does broadcast the chat to all clients in group
	TSD9_groupChat = ICE_groupChat;
};
//-----------------------------------------------------------------------------
TSD9_GetParamIndexByName = {
	// Desc: Get index of named param in array
	// Result: integer index
	//-----------------------------------------------------------------------------
	private ["_result", "_paramName", "_nestedArray", "_paramIndex", "_i", "_record", "_equal"];

	_paramName = _this select 0;
	_nestedArray = _this select 1; // nested array. inside array can contain 1..n fields and can also be a non-array
	_paramIndex = 0; if (count _this > 2) then {_paramIndex = _this select 2}; // specify which field index to compare with

	_result = -1;
	if (typeName _paramName == "ARRAY") exitWith {_result};
	if (typeName _nestedArray != "ARRAY") exitWith {_result};
	if (_paramIndex < 0) exitWith {_result};

	_i = 0;
	{
		_record = _x;
		if (typeName _record == "ARRAY") then {
			if (count _record > _paramIndex) then {
				if (typeName(_record select _paramIndex) == typeName _paramName) then {
					if ((_record select _paramIndex) == _paramName) exitWith {
						_result = _i;
					};
				};
			};
		};
		_i = _i + 1;
	} forEach _nestedArray;
	_result;
};
//-----------------------------------------------------------------------------
TSD9_GetParamByName = {
	// Desc: Get variable (any type) of named param in array
	// Result: any
	//-----------------------------------------------------------------------------
	// _nestedArray = [ ["Item1", [1,[a,b],3]], ["Item2", "hello"] ]
	private ["_result", "_paramName", "_nestedArray", "_default", "_paramIndex", "_resultIndex", "_index", "_record"];

	// params
	_paramName = _this select 0;
	_nestedArray = _this select 1;
	_default = _this select 2;
	_paramIndex = 0; if (count _this > 3) then {_paramIndex = _this select 3}; // specify which field index to compare with
	_resultIndex = 1; if (count _this > 4) then {_resultIndex = _this select 4}; // specify which field index to return

	_result = _default;
	_index = [_paramName, _nestedArray, _paramIndex] call TSD9_GetParamIndexByName;
	if (_index >= 0) then {
		_record = _nestedArray select _index;
		if (count _record > _resultIndex) then {_result = _record select _resultIndex;};
	};
	_result;
};
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Variables
//-----------------------------------------------------------------------------
TSD9_ClosedGroups = []; // move this external to this file, to make it persistent between dialog uses.
TSD9_VehicleSearchComplete = true;
TSD9_Vehicle = objNull;
TSD9_HideIcons = false;
TSD9_DeleteRemovedAI = false;
TSD9_AllowAILeaderSelect = false;
TSD9_AllowAIRecruitment = false;
TSD9_AllowPlayerInvites = false;
TSD9_ShowAIGroups = false;
TSD9_CloseOnKeyPress = false;

//-----------------------------------------------------------------------------
// Control functions
//-----------------------------------------------------------------------------
TSD9_ArraysAreEqual = {
	_Array1 = _this select 0;
	_Array2 = _this select 1;

	_Result = true;
	if (count _Array1 != count _Array2) then {
		_Result = false
	} else {
		for "_i" from 0 to (count _Array1 - 1) do {
			if (_Array1 select _i != _Array2 select _i) then  {_Result = false};
		};
	};
	_Result;
};
//----------------------
TSD9_SetCtrlColors = {
	_idc2 = _this select 0;
	_col = _this select 1;
	_fg2 = _this select 2; 
	_bg2 = _this select 3;

	if (_fg2 select 0 == TSD9_color_default select 0) then { _fg2 = TSD9_color_textFG; };

	// add alternating column colors
	if (_bg2 select 0 == TSD9_color_default select 0) then {
		if (_col in [1,3,5,8,18,15]) then {
			_bg2 = TSD9_color_cellABG
		} else {
			_bg2 = TSD9_color_cellBBG
		};
	};

	// add alternating row colors
	_grey0 = _bg2 select 0;
	_grey1 = _bg2 select 1;
	_grey2 = _bg2 select 2;
	// don't alternate: a) bottom area, b) non-cell colours.
	//(!([_bg2, TSD9_color_voidBG] call TSD9_ArraysAreEqual)) && 
	if ((([_bg2, TSD9_color_cellABG] call TSD9_ArraysAreEqual) || ([_bg2, TSD9_color_cellBBG] call TSD9_ArraysAreEqual))) then {
		_row = round((_idc2-1000)/100);  
		if (_row / 3 == round(_row / 3)) then {
			_altRow0 = _grey0-TSD9_AltBGDiff;
			_altRow1 = _grey1-TSD9_AltBGDiff;
			_altRow2 = _grey2-TSD9_AltBGDiff;
			_bg2 = [_altRow0, _altRow1, _altRow2, _bg2 select 3];
		};
	};

	_control = TSD9_display displayCtrl _idc2;

	/* TODO: finish later, but change logic to use array instead of embedded strings
	if ((_txt2 find/str _hightlight_text_code) != -1) then
	{
	_control ctrlSetTextColor TSD9_color_textFG;
	_control ctrlSetBackgroundColor TSD9_color_maroon;
	}
	else
	{
	*/
	_control ctrlSetTextColor _fg2;
	_control ctrlSetBackgroundColor _bg2;
	//_control ctrlSetActiveColor _bg2;
	//};  
};
//----------------------
TSD9_SetText = {
	_idc2 = _this select 0;
	/*
	_col = _this select 1;
	_fg2 = _this select 2; 
	_bg2 = _this select 3;
	*/
	_txt2 = _this select 4;

	ctrlSetText [_idc2, _txt2];

	//_control = TSD9_display displayCtrl _idc2;
	//_control ctrlSetTooltip _txt2; // doesn't do anything for text ctrl types, only buttons

	_this call TSD9_SetCtrlColors;
};
//----------------------
TSD9_SetCombo = {
	_idc2 = _this select 0;
	/*
	_col = _this select 1;
	_fg2 = _this select 2; 
	_bg2 = _this select 3;
	*/
	_txtArray2 = _this select 4;

	lbClear _idc2;

	{
		_value = "";
		_data = "";
		_picture = "";
		//['TeamStatusDialog.sqf', format["TSD9_SetCombo=%1:%2", _idc2, _x]] call fn_DebugAppend;
		if (count _x > 0) then { _value = _x select 0 };
		if (count _x > 1) then { _data = _x select 1 };
		if (count _x > 2) then { _picture = _x select 2 };

		/*
		// TODO: validate picture path - how?
		if (!isValidAddonPath _picture) then
		{
		  _picture = "";
		};
		*/

		_index = lbAdd [_idc2, _value];
		lbSetPicture [_idc2, _index, _picture];
		lbSetData [_idc2, _index, _value];
		// lbSetColor [_idc2, _index, [0, 1, 0, 0.9]]; // TODO: add color param to highlight certain items
	} forEach _txtArray2;

	lbSetCurSel [_idc2, 0];
	_this call TSD9_SetCtrlColors;
};
//----------------------
TSD9_HideCtrl = {
	_idc2 = _this select 0;
	_col = _this select 1;

	lbClear _idc2;
	ctrlShow [_idc2, false];
};
//----------------------
TSD9_ShowCtrl = {
	_idc2 = _this select 0;
	_col = _this select 1;

	ctrlShow [_idc2, true];
};
//----------------------
TSD9_GetRowIdc = {
	_row = _this select 0;

	1000+(_row*100); // (row:col = RRCC, max = 100 * 100 cells)
};
//----------------------
TSD9_FilterIcons = {
	_picture = _this select 0;
	if (TSD9_HideIcons) then { _picture = "" };
	_picture;
};
//-----------------------------------------------------------------------------
// Player Stats functions
//-----------------------------------------------------------------------------
TSD9_GetPlayerIndex = {
	//_player = _this select 0;
	//_row = _this select 1;
	_id = _this select 2;

	if (_id < 0)  then { "" } else { format["%1", _id] };
	// can't find a reliable command to return the true group position id, similar to the "3" in "WEST 1-1-A-3"
};
//----------------------
TSD9_GetCloseGroupButtonText = {
	_group = _this select 0;

	if ((TSD9_Page == "Team") || (TSD9_Page == "Opposition")) then {
		_ExpandOrCollapseBlock = "-";
		if (format["%1", _group] in TSD9_ClosedGroups) then {_ExpandOrCollapseBlock = "+";};
		format["[%1]", _ExpandOrCollapseBlock];
	} else {
		"";
	};
};
//----------------------
TSD9_CreateCloseGroupButtonAction = {
	_group = _this select 0;

	if ((TSD9_Page == "Team") || (TSD9_Page == "Opposition")) then {
		_AddOrRemoveSet = "+";
		if (format["%1", _group] in TSD9_ClosedGroups) then {_AddOrRemoveSet = "-";};
		format[ "TSD9_ClosedGroups = TSD9_ClosedGroups %1 [""%2""]; [] call TSD9_DrawPage", _AddOrRemoveSet, _group];
	} else {
		""
	};
};
//----------------------
//+++ Sygsky TODO: change to call for player func: _rank = _rank call XGetRankStringLocalized;
TSD9_GetRank = {
	_player = _this select 0;
	_rank = rank _player;

	switch (_rank) do {
		case "PRIVATE": {_rank = localize "STR_TSD9_26"};
		case "CORPORAL": {_rank = localize "STR_TSD9_27"};
		case "SERGEANT": {_rank = localize "STR_TSD9_28"};
		case "LIEUTENANT": {_rank = localize "STR_TSD9_29"};
		case "CAPTAIN": {_rank = localize "STR_TSD9_30"};
		case "MAJOR": {_rank = localize "STR_TSD9_31"};
		case "COLONEL": {_rank = localize "STR_TSD9_32"};
	};
	_rank;
};
//----------------------
TSD9_GetPlayerName = {
	_player = _this select 0;
	_name = name _player;
	_rank = [_player] call TSD9_GetRank;
	_name = _rank+". "+_name;
	if (_name == "Error: No unit") then { _name = format[ "--%1-- %2. %3", localize "STR_TSD9_34", vehicleVarName _player, localize "STR_TSD9_35" ] };
	if (not isPlayer _player) then { _name = format["(%1) %2", localize "STR_TSD9_33", _name] };
	_name;
};
//----------------------
TSD9_VehicleHasTrueWeapons = {
	_vehicle = _this select 0;

	_weapons = weapons _vehicle;
	_count = count _weapons;
	_hasTrueWeapon = (_count > 0);

	// check if weapon is actually only a car horn
	// assumes if weapon count >= 2, then 1 of them must be a true weapon - handles most cases
	if (_count == 1) then {
		// include CarHorn sub classes: TruckHorn, etc
		_weaponName = (_weapons select 0);
		/*
		_classPath = configFile >> "cfgWeapons" >> _weaponName; // not sure about this
		_classHorm = configFile >> "cfgWeapons" >> "CarHorn";
		_hasTrueWeapon = (isClass _classPath && _classPath inheritsFrom _classHorm);
		*/
		if (_weaponName in ["CarHorn", "TruckHorn", "BikeHorn", "SportCarHorn"]) then { _hasTrueWeapon = false };
	};
	_hasTrueWeapon;
};
//----------------------
TSD9_IsVehicle = {
	_obj = _this select 0;
	if ((_obj isKindOf "LandVehicle") OR (_obj isKindOf "Air") OR (_obj isKindOf "Ship")) then {true} else {false};
};
//----------------------
TSD9_PlayerIsOpposition = {
	_player = _this select 0;
	if (side _player != sideFriendly) then {true} else {false};
};
//----------------------
TSD9_HideOppositionInfo = {
	_player = _this select 0;
	_txt = _this select 1;
	if (side _player != playerSide) then {""} else {_txt};
};
//----------------------
TSD9_HideOppositionComboInfo = {
	_player = _this select 0;
	_array = _this select 1;
	if (side _player != playerSide) then {[]} else {_array};
};
//----------------------
TSD9_GetVehicleType = {
	_result = [];
	/*try
	{*/
	_obj = _this select 0;

	//if ([_player] call TSD9_PlayerIsOpposition) then exitWith { "-XX-" };
	_vehicle = objNull;
	_isVehicle = ([_obj] call TSD9_IsVehicle);
	if (_isVehicle) then {_vehicle = _obj} else {_vehicle = vehicle _obj};

	_value = "";
	_data = "";
	_picture = "";
	if ([_vehicle] call TSD9_IsVehicle) then {
		_value = typeOf _vehicle;

		// add basic vehicle info
		_classPath = configFile >> "cfgVehicles" >> _value;
		if (isClass _classPath) then {
			_class = _classPath >> "picture"; if (isText _class) then { _picture = getText _class };
			_class = _classPath >> "displayName"; if (isText _class) then { _value = getText _class };
		};
		_result = [[_value, _data, [_picture] call TSD9_FilterIcons]];
		_result = _result+[["", "", ""]];

		// add vehicle stats: fuel, etc
		_result = _result+[
			[ format["%1", round((1.0 - (damage _vehicle)) * 100) ]+"%", 
				"",	"\CA\ui\data\ui_action_repair_ca.paa" ]];

		_result = _result+[
			[ format["%1", round((fuel _vehicle) * 100) ]+"%",
				"", "\CA\ui\data\ui_action_refuel_ca.paa" ]];

		if ([_vehicle] call TSD9_VehicleHasTrueWeapons) then {
			_noAmmo = "0%"; 
			if (someAmmo _vehicle) then { _noAmmo = localize "STR_TSD9_36" /* "some" */ };
			_result = _result+[
				[ format["%1", _noAmmo /*"%1", round((ammo _vehicle) * 100)*/ ], 
					"", "\CA\ui\data\ui_action_reammo_ca.paa" ]];
		};

		// add available vehicle armaments: weapons and ammo (if no ammo or depleted, it won't show)
		_weapons = [_vehicle, true] call TSD9_GetGear;
		if (count _weapons > 0) then {
			_result = _result + [["--------------------", "", ""]];
			{_result = _result + [_x]} forEach _weapons;
		};
	} else {
		//_value = "";
		_result = [/*[_value, _data, _picture]*/];
	};  
	/*}

	catch
	{
	//hint _exception;
	_result = [["Error", "", ""]];
	};*/
	_result;
};
//----------------------
TSD9_GetVehicleSeat = {
	_unit = _this select 0;

	_seat = [];
	if (not ([_unit] call TSD9_IsVehicle)) then {
		_vehicle = vehicle _unit;
		if ([_vehicle] call TSD9_IsVehicle) then {
			if (_unit == driver _vehicle) then {
				if (_vehicle isKindOf "Air") then {
					_seat = [["", "Pilot", "\CA\ui\data\i_driver_ca.paa"]]
				} else {
					_seat = [["", "Driver", "\CA\ui\data\i_driver_ca.paa"]]
				};
		  };
		  // TODO: Can you use new 1.05 assignedVehicleRole command here?
		  if (_unit == gunner _vehicle) then { _seat = [["", "Gunner", "\CA\ui\data\i_gunner_ca.paa"]] };
		  if (_unit == commander _vehicle) then { _seat = [["", "Cmdr", "\CA\ui\data\i_commander_ca.paa"]] };
		  if (count _seat == 0 && _unit in _vehicle) then { _seat = [["", "Cargo", "\CA\ui\data\i_cargo_ca.paa"]] };
		};
	};
	//['TeamStatusDialog.sqf', format["_seat=%1:%2", _unit, _seat]] call fn_DebugAppend;
	_seat;
};
//----------------------
TSD9_GetShortRoleName = {
	_ObjType = _this select 0;

	_role = _ObjType;
	_classPath = configFile >> "cfgVehicles" >> _role;
	if (isClass _classPath) then {
		_class = _classPath >> "displayName"; 
		if (isText _class) then { _role = getText _class };
	};

	_role;
};
//----------------------
TSD9_GetRoleAndGear = {
	_player = _this select 0;
	_allowVehicleGear = _this select 1;

	_role = [_player] call TSD9_GetRole;
	_gear = [_player, _allowVehicleGear] call TSD9_GetGear;

	_result = _role+[["", "", ""]]/*+[["Weapons:", "", ""]]*/+_gear;
	_result;
};
//----------------------
TSD9_GetRole = {
	_player = _this select 0;

	_role = "";
	if (not ([_player] call TSD9_IsVehicle)) then {
		_role = typeOf _player;
		_role = [_role] call TSD9_GetShortRoleName;
		if (_player == leader _player) then {
			_role = format["[%1] %2", localize "STR_TSD9_37", _role];
		};
	};
	_result = [[_role, "", ""]];
	_result;
};
//----------------------
TSD9_GetGear = {
	_player = _this select 0;
	_allowVehicleGear = _this select 1;

	_gear = [];
	if (!_allowVehicleGear && [_player] call TSD9_IsVehicle) then {
		_gear = [];
	} else {
		_fn_GetGearArray = {
			_type = _this select 0;
			_value = _this select 1;
			_data = "";//_this select 2;
			_picture = "";//_this select 3;

			// check Magazines before Weapons, since Weapons contains most magazine classes with indirect picture paths
			if (_type == "m") then {
				_classPath = configFile >> "CfgMagazines" >> _value;
				if (isClass _classPath) then {
					_class = _classPath >> "picture"; if (isText _class) then { _picture = getText _class };
					_class = _classPath >> "displayName"; if (isText _class) then { _value = getText _class };
				};
			};

			if (_type == "w") then {
				/*if (_picture == "") then
				{*/
				_classPath = configFile >> "cfgWeapons" >> _value;
				if (isClass _classPath) then {
					_class = _classPath >> "picture"; if (isText _class) then { _picture = getText _class };
					_class = _classPath >> "displayName"; if (isText _class) then { _value = getText _class };
				};
				//};
			};
	  
			if (_picture == "") then {
				_classPath = configFile >> "cfgVehicles" >> _value;
				if (isClass _classPath) then {
					_class = _classPath >> "picture"; if (isText _class) then { _picture = getText _class };
					_class = _classPath >> "displayName"; if (isText _class) then { _value = getText _class };
				};
			};
	  
			_item = [_value, _data, [_picture] call TSD9_FilterIcons];
			_item;
		};

		_weapons = weapons _player;
		_secondaryWeapon = secondaryWeapon _player;
		{
			if (_x == _secondaryWeapon) then {
				// place secondary weapon at top of weapon list
				_gear = [["w", _x] call _fn_GetGearArray] + _gear;
			} else {
				_gear = _gear + [["w", _x] call _fn_GetGearArray];
			};
		} forEach _weapons;

		if (count _weapons > 0) then {_gear = _gear + [["--------------------"+"            ", "", ""]];};

		_magazines = magazines _player;
		{ 
			_gear = _gear + [["m", _x] call _fn_GetGearArray];
		} forEach _magazines;
	};

	//['TeamStatusDialog.sqf', format["_gear=%1:%2", _player, _gear]] call fn_DebugAppend;
	_gear;
};
//----------------------
TSD9_GetScoreTotal = {
	_player = _this select 0;

	if ([_player] call TSD9_IsVehicle || !difficultyEnabled "netStats") then {
		"--"
	} else {
		format["%1", score _player]
	};
};
//----------------------
TSD9_GetBonusScore = {
	_player = _this select 0;

	"--"; //format["%1", score _player];
};
//----------------------
TSD9_GetKills = {
	_player = _this select 0;

	"--"; //format["%1", score _player];
};
//----------------------
TSD9_GetDeaths = {
	_player = _this select 0;

	"--"; //format["%1", score _player];
};
//----------------------
TSD9_GetTKs = {
	_player = _this select 0;

	"--"; //format["%1", score _player];
};
//----------------------
TSD9_GetCommand = {
	_player = _this select 0;

	/*
	_vehicle = vehicle _player;
	if ([_vehicle] call TSD9_IsVehicle) then 
	{ currentCommand _vehicle } else { currentCommand _player };
	*/  
	_command = currentCommand _player;
	//_wps = waypoints _player; // TODO: add the actual WP grid ref for the command

	//  show gridref of Waypoint 1.
	_WPs = waypoints _player;
	if (count _WPs >= 2) then {
		_wpGrifRef = "";
		_MapGridRef = [waypointPosition  (_WPs select 1)] call TSD9_GridRefCoords;
		_wpGrifRef = format[" %1", _MapGridRef];

		// show if there are more than 2 wp's (including WP 0).
		if (count _WPs > 2) then { 
			_wpGrifRef = _wpGrifRef+format[",%1", count _WPs]; // warn's player that grid ref for wp1 may not be current WP.
		} else {
			_wpGrifRef = _wpGrifRef+" ";
		};
		_command = _wpGrifRef+_command;
	};

	if (not alive _player) then { _command = /*_hightlight_text_code+*/ format["--%1--", localize "STR_TSD9_34"] }; // +format[" (%1s)", playerRespawnTime]
	_command;
};
//----------------------
TSD9_GetRequires = {
	_obj = _this select 0;

	_requires = [];
	_vehicle = objNull;
	if ([_obj] call TSD9_IsVehicle) then {_vehicle = _obj} else {_vehicle = vehicle _player};

	if ([_vehicle] call TSD9_IsVehicle) then {
		if (damage _vehicle > 0.1) then {
			_requires = _requires+[
				[ format["%1", round((1.0 - (damage _vehicle)) * 100) ]+"%", 
					"", "\CA\ui\data\ui_action_repair_ca.paa" ]]
		};
		if (fuel _vehicle < 0.3) then { 
			_requires = _requires+[
				[ format["%1", round((fuel _vehicle) * 100) ]+"%", 
					"", "\CA\ui\data\ui_action_refuel_ca.paa" ]]
		};

		if (([_vehicle] call TSD9_VehicleHasTrueWeapons) && (!someAmmo _vehicle)) then {
			_requires = _requires+[
				[ format["" /*"%1", round((ammo _vehicle) * 100)*/ ],
					"","\CA\ui\data\ui_action_reammo_ca.paa" ]]
		};
	};

	if (!([_obj] call TSD9_IsVehicle)) then {// assume obj=person
		if (damage _obj > 0.1) then {
			_requires = _requires+[
				[ format["%1", round((damage _obj) * 100) ]+"%", 
					"","\CA\ui\data\ui_action_heal_ca.paa" ]]
		};
	};

	_requires;
};
//----------------------
TSD9_GetPos = {
	_obj = _this select 0;

	_MapGridRef = [position _obj] call TSD9_GridRefCoords;
	_MapGridRef;  
};
//----------------------
TSD9_GetSLProximity = {
	_player = _this select 0;

	_prox = round(_player distance leader _player);
	if (_prox < 0.5 || _prox > 99999) then { _prox = 0.0 }; // fixes E+010 type values for vacant vehicle seats.
	format["%1m", _prox];
};
//----------------------
TSD9_GetMyProximity = {
	_player = _this select 0;

	_prox = round(_player distance player);
	if (_prox < 0.5 || _prox > 99999) then { _prox = 0.0 }; // fixes E+010 type values for vacant vehicle seats.
	format["%1m", _prox];
};
//----------------------
TSD9_GetTargetOrThreats = {
	_player = _this select 0;

	_Target = objNull;
	if (vehicle _player == _player) then {
		_Target = assignedTarget _player
	} else {
		_Target = assignedTarget (vehicle _player)
	};

	_TargetName = "";
	if (isNull _Target) then {
		_TargetName = ""
	} else {
		_TargetName = [format[ "%1", typeOf _Target]] call TSD9_GetShortRoleName
	};

	format[ "%1", _TargetName];
};
//----------------------
TSD9_GetGroupDesc = {
	_group = _this select 0;

	_MyGroup = "";
	if (_group == group player) then { _MyGroup = format[" %1", localize "STR_TSD9_38"] };

	_GroupName = format[ "%1", _group];
	if ((TSD9_Page == "Vehicle") && ((_group == grpNull /* doesn't work? */) || (_GroupName == "<NULL-group>"))) then {_GroupName = localize "STR_TSD9_39"};

	format[ "%1%2", _GroupName, _MyGroup]; //"[%1] White" // TODO: determine how to obtain group team/squad colour. See assignTeam command.
};
//----------------------
TSD9_GetGroupSize = {
	_group = _this select 0;
	if (TSD9_Page == "Vehicle") then {""} else {format[ "(%1)", count units _group ]};
};
//----------------------
TSD9_GetGroupVehicleClassComposition = {
	_group = _this select 0;

	_result = [];

	/*
	// check if entire group is in same vehicle - show vehicle type rather than vehicle class
	if (count _result == 0) then
	{
	_vehicle = vehicle leader _group;
	{
	  if (vehicle _x != _vehicle) exitWith
	  {
		_vehicle = objNull;
	  };  
	} forEach units _group;

	if ([_vehicle] call TSD9_IsVehicle) then 
	{
	  _result = [_vehicle] call TSD9_GetVehicleType;
	  
	  // erase picture
	  _entry = _result select 0;
	  _entry set [2, ""];
	  _result set [0, _entry];
	};
	};
	*/

	// check if entire group is of same type
	if (count _result == 0) then {
		_sameClass = true;
		_vehicleClasses = [];
		{
			_vehicle = vehicle _x;
			//_isVehicle = [_vehicle] call TSD9_IsVehicle;
			//--------------------
			_currentVehicleClass = "";
			_classPath = configFile >> "cfgVehicles" >> typeOf _vehicle;
			if (isClass _classPath) then {
				_class = _classPath >> "vehicleClass";
				if (isText _class) then {_currentVehicleClass = getText _class};
			};

			if (not (_currentVehicleClass in _vehicleClasses)) then {
				_vehicleClasses = _vehicleClasses + [_currentVehicleClass];
				_sameClass = false;
			};
		} forEach units _group;

		_vehicleClassesList = "";
		{
			if (_vehicleClassesList != "") then {_vehicleClassesList = _vehicleClassesList + ","};
			_vehicleClassesList = _vehicleClassesList + format["%1", _x];
		} forEach _vehicleClasses;
		_result = [[_vehicleClassesList, "", ""]];
	};

	_result;
};
//----------------------
TSD9_JoinGroupByName_FromTriggerList = {
	_groupName = _this select 0;
	_UnitList = _this select 1;

	_groupList = [_UnitList] call TSD9_GetAllGroupsFromUnits;

	{
		_group = _x;
		if (format["%1", _group] == format["%1", _groupName]) then {
			// "%1 has left your group"
			[(leader player), format["%1 %2", name player, localize "STR_TSD9_40"]] call TSD9_groupChat;
			[player] join _group;
			if (!isNull d_grp_caller) then {
				_has_player = false;
				{
					if (isPlayer _x) exitWith {_has_player = true};
				} forEach units d_grp_caller;
				if (!_has_player) then {
					{
						deleteVehicle _x;
					} forEach units d_grp_caller;
					deleteGroup d_grp_caller;
				};
			};
			d_grp_caller = _group;
			// "%1 has joined your group"
			[(leader _group), format["%1 %2", name player, localize "STR_TSD9_41"]] call TSD9_groupChat;

			[] call TSD9_DrawPage; // refresh screen to redraw "join group" buttons
		};
	} forEach _groupList;
};
//----------------------
TSD9_JoinGroupByName = {
	_groupName = _this select 0;

	_Trig = createTrigger ["EmptyDetector", [0, 0, 0] ];
	_Trig setTriggerActivation ["ANY", "PRESENT", false];
	_Trig setTriggerArea [31000, 31000, 0, true ];
	_Trig setTriggerStatements [ 
		"this",
		format["['%1', thislist] call TSD9_JoinGroupByName_FromTriggerList", _groupName],
	"" ];
};
//----------------------
TSD9_InviteAIOrPlayerIntoGroupByName_FromTriggerList = {
	_playerToFind = _this select 0;
	_UnitList = _this select 1;

	_CheckIfPlayerMatches = {
		_player = _this select 0;

		if (format["%1", _player] == _playerToFind) then {
			if (isPlayer _player) then {
				// DEV: TODO: This code needs completion to allow invitee to simply reject or accept invitation, leave current group and join your group automatically.

				// "Player %2 was invited into your group."
				// (or "Invitation was sent to %2 to join your group.")
				[(leader player), format["%1 %2 %3.", 
					localize "STR_TSD9_44", 
					name _player, 
					localize "STR_TSD9_61"
				]] call TSD9_groupChat;

				// "%1, you have been invited to join group: %3 (%4)"
				[_player, format["%1, %2: %3 (%4).", 
					name _player, 
					localize "STR_TSD9_63", 
					name player,
					group player
				]] call TSD9_groupChat;
			} else {
				_groupIsEntirelyAI = true;
				{
					if (isPlayer _x) then {_groupIsEntirelyAI = false};
				} forEach units _player;

				// TODO: if player is greater than a certain distance, then don't allow
				// TODO: if group size is greater than a certain count or some ratio to total human players, then don't allow
				// DEV: TODO: This code needs completion to restrict how many AI can be recruited.

				// if AI is part of a human group, then don't allow leaching
				if (_groupIsEntirelyAI) then {
					// "A.I. %2 soldier was recruited into group."
					[(leader player), format["%1 %2 %3.", 
						localize "STR_TSD9_33", 
						[typeOf _player] call TSD9_GetShortRoleName, 
						localize "STR_TSD9_62"
					]] call TSD9_groupChat;

					[_player] join group player;
					[] call TSD9_DrawPage; // refresh screen to redraw "join group" buttons
				};
			};
		};  
	};

	{
		_unit = _x;
		if ([_unit] call TSD9_IsVehicle) then {
			// process vehicle crew list
			{
				[_x] call _CheckIfPlayerMatches;        
			} forEach crew _unit;      
		} else {
			[_unit] call _CheckIfPlayerMatches;
		};    
	} forEach _UnitList;
};
//----------------------
TSD9_InviteAIOrPlayerIntoGroupByName = {
	_playerToFind = _this select 0;

	_Trig = createTrigger ["EmptyDetector", [0, 0, 0] ];
	_Trig setTriggerActivation ["ANY", "PRESENT", false];
	_Trig setTriggerArea [31000, 31000, 0, true ];
	_Trig setTriggerStatements [ 
		"this",
		format["['%1', thislist] call TSD9_InviteAIOrPlayerIntoGroupByName_FromTriggerList", _playerToFind],
	"" ];
};
//----------------------
TSD9_SetNewTeamLeaderByName_FromTriggerList = {
	_playerToFind = _this select 0;
	_UnitList = _this select 1;

	_CheckIfPlayerMatches = {
		_player = _this select 0;

		if (format["%1", _player] == _playerToFind) then {
			// "Your new Team Leader is %2. %3 has resigned"

			[(leader player), format["%1 %2. %3 %4.", 
				localize "STR_TSD9_42", 
				name _player, 
				name player, 
			localize "STR_TSD9_43"]] call TSD9_groupChat;
			(group player) selectLeader _player;
		  
			[] call TSD9_DrawPage; // refresh screen to redraw "join group" buttons
		};  
	};

	{
		_unit = _x;
		if (group _unit == group player) then {
			if ([_unit] call TSD9_IsVehicle) then {
				// process vehicle crew list
				{
					[_x] call _CheckIfPlayerMatches;
				} forEach crew _unit;      
			} else {
				[_unit] call _CheckIfPlayerMatches;
		  };  
		};
	} forEach _UnitList;
};
//----------------------
TSD9_SetNewTeamLeaderByName = {
	_playerToFind = _this select 0;

	_Trig = createTrigger ["EmptyDetector", [0, 0, 0] ];
	_Trig setTriggerActivation ["ANY", "PRESENT", false];
	_Trig setTriggerArea [31000, 31000, 0, true ];
	_Trig setTriggerStatements [ 
		"this",
		format["['%1', thislist] call TSD9_SetNewTeamLeaderByName_FromTriggerList", _playerToFind],
	"" ];
};
//----------------------
TSD9_RemoveAIOrPlayerFromYourGroupByName = {
	_playerToFind = _this select 0;

	_CheckIfPlayerMatches = {
		_player = _this select 0;

		if (format["%1", _player] == _playerToFind) then {
			if (isPlayer _player) then {
				// "Player %2 was kicked from the group."
				[(leader player), format["%1 %2 %3.", 
					localize "STR_TSD9_44", 
					name _player, 
				localize "STR_TSD9_45"]] call TSD9_groupChat;
			} else {
				// "A.I. %2 soldier was removed from group."
				[(leader player), format["%1 %2 %3.", 
					localize "STR_TSD9_33", 
					[typeOf _player] call TSD9_GetShortRoleName, 
				localize "STR_TSD9_46"]] call TSD9_groupChat;

				// When deleted, it assumes the AI player was spawned and is replacable.
				if (TSD9_DeleteRemovedAI) then {deleteVehicle _player;};
			};
			[_player] join grpNull;
		  
			[] call TSD9_DrawPage; // refresh screen to redraw "join group" buttons
		};  
	};

	{
		_unit = _x;
		if (group _unit == group player) then {
			if ([_unit] call TSD9_IsVehicle) then {
				// process vehicle crew list
				{
					[_x] call _CheckIfPlayerMatches;        
				} forEach crew _unit;      
			} else {
				[_unit] call _CheckIfPlayerMatches;
			};      
		};
	} forEach (units player);  
};
//----------------------
TSD9_GetVehicleByName_FromTriggerList = {
	_VehicleName = _this select 0;
	_UnitList = _this select 1;

	{
		_unit = _x;
		if ([_unit] call TSD9_IsVehicle) then {
			if (format["%1", _unit] == _VehicleName) then {
				TSD9_Vehicle = _unit;
				TSD9_VehicleSearchComplete = true;
			};
		};    
	} forEach _UnitList;
	TSD9_VehicleSearchComplete = true;
};
//----------------------
TSD9_GetVehicleByName = {
	_VehicleName = _this select 0;

	_Trig = createTrigger ["EmptyDetector", [0, 0, 0] ];
	_Trig setTriggerActivation ["ANY", "PRESENT", false];
	_Trig setTriggerArea [31000, 31000, 0, true ];
	_Trig setTriggerStatements [ 
		"this",
		format["['%1', thislist] call TSD9_GetVehicleByName_FromTriggerList", _VehicleName],
	"" ];
};
//----------------------
TSD9_LeaveGroup = {
	//"%1 has left your group"
	[(leader player), format["%1 %2", name player, localize "STR_TSD9_40"]] call TSD9_groupChat;
	[player] join grpNull;
	if (!isNull d_grp_caller) then {
		_has_player = false;
		{
			if (isPlayer _x) exitWith {_has_player = true};
		} forEach units d_grp_caller;
		if (!_has_player) then {
			{
				deleteVehicle _x;
			} forEach units d_grp_caller;
			deleteGroup d_grp_caller;
		};
	};
	d_grp_caller = objNull;
	[] call TSD9_DrawPage; // refresh screen to redraw "join group" buttons
};
//----------------------
TSD9_SetNewTLForAITeamLeader = {
	_TL_is_AI = (!(isPlayer (leader player)));

	if (_TL_is_AI) then {
		//"You are the new Team Leader. (AI) %1 has been demoted."
		[(leader player), format["%1. (%2) %3 %4.", 
			localize "STR_TSD9_48",
			localize "STR_TSD9_33",
			name (leader player),
			localize "STR_TSD9_49"]] call TSD9_groupChat;
		(group player) selectLeader player;    
	} else {
		//"The Team Leader is no longer an AI player"
		[(leader player), format["%1", localize "STR_TSD9_50"]] call TSD9_groupChat;
		hint format["%1", localize "STR_TSD9_50"];
	};

	[] call TSD9_DrawPage; // refresh screen to redraw "join group" buttons
};
//-----------------------------------------------------------------------------
// Cell Grid functions
//-----------------------------------------------------------------------------
TSD9_HideRow = {
	_row = _this select 0;

	_idc = [_row] call TSD9_GetRowIdc;

	// TODO: change to for loop   // for "_i" from 0 to (_seatCount - 1) do {
	[_idc+01, 01] call TSD9_HideCtrl;
	[_idc+02, 02] call TSD9_HideCtrl;
	[_idc+03, 03] call TSD9_HideCtrl;
	[_idc+04, 04] call TSD9_HideCtrl;
	[_idc+05, 05] call TSD9_HideCtrl;
	//[_idc+06, 06] call TSD9_HideCtrl;
	[_idc+07, 07] call TSD9_HideCtrl;
	[_idc+08, 08] call TSD9_HideCtrl;
	/*
	[_idc+09, 09] call TSD9_HideCtrl;
	[_idc+10, 10] call TSD9_HideCtrl;
	[_idc+11, 11] call TSD9_HideCtrl;
	[_idc+12, 12] call TSD9_HideCtrl;
	*/
	[_idc+13, 13] call TSD9_HideCtrl;
	[_idc+14, 14] call TSD9_HideCtrl;
	[_idc+15, 15] call TSD9_HideCtrl;
	//[_idc+16, 16] call TSD9_HideCtrl;
	[_idc+17, 17] call TSD9_HideCtrl;
	[_idc+18, 18] call TSD9_HideCtrl;
	[_idc+19, 19] call TSD9_HideCtrl;
	buttonSetAction [_idc+01, ""];
	buttonSetAction [_idc+19, ""];
};
//----------------------
TSD9_ShowRow = {
	_row = _this select 0;

	_idc = [_row] call TSD9_GetRowIdc;

	{
		[_idc+_x, _x] call TSD9_ShowCtrl;
	} forEach [/* 00, */ 01, 02, 03, 04, 05, /* 06, */ 07, 08, /* 09, 10, 11, 12, */ 13, 14, 15, /* 16, */ 17, 18, 19];

	{
		[_idc+_x, _x, TSD9_color_default, TSD9_color_default] call TSD9_SetCtrlColors;
	} forEach [/* 00, */ 01, 02, 03, 04, 05, /* 06, */ 07, 08, /* 09, 10, 11, 12, */ 13, 14, 15, /* 16, */ 17, 18, 19];
};
//----------------------
TSD9_ConfigTitleRow = {
	_row = 0;
	_idc = [_row] call TSD9_GetRowIdc;

	_fg = TSD9_color_default;
	_bg = TSD9_color_default;

	[_idc+01, 01, _fg, _bg, localize "STR_TSD9_11"] call TSD9_SetText;
	[_idc+02, 02, _fg, _bg, localize "STR_TSD9_12"] call TSD9_SetText;
	[_idc+03, 03, _fg, _bg, localize "STR_TSD9_13"] call TSD9_SetText;
	[_idc+04, 04, _fg, _bg, format["%1 %2", localize "STR_TSD9_05", localize "STR_TSD9_47"]] call TSD9_SetText;
	[_idc+05, 05, _fg, _bg, localize "STR_TSD9_15"] call TSD9_SetText;
	//[_idc+06, 06, _fg, _bg, localize "STR_TSD9_16"] call TSD9_SetText;
	[_idc+07, 07, _fg, _bg, format["%1/%2 %3", localize "STR_TSD9_16", localize "STR_TSD9_17", localize "STR_TSD9_47"]] call TSD9_SetText;
	[_idc+08, 08, _fg, _bg, localize "STR_TSD9_18"] call TSD9_SetText;
	/*
	[_idc+09, 09, _fg, _bg, "Work"] call TSD9_SetText;
	[_idc+10, 10, _fg, _bg, "Kills"] call TSD9_SetText;
	[_idc+11, 11, _fg, _bg, "Deaths"] call TSD9_SetText;
	[_idc+12, 12, _fg, _bg, "TK's"] call TSD9_SetText;
	*/
	[_idc+13, 13, _fg, _bg, localize "STR_TSD9_19"] call TSD9_SetText;
	[_idc+14, 14, _fg, _bg, format["%1 %2", localize "STR_TSD9_20", localize "STR_TSD9_47"]] call TSD9_SetText;
	[_idc+15, 15, _fg, _bg, localize "STR_TSD9_21"] call TSD9_SetText;
	//[_idc+16, 16, _fg, _bg, localize "STR_TSD9_22"] call TSD9_SetText;
	[_idc+17, 17, _fg, _bg, localize "STR_TSD9_23"] call TSD9_SetText;
	[_idc+18, 18, _fg, _bg, localize "STR_TSD9_24"] call TSD9_SetText;
	[_idc+19, 19, _fg, _bg, localize "STR_TSD9_25"] call TSD9_SetText;
};
//----------------------
TSD9_AddGroupRowButtonAction = {
	if (!((TSD9_Page == "Team") || (TSD9_Page == "Group") || (TSD9_Page == "Vehicle"))) exitWith {};

	_group = _this select 0;
	_idc2 = _this select 1;

	_col = 19;
	_fg = TSD9_color_default;
	_bg = TSD9_color_groupBG; // TSD9_color_cellABG

	if (_group == group player) then {
		if (count units group player > 1) then {
			[_idc2, _col, _fg, _bg, localize "STR_TSD9_51" /* "New group" */] call TSD9_SetText;  
			buttonSetAction [_idc2, "[] call TSD9_LeaveGroup"]; 
		};
	} else {
		if (count units _group > 0) then {
			[_idc2, _col, _fg, _bg, localize "STR_TSD9_52" /* "Join group" */] call TSD9_SetText;  
			buttonSetAction [_idc2, format["['%1'] call TSD9_JoinGroupByName", _group]];
		};
	};
};
//----------------------
TSD9_AddPlayerStatsRowButtonAction = {
	if (!((TSD9_Page == "Team") || (TSD9_Page == "Group") || (TSD9_Page == "Vehicle"))) exitWith {};

	_player = _this select 0;
	_idc2 = _this select 1;
	_emptySeatStatRow = _this select 2;

	_col = 19;
	_fg = TSD9_color_default;
	_bg = TSD9_color_cellABG;

	if (_player == player) then {
		_TL_is_AI = (!(isPlayer (leader player)));
		if (_TL_is_AI) then {
			[_idc2, _col, _fg, _bg, localize "STR_TSD9_53" /* "Go TL" */] call TSD9_SetText;
			buttonSetAction [_idc2, "[] call TSD9_SetNewTLForAITeamLeader"];  
		};
	} else {
		_leaderAndYourGroup = (player == leader player) && (group _player == group player) && (!_emptySeatStatRow);
		_leaderAndOtherGroup = (player == leader player) && (group _player != group player) && (!_emptySeatStatRow);

		// Setting TSD9_AllowAILeaderSelect to true, will allow AI TL selection, otherwise it will limit to human player restricted leader selection.
		if ((TSD9_Page == "Group") && _leaderAndYourGroup && (TSD9_AllowAILeaderSelect || isPlayer _player) ) then {
			[_idc2, _col, _fg, _bg, localize "STR_TSD9_54" /* "New TL" */] call TSD9_SetText;
			buttonSetAction [_idc2, format["['%1'] call TSD9_SetNewTeamLeaderByName", _player]];
		};

		if ((TSD9_Page == "Team") && _leaderAndYourGroup) then {
			_command = localize "STR_TSD9_55" /* "Remove" */ ;
			if (isPlayer _player) then {_command = localize "STR_TSD9_56" /* "Kick" */};
			[_idc2, _col, _fg, _bg, _command] call TSD9_SetText;
			buttonSetAction [_idc2, format["['%1'] call TSD9_RemoveAIOrPlayerFromYourGroupByName", _player]];
		};

		if ((TSD9_Page == "Team") && _leaderAndOtherGroup) then {
			// TODO: if player is greater than a certain distance, then don't show invite option
	  
			_command = "";
			if (TSD9_AllowAIRecruitment && not (isPlayer _player)) then {
				// DEV: TODO: This code needs completion to restrict how many AI can be recruited.
				_command = localize "STR_TSD9_57" /* "Recruit" */ ;
			};
			if (TSD9_AllowPlayerInvites && isPlayer _player) then {
				// DEV: TODO: This code needs completion to allow invitee to simply reject or accept invitation, leave current group and join your group automatically.
				_command = localize "STR_TSD9_58" /* "Invite" */ 
			};
			if (_command != "") then {
				[_idc2, _col, _fg, _bg, _command] call TSD9_SetText;
				buttonSetAction [_idc2, format["['%1'] call TSD9_InviteAIOrPlayerIntoGroupByName", _player]];
			};
		};
	};
};
//----------------------
TSD9_AddGroupRow = {
	_group = _this select 0;
	_row = _this select 1;

	_idc = [_row] call TSD9_GetRowIdc;
	[_row] call TSD9_ShowRow;

	_fg = TSD9_color_default;
	_bg = TSD9_color_groupBG;

	if ((TSD9_Page == "Team") || (TSD9_Page == "Opposition")) then {
		buttonSetAction [_idc+01, [_group] call TSD9_CreateCloseGroupButtonAction ];
		[_idc+01, 01, _fg, TSD9_color_cellABG, [_group] call TSD9_GetCloseGroupButtonText ] call TSD9_SetText;
	} else {
		buttonSetAction [_idc+01, "" ];
		[_idc+01, 01, _fg, TSD9_color_cellABG, "" ] call TSD9_SetText;
	};
	[_idc+02, 02, _fg, _bg, [_group] call TSD9_GetGroupSize ] call TSD9_SetText;
	[_idc+03, 03, _fg, _bg, [_group] call TSD9_GetGroupDesc ] call TSD9_SetText;
	[_idc+04, 04, _fg, _bg, [leader _group, [_group] call TSD9_GetGroupVehicleClassComposition] call TSD9_HideOppositionComboInfo] call TSD9_SetCombo;
	[_idc+05, 05, _fg, _bg, []] call TSD9_SetCombo;
	//[_idc+06, 06, _fg, _bg, ""] call TSD9_SetText;
	[_idc+07, 07, _fg, _bg, []] call TSD9_SetCombo;
	[_idc+08, 08, _fg, _bg, ""] call TSD9_SetText;
	/*
	[_idc+09, 09, _fg, _bg, ""] call TSD9_SetText;
	[_idc+10, 10, _fg, _bg, ""] call TSD9_SetText;
	[_idc+11, 11, _fg, _bg, ""] call TSD9_SetText;
	[_idc+12, 12, _fg, _bg, ""] call TSD9_SetText;
	*/
	[_idc+13, 13, _fg, _bg, ""] call TSD9_SetText;
	[_idc+14, 14, _fg, _bg, []] call TSD9_SetCombo;
	[_idc+15, 15, _fg, _bg, ""] call TSD9_SetText;
	//[_idc+16, 16, _fg, _bg, ""] call TSD9_SetText;
	[_idc+17, 17, _fg, _bg, ""] call TSD9_SetText;
	[_idc+18, 18, _fg, _bg, ""] call TSD9_SetText;
	[_idc+19, 19, _fg, TSD9_color_cellABG, ""] call TSD9_SetText;  
	buttonSetAction [_idc+19, ""];

	[_group, _idc+19] call TSD9_AddGroupRowButtonAction;
};
//----------------------
TSD9_AddPlayerStatsRow = {
	_player = _this select 0;
	_row = _this select 1;
	_id = _this select 2;

	_nameDesc = "";
	_seatDesc = [];
	// special case - "Empty seat" rows
	_emptySeatStatRow = count _this >= 4;
	if (_emptySeatStatRow) then  {
		_seatName = _this select 3; // special empty vehicle seat case: ["--No driver--", "picture.paa"]
		_nameDesc = _seatName select 0;
		_seatDesc = [["", "", _seatName select 1]];
	} else {
		_nameDesc = [_player] call TSD9_GetPlayerName;
		_seatDesc = [_player, [_player] call TSD9_GetVehicleSeat] call TSD9_HideOppositionComboInfo;
	};

	_idc = [_row] call TSD9_GetRowIdc;
	[_row] call TSD9_ShowRow;

	_fg = TSD9_color_default;
	_bg = TSD9_color_default;
	if (_player == player) then { _bg = TSD9_color_playerBG };

	buttonSetAction [_idc+01, "" ];
	[_idc+01, 01, _fg, _bg, ""] call TSD9_SetText;
	[_idc+02, 02, _fg, _bg, [_player, _row, _id] call TSD9_GetPlayerIndex ] call TSD9_SetText;
	[_idc+03, 03, _fg, _bg, _nameDesc] call TSD9_SetText;
	[_idc+04, 04, _fg, _bg, [_player, [_player] call TSD9_GetVehicleType] call TSD9_HideOppositionComboInfo ] call TSD9_SetCombo;
	[_idc+05, 05, _fg, _bg, _seatDesc] call TSD9_SetCombo;
	//[_idc+06, 06, _fg, _bg, [_player, [_player] call TSD9_GetRole] call TSD9_HideOppositionInfo ] call TSD9_SetText;
	[_idc+07, 07, _fg, _bg, [_player, [_player, false] call TSD9_GetRoleAndGear] call TSD9_HideOppositionComboInfo ] call TSD9_SetCombo;
	[_idc+08, 08, _fg, _bg, [_player] call TSD9_GetScoreTotal ] call TSD9_SetText;
	/*
	[_idc+09, 09, _fg, _bg, [_player] call TSD9_GetBonusScore ] call TSD9_SetText;
	[_idc+10, 10, _fg, _bg, [_player] call TSD9_GetKills ] call TSD9_SetText;
	[_idc+11, 11, _fg, _bg, [_player] call TSD9_GetDeaths ] call TSD9_SetText;
	[_idc+12, 12, _fg, _bg, [_player] call TSD9_GetTKs ] call TSD9_SetText;
	*/
	[_idc+13, 13, _fg, _bg, [_player, [_player] call TSD9_GetCommand] call TSD9_HideOppositionInfo ] call TSD9_SetText;
	[_idc+14, 14, _fg, _bg, [_player, [_player] call TSD9_GetRequires] call TSD9_HideOppositionComboInfo ] call TSD9_SetCombo;
	[_idc+15, 15, _fg, _bg, [_player, [_player] call TSD9_GetPos] call TSD9_HideOppositionInfo ] call TSD9_SetText;
	//[_idc+16, 16, _fg, _bg, [_player, [_player] call TSD9_GetSLProximity] call TSD9_HideOppositionInfo ] call TSD9_SetText;
	[_idc+17, 17, _fg, _bg, [_player, [_player] call TSD9_GetMyProximity] call TSD9_HideOppositionInfo ] call TSD9_SetText;
	[_idc+18, 18, _fg, _bg, [_player, [_player] call TSD9_GetTargetOrThreats] call TSD9_HideOppositionInfo ] call TSD9_SetText;
	[_idc+19, 19, _fg, TSD9_color_cellABG, ""] call TSD9_SetText;
	buttonSetAction [_idc+19, ""];

	[_player, _idc+19, _emptySeatStatRow] call TSD9_AddPlayerStatsRowButtonAction;
};
//-----------------------------------------------------------------------------
// Group/Unit/Vehicle processing functions
//-----------------------------------------------------------------------------
TSD9_GetAllGroupsFromUnits = {
	_AllUnits = _this select 0;

	_AllGroups = [];
	{
		_group = group _x;
		if ((!(_group in _AllGroups)) && (_group != grpNull)) then {_AllGroups = _AllGroups + [_group]};
	} forEach _AllUnits;
	_AllGroups;
};
//----------------------
// currently only sorts the first 26 groups on any side
TSD9_SortGroupsArray = {
	_GroupArray = _this select 0;

	_Result = [];
	{
		_SideStr = _x;
		{
			_Letter = _x;
			_GroupStr = format["%1 1-1-%2", _SideStr, _Letter]; // Eg: "WEST 1-1-A"
			{
				//if (_GroupStr (object) in _GroupArray) then 
				_Group = _x;
				if (_GroupStr == format["%1", _Group]) then {
					_Result = _Result + [_Group];
					_GroupArray = _GroupArray - [_Group];
				};
			} forEach _GroupArray;
		} forEach ["A","B","C","D","E","F","G","H","I","J","K","L","M"/*,"N","O","P","Q","R","S","T","U","V","W","X","Y","Z"*/];
	} forEach ["WEST", "EAST", "GUER", "CIV"];

	_Result = _Result+_GroupArray; // add remaining unknown group id's to array
	_Result;
};
//----------------------
TSD9_FillGroups = {
	_AllUnitsOrVehicle = _this select 0;

	/*
	_control = TSD9_display displayCtrl TSD9_IDC_Progress;
	ctrlSetText [TSD9_IDC_Progress, "Loading"]; // doesn't show until redrawn
	_control ctrlCommit 0;  
	*/

	_row = 1;
	_reservedRows = 1;
	_lastRow = TSD9_ROWS-1-_reservedRows;

	//---------------------------------
	if ((TSD9_Page == "Team") || (TSD9_Page == "Opposition") || (TSD9_Page == "Group")) then {
		_AllUnits = _AllUnitsOrVehicle;
		_AllGroups = [_AllUnits] call TSD9_GetAllGroupsFromUnits;

		// Sort group object list
		/*
		_fn_SortBubble = compile preprocessFileLineNumbers "SortBubble.sqf";
		_ok = [_AllGroups, "_element"] call _fn_SortBubble;
		*/
		_AllGroups = [_AllGroups] call TSD9_SortGroupsArray;

		// process all groups
		{
			_group = _x;
			_ShowAIGroups = TSD9_ShowAIGroups || ({isPlayer _x} count (units _group) > 0);
			if ( (count units _group > 0) && 
			(((TSD9_Page == "Team") && (side _group == playerSide) && _ShowAIGroups) || 
			((TSD9_Page == "Opposition") && (side _group != playerSide) && _ShowAIGroups) || 
			(TSD9_Page == "Group"))) then { // determines which sides to include
				[_group, _row] call TSD9_AddGroupRow;
				_row = _row + 1;

				// display all units for "Group", but only display "open" groups for "Team"
				if ((TSD9_Page == "Group") || (((TSD9_Page == "Team") || (TSD9_Page == "Opposition")) && !(format["%1", _group] in TSD9_ClosedGroups))) then {
					// process all units in group
					_units = units _group;
					_id = 1;
					{
						if (_row < _lastRow) then {
							[_x, _row, _id] call TSD9_AddPlayerStatsRow;
							_row = _row + 1;
							_id = _id + 1;
						};
					} forEach _units;
				};
			};
		} forEach _AllGroups;
	};
	//---------------------------------
	if (TSD9_Page == "Vehicle") then {
		_vehicle = _AllUnitsOrVehicle;
		if (typeName _vehicle == "OBJECT") then {
			if ([_vehicle] call TSD9_IsVehicle) then {
				_AllUnits = crew _vehicle;
				_AllGroups = [_AllUnits] call TSD9_GetAllGroupsFromUnits;
				_id = 0;

				// process all groups
				{
					_group = _x;
					[_group, _row] call TSD9_AddGroupRow;
					_row = _row + 1;

					// process all units in group
					_id = 1;
					{
						if (_row < _lastRow) then {
							if (_x in (units _group)) then {
								[_x, _row, _id] call TSD9_AddPlayerStatsRow;
								_row = _row + 1;
								_id = _id + 1;
							};
						};
					} forEach _AllUnits;
				} forEach _AllGroups;
	  
				// add all vacant seats
				_dr = _vehicle emptyPositions "driver";
				_gu = _vehicle emptyPositions "gunner";
				_co = _vehicle emptyPositions "commander";
				_ca = _vehicle emptyPositions "cargo";
				if ((_dr > 0) || (_gu > 0) || (_co > 0) || (_ca > 0)) then {
					[grpNull, _row] call TSD9_AddGroupRow;
					_row = _row + 1;
					_id = 1; 

					_drType = ""; 
					if (_vehicle isKindOf "Air") then { _drType = "Pilot" } else { _drType = "Driver" };
					{
						_seatCount = _x select 0;
						_seatName = _x select 1;
						if ( _seatCount > 0) then  {
							// this does not yet detect multiple gunners, etc, but instead adds secondary gunners to passenger list
							for "_i" from 0 to (_seatCount - 1) do {
								_picture = "";
								if (_seatName == "Pilot") then {_picture = "\CA\ui\data\i_driver_ca.paa"};
								if (_seatName == "Driver") then {_picture = "\CA\ui\data\i_driver_ca.paa"};
								if (_seatName == "Gunner") then {_picture = "\CA\ui\data\i_gunner_ca.paa"};
								if (_seatName == "Commander") then {_picture = "\CA\ui\data\i_commander_ca.paa"};
			  
								[_vehicle, _row, _id, [format["%1 %2", localize "STR_TSD9_59", _seatName], _picture]] call TSD9_AddPlayerStatsRow;
								_row = _row + 1;
								_id = _id + 1; 
							};
						};
					} forEach [[_dr, _drType], [_gu, "Gunner"], [_co, "Commander"]];

					for "_i" from 0 to (_ca - 1) do {
						[_vehicle, _row, _id, [format["%1 %2 (%3)", localize "STR_TSD9_59", localize "STR_TSD9_60", 1+_i],
							"\CA\ui\data\i_cargo_ca.paa"]] call TSD9_AddPlayerStatsRow; 
						_row = _row + 1;
						_id = _id + 1;
					};
				};
			};
		};
	};
	//---------------------------------

	// hide unused cell rows
	while {_row < _lastRow+_reservedRows} do {
		[_row] call TSD9_HideRow;
		_row = _row + 1;
	};
	//ctrlSetText [TSD9_IDC_Progress, ""];
};
//----------------------
TSD9_ShowCollapseExpandButtons = {
	_show = _this select 0;
	ctrlShow [TSD9_IDC_CollapseAllButton, _show];
	ctrlShow [TSD9_IDC_ExpandAllButton, _show];
};
//----------------------
TSD9_DrawPage_MyVehicle = {
	TSD9_Page = "Vehicle";

	_vehicle = vehicle player; // default, before performing checks below

	//player groupChat format["%1 (%2)", TSD9_Vehicle, typeName TSD9_Vehicle]; // debug

	if (format["%1", TSD9_Vehicle] != "<NULL-OBJECT>" && typeName TSD9_Vehicle == "STRING") then {
		_vehicleNameToFind = TSD9_Vehicle;
		TSD9_Vehicle = objNull;
		//TSD9_Vehicle = call compile TSD9_Vehicle;

		TSD9_VehicleSearchComplete = false;
		[_vehicleNameToFind] call TSD9_GetVehicleByName;
		//['TeamStatusDialog.sqf', format["TSD9_Vehicle=%1,%2,%3,%4", typeName TSD9_Vehicle, TSD9_Vehicle, _vehicleNameToFind, TSD9_VehicleSearchComplete]] call fn_DebugAppend;
		waitUntil { TSD9_VehicleSearchComplete };
	};

	if (typeName TSD9_Vehicle != "ARRAY") then {
		if (!(isNull TSD9_Vehicle) && ([TSD9_Vehicle] call TSD9_IsVehicle)) then {
			_vehicle = TSD9_Vehicle
		};
	};

	[_vehicle] call TSD9_FillGroups;
	call TSD9_SetTitle;

	_control = TSD9_display displayCtrl TSD9_IDC_VehicleButton;
	ctrlSetFocus _control;

	[false] call TSD9_ShowCollapseExpandButtons;
};
//----------------------
TSD9_DrawPage_MyGroup = {
	TSD9_Page = "Group";
	[[player]] call TSD9_FillGroups;
	call TSD9_SetTitle;

	_control = TSD9_display displayCtrl TSD9_IDC_MyGroupButton;
	ctrlSetFocus _control;

	[false] call TSD9_ShowCollapseExpandButtons;
};
//----------------------
TSD9_DrawPage_Opposition = {
	TSD9_Page = "Opposition";

	_Trig = createTrigger ["EmptyDetector", [0, 0, 0] ];
	_Trig setTriggerActivation ["ANY", "PRESENT", false];
	_Trig setTriggerArea [31000, 31000, 0, true ];
	_Trig setTriggerStatements ["this","[thislist] call TSD9_FillGroups; ","" ];
	call TSD9_SetTitle;

	_control = TSD9_display displayCtrl TSD9_IDC_OppositionButton;
	ctrlSetFocus _control;

	[true] call TSD9_ShowCollapseExpandButtons;
};
//----------------------
TSD9_DrawPage_MyTeam = {
	TSD9_Page = "Team";

	_Trig = createTrigger ["EmptyDetector", [0, 0, 0] ];
	_Trig setTriggerActivation ["ANY", "PRESENT", false];
	_Trig setTriggerArea [31000, 31000, 0, true ];
	_Trig setTriggerStatements [ "this","[thislist] call TSD9_FillGroups; ","" ];
	//_Trig setTriggerType "SWITCH";
	//_Trig setTriggerTimeout [0, 0, 0, false];
	call TSD9_SetTitle;

	_control = TSD9_display displayCtrl TSD9_IDC_MyTeamButton;
	ctrlSetFocus _control;

	[true] call TSD9_ShowCollapseExpandButtons;
};
//----------------------
TSD9_DrawPage = {
	//player sidechat format["TSD9_Page=%1", TSD9_Page];
	switch (format["%1", TSD9_Page]) do {
		case "Vehicle": {[] call TSD9_DrawPage_MyVehicle};
		case "Group": {[] call TSD9_DrawPage_MyGroup};
		case "Opposition": {[] call TSD9_DrawPage_Opposition};
		default {[] call TSD9_DrawPage_MyTeam};
	};  
};
//----------------------
TSD9_FillClosedGroupsWithAllGroups = {
	_AllUnits = _this select 0;

	_AllGroups = [_AllUnits] call TSD9_GetAllGroupsFromUnits;

	TSD9_ClosedGroups = [];
	{
		TSD9_ClosedGroups = TSD9_ClosedGroups+[str(_x)];
	} forEach _AllGroups;

	[] call TSD9_DrawPage;
};
//----------------------
TSD9_CollapseAll = {
	_Trig = createTrigger ["EmptyDetector", [0,0,0]];
	_Trig setTriggerActivation ["ANY", "PRESENT", false];
	_Trig setTriggerArea [31000, 31000, 0, true];
	_Trig setTriggerStatements ["this","[thislist] call TSD9_FillClosedGroupsWithAllGroups; ",""];
};
//----------------------
TSD9_ExpandAll = {
	TSD9_ClosedGroups = [];

	[] call TSD9_DrawPage;
};
//----------------------
TSD9_SetTitle = {
	_Page = "";
	switch (format["%1", TSD9_Page]) do {
		case "Vehicle": {_Page = localize "STR_TSD9_05"};
		case "Group": {_Page = localize "STR_TSD9_09"};
		case "Opposition": {_Page = localize "STR_TSD9_06"};
		default {_Page = localize "STR_TSD9_07"};
	};  
	ctrlSetText [TSD9_IDC_FrameCaption, format[" %1 - %2 ", localize "STR_TSD9_01", _Page]];
};
//----------------------
// Localize all text for: buttons, titles, grid buttons, etc
TSD9_LocalizeText = {
	if (localize "STR_TSD9_01" == "") then {player sideChat "Missing STR_TSD9_* stringtable data" /* notify local client only */};
	call TSD9_SetTitle;
	call TSD9_ConfigTitleRow;

	ctrlSetText [TSD9_IDC_CloseButton, localize "STR_TSD9_02"];
	buttonSetAction [TSD9_IDC_CloseButton, "closeDialog 0"];

	ctrlSetText [TSD9_IDC_MyTeamButton, localize "STR_TSD9_03"];
	buttonSetAction [TSD9_IDC_MyTeamButton, "[] call TSD9_DrawPage_MyTeam;"];

	ctrlSetText [TSD9_IDC_MyGroupButton, localize "STR_TSD9_04"];
	buttonSetAction [TSD9_IDC_MyGroupButton, "[] call TSD9_DrawPage_MyGroup;"];

	ctrlSetText [TSD9_IDC_VehicleButton, localize "STR_TSD9_05"];
	buttonSetAction [TSD9_IDC_VehicleButton, "[] call TSD9_DrawPage_MyVehicle;"];

	ctrlSetText [TSD9_IDC_OppositionButton, localize "STR_TSD9_06"];
	buttonSetAction [TSD9_IDC_OppositionButton, "[] call TSD9_DrawPage_Opposition;"];

	ctrlSetText [TSD9_IDC_CollapseAllButton, localize "STR_TSD9_64"];
	buttonSetAction [TSD9_IDC_CollapseAllButton, "[] call TSD9_CollapseAll;"];

	ctrlSetText [TSD9_IDC_ExpandAllButton, localize "STR_TSD9_65"];
	buttonSetAction [TSD9_IDC_ExpandAllButton, "[] call TSD9_ExpandAll;"];
};
//----------------------
TSD9_ProcessParameters = {
	_parameters = _this;
	_actionParams = [];

	// TODO: Fix: how to detect if parameters passed are from Action or execVM?
	if (count _parameters == 4) then {
		if (typeName (_parameters select 3) == "ARRAY") then {
			_actionParams = _parameters select 3;
			// Note: This may not actually be real Action Params, but so long as it's an array, it will generally work.
		};
	};
	//['TeamStatusDialog.sqf', ["TSD9_ProcessParameters _parameters=", _parameters]] call fn_DebugAppend;
	//['TeamStatusDialog.sqf', ["TSD9_ProcessParameters _actionParams=", _actionParams] call fn_DebugAppend;

	_fn_ParamExists = {
		_paramName = _this select 0;

		_exists = ((_parameters find _paramName) > -1);
		if (! _exists) then {_exists = ((_actionParams find _paramName) > -1);};

		//['TeamStatusDialog.sqf', format["_fn_ParamExists=%1=%2", _paramName, _exists]] call fn_DebugAppend;
		_exists;
	};

	// TODO: Fix bug: if any param is not an array (eg: "AllowPlayerInvites"), it will match it instantly. So array options like "VehicleObject" & "Page" must be listed first.
	_getParamByName = {
		_paramName = _this select 0;
		_default = _this select 1; // could be of any type (including object, string, etc)

		_result = [_paramName, _parameters, _default] call TSD9_GetParamByName;

		_invalid = false;
		//player sideChat format["%1=%2 (%3)=%4 (%5)", _paramName, _default, typeName _default, _result, typeName _result]; // debug
		if (typeName _default != typeName _result) then {
			_invalid = true;
		} else {
			if (typeName _result != "OBJECT" || typeName _default != "OBJECT") then {
				_invalid = (_result == _default)
			} else {
				_invalid = ((isNull _default) && (isNull _result))
			};
		};

		if (_invalid) then {_result = [_paramName, _actionParams, _default] call TSD9_GetParamByName;};

		_result;
	};

	if (["HideTeam"] call _fn_ParamExists) then { ctrlShow [TSD9_IDC_MyTeamButton, false] };
	if (["HideGroup"] call _fn_ParamExists) then { ctrlShow [TSD9_IDC_MyGroupButton, false] };
	if (["HideVehicle"] call _fn_ParamExists) then { ctrlShow [TSD9_IDC_VehicleButton, false] };
	if (["HideOpposition"] call _fn_ParamExists) then { ctrlShow [TSD9_IDC_OppositionButton, false] };

	TSD9_Vehicle = objNull;
	TSD9_Page = ["Page", "Team"] call _getParamByName;
	TSD9_HideIcons = (["HideIcons"] call _fn_ParamExists);
	TSD9_DeleteRemovedAI = (["DeleteRemovedAI"] call _fn_ParamExists);
	TSD9_AllowAILeaderSelect = (["AllowAILeaderSelect"] call _fn_ParamExists);
	TSD9_AllowAIRecruitment = (["AllowAIRecruitment"] call _fn_ParamExists);
	TSD9_AllowPlayerInvites = (["AllowPlayerInvites"] call _fn_ParamExists);
	TSD9_ShowAIGroups = (["ShowAIGroups"] call _fn_ParamExists);
	TSD9_CloseOnKeyPress = (["CloseOnKeyPress"] call _fn_ParamExists);

	//TSD9_Vehicle = ["VehicleObject", objNull] call _getParamByName;
	TSD9_Vehicle = ["VehicleObject", objNull] call _getParamByName;
	//['TeamStatusDialog.sqf', format["TSD9_ProcessParameters TSD9_Vehicle=%1", TSD9_Vehicle]] call fn_DebugAppend;

	if (TSD9_CloseOnKeyPress) then {
		// enable close on key press
		_closeDialog = format["closeDialog %1", TSD9_IDD_TeamStatusDialog];
		TSD9_display displaySetEventHandler["KeyDown", _closeDialog];
	};

	call TSD9_LocalizeText;

	/* // can't seem to change bg color of buttons
	{
	_control = TSD9_display displayCtrl _x;
	_control ctrlSetBackgroundColor [0.8, 0.3, 0.0, 1];;

	} forEach 
	[
	  TSD9_IDC_CloseButton, 
	  TSD9_IDC_MyTeamButton, 
	  TSD9_IDC_MyGroupButton, 
	  TSD9_IDC_VehicleButton, 
	  TSD9_IDC_OppositionButton
	];
	*/
	/*
	_control = TSD9_display displayCtrl 1101;
	_control ctrlSetBackgroundColor [1, 0.3, 0.0, 1];;
	_control ctrlSetForegroundColor [1, 0.3, 0.0, 1];;
	_control ctrlSetActiveColor [1, 0.3, 0.0, 1];;
	_control ctrlSetTextColor [1, 0.3, 0.0, 1];;
	*/

	_reservedRows = 1;
	_lastRow = TSD9_ROWS-1-_reservedRows;
	_row = 1;
	while {_row < _lastRow+_reservedRows} do {
		[_row] call TSD9_HideRow;
		_row = _row + 1;
	};
};
//-----------------------------------------------------------------------------
// Init
//-----------------------------------------------------------------------------

//["TeamStatusDialog.sqf", _this] call fn_DebugAppend; // debug

if !(createDialog "ICE_TeamStatusDialog") then { hint "createDialog failed" };
TSD9_display = findDisplay TSD9_IDD_TeamStatusDialog;

//["TeamStatusDialog.sqf", _this] call fn_DebugAppend; // debug
_this call TSD9_ProcessParameters;

[] call TSD9_DrawPage;
