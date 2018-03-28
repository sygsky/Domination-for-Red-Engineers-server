// ////////////////////////////////////////////////////////////////////////////
// GL3 v.1.4
// ////////////////////////////////////////////////////////////////////////////
// Church Chor and Church Ambient
// Idea and Sounds by Operation Flashpoint MOD E.C.P. ( Enhanced Configuration Project )
// Script by =\SNKMAN/=
// ////////////////////////////////////////////////////////////////////////////
private ["_a","_b","_churchActList","_lightsArr","_churchArr","_cnt","_church","_light","_snd","_duration","_k","_l","_m"];

sleep (5 + (random 5));

if (isNull player) exitWith {};

_a = False;
_b = True;

_churchActList = [];
_lightsArr = [];

while { (GL3_Local select 17) } do
{
	_churchArr = nearestObjects [player, ["Church"], (GL3_Local select 18) ];

	if (count _churchArr > 0) then
	{
		if ( (dayTime > 4.00) && (dayTime < 20.00) ) then // day time
		{
			if ((random 100) > 50) then
			{
				// /////////// DEBUG ///////////
				// hint format ["DEBUG: Church Chor:\nChurches: %1", _churchArr];
				// /////////////////////////////

				if (_b) then
				{
					_b = False;
                    // remove lights, strt sounds
					if ( count _churchActList > 0) then
					{
					    { deleteVehicle _x; } forEach _lightsArr;
					    _lightsArr = [];
					    _churchActList = [];
					};

					// /////////// DEBUG ///////////
					// hint "DEBUG: Church Chor:\nChurch";
					// /////////////////////////////

					sleep (10 + (random 10));

                    /**
                        ["Church_v02","Church_v06","Church_v07"], //12 - short sounds
                        ["Church_v03","Church_v05"],    // 13 - medium sounds
                        ["Church_v01","Church_v04"],    //14 - long sounds

                    */
                    
					_cnt = (GL3_Resource select 12) call (GL3_Feature_F select 0);      // sound 1
					_church = (GL3_Resource select 13) call (GL3_Feature_F select 0);   // sound 2
					_light = (GL3_Resource select 14) call (GL3_Feature_F select 0);    // sound 3

					_snd = [_cnt, _church, _light] call (GL3_Feature_F select 0);

					// /////////// DEBUG ///////////
					// hint format ["DEBUG: Church Chor:\nChurch Sound Nr. %1", _snd];
					// /////////////////////////////

					_duration = 60 + (random 200);

					switch (_snd) do
					{
						case _cnt :
						{
							_duration = 60 + (random 60);
						};

						case _church :
						{
							_duration = 120 + (random 120);
						};

						case _light :
						{

							_duration = 200 + (random 200);
						};
					};

					// /////////// DEBUG ///////////
					// hint format ["DEBUG: Church Chor:\nChurch sound: %1\nChurch pause: %2" ,_snd,_duration];
					// /////////////////////////////

					(_churchArr select 0) say _snd;

					sleep _duration;

					_b = True;
				};
			}
			else
			{
				// /////////// DEBUG ///////////
				// hint "DEBUG: Church Chor:\nChurch pause";
				// /////////////////////////////

				sleep (240 + (random 240));
			};
		}
		else // evening or night
		{
		    // stop sounds феке light
			if (count _churchActList == 0) then
			{
				// /////////// DEBUG ///////////
				// hint format ["DEBUG: Church Ambient:\nChurches: %1", _churchArr];
				// /////////////////////////////

				_cnt = 0;

				while { (_cnt < count _churchArr) } do
				{
					_church = (_churchArr select _cnt);
					if ( alive _church) then
					{
                        _cnt = _cnt + 1;

                        sleep 0.1;

                        if !(_church in _churchActList) then
                        {
                            // /////////// DEBUG ///////////
                            // hint "DEBUG: Church Ambient:\nChurch light on";
                            // /////////////////////////////

                            _churchActList = _churchActList + [_church];

                            // /////////// DEBUG ///////////
                            // hint format ["DEBUG: Church Ambient:\nChurches: %1", _church];
                            // /////////////////////////////

                            _light = "#lightpoint" createVehicle (getPos _church);

                            _lightsArr = _lightsArr + [_light];

                            _light setPos [(getPos _light select 0), (getPos _light select 1), (getPos _light select 2) + 20];

                            _light setLightBrightness 0.1;
                            _light setLightAmbient [2, 1, 0];
                            _light setLightColor [2, 1, 0];
                        };
					};
				};
			}
			else
			{
				// /////////// DEBUG ///////////
				// hint "DEBUG: Church Ambient:\nChurch light pause";
				// /////////////////////////////

				sleep (240 + (random 240));
			};
		};
	}
	else
	{
		// /////////// DEBUG ///////////
		// hint "DEBUG: Church Ambient:\nChurch light pause";
		// /////////////////////////////

		sleep (240 + (random 240));
	};
};