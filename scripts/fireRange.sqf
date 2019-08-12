// fireRange.sqf: by sygsky, serve fire range targets. 06-NOV-2015
// XfGlobalChat

//
// call with input params:
// [_trg1, ... , trgN] execVM "scripts\fireRange.sqf";
//   or
// _target execVM "scripts\fireRange.sqf";
//


if (typeName _this != "ARRAY") then { _this = [_this];};

hint localize format["fireRange.sqf: %1 input params detected", count _this];

{
	//hint localize format["fireRange.sqf: addEventHandler to ""%1""", typeOf _x];

	if ( _x isKindOf "TargetEpopup" ) then
	{
		// Input params for "Hit" event
		// 0 unit: Object - Object the event handler is assigned to
		// 1 causedBy: Object - Object that caused the damage.  Contains the unit itself in case of collisions.
		// 2 damage: Scalar - Level of damage caused by the hit
		_x addEventHandler ["Hit", 
			{
				private ["_causedBy","_dist","_dmg"];
				_causedBy = _this select 1;
				_dist = "?";
				if (!isNull _causedBy) then
				{
					if (_causedBy != _this select 0) then
					{
						_dist = round(_causedBy distance (_this select 0));
					};
				};
				_dmg = (round((_this select 2) *1000))/10;
				(format[localize "STR_SYS_334", _dist, _dmg]) call XfHQChat; // "Dst %1, dmg %2"
			}
		]; 
	}
	else 
	{
		//hint localize format["fireRange.sqf: Error! Expected base type is ""TargetEpopup"", detected ""%1""", typeOf _x];
	};
} forEach _this;