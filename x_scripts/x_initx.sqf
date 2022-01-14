// x_scripts\x_initx.sqf, by Xeno
private ["_search_array"];
if (!isServer) exitWith{};

x_inited = false;

dead_list = [];
groups_east = [];
groups_west = [];
groups_resistance = [];
groups_civilian = [];
can_create_group = true;

if (d_smoke) then {smoke_groups = [];};
can_add_patrol_group = true;
check_vec_list = [];

// arma can create a maximum of 144 groups per side
d_max_groups = 144;

if (isNil "d_lock_ai_armor") then {d_lock_ai_armor = false;};
if (isNil "d_lock_ai_car") then {d_lock_ai_car = false;};
if (isNil "d_lock_ai_air") then {d_lock_ai_air = false;};

if (isNil "x_funcs2_compiled") then {call compile preprocessFileLineNumbers "x_scripts\x_funcs\x_functions2.sqf";};
call compile preprocessFileLineNumbers "x_scripts\x_funcs\x_serverfuncs.sqf";
if (isNil "x_repall") then {call compile preprocessFileLineNumbers "x_scripts\x_funcs\x_commonfuncs.sqf"};
x_removevehi = compile preprocessFileLineNumbers "x_scripts\x_removevehi.sqf";
x_removevehiextra = compile preprocessFileLineNumbers "x_scripts\x_removevehiextra.sqf";
execVM "x_scripts\x_removedead.sqf";
//x_groupsm = compile preprocessFileLineNumbers "x_scripts\x_groupsm.sqf";
x_dosmoke = compile preprocessFileLineNumbers "x_scripts\x_dosmoke.sqf";
x_dosmoke2 = compile preprocessFileLineNumbers "x_scripts\x_dosmoke2.sqf";
SYG_eventOnDamage = compile preprocessFileLineNumbers "scripts\eventOnDamage.sqf";

execVM "x_scripts\x_checklocalvec.sqf";

if (count d_with_isledefense > 0) then {execVM "x_scripts\x_isledefense.sqf";};

x_inited = true;

if (true) exitWith {};