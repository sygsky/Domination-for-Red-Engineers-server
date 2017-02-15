// by Xeno
private ["_m_name"];

player playMove "AinvPknlMstpSlayWrflDnon_medic";
sleep 3;
WaitUntil {animationState player != "AinvPknlMstpSlayWrflDnon_medic"};
if (!(alive player)) exitWith {
	"Скончался раньше чем удалил мед.палатку..." call XfGlobalChat;
};

deleteVehicle medic_tent;

"Mash removed." call XfGlobalChat;
d_medtent = [];
_m_name = format ["мед.палатка %1", player];
deleteMarker _m_name;

if (true) exitWith {};
