// by Xeno, x_sec_solved.sqf, called on client with params:
// ["sec_solved", kind_solved,killer_name]
private ["_sec_solved_kind","_is_solved"];
if (!X_Client) exitWith {};

_sec_solved_kind = _this select 1;

sec_kind = 0;

_is_solved = true;
_msg = "STR_SYS_248";

switch (_sec_solved_kind) do {
	case "gov_dead": {
		_msg = "STR_SYS_240"; // "Ваша команда ликвидировала губернатора..."
	};
	case "gov_out": {
		_msg = "STR_SYS_241"; // "Губернатор позорно сбежал из города..."
		_is_solved = false;
	};
	case "radar_down": {
		_msg = "STR_SYS_242"; // "Ваша команда уничтожила вышку связи противника..."
	};
	case "ammo_down": {
		_msg = "STR_SYS_243"; // "Ваша команда уничтожила грузовик с боезапасом..."
	};
	case "apc_down": {
		_msg = "STR_SYS_244"; // "Ваша команда уничтожила командный штаб противника..."
	};
	case "hq_down": {
		_msg = "STR_SYS_245"; // "Ваша команда уничтожила командный пункт противника..."
	};
	case "light_down": {
		_msg = "STR_SYS_246"; // "Ваша команда уничтожила завод по производству героина..."
	};
	case "heavy_down": {
		_msg = "STR_SYS_247"; // "Ваша команда уничтожила большой завод по производству героина..."
	};
	case "sec_over": {
		_msg = "STR_SYS_248"; // "Secondary objective achieved..."
		_is_solved = false;
	};
};
_msg = localize _msg;
if (_is_solved) then
{
    if ( (count _this) > 2 ) then
    {
        if (! isNull ( _this select 2)) then
        {
            if (( _this select 2) == (name player)) then
            {
                _msg = format["%1 %2 (+%3)!", _msg, localize "STR_SEC_COMPLETED_BY_YOU", d_ranked_a select 25];
                player addScore (d_ranked_a select 25);
            };
        };
    };
    hint localize format["+++ sec_solved: %1", _this];
};
_msg call XfHQChat; // "Губернатор позорно сбежал из города..."

if (true) exitWith {};
