//Animation mode 0 - characters enter the screen from the left and arch towards the camera.

private ["_ctrl", "_char", "_pos", "_Slot"];
_ctrl = _this select 0;
_char = _this select 1;
_pos = _this select 2;
_Slot = _this select 3;

//Remove control from pool.
controls = controls - [_ctrl];

_ctrl ctrlSetTextColor d_intro_color;

//Assign correct character.
_ctrl ctrlSetText _char;

//Start animation.
_ctrl ctrlSetPosition [-0.1, 0.3];
_ctrl ctrlSetFade 0;
_ctrl ctrlSetScale 0.2;
_ctrl ctrlCommit 0;

_ctrl ctrlSetPosition [(_pos * 0.03) + 0.1,0.05 + _Slot / 400];
_ctrl ctrlCommit 0.5;

_ctrl ctrlSetScale 4;
_ctrl ctrlCommit 0.25;

sleep 0.25;

_ctrl ctrlSetScale 1;
_ctrl ctrlCommit 0.25;

sleep 14.75;

_ctrl ctrlSetFade 1;
_ctrl ctrlCommit 1;

sleep 2;

//Give control back to pool.
controls = controls + [_ctrl];

true