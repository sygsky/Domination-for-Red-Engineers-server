//Animation mode 3 - characters enter the screen from a random position outside the screen.

private ["_ctrl", "_char", "_pos", "_Slot"];
_ctrl = _this select 0;
_char = _this select 1;
_pos = _this select 2;
_Slot = _this select 3;

controls = controls - [_ctrl];

_ctrl ctrlSetTextColor d_intro_color;

_ctrl ctrlSetText _char;

//Select a random quadrant and position.
private ["_quadrant", "_rdmX", "_rdmY"];
_quadrant = random 4;
_quadrant = _quadrant - (_quadrant % 1);

switch (_quadrant) do 
{
	case 0: 
	{
		_rdmX = -0.1;
		_rdmY = (random 1);
	};
	
	case 1: 
	{
		_rdmX = (random 1);
		_rdmY = -0.1;
	};
	
	case 2: 
	{
		_rdmX = 1.1;
		_rdmY = (random 1);
	};
	
	case 3: 
	{
		_rdmX = (random 1);
		_rdmY = 1.1;
	};
	
	default {};			
};
	
_ctrl ctrlSetPosition [_rdmX, _rdmY];
_ctrl ctrlSetFade 0;
_ctrl ctrlSetScale 1;
_ctrl ctrlCommit 0;

_ctrl ctrlSetPosition [(_pos * 0.03) + 0.1,0.05 + _Slot / 400];
_ctrl ctrlCommit 0.5;

sleep 15;

_ctrl ctrlSetFade 1;
_ctrl ctrlCommit 1;

sleep 2;

controls = controls + [_ctrl];

true