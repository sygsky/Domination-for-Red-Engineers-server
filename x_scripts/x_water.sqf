// by Xeno, x_scripts\x_water.sqf - check player weapon in water and restore it if lost into WeaponHolder (by Arma engine)

#define HOLDER_SEARCH_RADIUS 20

private [/*"_hasWeapon",*/"_posASL","_wpArr","_wpArr","_p"]; // Do we need this operator? Not sure

hint localize "+++ x_water started!!!";

_removeWeaponHolders = {
    if ( typeName _this != "ARRAY" ) exitWith {};
    if ( count _this <= 0 ) exitWith { /*hint localize "--- x_water.sqf._removeWeaponHolders: WeaponHolders array is []"; */};
    sleep (100 + (random 40));
    { if (typeOf _x == "WeaponHolder" ) then {deleteVehicle _x;}; } forEach _this;
//    hint localize format["+++ x_water.sqf._removeWeaponHolders: WeaponHolders (%1 pc.) from water  removed", count _this];
};

wp_weapon_array = [];

_wpArr = []; // array for all weapon holders found near player at moment of lost
_swimAnimList = ["aswmpercmstpsnonwnondnon","aswmpercmstpsnonwnondnon_aswmpercmrunsnonwnondf","aswmpercmrunsnonwnondf_aswmpercmstpsnonwnondnon","aswmpercmrunsnonwnondf","aswmpercmsprsnonwnondf","aswmpercmwlksnonwnondf"];
while {true} do {

    // wait until we are swimming!!!
	waitUntil {sleep 2.412; (animationState player) in _swimAnimList};

    if ( (count _wpArr) > 0 ) then {
        {deleteVehicle _x} forEach _wpArr; _wpArr = [];
        playSound "losing_patience";
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
            } do {sleep 0.621}; // wiat until weapons is lost
			sleep 0.521;
    	    playSound "under_water_3"; // you lost your weapon
			// find ALL nearest weapon holders as Arma-1 createsmultiple weapon holders, that is surprize!
			_wpArr = nearestObjects [ player, ["WeaponHolder"], HOLDER_SEARCH_RADIUS ]; // if you are at see with  depth at this point > 100 m it will not word
			if ( count _wpArr > 0 ) then {
//                hint localize format["+++ x_water.sqf: WeaponHolder[s] with your lost weapon found and remembered (%1 pc.)",count _wpArr];
                (localize "STR_SYS_620_0") call XfHQChat;
			}
			else {
//			    hint localize "--- x_water.sqf:  WeaponHolder[s] not found";
			    sleep 4;
			    (localize "STR_SYS_620_1") call XfHQChat; playSound "losing_patience";
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
/*
        if ( !( surfaceIsWater (getPos _wpArr) ) ) then // show message
        {
            ["msg_to_user", "", [["STR_SYS_620"]], 0,1,0,"good_news"] call SYG_msgToUserParser; // message output+sound
        }
        else {(localize "STR_SYS_620_1") call XfHQChat; playSound "losing_patience"};
    if (_hasWeapon) then {
        _p = player;
        removeAllWeapons _p;
        {_p addMagazine _x;} forEach (wp_weapon_array select 1);
        {_p addWeapon _x;} forEach (wp_weapon_array select 0);
        _primw = primaryWeapon _p;
        if (_primw != "") then {
            _p selectWeapon _primw;
            _muzzles = getArray(configFile>>"cfgWeapons" >> _primw >> "muzzles");
            _p selectWeapon (_muzzles select 0);
        };
        wp_weapon_array = [];
        hint localize "+++ x_water.sqf: player weapon restored after loadfall";
    };
*/
	};
	if ( (count _wpArr) > 0 ) then { _wpArr spawn _removeWeaponHolders; _wpArr = [] };
	if (!alive player) then {
	    waitUntil {alive player};
	    if (count wp_weapon_array > 0) then {
	        sleep 2.432;
	        wp_weapon_array = [];
	    };
	};
	sleep 10.012;
};