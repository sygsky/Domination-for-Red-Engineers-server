//
// Optimaze for ACE 1.09 weapon magazines repetitive output.
// Now any magazine with same name is displayed once in the whole list
//
#include "\ace_sys_ruck\h\script_RscDisplayGear_Defines.hpp"
private["_disp","_ctrl","_conf","_typeNum","_confPDM","_confEUM","_confEUW","_isPDM","_isWeapon","_isMagazine","_displayName","_magazines","_packSize","_count","_velocity","_weight","_size"];
_disp = _this select 0;
_conf = _this select 1;
_ctrl = _disp displayCtrl ACE_DESCRIPTION_IDC;

//hint localize "scripts/MyUpdateDescriptionDisplay.sqf run";
//The original gear menu doesn't store a data value for weapons.
//We could read the displayName, and search through every weapon in the config until we find one that matches, but that would be really slow.
//This simply uses the original description display if we don't know what we are supposed to describe.
if (format["%1",_this select 1] == "") then
{
	//hint format["%1\n%2",_this];
	_ctrl ctrlShow false;
	(_disp displayCtrl CA_DESCRIPTION_IDC)ctrlShow true
} else {
	(_disp displayCtrl CA_DESCRIPTION_IDC)ctrlShow false;
	_ctrl ctrlShow true
};

//Figure out what type of item this is.
_isPDM = false;
_isWeapon = false;
_isMagazine = false;
_typeNum = getNumber(_conf >> "type");
if (_typeNum == 4096) then
{
	_confTypeEUM = _conf >> "ACE_EndUseMag";
	_confTypeEUW = _conf >> "ACE_EndUseWeapon";
	if (isText(_confTypeEUM) || isText(_confTypeEUW)) then
	{
		_isPDM = true;
		_confPDM = _conf;
		if (isText(_confTypeEUM)) then
		{
			_isMagazine = true;
			_confEUM = configFile >> "CfgMagazines" >> getText(_confTypeEUM);
			_conf = _confEUM;
		};
		if (isText(_confTypeEUW)) then
		{
			_isWeapon = true;
			_confEUW = configFile >> "CfgWeapons" >> getText(_confTypeEUW);
			_conf = _confEUW;
		}
	}
};
if (!_isPDM) then
{
	if (_typeNum == 1 || _typeNum == 2 || _typeNum == 4 || _typeNum == 4096) then
	{
		_isWeapon = true;
		_confEUW = _conf;
	} else {
		_isMagazine = true;
		_confEUM = _conf;
	};
	_confTypePDM = _conf >> "ACE_PackDummyMag";
	if (isText(_confTypePDM)) then
	{
		_confPDM = configFile >> "CfgMagazines" >> getText(_confTypePDM);
	}
};

//Write the description text
_displayName = "";
_confDisplayName = _conf >> "DisplayName";
if (isText(_confDisplayName)) then { _displayName = getText(_confDisplayName); };

_description = "";
_confDescription = _conf >> "Library" >> "libTextDesc";
if (isText(_confDescription)) then
{
	_description = getText(_confDescription);
	if (_description == "") then { _description = localize "STR_LIB_INFO_NO_TEXT"; }
};

_packSize = "";
_magazines = "";
if (!_isPDM) then
{
	private["_confPackSize"];
	_confPackSize = _confEUW >> "ACE_PackSize";
	if (isNumber(_confPackSize)) then
	{
		_packSize = format["%1 %2 %3<br/>",localize "STR_ACE_SYS_RUCK_PACKSIZE",getNumber(_confPackSize),localize "STR_ACE_SYS_RUCK_CUBICCENTIMETERS"];
	} else {
		if (_typeNum != 4096) then
		{
			private["_confMagazines"];
			_confMagazines = _confEUW >> "magazines";
			if (isArray(_confMagazines)) then
			{
				private["_magArray","_magCount","_confMag", "_magDescr", "_magArr"];
				_confMag = configFile >> "CfgMagazines";
				_magArray = getArray(_confMagazines);
				_magCount = count _magArray;
				if (_magCount > 0) then { _magazines = getText(_confMag >> (_magArray select 0) >> "displayName"); };
				_magArr = [_magazines]; // array of already descibed mags
				for "_x" from 1 to _magCount step 1 do
				{
				    _magDescr = getText(_confMag >> (_magArray select _x) >> "displayName");
				    if ( !(_magDescr in _magArr) ) then
				    {
    				    _magazines = format["%1, %2",_magazines, _magDescr];
    				    _magArr = _magArr + [_magDescr];
				    };
				};
				_magazines = format["<t size = '1.35'><br/>%1<br/></t><t size = '1'>%2<br/></t>",localize "STR_LIB_INFO_MAGAZINE",_magazines];
			}
		}
	}
};

_count = "";
_velocity = "";
if (_isMagazine) then
{
	_confCount = _confEUM >> "count";
	if (isNumber(_confCount)) then { _count = format["%1 %2<br/>",localize "STR_LIB_INFO_AMMO_COUNT",getNumber(_confCount)]; };
	_confVelocity = _confEUM >> "initSpeed";
	if (isNumber(_confVelocity)) then { _velocity = format["%1 %2 %3<br/>",localize "STR_LIB_INFO_MUZZLE_VEL",getNumber(_confVelocity),localize "STR_LIB_INFO_UNIT_METERS_PER_SECOND"]; };
};

_weight = "";
_confMagWeight = _confEUM >> "ACE_Weight";
_confWepWeight = _confEUW >> "ACE_Weight";
if (isNumber(_confMagWeight) && isNumber(_confWepWeight)) then { _weight = format["%1 %2 %3<br/>",localize "STR_ACE_SYS_RUCK_WEIGHT",getNumber(_confMagWeight)+getNumber(_confWepWeight),localize "STR_ACE_SYS_RUCK_KILOGRAMS"]; };
if (isNumber(_confMagWeight)) then { _weight = format["%1 %2 %3<br/>",localize "STR_ACE_SYS_RUCK_WEIGHT",getNumber(_confMagWeight),localize "STR_ACE_SYS_RUCK_KILOGRAMS"]; };
if (isNumber(_confWepWeight)) then { _weight = format["%1 %2 %3<br/>",localize "STR_ACE_SYS_RUCK_WEIGHT",getNumber(_confWepWeight),localize "STR_ACE_SYS_RUCK_KILOGRAMS"]; };

_size = "";
_confSize = _confPDM >> "ACE_Size";
if (isNumber(_confSize)) then { _size = format["%1 %2 %3<br/>",localize "STR_ACE_SYS_RUCK_SIZE",getNumber(_confSize),localize "STR_ACE_SYS_RUCK_CUBICCENTIMETERS"]; };

_statistics = format["%1%2%3%4%5",_velocity,_count,_packSize,_weight,_size];
if (_statistics != "") then { _statistics = format["<t size = '1.35'><br/><br/>%1<br/></t><t size = '1'>%2</t>",localize "STR_LIB_LABEL_STATISTICS",_statistics]; };

_ctrl ctrlSetStructuredText parseText format["<t color = '#ffffff'><t font = 'Zeppelin32'><t size = '1.35'><t align = 'center'>%1</t><br/><br/>%2<br/></t><t size = '1'>%3</t></t>%4%5</t></t>",_displayName,localize "STR_LIB_LABEL_DESCRIPTION",_description,_statistics,_magazines];