/*
	author: Sygsky
	description: all subroutines may be inserted here
	returns: nothing
*/

waitUntil { !isNil "f_ChuteSteer" }; // wait ACE internal initialization
hint localize "<<< SYG version of scripts\ACE\ace_sys_eject.sqf procedures installed >>>";

// LOOPED STEERING FUNCTION, 100 times per second
f_ChuteSteer = {
hint localize "<<< SYG version of f_ChuteSteer procedure run >>>";
	_Hdg = getDir _chute;

	_Bank = 0; // DESIRED bank index factor (keys A,D,Left,Right will change this)
	_NewBank = 0; // ACTUAL bank the chute will be set to. This "follows" _Bank as best it can with a delay, for smoother turns :D

	_Pitch = 0;
	_NewPitch = 0;

	_Speed = 1; // basic velocity magnitude, caused by pitching forwards
	_Drop = -3 - (_weight/25); // basic descent speed, to be modified later -> -3 for ~80 kg? therefore drop = weight / 25
	_badLand = false; // rough landing, i.e. hitting a tree, player will drop to the ground in a gentler manner

	_Fwd = 6; // start parachute with some flight speed
	_Descent = 0.333 * ((velocity vehicle player) select 2); // start parachute with some downwards speed

	_DsdFwd = 12;
	_DsdDescent = -10;

	ACEChute_Steer = "CENTER";
	ACEChute_Pitch = "CENTER";

	while {(player getVariable "ChuteOpen") == 1} do {	//double loop in case players drop from REALLY high and break ArmA's 10,000 iteration limit of WHILE command
		while {(player getVariable "ChuteOpen") == 1} do {
			if (ACEChute_Unconcious) then {
				_Bank = (_Bank * 0.99); // Slowly bring the desired bank back to zero, when keys are released
				_Pitch = (_Pitch * 0.99);
			} else {
				switch (ACEChute_Steer) do {
					case "CENTER": {
						_Bank = (_Bank * 0.99); // Slowly bring the desired bank back to zero, when keys are released
					};
					case "LEFT":
					{
						if ((Abs _Bank) < 1) then {_Bank = _Bank - 0.0175;}; // Slowly move desired bank left. MAX value of -1 or +1
					};
					case "RIGHT":
					{
						if ((Abs _Bank) < 1) then {_Bank = _Bank + 0.0175;}; // Slowly move desired bank right. MAX value of -1 or +1
					};
				};
				switch (ACEChute_Pitch) do
				{
					case "CENTER":
					{
						_Pitch = (_Pitch -0.2) * 0.99 + 0.2; // Center-pitch is offset to ~20-30% brakes
					};
					case "FORWARD":
					{
						if ((_Pitch) > -0.1) exitWith {_Pitch = _Pitch - 0.01 };// apply less brakes
						_Pitch = -0.1;
					};
					case "BACK":
					{
						if ((_Pitch) < 1) exitWith { _Pitch = _Pitch + 0.01 }; // apply more brakes
						_Pitch = 1;
					};
				};
			};

			// Convert the index factor into a number of degrees
			_BAngle = 20 * _Bank;
			_NewBank = _NewBank + 0.015*(_BAngle - _NewBank);
			_Hdg = _Hdg + 0.0625*_NewBank;

			_HdgX = sin(_Hdg); // WHEN you are heading 0, this is MINIMUM
			_HdgY = cos(_Hdg); // when you are heading 0, this is MAXIMUM

			_NY = sin(_NewBank);
			_NZ = cos(_NewBank);

			_PAngle = 20 * _Pitch;
			_NewPitch = _NewPitch + 0.05*((_PAngle - 6) - _NewPitch); // A six-degree nosedown attitude is induced

			_DsdFwd = _Speed - 1.75*(_NewPitch);
			if (_DsdFwd < 1) then {_DsdFwd = 1;};
			_DsdDescent = _Drop + 0.5*(_NewPitch) - 1.75*abs(_Bank);

			_Fwd = _Fwd + 0.008*(_DsdFwd - _Fwd);

			if (_Fwd < 4 && !_badLand) then {_DsdDescent = _DsdDescent - 2.25*(5 - _Fwd);};

			_Descent = _Descent + 0.025*(_DsdDescent - _Descent);

			_sinP = sin(_NewPitch);

			_Chute setVectorUp [_HdgY * _NY - _HdgX * _sinP, -_HdgX * _NY - _HdgY * _sinP, _NZ];
			_Chute setVectorDir [_HdgX,_HdgY,1];

			// Tree or building impact detection:
			// if player is injured during the last 10m of the fall, slow down descent rate so they don't keep being setVelocity'd into the object and die. Problem: player who is SHOT in this period, will land very weirdly. Still seeking solution to this!
			if ((_NewDam - _OldDam > 0.0001) && (position (vehicle player) select 2 < 10) && !_badLand) then {_badLand = true;};
			if (_badLand) then {_Descent = -2.5;_Fwd = 1;};

			_Chute setVelocity [_Fwd*_HdgX,_Fwd*_HdgY,_Descent];
			_spd = (velocity _chute select 2);

			// Set colors for hint-dialog:
			if (_Fwd < 6.5) then {
				if (_Fwd < 3.5) exitWith { _Col1 = _text_grn; };
				if (_Fwd < 4.5) exitWith { _Col1 = _text_yel; };
				_Col1 = _text_ora;
			} else { _Col1 = _text_red; };


			if (_Descent < -5.5) then {
				if (_Descent < -9.5) exitWith { _Col2 = _text_red;};
				if (_Descent < -8) exitWith { _Col2 = _text_ora; };
				_Col2 = _text_yel;
			} else { _Col2 = _text_grn };

			//Calculate brakes percentage for hint dialog:
			_Br = 10*round(10*(_NewPitch + 8)/22);

			hint parseText ((localize "STR_AAHALO_0") + _lineBreak +
			str(10*round((getpos player select 2)/10)) + _lineBreak +
			//_lineBreak +
			(localize "STR_AAHALO_1") + _lineBreak +
			str(round(0.2*(Direction vehicle player))*5) + (localize "STR_AAHALO_2") + ([Direction vehicle player, 8, false] call SPON_directionName) + _lineBreak +
			//_lineBreak +
			(localize "STR_AAHALO_3") + _lineBreak +
			_Col1 + str(round(_Fwd)) + (localize "STR_AAHALO_4") + _text_normal + _lineBreak +
			//_lineBreak +
			(localize "STR_AAHALO_5") + _lineBreak +
			_Col2 + str(-round(_Descent)) + (localize "STR_AAHALO_4") + _text_normal + _lineBreak +
			//_lineBreak +
			(localize "STR_AAHALO_6") + _lineBreak +
			str(_Br) + " %");

			// if player is low, end control and goto chuteDelete!
			if ((position (vehicle player) select 2) < 1) exitWith {_chute setVelocity [0,0, -1];player setVariable ["ChuteOpen", 3];};

			_OldDam = Damage Player;

			sleep 0.01;

			_NewDam = Damage Player;

		};
		sleep 0.01;
	};
};

