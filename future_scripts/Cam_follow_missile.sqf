/*
	Cam_follow_missile
	author: Sygsky
	description:

	"Fired" event
	Triggered when the unit fires a weapon. This EH will not trigger if a unit fires out of a vehicle. For those cases an EH has to be attached to that particular vehicle.
	
	Global.	Passed array: [unit, weapon, muzzle, mode, ammo]
	
	unit: Object - Object the event handler is assigned to
	weapon: String - Fired weapon
	muzzle: String - Muzzle that was used
	mode: String - Current mode of the fired weapon
	ammo: String - Ammo used

	returns: nothing
*/

//Снайперу с свд которого зовут sniper в инит пишем:

_Ka50 addEventHandler ["fired",{_this exec "bullet.sqf"}];

//Скрипт bullet.sqf

_unit = _this select 0;
_round = _this select 4;
_camera = "camera" camcreate [0,0,0];
_camera cameraEffect ["internal", "back"];

_missile = nearestObject [_unit, _round];
_camera camSetTarget _missile;
while (!isNull _missile) do {
	_camera camSetRelPos [-0.5,-7,1];
	_camera camCommit 0;
};
_camera cameraEffect ["terminate", "Back"];
camdestroy _camera;

