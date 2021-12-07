/*
    scripts\healAnimDone.sqf, note this script is not used anymore
	author: Sygsky, by task #197
	description:
        2.2 AnimDone
        Trigerred everytime an animation is finished.
            Unknown MP behaviour. Probably local.
            Passed array: [unit, anim]
                unit: Object - Object the event handler is assigned to
                anim: String - Name of the anim that has been finished
	returns: nothing
*/
if ( ( _this select 1 ) in ["AinvPknlMstpSnonWnonDnon_medic_1" ])  then { // You healed somebody
    if ( SYG_lastAnimationType != _this select 1 ) exitWith {false};

    // healing started before and now completed
    private ["_str", "_nearestbase", "_nearmanList", "_points"];
    _nearestbase = (
        switch (d_own_side) do {
            case "WEST": {"SoldierWB"};
            case "EAST": {"SoldierEB"};
            case "RACS": {"SoldierGB"};
        }
    );
    // search nearest unconscious man nearby
    _nearmanList = nearestObjects [player, [_nearestbase], 3];

    if (count _nearmanList <= 0) exitWith { false };

    _friend_healed = false;
    {
        if ( ( alive _x ) && ( _x != player ) && ( isPlayer _x ) && (damage _x > 0.05) && (side _x == side player)) exitWith {
            // add score, send information
            _points = d_ranked_a select 7;
            (format [localize "STR_MED_8", _points, name _x, damage _x ] ) call XfHQChat; // "You get +%1 points for healing %2!"
            //player addScore _points;
            _points call SYG_addBonusScore;
            ["say_sound", _x, "healing"] call XSendNetStartScriptClientAll;
            _friend_healed = true;
        };
    } forEach _nearmanList;
    if (!_friend_healed) then { // may be some enemy healed?
        {
            if ( ( alive _x ) && (side _x == d_side_enemy)) exitWith {
                sleep 0.1;
                if (damage _x == 0) then { // player healed enemy, the enemy is surprised
                    ["say_sound", _x, call SYG_exclamationSound] call XSendNetStartScriptClientAll;
                };
            };
        } forEach _nearmanList;
    };
};
// TODO: animDone: AmovPpneMstpSrasWrflDnon_healed - healed at medic when laying
// TODO: animDone: AinvPknlMstpSlayWrflDnon_healed2 - healed by medic when staying
// TODO: animDone: AinvPknlMstpSlayWrflDnon_healed - healed in mash
