private["_unit","_disp","_typeEUM","_confEUM","_confPDM","_typePDM"];

// _cnt = [_unis, _mag] call _countMag;
/*
_countMag = {
    _mag = _this select 1;
    _cnt = 0;
    {
        if ( _mag == _x) then {_cnt = _cnt +1};
    } forEach magazines (_this select 0);
    _cnt
};
*/

_unit = _this select 0;
_disp = _this select 1;
_typeEUM = _this select 2;
_confEUM = configFile >> "CfgMagazines" >> _typeEUM;
_confPDM = _confEUM >> "ACE_PackDummyMag";
if (isText(_confPDM) && _typeEUM in magazines _unit) then
{
	_typePDM = getText(_confPDM);
	if ([_unit,_typePDM] call ACE_Sys_Ruck_FitsInRucksack) then
	{
		if (getNumber(_confEUM >> "count") == 1 || (_unit != vehicle _unit)) then
		{

		    _ammo1 = magazines _unit;
		    _cnt1  = {_typeEUM == _x} count (magazines _unit);
		    _ammo2 = [];
		    _ammo3 = [];
		    _ammo4 = [];

			_unit  removeMagazine _typeEUM;
			_ammo2 = magazines _unit;
			_cnt2  = {_typeEUM == _x} count (magazines _unit);
			if (_cnt1 == _cnt2) then
			{
			    _unit    addMagazine _typeEUM;
			    _ammo3 = magazines _unit;
			    _unit    removeMagazine _typeEUM; _unit removeMagazine _typeEUM;
			    _ammo4 = magazines _unit;
			};
			//hint localize format["*** mags: (%5)%1, (%6):%2, %3, %4", _ammo1, _ammo2, _ammo3, _ammo4, _cnt1, _cnt2 ];
			[_unit,_typePDM] call ace_sys_ruck_addruckmagazine;
			//hint localize format["*** mags after addruckmagazine: %1", magazines _unit];
		} else {
			[_unit,_disp,_typeEUM,_typePDM] spawn ACE_Sys_Ruck_CheckifFull;
		}
	}
}
