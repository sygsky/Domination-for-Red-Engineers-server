// by Xeno
private ["_m_name"];

if (vehicle player == mg_nest) exitWith {
	"Перед свёртыванием пулемётного гнезда вы должны выйти из него..." call XfGlobalChat;
};

player playMove "AinvPknlMstpSlayWrflDnon_medic";
sleep 3;
WaitUntil {animationState player != "AinvPknlMstpSlayWrflDnon_medic"};
if (!(alive player)) exitWith {
	"Скончался раньше чем удалил пулемётное гнездо..." call XfGlobalChat;
};

deleteVehicle mg_nest;

"Пулемётное гнездо убрано." call XfGlobalChat;
d_mgnest_pos = [];
_m_name = format ["Пулемётное гнездо %1", player];
deleteMarker _m_name;

if (true) exitWith {};
