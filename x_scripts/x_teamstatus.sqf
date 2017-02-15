// by Xeno
if (!XClient) exitWith {};

if (vehicle player == player) then {
	[player, player, 0, ["Page", "Team"],"HideOpposition","HideVehicle","DeleteRemovedAI"] execVM "scripts\TeamStatusDialog\TeamStatusDialog.sqf";
} else {
	_ts_vehicle = vehicle player;
	[player, player, 0, ["Page", "Vehicle"],["VehicleObject", _ts_vehicle],"HideTeam","HideGroup","HideOpposition","DeleteRemovedAI"] execVM "Scripts\TeamStatusDialog\TeamStatusDialog.sqf";
};

if (true) exitWith {};
