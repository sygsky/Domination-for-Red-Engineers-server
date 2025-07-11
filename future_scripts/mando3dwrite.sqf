/*
    mando3dwrite.sqf
    by Mandoble
    Converted from SQS to SQF
    
    Write 3D text in the space
*/

private ["_posini", "_angmov", "_altini", "_spdx", "_spdy", "_ang", "_texto", "_sizes", "_shape", "_space", "_color", "_dur", "_rots", "_pos", "_wf", "_dsx", "_hf", "_dsy", "_sp", "_sized", "_rad", "_type", "_vel", "_errorcmd", "_errorfonts", "_nfonts", "_nfont", "_font", "_command", "_cmds", "_ncmd", "_cmd", "_cmdok", "_dx", "_dy", "_write"];

_posini = _this select 0;
_angmov = _this select 1;
_altini = _this select 2;
_spdx = _this select 3;
_spdy = _this select 4;
_ang = _this select 5;
_texto = _this select 6;
_sizes = _this select 7;
_shape = _this select 8;
_space = _this select 9;
_color = _this select 10;
_dur = _this select 11;
_rots = _this select 12;

_pos = [_posini select 0, _posini select 1, _altini];
_wf = _sizes select 0;
_dsx = _wf/5.0;
_hf = _sizes select 1;
_dsy = _hf/5.0;
_sp = _sizes select 2;
_sized = [_sizes select 3];
_rad = 0.0;
_type = "Billboard";
if (_space) then {_type = "SpaceObject"};

_vel = [_spdx*sin(_angmov), _spdx*cos(_angmov), _spdy];

_errorcmd = "Unsupported commands - ";
_errorfonts = "Unsupported characters - ";

_nfonts = count _texto;
_nfont = 0;

