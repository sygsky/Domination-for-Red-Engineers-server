/*
	File: hasWeapon.sqf
	Description: function determining this entry has a weapon or is a weapon.
	
	Copyright © Bohemia Interactive Studio. All rights reserved.
*/

//ToDo: does not fully explore turrets, only 1 layer?
private ["_tid", "_entry", "_hasWeapon"];
_tid = _this select 0;
_entry = _this select 1;
_hasWeapon = false;

if ([_tid] call LIB_isWeaponFunction) then 
{
	_hasWeapon = true;
} 
else 
{
	private ["_weapons"];
	_weapons = getArray(_entry >> "weapons");

	if (_tid != 11) then 
	{
		private ["_turrets"];
		_turrets = _entry >> "turrets";
		for "_i" from 0 to ((count _turrets) - 1) do 
		{
			private ["_turret", "_turretWeapons"];
			_turret = _turrets select 0;
			
			if (isClass _turret) then 
			{
				_turretWeapons = getArray(_turret >> "weapons");
				_weapons = _weapons + _turretWeapons;
			};
		};
	};
		
	if ((count _weapons) > 0) then 
	{
		for "_i" from 0 to ((count _weapons) - 1) do 
		{
			private ["_weapon", "_enableAttack", "_type", "_useAsBinocular"];
			_weapon = _weapons select _i;
			_enableAttack = getNumber(LIB_cfgWea >> _weapon >> "enableAttack");
			_type = getNumber(LIB_cfgWea >> _weapon >> "type");
			_useAsBinocular = getNumber(LIB_cfgWea >> _weapon >> "useAsBinocular");
			
			//Exclude weapons that cannot be used to attack or that are dummy or used as binoculars.
			//ToDo: what about characters with only explosives?
			if ((_enableAttack == 1) && (_type != 0) && (_useAsBinocular != 1)) exitWith 
			{
				_hasWeapon = true;	
			};
		};
	};
};

_hasWeapon