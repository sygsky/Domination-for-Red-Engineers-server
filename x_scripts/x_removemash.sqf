// x_scripts/x_removemash.sqf: by Xeno
private ["_m_name"];

player playMove "AinvPknlMstpSlayWrflDnon_medic";
sleep 3;
WaitUntil {animationState player != "AinvPknlMstpSlayWrflDnon_medic"};
if (!(alive player)) exitWith {
	(localize "STR_MED_3_1") call XfGlobalChat; // "You died before your MASH was deleted..."
};

deleteVehicle medic_tent;

(localize "STR_MED_4_1") call XfGlobalChat; // "MASH deleted."
d_medtent = [];
_m_name = format [localize "STR_MED_5", player]; // "Mash %1"
deleteMarker _m_name;

if (true) exitWith {};
