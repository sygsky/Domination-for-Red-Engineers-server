#define __ACE__

SYG_ffunc = {
	private ["_l","_vUp","_angle", "_pos", "_tr", "_tr1", "_res","_dist"];
	if ((vehicle player) == player) then 
	{
		objectID1=(position player nearestObject "LandVehicle");
		if (!alive objectID1 || player distance objectID1 > 8) then {false}
		else
		{
			_vUp=vectorUp objectID1;
			_res = true;
			_tr = player nearestObject d_rep_truck;
#ifdef __ACE__			
			_tr1 = player nearestObject "ACE_Truck5t_Repair";
#else				
			_tr1 = player nearestObject "Truck5tRepair";
#endif			
			if ( (isNull _tr) && (isNull _tr1) ) then { _res = false;} // no any repair tracks near
			else
			{
				if ( isNull _tr ) then // _tr1 != null
				{ 
					_dist = player distance (position _tr1);
				}
				else // _tr != null
				{
					_dist = player distance (position _tr);
					if ( !(isNull _tr1) ) then // then both are found near me. Rare case but why not!)
					{
						// find nearest of two
						if ( (player distance (position _tr1)) < _dist ) then {_dist = distance (position _tr1);};
					};
				};
				_res = true;
			};

			if ( _res ) then 
			{
				if((_vUp select 2) < 0 && (_dist < 20))then {true}
				else // vehicle still can lay on one of its side
				{
					_l=sqrt((_vUp select 0)^2+(_vUp select 1)^2);
					if( _l != 0 )then
					{
						_angle=(_vUp select 2) atan2 _l;
						if( (_angle < 30) && (_dist < 20)) then {true} else{false};
					} else {false}; // standing in good posiition
				};
			}
			else{false};
		}
	} 
	else {false};
};
