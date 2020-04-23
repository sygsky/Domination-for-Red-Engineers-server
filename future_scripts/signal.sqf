pickup=true; 

if (alive jay) then {
	if ((player distance jay)<30) then {
		jay setUnitPos "up"; 
		jay move [getPos jay select 0, (getPos jay select 1)+2];
		sleep 1;
		jay playmove "AinvPknlMstpSlayWrflDnon_AmovPercMstpSrasWrflDnon";
		sleep 2.5; 
		
		_position = [getPos jay select 0, (getPos jay select 1)+.75];
		_color_r = 0;
		_color_g = 255;
		_color_b = 0;
		_colorprogression = [[_color_r+0.01,_color_g+0.01,_color_b+0.01,0.4],[_color_r+0.15,_color_g+0.15,_color_b+0.15,0.4],[_color_r+0.6,_color_g+0.6,_color_b+0.6,0.01],[_color_r+1,_color_g+1,_color_b+1,0.001],[1,1,1,0]];
		
		_colorprogression = [[_color_r+0.01,_color_g+0.01,_color_b+0.01,0.4],[_color_r+0.15,_color_g+0.15,_color_b+0.15,0.4],[_color_r+0.6,_color_g+0.6,_color_b+0.6,0.01],[_color_r+1,_color_g+1,_color_b+1,0.001],[1,1,1,0]];
		
		_smokeemitter1 = "#particlesource" createVehicle _position;
		_smokeemitter1 setParticleParams [["\Ca\data\ParticleEffects\FireAndSmokeAnim\SmokeAnim",8,1,8],"","Billboard",1,20,[0,0,0],[0,0,1],1,1.281,1,0.5,[0.2,9],_colorprogression,[0.01],0.1,0.005,"","",_smokeemitter1];
		_smokeemitter1 setParticleRandom [0.8,[0,0,0],[0.1,0.1,0.3],0.1,0.5,[0.4,0.4,0.4,0.3],0,0];
		_smokeemitter1 setDropInterval 0.1;
		
		_smokeemitter2 = "#particlesource" createVehicle _position;
		_smokeemitter2 setParticleParams [["\Ca\data\ParticleEffects\FireAndSmokeAnim\SmokeAnim",8,0,8],"","Billboard",1,20,[0,0,0],[0,0,1],1,1.281,1,0.5,[0.2,9],_colorprogression,[0.01],0.1,0.005,"","",_smokeemitter2];
		_smokeemitter2 setParticleRandom [0.5,[0,0,0],[0.1,0.1,0.3],0.1,0.5,[0.4,0.4,0.4,0.3],0,0];
		_smokeemitter2 setDropInterval 0.3;
		
		_smokeemitter3 = "#particlesource" createVehicle _position;
		_smokeemitter3 setParticleParams [["\Ca\data\ParticleEffects\FireAndSmokeAnim\SmokeAnim",8,5,8],"","Billboard",1,20,[0,0,0],[0,0,1],1,1.281,1,0.5,[0.2,9],_colorprogression,[0.01],0.1,0.005,"","",_smokeemitter3];
		_smokeemitter3 setParticleRandom [0.5,[0,0,0],[0.1,0.1,0.3],0.1,0.5,[0.4,0.4,0.4,0.3],0,0];
		_smokeemitter3 setDropInterval 0.3;
		
		_smokeemitter4 = "#particlesource" createVehicle _position;
		_smokeemitter4 setParticleParams [["\Ca\data\ParticleEffects\FireAndSmokeAnim\SmokeAnim",8,3,8],"","Billboard",1,20,[0,0,0],[0,0,1],1,1.281,1,0.5,[0.2,7],_colorprogression,[0.01],0.1,0.005,"","",_smokeemitter4];
		_smokeemitter4 setParticleRandom [0.5,[0,0,0],[0.1,0.1,0.3],0.1,0.5,[0.4,0.4,0.4,0.3],0,0];
		_smokeemitter4 setDropInterval 0.1;
		
		[jay] join player; 
		jay setCaptive false; 
		jay setCombatMode "red"; 
	
		[group wp1,2] setWPPos getPos jay; 
		wp1 setSpeedMode "full"; 
		wp1 setBehaviour "combat";
		
		sleep 120;
		{deleteVehicle _x} forEach [_smokeemitter4,_smokeemitter3,_smokeemitter2,_smokeemitter1];
	};
};
