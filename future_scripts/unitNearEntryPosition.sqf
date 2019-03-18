private ["_unit","_vehicle","_pos"];

_unit = _this select 0;
_vehicle = _this select 1;
_pos = _this select 2;

if ((_unit distance (_vehicle modelToWorld (_vehicle selectionPosition (getText(configFile >> "CfgVehicles" >> (typeOf _vehicle) >> ("memoryPointsGetIn" + _pos)))))) < 5) then
{
 	true
}
else
{
	false
};


