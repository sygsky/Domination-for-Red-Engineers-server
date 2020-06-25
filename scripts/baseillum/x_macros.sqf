#define ADD_HIT_EH(AHEOBJ) AHEOBJ addEventHandler ["hit", {(_this select 0) setDamage 0}];
#define ADD_DAM_EH(ADEOBJ) ADEOBJ addEventHandler ["dammaged", {(_this select 0) setDamage 0}];

#define __compile_to_var call compile ((_this select 0) + "=(_this select 1)");

#define __isRacs if (d_own_side == "RACS") then {
#define __isWest if (d_own_side == "WEST") then {

#define __ReviveVer "REVIVE" in d_version
#define __AIVer "AI" in d_version
#define __CSLAVer "CSLA" in d_version
#define __ACEVer "ACE" in d_version
#define __MandoVer "MANDO" in d_version
#define __TTVer "TT" in d_version
#define __P85Ver "P85" in d_version
#define __RankedVer "RANKED" in d_version

#define __AddToExtraVec(ddvec) extra_mission_vehicle_remover_array set [count extra_mission_vehicle_remover_array, ddvec];

//#define __WaitForGroup waitUntil {sleep random 0.3;can_create_group};
#define __WaitForGroup while {!can_create_group} do {sleep 0.1 + random (0.2)};

//#define __WaitForPatrol waitUntil {sleep 0.321;can_add_patrol_group};
//#define __WaitForPatrol while {!can_add_patrol_group} do {sleep 0.1 + random (0.2)};

#define __GetEGrp(grpnamexx) grpnamexx = [d_enemy_side] call x_creategroup;

#define __TargetInfo _target_array2 = target_names select current_target_index;_current_target_name = _target_array2 select 1;

#define __addRemoveVehi(xvecx) xvecx addEventHandler ["killed", {_this spawn x_removevehi;}];

#define __addDead(xunitx) xunitx addEventHandler ["killed", {[_this select 0] call XAddDead;}];

// uncomment/comment for debug messages
//#define __DEBUG_NET(dscript,dmsg) if (isServer) then {hint localize format ['NET: %1: dmsg = %2', dscript,dmsg]} else {server globalChat format ['NET: %1: dmsg = %2', dscript,dmsg];hint localize format ['NET: %1: dmsg = %2', dscript,dmsg]};
#define __DEBUG_NET(dscript,dmsg)
//#define __DEBUG_SERVER(dscript,dmsg) if (isServer) then {hint localize format ['%1: dmsg = %2', dscript,dmsg]};
#define __DEBUG_SERVER(dscript,dmsg)
//#define __DEBUG_CLIENT(dscript,dmsg) if (X_Client) then {_dm = format ['%1: dmsg = %2', dscript,dmsg];player sideChat _dm;hint localize _dm;};
#define __DEBUG_CLIENT(dscript,dmsg)
#define __DEBUG_SYG(dscript,dmsg) hint localize (format['%1:msg: %2',dscript,dmsg]);
//#define __DEBUG_SYG(dscript,dmsg)

#define arg(x) (_this select(x))
#define argp(a,x) ((a)select(x))
#define argopt(num,val) if((count _this)<=(num))then{val}else{arg(num)}
#define argpopt(a,num,val) if((count a)<=(num))then{val}else{argp(a,num)}

#define DEBUG_MSG(msg) 	((msg)createVehicleLocal[0,0,0])

#define COMPUTER_ACTION_ID_NAME "GRU_comp_action_id"

#define __SetGVar(gvar_def,gvar_val)if(true)then{global_vars set[(gvar_def),(gvar_val)];publicVariable "global_vars";gvar_val}
#define __GetGVar(gvar_def)if(isNil "global_vars")then{objNull}else{argpopt(global_vars,gvar_def,objNull)}
#define __HasGVar(gvar_def)if(isNil "global_vars")then{false}else{(count global_vars)>(gvar_def)}
