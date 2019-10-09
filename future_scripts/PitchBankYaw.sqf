/*
	author: Gigan
	description: https://forums.bohemia.net/forums/topic/86426-setvectordirandup-usage-solved/?do=findComment&comment=1460771
	returns: nothing
*/

private [""];
_dir = 60;
_angle = 45;
_pitch = 30;

_vecdx = sin(_dir) * cos(_angle);

_vecdy = cos(_dir) * cos(_angle);

_vecdz = sin(_angle);

_vecux = cos(_dir) * cos(_angle) * sin(_pitch);

_vecuy = sin(_dir) * cos(_angle) * sin(_pitch);

_vecuz = cos(_angle) * cos(_pitch);

object setVectorDirAndUp [ [_vecdx,_vecdy,_vecdz], [_vecux,_vecuy,_vecuz] ];