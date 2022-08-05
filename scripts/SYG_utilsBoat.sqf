private [ "_unit", "_dist", "_lastPos", "_curPos", "_boat", "_grp", "_wplist","_startPos", "_procWP", "_wpIndex", "_unittype", "_stopBoat" ];

if ( !isNil "boat_trip_is_in_progress" )exitWith { hint "SYG_utilsBoat already initialized"};
hint "INIT of SYG_utilsBoat";

#define BOAT_CHECK_PERIOD 5.0

_startPos = position cone1; // initial position to create boat
_center = position centerPos; // center of land to use for searching coast direction
boat_trip_is_in_progress = false;


// process waypoints
// call as: [_wp, _wplist, _boat] call procWP
// _wp
// _wplist
// _boat
procWP = {
	boat_trip_is_in_progress = true;
	private ["_wp", "_wplist", "_boat", "_wpPos", "_cupPos", "_lastPos"];
	_wp = _this select 0;
	_wplist = _this select 1;
	_boat = _this select 2;

	hint localize format[ "procWP: wp1=[%1], %2 WPs]", _wp, count _wplist];
	
	player globalChat format["procWP, %1 WPs", count _wplist];

	for "_wpIndex" from 0 to ((count _wplist) - 1) do {
		_wpPos = _wplist select _wpIndex; // next way point position
		hint localize format[ "WP %1, dist %2", _wpIndex, _boat distance _wpPos ];
		_wp setWaypointPosition [ _wpPos, 0 ];
		_wp setWaypointBehaviour "STEALTH";
		_wp setWaypointCombatMode "WHITE";
		_wp setWaypointType "HOLD";
		_wp setWaypointSpeed "FULL";
		_lastPos = position _boat; // original position 
		while { !stopBoat } do {
			sleep BOAT_CHECK_PERIOD;
			player globalChat format["procWP:sleeped %1 sec", BOAT_CHECK_PERIOD];
			_cupPos = position _boat;
			if ( ( (_curPos distance _lastPos) < 3) or (!( canMove _boat)) or (!( alive driver _boat)) ) exitWith { stopBoat = true;};
			if ( (_curPos distance _wpPos)  < 30 ) exitWith { hint "WP reached"}; // move to next point
			_lastPos = _curPos;
		};
		if ( stopBoat ) exitWith {	hint "Boat script stopped"};
	};
	boat_trip_is_in_progress = false;
};

// start boat movement
startBoat = {
	if ( boat_trip_is_in_progress ) exitWith {hint "startBoat: already in progress, exit"};
	private ["_wplist", "_boat", "_wp"];
	_wplist = []; // waypoints
	{
		_wplist set [count _wplist, position _x];
	} forEach [pnt1, pnt2, pnt3, pnt4, pnt5, cone1];
	stopBoat = false;
	_boat = _this;
	player globalChat format[ "startBoat: boat is %1, WPs[%2]", typeOf _boat, count _wplist ];
	_grp = group driver _boat;
	_grp setCombatMode "WHITE"; // shooting only if detected
	_wp = _grp addWaypoint [position cone1, 0 ];
	_wp setWaypointStatements ["never", ""];
	player globalChat format["startBoat: 1st WP (%1) added with dist = %2", waypointPosition _wp,  (waypointPosition _wp) distance _boat];
	sleep 1;
	boat_trip_is_in_progress = false;
	[ _wp, _wplist, _this ] spawn procWP;
};

// stop boat movement
_stop = {
	stopBoat = true;
};

_boat = createVehicle  ["RHIB", _startPos, [], 0, "FORM"];
_unittype = "ACE_SoldierWB_A";

// create boat teamMember
_grp = [west] call x_creategroup;
_grp = [_boat, _grp, _unittype] call SYG_populateVehicle;
(leader _grp) setRank "LIEUTENANT";

// process waypoints

player globalChat format["%1 is populated with crew of %2 man", typeOf _boat, count units _grp];

//boatID = player addAction ["Start boat", "startBoat.sqf", nil, 0, true, true];
boatID = _boat  addAction ["Start boat trip", "startBoat.sqf", [_boat], 0, true, true];

if ( true ) exitWith {};