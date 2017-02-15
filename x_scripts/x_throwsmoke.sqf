// by Xeno
private ["_vehicle","_type","_weapons"];
_vehicle = _this select 0;
_type = typeOf _vehicle;

scopeName "x_throwsmoke";

if (!isNull d_throw_smoke_vec) then {
	if (d_throw_smoke_vec == _vehicle) then {
		[d_throw_smoke_vec,"Smoke currently not available... reloading"] call XfVehicleChat;
		breakOut "x_throwsmoke";
	};
};

_weapons = getArray (configFile >> "CfgVehicles" >> _type >> "Turrets" >> "MainTurret" >> "weapons");

if (count _weapons > 0) then {
	d_throw_smoke_vec = _vehicle;
	[] spawn {
		sleep 25 + random (5);
		[d_throw_smoke_vec,"Smoke available again..."] call XfVehicleChat;
		d_throw_smoke_vec = objNull;
	};
	_mainweapon = _this select 0;
	_wDir = _vehicle weaponDirection (_weapons select 0);
	_weaponDir = (_wDir select 0) atan2 (_wDir select 1);
	_start_angle = (_weaponDir - 60) + 180;
	_end_angle = (_weaponDir + 60) + 180;
	_smoke_positions = [];
	_center_x = (position _vehicle) select 0;
	_center_y = (position _vehicle) select 1;
	_radius = 25;
	_angle = _start_angle;
	
	_posvec = position _vehicle;
	_dir = _weaponDir;
	_vehpos = [(_posvec select 0)+sin(_dir)*1, (_posvec select 1)+cos(_dir)*1, (_posvec select 2)];

	sleep 0.2;
	
	_shellpos = [(_vehpos select 0)+sin(_dir)*1,(_vehpos select 1)+cos(_dir)*1,3.5];
	_shell1 = "Grenade" createVehicle _shellpos;
	_shell1 setPos _shellpos;
	_shell1 setdir random 360;
	_shell1 setvelocity [sin(_dir)*10,cos(_dir)*10,12+random 3];

	_shellpos = [(_vehpos select 0)+sin(_dir+20)*1,(_vehpos select 1)+cos(_dir+20)*1,3.5];
	_shell2 = "Grenade" createVehicle _shellpos;
	_shell2 setPos _shellpos;
	_shell2 setdir random 360;
	_shell2 setvelocity [sin(_dir+20)*10,cos(_dir+20)*10,12+random 3];

	_shellpos = [(_vehpos select 0)+sin(_dir-20)*1,(_vehpos select 1)+cos(_dir-20)*1,3.5];
	_shell3 = "Grenade" createVehicle _shellpos;
	_shell3 setPos _shellpos;
	_shell3 setdir random 360;
	_shell3 setvelocity [sin(_dir-20)*10,cos(_dir-20)*10,12+random 3];

	
	_shellpos = [(_vehpos select 0)+sin(_dir+40)*1,(_vehpos select 1)+cos(_dir+40)*1,3.5];
	_shell4 = "Grenade" createVehicle _shellpos;
	_shell4 setPos _shellpos;
	_shell4 setdir random 360;
	_shell4 setvelocity [sin(_dir+40)*10,cos(_dir+40)*10,12+random 3];

	_shellpos = [(_vehpos select 0)+sin(_dir-40)*1,(_vehpos select 1)+cos(_dir-40)*1,3.5];
	_shell5 = "Grenade" createVehicle _shellpos;
	_shell5 setPos _shellpos;
	_shell5 setdir random 360;
	_shell5 setvelocity [sin(_dir-40)*10,cos(_dir-40)*10,12+random 3];

	_shellpos = [(_vehpos select 0)+sin(_dir+60)*1,(_vehpos select 1)+cos(_dir+60)*1,3.5];
	_shell6 = "Grenade" createVehicle _shellpos;
	_shell6 setPos _shellpos;
	_shell6 setdir random 360;
	_shell6 setvelocity [sin(_dir+60)*10,cos(_dir+60)*10,12+random 3];

	_shellpos = [(_vehpos select 0)+sin(_dir-60)*1,(_vehpos select 1)+cos(_dir-60)*1,3.5];
	_shell7 = "Grenade" createVehicle _shellpos;
	_shell7 setPos _shellpos;
	_shell7 setdir random 360;
	_shell7 setvelocity [sin(_dir-60)*10,cos(_dir-60)*10,12+random 3];

	sleep 1.45;
	deletevehicle _shell1;
	sleep random 0.10;
	deletevehicle _shell2;
	sleep random 0.10;
	deletevehicle _shell3;
	sleep random 0.10;
	deletevehicle _shell4;
	sleep random 0.10;
	deletevehicle _shell5;
	sleep random 0.10;
	deletevehicle _shell6;
	sleep random 0.10;
	deletevehicle _shell7;
	
	for "_i" from 1 to 7 do {
		_x1 = _center_x - (_radius * sin _angle);
		_y1 = _center_y - (_radius * cos _angle);
		_smoke_positions = _smoke_positions + [[_x1, _y1, 0]];
		_angle = _angle + 20;
	};
	_shells = [];
	{
		_shell = "SmokeShell" createVehicle _x;
		_shells = _shells + [_shell];
		if (d_found_DMSmokeGrenadeVB) then {
			[_shell] spawn X_DM_SMOKE_SHELL;
		};
	} forEach _smoke_positions;
	sleep 65 + random 3;
	{
		if (!isNull _x) then {
			deleteVehicle _x;
		};
	} forEach _shells;
};
