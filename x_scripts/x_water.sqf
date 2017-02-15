// by Xeno
private ["_has_primary","_has_secondary"];
wp_weapon_array = [];

_has_primary = false;
_has_secondary = false;

while {true} do {
	waitUntil {sleep 0.412;surfaceIsWater [(position player) select 0, (position player) select 1] && ((getPosASL player) select 2) < 1};
	if (alive player) then {
		wp_weapon_array = [weapons player, magazines player];
		_has_primary = false;
		_has_secondary = false;
		if (primaryWeapon player != "") then {
			_has_primary = true;
			while {(primaryWeapon player != "") && (alive player) && (surfaceIsWater [(position player) select 0, (position player) select 1])} do {sleep 0.621};
			sleep 0.521;
			// remove the weapon holders
			_nwho = position player nearObjects 20;
			{if (_x isKindOf "WeaponHolder") then {deleteVehicle _x};} forEach _nwho;
		} else {
			if (secondaryWeapon player != "") then {
				_has_secondary = true;
				while {(secondaryWeapon player != "") && (alive player) && (surfaceIsWater [(position player) select 0, (position player) select 1])} do {sleep 0.621};
				sleep 0.521;
				// remove the weapon holders
				_nwho = position player nearObjects 40;
				{if (_x isKindOf "WeaponHolder") then {deleteVehicle _x};} forEach _nwho;
			};
		};
	};
	waitUntil {sleep 0.412;!surfaceIsWater [(position player) select 0, (position player) select 1] || !alive player};
	if (alive player) then {
		if (_has_primary || _has_secondary) then {
			_p = player;
			removeAllWeapons _p;
			{_p addMagazine _x;} forEach (wp_weapon_array select 1);
			{_p addWeapon _x;} forEach (wp_weapon_array select 0);
			_primw = primaryWeapon _p;
			if (_primw != "") then {
				_p selectWeapon _primw;
				_muzzles = getArray(configFile>>"cfgWeapons" >> _primw >> "muzzles");
				_p selectWeapon (_muzzles select 0);
			};
			wp_weapon_array = [];
		};
	};
	if (!alive player) then {waitUntil {alive player};if (count wp_weapon_array > 0) then {sleep 2.432;wp_weapon_array = [];};};
	sleep 10.012;
};