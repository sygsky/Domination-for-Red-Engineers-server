//Animation mode 1 - characters enter the screen behind the camera and move away from the camera.

private ["_ctrl", "_char", "_pos", "_Slot"];
_ctrl = _this select 0;
_char = _this select 1;
_pos = _this select 2;
_Slot = _this select 3;

controls = controls - [_ctrl];

_ctrl ctrlSetTextColor d_intro_color;

_ctrl ctrlSetText _char;
	
_ctrl ctrlSetPosition [(_pos * 0.03) + 0.1,0.05 + _Slot / 400];
_ctrl ctrlSetFade 0;
_ctrl ctrlSetScale 10;
_ctrl ctrlCommit 0;

_ctrl ctrlSetScale 1;
_ctrl ctrlCommit 0.5;

sleep 15;

_ctrl ctrlSetFade 1;
_ctrl ctrlCommit 1;

sleep 2;

controls = controls + [_ctrl];

true