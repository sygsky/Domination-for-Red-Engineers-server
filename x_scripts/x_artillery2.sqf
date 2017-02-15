// by Xeno
private ["_ok","_oldpos","_pos1","_pos2","_dist"];

#include "x_setup.sqf"

if (!ari2_available) exitWith {
		(localize "STR_SYS_302") call XfHQChat; //"Вторая арт.батарея недоступна..."
};

#ifdef __RANKED__
_score = score player;
if (_score < (d_ranked_a select 19)) exitWith {
	(format [localize "STR_SYS_303",(d_ranked_a select 19), _score]) call XfHQChat; //"У вас недостаточно очков для вызова артилерии... Требуется %1. Сейчас у вас: %2."
};
#endif

#ifdef __ACE__
_exitacearti = false;
if (d_with_ace_map) then {
	if (!(call XCheckForMap)) then {
		_exitacearti = true;
		localize "STR_SYS_304" call XfHQChat; // "!!!!!!!!!!!! Нужна карта !!!!!!!!!!!"
	};
};
if (_exitacearti) exitWith {};
#endif

["arti2_marker_1",position player,"ELLIPSE","ColorYellow",[d_arti_operator_max_dist,d_arti_operator_max_dist],"",0,"","FDiagonal"] call XfCreateMarkerLocal;

ari_type2 = "";
ari_salvos2 = 1;
_oldpos = position AriTarget2;
_ok = createDialog "XD_ArtilleryDialog2";
#ifdef __RANKED__
_XD_display = findDisplay 11233;
_rank = rank player;
if (_rank in ["PRIVATE","CORPORAL"]) then {
	_control = _XD_display displayCtrl 11007;
	_control ctrlShow false;
	_control = _XD_display displayCtrl 11008;
	_control ctrlShow false;
} else {
	if (_rank in ["SERGEANT","LIEUTENANT"]) then {
		_control = _XD_display displayCtrl 11008;
		_control ctrlShow false;
	};
};
#endif
onMapSingleClick "AriTarget2 setPos _pos;""arti_target2"" setMarkerPos _pos;";

waitUntil {ari_type2 != "" || !dialog || !alive player};

onMapSingleClick "";
if (!alive player) exitWith {
	if (dialog) then {
		closeDialog 11233;
	};
};
if (ari_type2 != "") then {
	if (!ari2_available) exitWith {
		(localize "STR_SYS_306") call XfHQChat; // "Первая арт.батарея недоступна, т.к. используется кем-то другим..."
	};
	_pos1 = getPos player;
	_pos1 set [2,0];
	_pos2 = position AriTarget2;
	_pos2 set [2,0];
	_dist = round(_pos1 distance _pos2);

	if ( _dist > d_arti_operator_max_dist) exitWith {
		(format [localize "STR_SYS_300", _dist, d_arti_operator_max_dist]) call XfHQChat; // "Вы слишком далеко от выбранной области (%1 м.), требуемая дистанция <= %2 м."
		AriTarget2 setPos _oldpos;
		"arti_target2" setMarkerPos _oldpos;
	};

	_no = objNull;
	if (d_arti_check_for_friendlies) then {
		if (ari_type2 == "he" || ari_type2 == "dpicm") then {
#ifndef __TT__
			_man_type = (
				switch (d_own_side) do {
					case "WEST": {"SoldierWB"};
					case "EAST": {"SoldierEB"};
					case "RACS": {"SoldierGB"};
				}
			);
			_pos_at = [position AriTarget2 select 0,position AriTarget2 select 1,0];
			_no = nearestObject [_pos_at, _man_type];
#endif
#ifdef __TT__
			_pos_at = [position AriTarget2 select 0,position AriTarget2 select 1,0];
			_no = nearestObject [_pos_at, "SoldierWB"];
			if (isNull _no) then {
				_no = nearestObject [_pos_at, "SoldierGB"];
			};
#endif

			//if (isNull _no) then {
			//	_no = nearestObject [_pos_at, "Civilian"];
			//};
		};
	};

	if (!isNull _no) exitWith {
		(localize "STR_SYS_307") call XfHQChat; // "В зоне работы арт.батареи присутствует дружественный контингент!!! Запрос отменен..."
		AriTarget2 setPos _oldpos;
		"arti_target2" setMarkerPos _oldpos;
	};

	if (!X_SPE) then {
		ari2_available = false;
	};
	#ifdef __RANKED__
	if ((d_ranked_a select 2) > 0) then {
		player addScore (d_ranked_a select 2) * -1;
	};
	#endif
	if (!X_SPE) then {
		[player, (format [localize "STR_SYS_308", ari_type,ari_salvos, position AriTarget select 1, position AriTarget select 0])] call XfSideChat; // "Запрашиваю арт.удар (%1) снарядами, %2 залпом(и) по следующим координатам: %3 - %4."
		player say "Funk";
	};
	["d_say",player,"Funk"] call XSendNetStartScriptAll;
	["ari2msg", 4, ari_type2,ari_salvos2, position AriTarget2 select 1, position AriTarget2 select 0] call XSendNetStartScriptClient;
	sleep 9.123;
	if (!X_SPE) then {
		(localize "STR_SYS_321") call XfHQChat; // "Говорит вторая арт.батарея. Вас понял, прием."
	};
	["ari2msg", 5] call XSendNetStartScriptClient;
	sleep 8.54;
	if (!X_SPE) then {
		(format [localize "STR_SYS_323", ari_type,ari_salvos]) call XfHQChat; // "Говорит вторая арт.батарея, заряжаем %1. Прием."
	};
	["ari2msg", 6, ari_type2, ari_salvos2] call XSendNetStartScriptClient;
	["ari_type2",ari_type2,ari_salvos2,str(player)] call XSendNetStartScriptServer;
} else {
	deleteMarkerLocal "arti1_marker_1";
	(localize "STR_SYS_103") call XfHQChat; // "Отмена..."
	AriTarget2 setPos _oldpos;
	"arti_target2" setMarkerPos _oldpos;
};

deleteMarkerLocal "arti2_marker_1";

if (true) exitWith {};
