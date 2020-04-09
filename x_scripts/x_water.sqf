// by Xeno, x_scripts\x_water.sqf - check player weapon in water and restore it if lost into WeaponHolder (by Arma engine)

#define HOLDER_SEARCH_RADIUS 20

private [/*"_hasWeapon",*/"_posASL","_wpArr","_wpArr","_p","_marker"]; // Do we need this operator? Not sure

hint localize "+++ x_water started!!!";

_removeWeaponHolders = {
    private ["_wpArr","_notNull"];
    if ( typeName _this != "ARRAY" ) exitWith {};
    if ( count _this <= 0 ) exitWith { /*hint localize "--- x_water.sqf._removeWeaponHolders: WeaponHolders array is []"; */};
    _wpArr = + _this;
    sleep (100 + (random 40));
    _notNull = false;
    { if ( !isNull _x ) then { deleteVehicle _x; _notNull = true;} } forEach _this;
    if ( _notNull ) then { playSound "losing_patience" };
//    hint localize format["+++ x_water.sqf._removeWeaponHolders: WeaponHolders (%1 pc.) from water  removed", count _this];
};

wp_weapon_array = [];
_marker = "";
_wpArr = []; // array for all weapon holders found near player at moment of lost
_swimAnimList = ["aswmpercmstpsnonwnondnon","aswmpercmstpsnonwnondnon_aswmpercmrunsnonwnondf","aswmpercmrunsnonwnondf_aswmpercmstpsnonwnondnon","aswmpercmrunsnonwnondf","aswmpercmsprsnonwnondf","aswmpercmwlksnonwnondf"];
while {true} do {

    // wait until we are swimming!!!
	waitUntil {sleep 2.412; (animationState player) in _swimAnimList};

    if ( (count _wpArr) > 0 ) then {
        {deleteVehicle _x} forEach _wpArr; _wpArr = [];
    }; // remove all found before weapon holders

	if ( alive player ) then {
//		wp_weapon_array = [ weapons player, magazines player ]; // We don't need now this item. If you lost weapons, why try to restore it?
//		_hasWeapon = false;
		if ( ( primaryWeapon player != "" ) || ( secondaryWeapon player != "" ) ) then {
//			_hasWeapon = true;
			while {
                ( ( primaryWeapon player != "" ) || ( secondaryWeapon player != "" ))
                && ( alive player )
                && (surfaceIsWater (getPos player))
            } do {sleep 0.621}; // wait until weapons is lost or player dead or out of water
			sleep 0.521;
    	    playSound "under_water_3"; // you lost your weapon
			// find ALL nearest weapon holders as Arma-1 createsmultiple weapon holders, that is surprize!
			_wpArr = nearestObjects [ player, ["WeaponHolder"], HOLDER_SEARCH_RADIUS ]; // It will find all holdear around #N meters in 2D and any depth (so say https://community.bistudio.com/wiki/nearestObject)
			if ( count _wpArr > 0 ) then {
//                hint localize format["+++ x_water.sqf: WeaponHolder[s] with your lost weapon found and remembered (%1 pc.)",count _wpArr];
                playSound "under_water_3";
                (localize "STR_SYS_620_0") call XfHQChat;
                "" spawn {sleep 5; (localize "STR_SYS_620_2") call XfHQChat;};
                _mname = format ["%1", _wpArr select 0];
                _marker = [_mname, getPos player,"ICON","ColorBlue",[0.5,0.5],format [localize "STR_SYS_620_3", round(((_wpArr select 0) modelToWorld [0,0,0]) select 2)],0,"Marker"] call XfCreateMarkerLocal; // "ammocrate", _marker is assigned in call of XfCreateMarkerGlobal function
			}
			else {
			    if (alive player && (surfaceIsWater (getPos player)) ) then {
    //			    hint localize "--- x_water.sqf:  WeaponHolder[s] not found";
                    sleep 4;
                    (localize "STR_SYS_620_1") call XfHQChat; playSound "losing_patience";
			    };
			};
		};
	};

	waitUntil { sleep 0.412; !( (surfaceIsWater (getPos player) ) && (alive player) ) }; // wait until out of water or dead

	if (alive player) then {
	    if ((count _wpArr) == 0) exitWith {};
        // make new position of the weapon holder with your lost weapon 10 meters ahead your current position
        {
            _pos = [ _x, player, 12 ] call SYG_elongate2;
            _x setPos _pos;
            sleep 0.1;
        } forEach _wpArr;
        ["msg_to_user", "", [["STR_SYS_620"]], 0,1,0,"good_news"] call SYG_msgToUserParser; // message output+sound
        _marker setMarkerPosLocal (getPos (_wpArr select 0));
        _marker setMarkerColorLocal "ColorRed";
	};
	if ( (count _wpArr) > 0 ) then { _wpArr spawn _removeWeaponHolders; _wpArr = [] };
	if (_marker != "") then { deleteMarker _marker; _marker = "" };
	if (!alive player) then {
	    waitUntil {alive player};
	};
	sleep 10.012;
};