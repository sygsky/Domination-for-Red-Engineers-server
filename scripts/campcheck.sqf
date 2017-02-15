//
// campcheck.sqf: action on camp being checked by player
//

#define INDEX_FOR_VISIT_SCORE 23

_msg_arr = [
	[3,4,5,6],
	[7,8,9,10,11],
	[12,13,14,15,16]
];

_camp_hint = {
	private ["_str","_camp_id"];
	// ids for messages
	_camp_id = _this select 0;
	_id1 = _this select 1; 
	_id2 = _this select 2; 
	_id3 = _this select 3; 
	
	//_str = format["<t color='#00ff00'>%1</t>",localize "STR_CAMP_1"]; 


	_msgs = _msg_arr select 0;
	_age = localize format[ "STR_CAMP_%1", _msgs select ( _id1 min ( count _msgs - 1 ) ) ];

	_msgs = _msg_arr select 1;
	_label = localize format[ "STR_CAMP_%1", _msgs select ( _id2 min ( count _msgs - 1 ) ) ];

	_msgs = _msg_arr select 2;
	_logo = localize format[ "STR_CAMP_%1", _msgs select ( _id3 min ( count _msgs - 1 ) ) ];
	_str = composeText[ format[ localize "STR_CAMP_19", _label   ], lineBreak, lineBreak, parseText("<t align='center'><t color='#ff00ff00'>" + (localize "STR_CAMP_1")+ "</t></t>")];
	if (!isNil "d_partisans_started") then
	{
		if ( !d_partisans_started ) then
		{
			_str = composeText[ format[ localize "STR_CAMP_19", _label   ], lineBreak, lineBreak, parseText("<t align='center'><t color='#ffffff00'>" + (localize "STR_CAMP_2")+ "</t></t>")]; // "Х-м-м, похоже, партизаны уже действуют!", "В итоге Вы ничего не поняли"
			//_str = composeText[ parseText("<t color='#ffffff00'>" + (localize "STR_CAMP_2")+ "</t>")];
			d_partisans_started = true;
			// TODO: sent message over network about partisans activity started
		};
	};

	localize "STR_CAMP_17"	hintC [
		format[ localize "STR_CAMP_21", _camp_id ],
		format[ localize "STR_CAMP_18", _age     ],
		format[ localize "STR_CAMP_20", _logo    ],
		_str
	];
};

//hint  localize format["campcheck.sqf: called with [%1]",_this select 3];
(_this select 3) call _camp_hint;

_visited =  (_this select 0) getVariable ["camp_is_visited",false];
if ( !_visited ) then
{
	// TODO: add some score to player
	(_this select 0) setVariable ["camp_is_visited", true];
	player addScore d_ranked_a select INDEX_FOR_VISIT_SCORE;
};


/*
STR_CAMP_1,"H-m-m, it seems that the partisans are already!","H-m-m, es scheint, die Partisanen wirkt schon!","Х-м-м, похоже, партизаны уже действуют!"
STR_CAMP_2,"In the end, You don't get it","Am Ende haben Sie nichts verstanden","В итоге Вы ничего не поняли"
STR_CAMP_3,"new",die neue,"новая"
STR_CAMP_4,"nearly new","fast neu","почти новая"
STR_CAMP_5,"rather old","ziemlich alt","старенькая"
STR_CAMP_6,"of weird age","wird auf unbestimmte Alterunverständlich Alter","непонятного возраста"
STR_CAMP_7,"'Ярославская фабрика турснаряжения'","'Ярославская фабрика турснаряжения'","'Ярославская фабрика турснаряжения'"
STR_CAMP_8,"'филиал з-да им. Ленина'","'филиал з-да им. Ленина'","'филиал з-да им. Ленина'"
STR_CAMP_9,"'артель 'Красный артельщик''","'артель 'Красный артельщик''","'артель 'Красный артельщик''"
STR_CAMP_10,"... almost erased","... fast gelöscht","... практически стёрся"
STR_CAMP_11,"impossible to read","lesen ist unmöglich","разобрать невозможно"
STR_CAMP_12,"'The Union of young sahranians'","'Die Vereinigung von Jungen sahranians'","'Союз молодых сахранийцев'"
STR_CAMP_13,"'take the example of the 'Young Guarde'","'nehmen wir das Beispiel mit 'Jungen Garde'","'берём пример с 'Молодой гвардии'"
STR_CAMP_14,"'Juanito is fool'","'Juanito - Narr'","'Хуанито - дурак'"
STR_CAMP_15,'Fidel is coming!'",'Fidel kommt!'","'Фидель грядёт!'"
STR_CAMP_16,"impossible to read","zu Lesen unmöglich","разобрать невозможно"
STR_CAMP_17,"You've checked the tent and see:","Haben Sie überprüft, Zelt und sehen:","Вы проверили палатку и видите:"
STR_CAMP_18,"It is %1","Es ist %1","Она %1"
STR_CAMP_19,"Label: %1","die Verknüpfung: %1","Ярлык: %1"
STR_CAMP_20,"Inscription made by the marker: %1","Die Inschrift Filzstift: %1","Надпись фломастером %1"
STR_CAMP_21,"Inventory number %1","Inventarnummer %1","Инвентарный номер %1"

*/