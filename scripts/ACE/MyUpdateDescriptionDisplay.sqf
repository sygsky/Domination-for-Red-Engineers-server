//
// Optimaze for ACE 1.09 weapon magazines repetitive output.
// Now any magazine with same name is displayed once in the whole list
//
#include "\ace_sys_ruck\h\script_RscDisplayGear_Defines.hpp"
private["_disp","_ctrl","_conf","_typeNum","_confPDM","_confEUM","_confEUW","_isPDM","_confMag","_isWeapon","_isMagazine","_displayName","_magazines","_packSize","_count","_velocity","_weight","_size","_magArr"];
_disp = _this select 0;
_conf = _this select 1;
_ctrl = _disp displayCtrl ACE_DESCRIPTION_IDC;

//hint localize "scripts/MyUpdateDescriptionDisplay.sqf run";
//The original gear menu doesn't store a data value for weapons.
//We could read the displayName, and search through every weapon in the config until we find one that matches, but that would be really slow.
//This simply uses the original description display if we don't know what we are supposed to describe.
if (format["%1",_this select 1] == "") then {
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
if (_typeNum == 4096) then {
	_confTypeEUM = _conf >> "ACE_EndUseMag";
	_confTypeEUW = _conf >> "ACE_EndUseWeapon";
	if (isText(_confTypeEUM) || isText(_confTypeEUW)) then {
		_isPDM = true;
		_confPDM = _conf;
		if (isText(_confTypeEUM)) then {
			_isMagazine = true;
			_confEUM = configFile >> "CfgMagazines" >> getText(_confTypeEUM);
			_conf = _confEUM;
		};
		if (isText(_confTypeEUW)) then {
			_isWeapon = true;
			_confEUW = configFile >> "CfgWeapons" >> getText(_confTypeEUW);
			_conf = _confEUW;
		}
	}
};
if (!_isPDM) then {
	if (_typeNum == 1 || _typeNum == 2 || _typeNum == 4 || _typeNum == 4096) then {
		_isWeapon = true;
		_confEUW = _conf;
	} else {
		_isMagazine = true;
		_confEUM = _conf;
	};
	_confTypePDM = _conf >> "ACE_PackDummyMag";
	if (isText(_confTypePDM)) then {
		_confPDM = configFile >> "CfgMagazines" >> getText(_confTypePDM);
	}
};

//Write the description text
_displayName = "";
_confDisplayName = _conf >> "DisplayName";
if (isText(_confDisplayName)) then { _displayName = getText(_confDisplayName); };

_description = "";
_confDescription = _conf >> "Library" >> "libTextDesc";
if (isText(_confDescription)) then {
	_description = getText(_confDescription);
	if (_description == "") then { _description = localize "STR_LIB_INFO_NO_TEXT"; }
};

_packSize = "";
_magazines = "";
_confMag = configFile >> "CfgMagazines";
_magArr = []; // array of unique magaizine description
if (!_isPDM) then {
	private["_confPackSize"];
	_confPackSize = _confEUW >> "ACE_PackSize";
	if (isNumber(_confPackSize)) then {
		_packSize = format["%1 %2 %3<br/>",localize "STR_ACE_SYS_RUCK_PACKSIZE",getNumber(_confPackSize),localize "STR_ACE_SYS_RUCK_CUBICCENTIMETERS"];
	} else {
		if (_typeNum != 4096) then {
			private["_confMagazines"];
			_confMagazines = _confEUW >> "magazines"; // process magazines placed in the weapon class itself
			if (isArray(_confMagazines)) then {
				private["_magArray","_magCount", "_magDescr"];
				//_confMag = configFile >> "CfgMagazines";
				_magArray = getArray(_confMagazines);
				_magCount = count _magArray;
			    //hint localize format["--- Weapon %1: mag count %2", _displayName, _magCount];
				if (_magCount > 0) then { _magazines = getText(_confMag >> (_magArray select 0) >> "displayName"); };
				_magArr = [_magazines]; // // store 1st known magazine display name
				for "_x" from 1 to _magCount step 1 do {
				    _magDescr = getText(_confMag >> (_magArray select _x) >> "displayName");
				    if ( !(_magDescr in _magArr) ) then {
    				    _magazines = format["%1, %2",_magazines, _magDescr];
    				    _magArr = _magArr + [_magDescr];
				    };
				};
			};
			// process magazines from muzzles of weapon class if available
			_muzzles = _confEUW >> "muzzles";
			if (isArray(_muzzles)) then {
			    _muzzleArray = getArray(_muzzles);
			    _muzzleCount = count _muzzleArray;
			    // hint localize format["--- Weapon %1: muzzleCount = %2", _displayName, _muzzleCount];
			    for "_i" from 0 to _muzzleCount - 1 do {
                    // read found muzzle class if present and try to find magazines in it
      			    _confMagazines = _confEUW >> (_muzzleArray select _i) >> "magazines";
                    if (isArray(_confMagazines)) then {
                        private["_magArray","_magCount","_magDescr"];
                        _magArray = getArray(_confMagazines);
                        _magCount = count _magArray;
                        if (_magCount > 0) then  {// still no one magazine is in unique array
                            _magDescr = getText(_confMag >> (_magArray select 0) >> "displayName");
                            if ( _magazines != "") then {
                                _magazines = format["%1, %2",_magazines, _magDescr];
                            } else {
                                _magazines = _magDescr;
                            };
                            _magArr = _magArr + [_magDescr]; // remember 1st known magazine display name
                        };
                        for "_x" from 1 to _magCount step 1 do {
                            _magDescr = getText(_confMag >> (_magArray select _x) >> "displayName");
                            if ( !(_magDescr in _magArr) ) then {
                                _magazines = format["%1, %2",_magazines, _magDescr];
                                _magArr = _magArr + [_magDescr];
                            };
                        };
                    };
			    };
			};
    		_magazines = format["<t size = '1.35'><br/>%1<br/></t><t size = '1'>%2<br/></t>",localize "STR_LIB_INFO_MAGAZINE",_magazines];
		}//else {hint localize "--- Weapon Display: _typeNum == 4096"}
	};
};

_count = "";
_velocity = "";
if (_isMagazine) then {
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

_params = "";
if ( _isMagazine ) then {
    _params = ">";
    // add more info on magazine
    _confParam = _conf >> "ammo";
    if (isText(_confParam)) then {
        _confAmmo = getText(_confParam);
        _param = format["> "];
        _confParam = configFile >> "CfgAmmo" >> _confAmmo >> "hit";
        if (isNumber(_confParam) &&  getNumber(_confParam) >= 0.1) then { // if less - it is dummy magazine (bandage etc)
            if (isNumber(_confParam) ) then { _params = format[ localize "STR_ACE_HIT", _params,  getNumber(_confParam) ]; };
            _confParam = configFile >> "CfgAmmo" >> _confAmmo >> "indirectHit";
            if (isNumber(_confParam) && getNumber(_confParam) > 0) then { _params = format[  localize "STR_ACE_INDIRECT_HIT", _params, getNumber(_confParam) ]; };
            _confParam = configFile >> "CfgAmmo" >> _confAmmo >> "indirectHitRange";
            if (isNumber(_confParam) && getNumber(_confParam) > 0) then { _params = format[ localize "STR_ACE_INDIRECT_HIT_RANGE", _params, getNumber(_confParam) ]; };
        }
    };
};

_ctrl ctrlSetStructuredText parseText format["<t color = '#ffffff'><t font = 'Zeppelin32'><t size = '1.35'><t align = 'center'>%1</t><br/><br/>%2<br/></t><t size = '1'>%3</t></t>%4%5%6</t></t>",
_displayName,
localize "STR_LIB_LABEL_DESCRIPTION",
_description,
_statistics,
_magazines,
_params];