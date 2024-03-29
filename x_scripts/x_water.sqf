// by Xeno, x_scripts\x_water.sqf - check player weapon in water and restore it if lost into WeaponHolder (by Arma engine)

#define HOLDER_SEARCH_RADIUS 50

private ["_posASL","_wpArr","_p","_marker"]; // Do we need this operator? Not sure

hint localize "+++ x_water.sqf started!!!";

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
	waitUntil {sleep 4.412; (animationState player) in _swimAnimList};

    if ( (count _wpArr) > 0 ) then {
        {deleteVehicle _x} forEach _wpArr; _wpArr = [];
    }; // remove all found before weapon holders

	if ( alive player ) then {
		if ( ( primaryWeapon player != "" ) || ( secondaryWeapon player != "" ) ) then {
			while {
                ( ( primaryWeapon player != "" ) || ( secondaryWeapon player != "" ))
                && ( alive player )
                && (surfaceIsWater (getPos player))
            } do {sleep 0.621}; // wait until weapons is lost or player dead or out of water
			sleep 0.521;
			_sound = "under_water_3"; // you lost your weapon
			// find ALL nearest weapon holders as Arma-1 may create multiple weapon holders, that is surprize!
			_wpArr = player nearObjects [ "WeaponHolder", HOLDER_SEARCH_RADIUS ]; // It will find all holders around < 50 meters at depth <= 5D meters at point directly beneath  the point

			if ( count _wpArr > 0 ) then {
				for "_i" from 0 to count _wpArr - 1 do {
					_wp = _wpArr select _i;
					if ( [_wp, player] call SYG_distance2D > 20 ) then { _wpArr set [_i, "RM_ME"]};
				};
				_wpArr call SYG_clearArray;
			};
			if ( count _wpArr > 0 ) then {
//                hint localize format["+++ x_water.sqf: WeaponHolder[s] with your lost weapon found and remembered (%1 pc.)",count _wpArr];
				if (alive player) then {
					(localize "STR_SYS_620_0") call XfHQChat; // "Some weapon drowned, if it's mine, I'll find it on the shore. Otherwise..."
					"" spawn {sleep 5; (localize "STR_SYS_620_2") call XfHQChat;}; // "I just need to get out on a gentle Bank, so I'll find it faster..."
					_mname = format ["%1", _wpArr select 0];
					// "depth %1 m."
					_marker = [_mname, getPos player,"ICON","ColorBlue",[0.5,0.5],format [localize "STR_SYS_620_3", round(((_wpArr select 0) modelToWorld [0,0,0]) select 2)],0,"Marker"] call XfCreateMarkerLocal; // "ammocrate", _marker is assigned in call of XfCreateMarkerGlobal function
                };
			} else {
			    if (alive player && surfaceIsWater (getPos player) && ( primaryWeapon player == "" ) && ( secondaryWeapon player == "" )) then {
    			    hint localize "--- x_water.sqf:  Weapon lost but WeaponHolder[s] not found";
                    sleep 4;
                    (localize "STR_SYS_620_1") call XfHQChat; // You drowned your weapons foreve-e-e-er
	                _sound = "losing_patience"; // you lost weapon forever
			    };
			};
			if ( _sound != "" ) then { playSound _sound };
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
        // "Here it is - lying on the shore! If I collect it in 2 minutes, the waves will not carry it away!"
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