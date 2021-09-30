// by Xeno x_scripts\x_endcam.sqf, outro playing
private ["_camera"];

#include "x_setup.sqf"

showCinemaBorder false;
_dlg = createDialog "X_RscAnimatedLetters";
_line = 0;
i = 0;
playMusic "farewell_slavs"; // "ATrack8";
_display = findDisplay 11098;
_control = _display displayCtrl 101113;

_camera = "camera" camCreate position player;
_camera cameraEffect ["External","back"];

_camera camSetTarget position player;
_camera camSetRelPos [2.71,19.55,3.94];
_camera camSetFOV 1;
_camera camCommit 0.0;
waitUntil {camCommitted _camera};
[] spawn {
	if (vehicle player != player) then {
		_vec = vehicle player;
		if (_vec isKindOf "Air") then {
			_posp = position player;
			_is_driver = (if (driver _vec == player) then {true} else {false});
			player action["EJECT",_vec];
			waitUntil {vehicle player == player};
			player setPos [_posp select 0, _posp select 1, 0];
			player setVelocity [0,0,0];
			if (_is_driver) then {
				_vec spawn {
					private ["_vec"];
					_vec = _this;
					waitUntil {count crew _vec == 0};
					deleteVehicle _vec;
				};
			};
		};
	};
};

_camera camSetRelPos [80.80,120.29,633.07];
_camera camCommit 20;
#ifndef __TT__
[5, localize "STR_SYS_100" /* "CONGRATULATIONS" */, 2] execVM "IntroAnim\animateLettersX.sqf";_line = _line + 1; waitUntil {i == _line};
sleep 5;
[0, localize "STR_SYS_101" /* "Вы очистили остров от врага..." */, 4] execVM "IntroAnim\animateLettersX.sqf";_line = _line + 1; waitUntil {i == _line};
#endif
#ifdef __TT__
_str = "";
_str2 = "";
if (points_west > points_racs) then {
	_str = "Winner: The US Team";
	_str2 = format [" West %1:%2 Racs", points_west, points_racs];
} else {
	if (points_racs > points_west) then {
		_str = "Winner: The RACS Team";
		_str2 = format ["Racs %1:%2 West", points_racs, points_west];
	} else {
		if (points_racs == points_west) then {
			_str = "Winner: Both Teams";
			_str2 = format ["West %1:%2 Racs", points_west, points_racs];
		};
	};
};
[4, _str, 2] execVM "IntroAnim\animateLettersX.sqf";_line = _line + 1; waitUntil {i == _line};
sleep 5;
[6, _str2, 4] execVM "IntroAnim\animateLettersX.sqf";_line = _line + 1; waitUntil {i == _line};
#endif
waitUntil {camCommitted _camera};

_camera camSetFOV 5;

_camera camCommit 20;
[2, localize "STR_SYS_102" /* "Мирной жизни!!!" */, 6] execVM "IntroAnim\animateLettersX.sqf";_line = _line + 1; waitUntil {i == _line};
waitUntil {camCommitted _camera};

_camera cameraEffect ["terminate","front"];
camDestroy _camera;

3 fadeMusic 0;

if (true) exitWith {};


