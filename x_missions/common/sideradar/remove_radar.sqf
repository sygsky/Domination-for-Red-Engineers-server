/*
	author: Sygsky
	description: none
	_killed = _this select 0;
	_killer = _this select 1;
	returns: nothing
*/

if (!isServer) exitWith{};
sleep 300 + random 300;
deleteVehicle (_this select 0);