// Player lands successfully!
f_ChuteDelete = {
	hint localize "<<< SYG version of f_ChuteDelete procedure run >>>";

	hint "";
	player removeWeapon "ACE_ParachutePack";
	player setVariable ["ChuteOpen", 0];
	_V1 = VectorDir _chute;
	_V2 = VectorUp _chute;
	_V3 = getpos _chute;
	deleteVehicle _chute;
	player setVelocity [0,0,0];
	_Offset = [0,0,0];
	_worldPos = player modelToWorld _Offset;
	_worldPos set [2, (_worldPos select 2) - 2.4];
	player setPos _worldPos;
	if !(surfaceIsWater (position vehicle player)) then {
		player switchmove "SprintCivilBaseDf";
		player setVehicleInit "this say [""ParaLand"", 50, 1]";
		if (_spd < (-9.5-random 1)) then {
			player switchmove "AmovPercMsprSnonWnonDf_AmovPpneMstpSnonWnonDnon";
			player setDamage (getDammage player + 0.3);
			if (!isNil "ACE_Sys_Wound_HitEH") then { [player, "", .76] call ACE_Sys_Wound_HitEH };
		} else {
			if (_spd < (-6 - random 1)) then {
				player switchmove "AmovPercMsprSnonWnonDf_AmovPpneMstpSnonWnonDnon";
				player setDamage (getDammage player + 0.25);
			} else {
				if (_spd < -3) then {
					player switchmove "AmovPercMsprSnonWnonDf_AmovPpneMstpSnonWnonDnon";
				} else {
					player switchmove "SprintCivilBaseDf";
					sleep 2;
					player switchmove "AmovPercMevaSnonWnonDfl";
				};
			};
		};
	} else {
		player setVehicleInit "this say [""ParaLandinWater"", 50, 1]";
	};
	processInitCommands;
};

// Player cuts his chute!
f_CutChute =
{
	hint localize "<<< SYG version of f_CutChute procedure run >>>";
	deleteVehicle _chute;
//	player setVelocity [0,0,0];
	if ((getpos Player select 2) > 20) then {
		[player] execVM "\ace_sys_eject\s\ace_jumpOut_cord.sqf";
		waitUntil { player getVariable "ChuteOpen" == 0 };
		player setVariable ["ChuteOpen", 4]; // "reserve" status
	} else {
		waitUntil {(getPos player select 2) < 2};
		_vel = velocity player;
		player setVelocity [(_vel select 0),(_vel select 1),(_vel select 2)/1.5];
	};
};
