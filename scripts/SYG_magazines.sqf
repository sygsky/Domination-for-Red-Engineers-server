// Syg: hint nearest man magazines information
private ["_lstobj", "_objlist", "_obj", "_cn", "_dn","_str","_magcnt","_lastmag"];

//hint "SYG_magazines.sqf started";

while { true} do {

	//waitUntil(alive player );

	_objlist = nearestObjects [ player, ["Man"],20];
	_obj = objNull;
	{
		if (_x != player) exitWith {
				_obj = _x;
		};
	} forEach _objlist;

	if (!(isNull _obj) && (_obj != _lstobj)) then {
		_lstobj = _obj;
		_cn = typeOf _obj;
		_dn = getText (configFile >> "CfgVehicles" >> typeof _obj >> "displayName");
		_str = "mags: ";
		_magcnt = 1;
		_lastmag = "";
		{
			if 	(_x != _lastmag ) then // add last one and count next
			{
				if ( _lastmag != "" ) then
				{
					_str= _str + _lastmag + format["(%1)\n",_magcnt];
				};
				_lastmag = _x;
				_magcnt = 1;
			}
			else
			{
				_magcnt = _magcnt + 1;
			};
		} forEach magazines _obj;
		
		if ( _lastmag == "" ) then
		{
			_str = "empty";
		}
		else
		{
			_str= _str+_lastmag+format["(%1)\n",_magcnt];
		};		
		
		hint format["Display Name: %1\nClass Name: %2\n%3",_dn,_cn,_str];
	};
	sleep 0.5;
};
hint "SYG_magazines: player isNull, exiting script";
localize "SYG_magazines: player isNull, exiting script";
