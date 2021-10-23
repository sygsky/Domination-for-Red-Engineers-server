#include "x_setup.sqf"
#include "x_macros.sqf"

XHandleNetVar = {
	private ["_this"];
	__DEBUG_NET("x_netinit.sqf XHandleNetVar",_this)
	__compile_to_var
};

XSendNetVarAll = {
	private ["_this"];
	__DEBUG_NET("x_netinit.sqf XSendNetVarAll",_this)
	d_nv_all = _this;publicVariable "d_nv_all";
};

"d_nv_all" addPublicVariableEventHandler {
	(_this select 1) call XHandleNetVar;
};

///////////////////////////////////

XHandleNetStartScriptAll = {
	private ["_this"];
	__DEBUG_NET("x_netinit.sqf XHandleNetStartScriptAll",_this)
	switch (_this select 0) do {
		case "rep_array": {
#ifdef __LIMITED_REFUELING__
			(_this select 1) spawn x_repall;
#else
			[(_this select 1) select 0] spawn x_repall;
#endif			
		};
		// deletes ruins nearest to the designated position
		case "d_del_ruin": {
			_ruin = nearestObject [(_this select 1), "Ruins"];
			if (!isNull _ruin) then {deleteVehicle _ruin};
		};
		case "d_ammo_load": {
			(_this select 1) setVariable ["d_ammobox", (_this select 2)];
			ammo_boxes = ammo_boxes + 1;
		};
		case "d_ammo_vec": {
			(_this select 1) setVariable ["d_ammobox", (_this select 2)];
			(_this select 1) setVariable ["d_ammobox_next", (_this select 3)];
		};
		case "d_say": {
			(_this select 1) say (_this select 2);
		};
	};
};

XSendNetStartScriptAll = {
	private ["_this"];
	__DEBUG_NET("x_netinit.sqf XSendNetStartScriptAll",_this)
	d_ns_all = _this;publicVariable "d_ns_all";
	if (X_SPE) then {_this spawn XHandleNetStartScriptAll};
};

"d_ns_all" addPublicVariableEventHandler {
	(_this select 1) spawn XHandleNetStartScriptAll;
};

/////////////////////////////////// received on server and client simutaneously with the same command name but processed by different code

XHandleNetStartScriptAllDiff = {
	private ["_this"];
	__DEBUG_NET("x_netinit.sqf XHandleNetStartScriptAllDiff",_this)
	switch (_this select 0) do {
		case "d_create_box";
		case "d_rem_box";
		case "mr1_in_air";
		case "mr2_in_air": {if (isServer) then {_this spawn XHandleNetStartScriptServer} else {_this spawn XHandleNetStartScriptClient};};
		#ifdef __TT__
		case "mrr1_in_air";
		case "mrr2_in_air": {if (isServer) then {_this spawn XHandleNetStartScriptServer} else {_this spawn XHandleNetStartScriptClient};};
		#endif
	};
};

XSendNetStartScriptAllDiff = {
	private ["_this"];
	__DEBUG_NET("x_netinit.sqf XSendNetStartScriptAllDiff",_this)
	d_ns_alld = _this;publicVariable "d_ns_alld";
	if (X_SPE) then {_this spawn XHandleNetStartScriptAllDiff};
};

 "d_ns_alld" addPublicVariableEventHandler {
	(_this select 1) spawn XHandleNetStartScriptAllDiff;
};

///////////////////////////////////

XSendNetStartScriptServer = {
	private ["_this"];
	__DEBUG_NET("x_netinit.sqf XSendNetStartScriptServer",_this)
	d_ns_serv = _this;publicVariable "d_ns_serv";
	if (X_SPE) then {_this spawn XHandleNetStartScriptServer}; // if Server on Player is Executed (not dedicated)
};

XSendNetVarServer = {
	private ["_this"];
	__DEBUG_NET("x_netinit.sqf XSendNetVarServer",_this)
	d_nv_serv = _this;publicVariable "d_nv_serv";
};

///////////////////////////////////

XSendNetStartScriptClient = {
	private ["_this"];
	__DEBUG_NET("x_netinit.sqf XSendNetStartScriptClient",_this)
	d_ns_client = _this;publicVariable "d_ns_client";
	if (X_SPE) then {_this spawn XHandleNetStartScriptClient}; // if Server on Player is Executed (not dedicated)
};

// To ensure all clients receive this message
XSendNetStartScriptClientAll = {
	private ["_this"];
	__DEBUG_NET("x_netinit.sqf XSendNetStartScriptClientAll",_this)
	d_ns_client = _this; publicVariable "d_ns_client";
	if (X_Client) then {_this spawn XHandleNetStartScriptClient}; // if sent from client, it should receive it too
};

XSendNetVarClient = {
	private ["_this"];
	__DEBUG_NET("x_netinit.sqf XSendNetVarClient",_this)
	d_nv_client = _this;publicVariable "d_nv_client";
};
