/*
	author: Sygsky

	description:
	    try to restore destroyed barracks (AI_HUT), Barrack must exists and be destroyed by ordinal activity of Arma (RPG, heli crash etc)
	    Parameters array passed to the script upon activation in _this variable is: [target, caller, ID, arguments]
        target (_this select 0): Object - the object which the action is assigned to
        caller (_this select 1): Object - the unit that activated the action
        ID (_this select 2): Number - ID of the activated action (same as ID returned by addAction)
        arguments (_this select 3): Anything - arguments given to the script if you are using the extended syntax

	returns: nothing
*/


// check for the AI_HUT to be alive
if (isNil "AI_HUT") exitWith {hint localize "--- restore_barracks.sqf: no AI_HUT detected"}; // no hut
if ( damage AI_HUT == 0) exitWith{}; // All is well
if (damage AI_HUT < 1 ) exitWith { hint localize format["--- restore_barracks.sqf: AI_HUT repaired damage %1",damage AI_HUT]; AI_HUT setDamage 0;};

// AI_HUT is destroyed (damage 1), lets restore it
_ruin = pos_ nearestObject "Land_budova2_ruins"; // ruins name for Barracks
if ( isNull _ruin) then
{
    hint localize "--- restore_barracks.sqf: try to repair, but no land_budova2_ruin found near";
}
else
{
    deleteVehicle _ruin;
    sleep 0.5;
};

// TODO: remove events and delete AI_HUT, create new one and assign the same envirinment as for previous AI_HUT

// 1. try to delete old building, hidden far under the ground
{ AI_HUT removeAction _x } forEach [0,1,2]; // just in case

AI_HUT removeAllEventHandlers "hit";
AI_HUT removeAllEventHandlers "damage";
deleteVehicle AI_HUT;
sleep 0.1;

if ( isNull AI_HUT ) then { hint localize "+++ restore_barracks.sqf: Hidden AI_HUT deleted!";}
else {hint localize  "--- restore_barracks.sqf: Unable to delete hiddden AI_HUT";};

AI_HUT = "WarfareBBarracks" createVehicle (d_pos_ai_hut select 0);
AI_HUT setDir (d_pos_ai_hut select 1);
AI_HUT setPos (d_pos_ai_hut select 0);
AI_HUT addEventHandler ["hit", {(_this select 0) setDamage 0}];
AI_HUT addEventHandler ["damage", {(_this select 0) setDamage 0}];
publicVariable "AI_HUT";

if ( !isNull AI_HUT ) then { hint localize "--- restore_barracks.sqf: AI_HUT restored";}
else { hint localize  "--- restore_barracks.sqf: unable  to restore AI_HUT"; };

publicVariable "AI_HUT";

["say_sound", AI_HUT, "fanfare"] call XSendNetStartScriptServer;

sleep 0.1;

