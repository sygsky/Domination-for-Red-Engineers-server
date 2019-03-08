if (alive (_this select 0)) then
{	
	(_this select 0) setVariable ['ACE_unconscious', true];
	(_this select 0) setFaceAnimation 0;
	(_this select 0) setMimic 'Hurt';
	// No set captive as it gives strange aberrations sometimes 
	//(_this select 0) setCaptive true;
	(_this select 0) switchMove (_this select 1);
};
