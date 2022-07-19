// DragBoat.sqf: allow to drags boats
// Call as:
//
//		class Item313
//		{
//			position[]={2966.286865,24.244808,7585.515625};
//			azimut=-94.661797;
//			id=361;
//			side="EMPTY";
//			vehicle="Zodiac";
//			skill=0.600000;
//			init="nul = this addaction [""Drag boat"", ""scripts\DragBoat.sqf"", [], -100, true, true]";
//		};
//
_boat = (_this select 0);
_unit = (_this select 1);

//hint format ["%1, %2", _boat, _unit];

_dragger = "SLX_Dragger" createVehicle (_unit modelToWorld[0,0,1000]);
_unit reveal _dragger;

_dragger setDir (getDir _boat);
_dragger setPos (_unit modelToWorld[0,0,0]);

_unit action ["getInDriver", _dragger];

waitUntil {vehicle _unit == _dragger};

cutText ["CAREFUL: If you hit your teammates with the boat, it may injure them.","PLAIN DOWN"];

while {(vehicle _unit == _dragger) AND (Alive _unit)} do
	{
	if ((getposASL _unit) select 2 < 1) then {_unit action ["EJECT", _boat]};
	_dir = getDir _dragger;
	_pos = getPos _dragger;
	_boatPos = [(_pos select 0) - (2.4*sin(_dir)), (_pos select 1) - (2.4*cos(_dir))];

	_boat setPos _boatPos;
	_boat setDir _dir;
	_boat setVelocity [0,0,0];
	_boat setVectorUp (vectorUp _dragger);

	sleep 0.01;
	};

deleteVehicle _dragger;