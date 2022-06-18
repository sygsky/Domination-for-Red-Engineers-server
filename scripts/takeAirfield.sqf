//
// takeAirfield.sqf. By Sygsky at 13-JUL-2016 23:00. For first action in game - taking of airfield
//

#define __DEBUG__
//#define __FUTURE__

#define X_INC_BOUNDS 50
#define Y_INC_BOUNDS 50

SYG_takeAirfield = true;
publicVariable "SYG_takeAirfield";
_current_target_pos = d_base_array select 0;

#ifdef __FUTURE__

trigger_men_cnt  = -1;

update_target = false;

_dx = (d_base_array select 1) + X_INC_BOUNDS;
_dy = (d_base_array select 2) + Y_INC_BOUNDS;
check_trigger=createTrigger["EmptyDetector",_current_target_pos];
check_trigger setTriggerArea [_dx, _dy, 0, true];
check_trigger setTriggerActivation [d_enemy_side, "PRESENT", false];
//check_trigger setTriggerStatements["(""Man"" countType thislist >= d_man_count_for_target_clear) && (""Car"" countType thislist  >= d_car_count_for_target_clear)", "target_clear = false;update_target=true;[""take_airbase""] call XSendNetStartScriptClient;deleteVehicle check_trigger;", ""];
check_trigger setTriggerStatements["""Man"" countType thislist >= d_man_count_for_target_clear", "target_clear = false; update_target=true; trigger_men_cnt = count thislist; [""take_airbase""] call XSendNetStartScriptClient; deleteVehicle check_trigger;", ""];
//
// TODO: create 3-5 groups of infantry with some humwee
//
airbaseteam_W = [ "ACE_SoldierGCrew_IRAQ_ARMY","ACE_OfficerG_IRAQ_ARMY",
                     "ACE_SoldierG_B_WG","ACE_SoldierG_AT_WG","ACE_SoldierGAT_IRAQ_ARMY","ACE_SoldierGMAT_IRAQ_ARMY",
                     "ACE_SoldierGMiner_IRAQ_ARMY","ACE_OfficerG","ACE_SoldierGMedic_IRAQ_ARMY"];

airbaseteam_pilots_W = [ "ACE_SoldierGCrew", "ACE_SoldierGPilot", "ACE_SoldierGPilot_IRAQ_ARMY"];

sleep 1.01;
_cnt = 0;
{
    _side = "<undefined>";
    __WaitForGroup;
    _newgroup = [d_enemy_side] call x_creategroup;
    _type_unit_array = [_x, d_enemy_side] call x_getunitliste;
    _arr = + d_base_array; // [centre, a, b, angle]
   	_side_str = (switch (d_enemy_side) do {case "EAST": {"east"};case "WEST": {"west"};case "RACS": {"resistance"};case "CIV": {"civilian"};});

    _pos =  _arr call XfGetRanPointSquare;
    _maxcnt = 10;
    while {count _pos == 0 && _maxcnt > 0} do {
        _pos = _arr call XfGetRanPointSquare;
        sleep 0.04;
        _maxcnt = _maxcnt - 1;
    };
    if ( _maxcnt > 0) then {
        _units = [_pos, (_unit_array select 0), _newgroup] call x_makemgroup;
        sleep 2.045;
        _leader = leader _newgroup;
        _leader setRank "LIEUTENANT";
        _newgroup allowFleeing 0;
        _grp_array = [_newgroup, _pos, 0,d_base_array,[],-1,0,[],400,1];
        _grp_array execVM "x_scripts\x_groupsm.sqf";
        _cnt = _cnt + (count _units);
        if ( count _units > 0) then {_side = side _newgroup;};
        hint localize format[ "+++ takeAirfield.sqf: unit type list of ""%1"" %11, men %3, side %4 [%5:%6], d_base_arr %7, 1st unit side %8, group %9, pos %10, ",
            _x, count _type_unit_array, _units, side _newgroup, d_enemy_side, _side_str, _arr, _side, _newgroup, _pos, _type_unit_array ];
    } else {hint localize "--- scripts/takeAirfield.sqf: initial pos for group not created in 10 steps!!!"};
} forEach ["airteam1","airteam2"];

hint localize format["+++ takeAirfield.sqf: air base team (%1 men) created", _cnt];

while {!update_target} do {
    hint localize format["+++ takeAirfield.sqf: check_trigger list has %1 men ", count (list check_trigger) ];
    sleep 2.123;
};

hint localize format["+++ takeAirfield.sqf: check_trigger actvated on men count %1 ", trigger_men_cnt ];

current_trigger = createTrigger["EmptyDetector",_current_target_pos];
current_trigger setTriggerArea [_dx, _dy, 0, true];
current_trigger setTriggerActivation [d_enemy_side, "PRESENT", false];
//current_trigger setTriggerStatements["(""Car"" countType thislist <= d_car_count_for_target_clear) && (""Man"" countType thislist <= d_man_count_for_target_clear)", "xhandle = [-1] execVM ""x_scripts\x_target_clear.sqf"";execVM ""x_scripts\x_createnexttarget.sqf""", ""];
current_trigger setTriggerStatements["""Man"" countType thislist < d_man_count_for_target_clear", "xhandle = [-1] execVM ""x_scripts\x_target_clear.sqf"";execVM ""x_scripts\x_createnexttarget.sqf"";hint localize format[""+++ takeAirfield.sqf: Trigger 'Man' count %1"",""Man"" countType thislist]", ""];
// TODO: replace original action with special one


#else

hint localize "+++ takeAirfield.sqf: execVM x_scripts\x_createnexttarget.sqf";
xhandle = [-1] execVM "x_scripts\x_target_clear.sqf";
execVM "x_scripts\x_createnexttarget.sqf"
#endif
