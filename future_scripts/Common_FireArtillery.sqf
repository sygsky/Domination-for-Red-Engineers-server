//Last modified 5/9/8
//*****************************************************************************************
//Description: Aim and fire artillery.
//*****************************************************************************************

private["_ammo","_angle","_arcDistance","_artillery","_destination","_direction","_distance","_minRange","_maxRange","_position","_radius","_shell","_side","_type","_velocity","_weapon","_x","_y"];

_artillery = _this select 0;
_destination = _this select 1;
_side = _this select 2;
_radius = _this select 3;

_type = call compile format["%1ArtilleryNames Find TypeOf _artillery",str _side];
if (_type < 0) exitWith {};

_minRange = call compile format["%1ArtilleryMinRanges select _type",str _side];
_maxRange = call compile format["%1ArtilleryMaxRanges select _type",str _side];
_weapon = call compile format["%1ArtilleryWeapons select _type",str _side];
_ammo = call compile format["%1ArtilleryAmmos select _type",str _side];
_velocity = call compile format["%1ArtilleryVelocities select _type",str _side];
_dispersion = call compile format["%1ArtilleryDispersions select _type",str _side];

if (isNull gunner _artillery) exitWith {};
if (isPlayer gunner _artillery) exitWith {};

_position = getPos _artillery;
_x = (_destination select 0) - (_position select 0);
_y = (_destination select 1) - (_position select 1);

_direction =  -(((_y atan2 _x) + 270) % 360);
if (_direction < 0) then {_direction = _direction + 360};

_distance = sqrt ((_x ^ 2) + (_y ^ 2)) - _minRange;
_angle = _distance / (_maxRange - _minRange) * 100 + 15;

if (_angle > 90) then {_angle = 90};
if (_distance < 0 || _distance + _minRange > _maxRange) exitWith {};

_watchPosition = [(_position select 0) + (sin _direction) * 50,(_position select 1) + (cos _direction) * 50,_angle];
gunner _artillery doWatch _watchPosition;

sleep (3 + random 3);

_amount = _artillery ammo _weapon;
_artillery fire _weapon;

waitUntil {_artillery ammo _weapon < _amount};

_shell = nearestObject [_artillery,_ammo];

_shell setPos [0,0,1000 + random 20];
_shell setPos [0,0,0];

//Rough approximation of the distance the shell will travel in a parabola.
_arcDistance = sqrt((_distance ^ 2) * 2);

//Wait until shell should arrive.
sleep (_arcDistance / _velocity);

_distance = random (_distance / _maxRange * 100) + random _radius;
_direction = random 360;
_shell setPos [(_destination select 0)+((sin _direction)*_distance),(_destination select 1)+((cos _direction)*_distance),400];
_destination = [(_destination select 0)+((sin _direction)*_distance),(_destination select 1)+((cos _direction)*_distance),400];
_shell setPos [0,0,-_velocity];

//*****************************************************************************************
//12/18/7 MM - Created file.
