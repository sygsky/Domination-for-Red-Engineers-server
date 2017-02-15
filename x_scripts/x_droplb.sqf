// by Xeno
lbClear 44449;
_XD_display = findDisplay 11002;
_control = _XD_display displayCtrl 44449;

{
	_pic = getText(configFile >> "cfgVehicles" >> _x >> "picture");
	_index = _control lbAdd "";
	_control lbSetPicture [_index, _pic];
	_control lbSetColor [_index, [1, 1, 0, 0.5]];
	player sideChat format ["%1",_x];
} forEach d_create_bike;

_control lbSetCurSel 0;

if (true) exitWith {};