while {_nfont < _nfonts} do {
    _font = _texto select _nfont;
    
    switch (_font) do {
        case "A": {_command = ["U","U","UR","UR","DR","DR","D","D","UL","L","L","L","JDR","JR","JR","JR","JR"]};
        case "B": {_command = ["U","U","U","U","R","R","R","DR","DL","L","R","JDR","DL","L","L","L","JR","JR","JR","JR","JR"]};
        case "C": {_command = ["JU","U","U","UR","R","R","R","D","JD","JD","JD","L","L","L","UL","JDR","JR","JR","JR","JR"]};
        case "D": {_command = ["U","U","U","U","R","R","R","DR","DR","DL","DL","L","L","L","JR","JR","JR","JR","JR","JR"]};
        case "E": {_command = ["U","U","U","U","R","R","R","R","DL","JDL","L","L","JD","JD","JR","R","R","R","R"]};
        case "F": {_command = ["U","U","U","U","R","R","R","R","DL","JDL","L","L","JD","JD","JR","JR","JR","JR","JR"]};
        case "G": {_command = ["JU","U","U","UR","R","R","R","D","JDL","R","D","DL","L","L","R","JR","JR","JR"]};
        case "H": {_command = ["U","U","U","U","D","JDR","R","R","R","U","U","D","JD","JD","D","R"]};
        case "I": {_command = ["R","R","U","U","U","U","L","L","R","JR","JR","R","DL","JD","JD","JD","R","R"]};
        case "J": {_command = ["JU","DR","R","U","U","U","U","L","L","R","JR","JR","R","R","JD","JD","JD","JD"]};
        case "K": {_command = ["U","U","U","U","DR","JD","R","UR","UR","D","JD","JDL","DR","R"]};
        case "L": {_command = ["U","U","U","U","D","JD","JD","JDR","R","R","R","R"]};
        case "M": {_command = ["U","U","U","U","DR","DR","UR","UR","D","D","D","D","R"]};
        case "N": {_command = ["U","U","U","U","DR","DR","DR","DR","U","U","U","U","D","JDR","JD","JD"]};
        case "С": {_command = ["U","U","U","U","DR","DR","DR","DR","U","U","U","U","UL","JU","L","L","DR","JDR","JDR","JDR","JD","JD"]};
        case "O": {_command = ["JU","U","U","UR","R","R","DR","D","D","DL","L","L","UL","JDR","JR","JR","JR","JR"]};
        case "P": {_command = ["U","U","U","U","R","R","R","DR","DL","L","L","DR","JDR","JR"]};
        case "Q": {_command = ["JU","U","U","UR","R","R","DR","D","D","DL","L","L","UL","JDR","JDR","DR","U","JUR","JR"]};
        case "R": {_command = ["U","U","U","U","R","R","DR","DL","L","R","JDR","DR","R"]};
        case "S": {_command = ["R","R","R","UR","UL","L","L","UL","UR","R","R","R","D","JD","JD","JD"]};
        case "T": {_command = ["JR","JR","U","U","U","U","L","L","R","JR","JR","R","DL","JD","JD","JD","JR","JR"]};
        case "U": {_command = ["JU","U","U","U","R","JR","JR","JR","D","D","D","DL","L","L","R","JR","JR","JR"]};
        case "V": {_command = ["JU","JU","U","U","DR","JD","JD","DR","UR","UR","U","U","D","JD","JD","JDR"]};
        case "W": {_command = ["U","U","U","U","DR","JD","JD","UR","DR","DR","U","U","U","U","DR","JD","JD","JD"]};
        case "X": {_command = ["UR","UR","UR","UR","L","JL","JL","JL","DR","DR","JDR","DR","R"]};
        case "Y": {_command = ["JU","JU","JU","JU","DR","DR","D","D","U","JU","JUR","UR","UR","JD","JD","JD","JD","JD"]};
        case "Z": {_command = ["R","R","R","R","UL","UL","UL","UL","R","R","R","R","R","JD","JD","JD","JD"]};
        case " ": {_command = ["JR","JR","JR","JR","JR"]};
        case ".": {_command = ["U","R","D","R","JR","JR","JR"]};
        case ",": {_command = ["JD","UR","U","R","D","R","JR","JR","JR"]};
        case "0": {_command = ["JU","U","U","UR","R","R","DR","D","D","DL","L","L","UL","JDR","JR","JR","JR","JR"]};
        case "1": {_command = ["JR","R","U","U","U","U","DL","DL","JR","JD","JD","JR","JR","R","JR"]};
        case "2": {_command = ["UR","UR","UR","UL","L","DL","D","JD","JDR","R","R","R"]};
        case "3": {_command = ["R","R","UR","UL","L","R","JUR","UL","L","L","R","JDR","JDR","JDR","JD"]};
        case "4": {_command = ["JU","JU","U","U","U","JDR","JD","JD","R","U","U","D","JD","JD","D","UR","JU","D","JDR"]};
        case "5": {_command = ["R","R","UR","UL","L","L","U","U","R","R","R","R","JD","JD","JD","JD"]};
        case "6": {_command = ["JU","JUR","R","DR","DL","L","UL","U","U","UR","R","R","JDR","JD","JD","JD"]};
        case "7": {_command = ["JU","JU","JU","JU","R","R","R","DL","DL","D","D","R","JR","JR"]};
        case "8": {_command = ["JU","UR","R","UR","UL","L","DL","DR","JD","JD","R","UR","DR"]};
        case "9": {_command = ["JR","R","UR","U","U","UL","L","DL","DR","R","DR","JD"]};
        default {
            _errorfonts = _errorfonts + format["%1",_font];
        };
    };
    
    if (!isNil "_command") then {
        _cmds = count _command;
        _ncmd = 0;
        
        while {_ncmd < _cmds} do {
            _cmd = _command select _ncmd;
            _cmdok = false;
            
            switch (_cmd) do {
                case "JDR": {_dx = _dsx; _dy = -_dsy; _write = false; _cmdok = true};
                case "JDL": {_dx = -_dsx; _dy = -_dsy; _write = false; _cmdok = true};
                case "JUR": {_dx = _dsx; _dy = _dsy; _write = false; _cmdok = true};
                case "JUL": {_dx = -_dsx; _dy = _dsy; _write = false; _cmdok = true};
                case "JU": {_dx = 0.0; _dy = _dsy; _write = false; _cmdok = true};
                case "JD": {_dx = 0.0; _dy = -_dsy; _write = false; _cmdok = true};
                case "JL": {_dx = -_dsx; _dy = 0.0; _write = false; _cmdok = true};
                case "JR": {_dx = _dsx; _dy = 0.0; _write = false; _cmdok = true};
                case "DR": {_dx = _dsx; _dy = -_dsy; _write = true; _cmdok = true};
                case "DL": {_dx = -_dsx; _dy = -_dsy; _write = true; _cmdok = true};
                case "UR": {_dx = _dsx; _dy = _dsy; _write = true; _cmdok = true};
                case "UL": {_dx = -_dsx; _dy = _dsy; _write = true; _cmdok = true};
                case "U": {_dx = 0.0; _dy = _dsy; _write = true; _cmdok = true};
                case "D": {_dx = 0.0; _dy = -_dsy; _write = true; _cmdok = true};
                case "L": {_dx = -_dsx; _dy = 0.0; _write = true; _cmdok = true};
                case "R": {_dx = _dsx; _dy = 0.0; _write = true; _cmdok = true};
                default {
                    _errorcmd = _errorcmd + format["%1 ",_cmd];
                };
            };
            
            if (_cmdok) then {
                if (_write) then {
                    drop[_shape,"",_type,100,_dur,_pos,_vel,_rots,25.50,20,0,_sized,_color,[0],0,0,"","",""];
                };
                _rad = _rad + _dx;
                _pos = [(_posini select 0)+_rad*sin(_ang), (_posini select 1)+_rad*cos(_ang), (_pos select 2)+_dy];
            };
            
            _ncmd = _ncmd + 1;
        };
    };
    
    _rad = _rad + _sp;
    _pos = [(_posini select 0)+_rad*sin(_ang), (_posini select 1)+_rad*cos(_ang), (_pos select 2)];
    _nfont = _nfont + 1;
};

if ((_errorfonts != "Unsupported characters - ") || (_errorcmd != "Unsupported commands - ")) then {
    hint format["%1\n\n%2",_errorfonts, _errorcmd];
};