private ["_unit", "_movpnlty", "_unitstance"];

_unit = _this;
_movpnlty = 0;

_unitstance = _unit call ACE_fGetUnitStance;

if ((_unitstance select 0) == "unknown" || (_unitstance select 0) == "vehicle") then
{
	_movpnlty = 0;
}
else
{
	switch (_unitstance select 0) do
	{
		case "prone":
		{
		 	_movpnlty = -0.75 - (random(0.5));
		};
		case "kneel":
		{
		 	switch (_unitstance select 1) do
		 	{
				case "stop": { _movpnlty = 0.5 + (random(0.5)); };
				case "slow": { _movpnlty = 1 + (random(0.6)); };
				case "normal": { _movpnlty = 3 + (random(2)); };
				case "fast": { _movpnlty = 6 + (random(3)); };
				default { _movpnlty = 0; };
			};
		};
		case "stand":
		{
			switch (_unitstance select 1) do
		 	{
				case "stop": { _movpnlty = 0.75 + (random(0.5)); };
				case "slow": { _movpnlty = 1.5 + (random(1)); };
				case "normal": { _movpnlty = 3 + (random(2)); };
				case "fast": { _movpnlty = 6 + (random(3)); };
				default { _movpnlty = 0; };
			};
		};
		default { _movpnlty = 0; };
	};
};

_movpnlty