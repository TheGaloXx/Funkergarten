package substates;

import funkin.Section.SwagSection;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import haxe.Json;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import flixel.group.FlxGroup.FlxTypedGroup;

using StringTools;

class ChartingState extends funkin.MusicBeatState
{
	var _file:openfl.net.FileReference;

	public var snap:Int = 1;

	var UI_box:flixel.addons.ui.FlxUITabMenu;

	/**
	  Array of notes showing when each section STARTS in STEPS
	  Usually rounded up?
	 */
	var curSection:Int = 0;

	public static var lastSection:Int = 0;

	var bpmTxt:FlxText;

	var strumLine:FlxSprite;
	var bullshitUI:flixel.group.FlxGroup;

	var GRID_SIZE:Int = 40;

	var dummyArrow:FlxSprite;

	var curRenderedNotes:FlxTypedGroup<objects.Note>;
	var curRenderedSustains:FlxTypedGroup<FlxSprite>;

	var gridBG:FlxSprite;

	var _song:funkin.Song.SwagSong;

	var typingShit:flixel.addons.ui.FlxInputText;
	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic>;

	var tempBpm:Float = 0;
	var gridBlackLine:FlxSprite;

	/* Ok I updated Flixel and it says " Warning : flixel.sound.FlxSound was moved to flixel.sound.FlxSound " 
	but when I change it to that, a bunch of errors pop up so yeah fuck you
	it compiles fine both ways tho
	idk flixel's weird.
	*/
	var vocals:flixel.sound.FlxSound;

	var leftIcon:objects.HealthIcon;
	var rightIcon:objects.HealthIcon;

	private var lastNote:objects.Note;
	var claps:Array<objects.Note> = [];

	var noteStyle:Int = 0;
	var styles:Array<String> = ['n', 'nuggetP', /* 'nuggetN', 'gum', */ 'b', 'apple'];
	var noteStyleTxt:FlxText;
	
	public static var eventData:Array<String> = [];

	override function create()
	{
		eventData = [];
		curSection = lastSection;

		if (states.PlayState.SONG != null)
			_song = states.PlayState.SONG;
		else
		{
			_song = {
				song: 'Test',
				notes: [],
				bpm: 150,
				needsVoices: true,
				player1: 'bf',
				player2: 'dad',
				stage: 'stage',
				speed: 1,
				songDrains: false
			};
		}

		var fring = new FlxSprite().loadGraphic(Paths.image('menu/gustavo fring', 'preload'));
		fring.active = false;
		fring.screenCenter();
		fring.scrollFactor.set();
		fring.color = flixel.util.FlxColor.GRAY;
		add(fring);

		gridBG = flixel.addons.display.FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);
		add(gridBG);

		var blackBorder:FlxSprite = new FlxSprite(60,10).makeGraphic(120,100,FlxColor.BLACK);
		blackBorder.scrollFactor.set();

		blackBorder.alpha = 0.3;

		var snapText = new FlxText(60,10,0, "Use mouse wheel or space to move trough grid.\nAdd Notes: press 1-8 (or click)\n", 14);
		snapText.scrollFactor.set();

		gridBlackLine = new FlxSprite(gridBG.x + gridBG.width / 2).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(gridBlackLine);

		curRenderedNotes = new FlxTypedGroup<objects.Note>();
		curRenderedSustains = new FlxTypedGroup<FlxSprite>();

		tempBpm = _song.bpm;

		addSection();
		updateGrid();

		loadSong(_song.song);
		funkin.Conductor.changeBPM(_song.bpm);
		funkin.Conductor.mapBPMChanges(_song);

		leftIcon = new objects.HealthIcon(_song.player1);
		rightIcon = new objects.HealthIcon(_song.player2);
		leftIcon.scrollFactor.set(1, 1);
		rightIcon.scrollFactor.set(1, 1);

		leftIcon.setGraphicSize(0, 45);
		rightIcon.setGraphicSize(0, 45);

		add(leftIcon);
		add(rightIcon);

		leftIcon.setPosition(0, -100);
		rightIcon.setPosition(gridBG.width / 2, -100);

		bpmTxt = new FlxText(1000, 50, 0, "", 16);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(FlxG.width / 2), 4);
		add(strumLine);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		var tabs = [
			{name: "Song", label: 'Song Data'},
			{name: "Section", label: 'Section Data'},
			{name: "Note", label: 'Note Data'},
			{name: "Assets", label: 'Assets'}
		];

		UI_box = new flixel.addons.ui.FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = FlxG.width / 2;
		UI_box.y = 20;
		add(UI_box);

		addSongUI();
		addSectionUI();
		addNoteUI();

		add(curRenderedNotes);
		add(curRenderedSustains);

		add(blackBorder);
		add(snapText);

		noteStyleTxt = new FlxText(5, 100, FlxG.width, "Note Type: Normal\n(X or Z to change)", 20);
		noteStyleTxt.autoSize = false;
		noteStyleTxt.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.BLACK, LEFT, FlxTextBorderStyle.OUTLINE,FlxColor.WHITE);
		noteStyleTxt.scrollFactor.set(0, 0);
		noteStyleTxt.borderSize = 1.50;
		add(noteStyleTxt);

		super.create();
	}

	function addSongUI():Void
	{
		var UI_songTitle = new flixel.addons.ui.FlxUIInputText(10, 10, 70, _song.song, 8);
		typingShit = UI_songTitle;

		var check_voices = new FlxUICheckBox(10, 25, null, null, 'Has Voice Track', 100);
		check_voices.checked = _song.needsVoices;
		check_voices.callback = function()
		{
			_song.needsVoices = check_voices.checked;
			trace('CHECKED!');
		};

		var check_mute_inst = new FlxUICheckBox(10, 200, null, null, 'Mute Instrumental', 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_inst.checked)
				vol = 0;

			FlxG.sound.music.volume = vol;
		};

		var saveButton:FlxButton = new FlxButton(110, 8, 'Save', function()
		{
			saveLevel();
		});

		var reloadSong:FlxButton = new FlxButton(saveButton.x + saveButton.width + 10, saveButton.y, 'Reload Audio', function()
		{
			loadSong(_song.song);
		});

		var reloadSongJson:FlxButton = new FlxButton(reloadSong.x, saveButton.y + 30, 'Reload JSON', function()
		{
			loadJson(_song.song.toLowerCase());
		});

		
		var restart = new FlxButton(10,140, 'Reset Chart', function()
            {
                for (ii in 0..._song.notes.length)
                {
                    for (i in 0..._song.notes[ii].sectionNotes.length)
                        {
                            _song.notes[ii].sectionNotes = [];
                        }
                }
                resetSection(true);
            });

		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'Load Autosave', loadAutosave);
		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 65, 0.1, 1, 1.0, 5000.0, 1);
		stepperBPM.value = funkin.Conductor.bpm;
		stepperBPM.name = 'song_bpm';

		var stepperBPMLabel = new FlxText(74,65,'BPM');
		
		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, 80, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';

		var stepperSpeedLabel = new FlxText(74,80, 'Scroll Speed');
		
		var stepperVocalVol:FlxUINumericStepper = new FlxUINumericStepper(10, 95, 0.1, 1, 0.1, 10, 1);
		stepperVocalVol.value = vocals.volume;
		stepperVocalVol.name = 'song_vocalvol';

		var stepperVocalVolLabel = new FlxText(74, 95, 'Vocal Volume');
		
		var stepperSongVol:FlxUINumericStepper = new FlxUINumericStepper(10, 110, 0.1, 1, 0.1, 10, 1);
		stepperSongVol.value = FlxG.sound.music.volume;
		stepperSongVol.name = 'song_instvol';

		var stepperSongVolLabel = new FlxText(74, 110, 'Instrumental Volume');

		var characters:Array<String> = Main.characters;

		var stages:Array<String> = ['stage', 'room', 'newRoom', 'room-pixel', 'cave', 'closet', 'principal', 'void', 'cafeteria'];

		var player1DropDown = new FlxUIDropDownMenu(10, 100, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player1 = characters[Std.parseInt(character)];
		});
		player1DropDown.selectedLabel = _song.player1;

		var player1Label = new FlxText(10,80,64, 'Player 1');

		var player2DropDown = new FlxUIDropDownMenu(140, 100, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player2 = characters[Std.parseInt(character)];
		});
		player2DropDown.selectedLabel = _song.player2;

		var player2Label = new FlxText(140,80,64, 'Player 2');

		var stageDropDown = new FlxUIDropDownMenu(140, 200, FlxUIDropDownMenu.makeStrIdLabelArray(stages, true), function(stage:String)
			{
				_song.stage = stages[Std.parseInt(stage)];
			});
		stageDropDown.selectedLabel = _song.stage;
		
		var stageLabel = new FlxText(140,180,64, 'Stage');

		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "funkin.Song";
		tab_group_song.add(UI_songTitle);
		tab_group_song.add(restart);
		tab_group_song.add(check_voices);
		tab_group_song.add(check_mute_inst);
		tab_group_song.add(saveButton);
		tab_group_song.add(reloadSong);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperBPMLabel);
		tab_group_song.add(stepperSpeed);
		tab_group_song.add(stepperSpeedLabel);
		tab_group_song.add(stepperVocalVol);
		tab_group_song.add(stepperVocalVolLabel);
		tab_group_song.add(stepperSongVol);
		tab_group_song.add(stepperSongVolLabel);

		var tab_group_assets = new FlxUI(null, UI_box);
		tab_group_assets.name = "Assets";
		tab_group_assets.add(stageDropDown);
		tab_group_assets.add(stageLabel);
		tab_group_assets.add(player1DropDown);
		tab_group_assets.add(player2DropDown);
		tab_group_assets.add(player1Label);
		tab_group_assets.add(player2Label);

		UI_box.addGroup(tab_group_song);
		UI_box.addGroup(tab_group_assets);
		UI_box.scrollFactor.set();

		FlxG.camera.follow(strumLine);
	}

	var stepperLength:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var check_altAnim:FlxUICheckBox;

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'funkin.Section';

		stepperLength = new FlxUINumericStepper(10, 10, 4, 0, 0, 256 * 2, 0);
		stepperLength.value = _song.notes[curSection].lengthInSteps;
		stepperLength.name = "section_length";

		var stepperLengthLabel = new FlxText(74,10, 'Zoom (in Steps)');

		stepperSectionBPM = new FlxUINumericStepper(10, 80, 1, funkin.Conductor.bpm, 0.1, 999, 0);
		stepperSectionBPM.value = funkin.Conductor.bpm;
		stepperSectionBPM.name = 'section_bpm';

		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 132, 1, 1, -999, 999, 0);
		var stepperCopyLabel = new FlxText(174,132, 'sections back');

		var copyButton:FlxButton = new FlxButton(10, 130, 'Copy Section', function()
		{
			copySection(Std.int(stepperCopy.value));
		});

		var clearSectionButton:FlxButton = new FlxButton(10, 150, 'Clear Section', clearSection);

		var swapSection:FlxButton = new FlxButton(10, 170, 'Swap Section', function()
		{
			for (i in 0..._song.notes[curSection].sectionNotes.length)
			{
				var note = _song.notes[curSection].sectionNotes[i];
				note[1] = (note[1] + 4) % 8;
				_song.notes[curSection].sectionNotes[i] = note;
				updateGrid();
			}
		});
		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, 'Your Turn', 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = true;
		// _song.needsVoices = check_mustHit.checked;

		check_altAnim = new FlxUICheckBox(10, 400, null, null, 'Alternate Animation', 100);
		check_altAnim.name = 'check_altAnim';

		check_changeBPM = new FlxUICheckBox(10, 60, null, null, 'Change BPM', 100);
		check_changeBPM.name = 'check_changeBPM';

		tab_group_section.add(stepperLength);
		tab_group_section.add(stepperLengthLabel);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(stepperCopyLabel);
		tab_group_section.add(check_mustHitSection);
		tab_group_section.add(check_altAnim);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(copyButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(swapSection);

		UI_box.addGroup(tab_group_section);
	}

	var stepperSusLength:FlxUINumericStepper;

	var tab_group_note:FlxUI;
	
	function addNoteUI():Void
	{
		tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		stepperSusLength = new FlxUINumericStepper(10, 10, funkin.Conductor.stepCrochet / 2, 0, 0, funkin.Conductor.stepCrochet * _song.notes[curSection].lengthInSteps * 4);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';

		var stepperSusLengthLabel = new FlxText(74,10, 'Note Length');
		tab_group_note.add(stepperSusLength);
		tab_group_note.add(stepperSusLengthLabel);

		UI_box.addGroup(tab_group_note);
	}

	function loadSong(daSong:String):Void
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		FlxG.sound.playMusic(Paths.inst(daSong), 0.6);
		vocals = new flixel.sound.FlxSound().loadEmbedded(Paths.voices(daSong));

		FlxG.sound.list.add(vocals);

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.onComplete = function()
		{
			vocals.pause();
			vocals.time = 0;
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		};
	}

	function generateUI():Void
	{
		while (bullshitUI.members.length > 0)
		{
			bullshitUI.remove(bullshitUI.members[0], true);
		}

		// general shit
		var title:FlxText = new FlxText(UI_box.x + 20, UI_box.y + 20, 0);
		bullshitUI.add(title);
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Your Turn' | 'Tu Turno':
					_song.notes[curSection].mustHitSection = check.checked;
				case 'Change BPM' | 'Cambiar BPM':
					_song.notes[curSection].changeBPM = check.checked;
					FlxG.log.add('changed bpm shit');
				case 'Alternate Animation' | 'Animacion Alternativa':
					_song.notes[curSection].altAnim = check.checked;
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
			if (wname == 'section_length')
			{
				if (nums.value <= 4)
					nums.value = 4;
				_song.notes[curSection].lengthInSteps = Std.int(nums.value);
				updateGrid();
			}
			else if (wname == 'song_speed')
			{
				if (nums.value <= 0)
					nums.value = 0;
				_song.speed = nums.value;
			}
			else if (wname == 'song_bpm')
			{
				if (nums.value <= 0)
					nums.value = 1;
				tempBpm = Std.int(nums.value);
				funkin.Conductor.mapBPMChanges(_song);
				funkin.Conductor.changeBPM(Std.int(nums.value));
			}
			else if (wname == 'note_susLength')
			{
				if (curSelectedNote == null)
					return;

				if (nums.value <= 0)
					nums.value = 0;
				curSelectedNote[2] = nums.value;
				updateGrid();
			}
			else if (wname == 'section_bpm')
			{
				if (nums.value <= 0.1)
					nums.value = 0.1;
				_song.notes[curSection].bpm = Std.int(nums.value);
				updateGrid();
			}else if (wname == 'song_vocalvol')
			{
				if (nums.value <= 0.1)
					nums.value = 0.1;
				vocals.volume = nums.value;
			}else if (wname == 'song_instvol')
			{
				if (nums.value <= 0.1)
					nums.value = 0.1;
				FlxG.sound.music.volume = nums.value;
			}
		}
	}

	var updatedSection:Bool = false;

	function stepStartTime(step):Float
	{
		return _song.bpm / (step / 4) / 60;
	}

	function sectionStartTime():Float
	{
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...curSection)
		{
			if (_song.notes[i].changeBPM)
			{
				daBPM = _song.notes[i].bpm;
			}
			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}

	var writingNotes:Bool = false;
	var doSnapShit:Bool = true;

	override function update(elapsed:Float)
	{
		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		if (FlxG.keys.justPressed.H)
			loadAutosave();
		if (FlxG.keys.justPressed.G)
			saveLevel();

		updateHeads();
		input();
		songShit();

		strumLine.y = getYfromStrum((funkin.Conductor.songPosition - sectionStartTime()) % (funkin.Conductor.stepCrochet * _song.notes[curSection].lengthInSteps));

		if (curBeat % 4 == 0 && curStep >= 16 * (curSection + 1))
		{
			trace(curStep);
			trace((_song.notes[curSection].lengthInSteps) * (curSection + 1));
			trace('new section');

			if (_song.notes[curSection + 1] == null)
				addSection();

			changeSection(curSection + 1, false);
		}

		super.update(elapsed);
	}

	function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}

		updateNoteUI();
		updateGrid();
	}

	override function beatHit() 
	{
		trace('beat');

		super.beatHit();
	}

	function recalculateSteps():Int
	{
		var lastChange:funkin.Conductor.BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...funkin.Conductor.bpmChangeMap.length)
		{
			if (FlxG.sound.music.time > funkin.Conductor.bpmChangeMap[i].songTime)
				lastChange = funkin.Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime) / funkin.Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		updateGrid();

		FlxG.sound.music.pause();
		vocals.pause();

		// Basically old shit from changeSection???
		FlxG.sound.music.time = sectionStartTime();

		if (songBeginning)
		{
			FlxG.sound.music.time = 0;
			curSection = 0;
		}

		vocals.time = FlxG.sound.music.time;
		updateCurStep();

		updateGrid();
		updateSectionUI();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		trace('changing section' + sec);

		if (_song.notes[sec] != null)
		{
			trace('naw im not null');
			curSection = sec;

			updateGrid();

			if (updateMusic)
			{
				FlxG.sound.music.pause();
				vocals.pause();

				FlxG.sound.music.time = sectionStartTime();
				vocals.time = FlxG.sound.music.time;
				updateCurStep();
			}

			updateGrid();
			updateSectionUI();
		}
		else
			trace('bro wtf I AM NULL');
	}

	function copySection(?sectionNum:Int = 1)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (note in _song.notes[daSec - sectionNum].sectionNotes)
		{
			var strum = note[0] + funkin.Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2], note[3]];
			_song.notes[daSec].sectionNotes.push(copiedNote);
		}

		updateGrid();
	}

	function updateSectionUI():Void
	{
		var sec = _song.notes[curSection];

		stepperLength.value = sec.lengthInSteps;
		check_mustHitSection.checked = sec.mustHitSection;
		check_altAnim.checked = sec.altAnim;
		check_changeBPM.checked = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;
	}

	function updateHeads():Void
	{
		if (check_mustHitSection.checked)
		{
			gridBG.color = 0x1bbedb;
			leftIcon.animation.play(_song.player1);
			rightIcon.animation.play(_song.player2);
		}
		else
		{
			gridBG.color = 0x910cac;
			leftIcon.animation.play(_song.player2);
			rightIcon.animation.play(_song.player1);
		}
	}

	function updateNoteUI():Void
	{
		if (curSelectedNote != null)
			stepperSusLength.value = curSelectedNote[2];
	}

	function updateGrid():Void
	{
		remove(gridBG);
		gridBG = flixel.addons.display.FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * _song.notes[curSection].lengthInSteps);
        add(gridBG);

		remove(gridBlackLine);
		if (gridBG != null)
		{
			gridBlackLine = new FlxSprite(gridBG.x + gridBG.width / 2).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
			add(gridBlackLine);
		}
		
		while (curRenderedNotes.members.length > 0)
		{
			curRenderedNotes.remove(curRenderedNotes.members[0], true);
		}

		while (curRenderedSustains.members.length > 0)
		{
			curRenderedSustains.remove(curRenderedSustains.members[0], true);
		}

		var sectionInfo:Array<Dynamic> = _song.notes[curSection].sectionNotes;

		if (_song.notes[curSection].changeBPM && _song.notes[curSection].bpm > 0)
		{
			funkin.Conductor.changeBPM(_song.notes[curSection].bpm);
			FlxG.log.add('CHANGED BPM!');
		}
		else
		{
			// get last bpm
			var daBPM:Float = _song.bpm;
			for (i in 0...curSection)
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;
			funkin.Conductor.changeBPM(daBPM);
		}

		for (i in sectionInfo)
		{
			var daNoteInfo = i[1];
			var daStrumTime = i[0];
			var daSus = i[2];
			var daStyle = i[3];

			var note:objects.Note = new objects.Note(daStrumTime, daNoteInfo % 4,null,false,true, daStyle);
			note.sustainLength = daSus;
			note.setGraphicSize(GRID_SIZE, GRID_SIZE);
			note.updateHitbox();
			note.x = Math.floor(daNoteInfo * GRID_SIZE);
			note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime()) % (funkin.Conductor.stepCrochet * _song.notes[curSection].lengthInSteps)));

			if (curSelectedNote != null)
				if (curSelectedNote[0] == note.strumTime)
					lastNote = note;

			curRenderedNotes.add(note);

			if (daSus > 0)
			{
				var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2),
					note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, funkin.Conductor.stepCrochet * _song.notes[curSection].lengthInSteps, 0, gridBG.height)));
				curRenderedSustains.add(sustainVis);
			}
		}
	}

	private function addSection(lengthInSteps:Int = 16):Void
	{
		var sec:SwagSection = {
			lengthInSteps: lengthInSteps,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: false
		};

		_song.notes.push(sec);
	}

	function selectNote(note:objects.Note):Void
	{
		var swagNum:Int = 0;

		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i.strumTime == note.strumTime && i.noteData % 4 == note.noteData)
			{
				curSelectedNote = _song.notes[curSection].sectionNotes[swagNum];
			}

			swagNum += 1;
		}

		updateGrid();
		updateNoteUI();
	}


	function deleteNote(note:objects.Note):Void
		{
			lastNote = note;
			for (i in _song.notes[curSection].sectionNotes)
			{
				if (i[0] == note.strumTime && i[1] % 4 == note.noteData)
				{
					_song.notes[curSection].sectionNotes.remove(i);
				}
			}
	
			updateGrid();
		}

	function clearSection():Void
	{
		_song.notes[curSection].sectionNotes = [];

		updateGrid();
	}

	function clearSong():Void
	{
		for (daSection in 0..._song.notes.length)
		{
			_song.notes[daSection].sectionNotes = [];
		}

		updateGrid();
	}

	private function newSection(lengthInSteps:Int = 16,mustHitSection:Bool = false,altAnim:Bool = true):SwagSection
		{
			var sec:SwagSection = {
				lengthInSteps: lengthInSteps,
				bpm: _song.bpm,
				changeBPM: false,
				mustHitSection: mustHitSection,
				sectionNotes: [],
				typeOfSection: 0,
				altAnim: altAnim
			};

			return sec;
		}

	function shiftNotes(measure:Int=0,step:Int=0,ms:Int = 0):Void
		{
			var newSong = [];
			
			var millisecadd = (((measure*4)+step/4)*(60000/_song.bpm))+ms;
			var totaladdsection = Std.int((millisecadd/(60000/_song.bpm)/4));
			trace(millisecadd,totaladdsection);
			if(millisecadd > 0)
				{
					for(i in 0...totaladdsection)
						{
							newSong.unshift(newSection());
						}
				}
			for (daSection1 in 0..._song.notes.length)
				{
					newSong.push(newSection(16,_song.notes[daSection1].mustHitSection,_song.notes[daSection1].altAnim));
				}
	
			for (daSection in 0...(_song.notes.length))
			{
				var aimtosetsection = daSection+Std.int((totaladdsection));
				if(aimtosetsection<0) aimtosetsection = 0;
				newSong[aimtosetsection].mustHitSection = _song.notes[daSection].mustHitSection;
				newSong[aimtosetsection].altAnim = _song.notes[daSection].altAnim;
				//trace("section "+daSection);
				for(daNote in 0...(_song.notes[daSection].sectionNotes.length))
					{	
						var newtiming = _song.notes[daSection].sectionNotes[daNote][0]+millisecadd;
						if(newtiming<0)
						{
							newtiming = 0;
						}
						var futureSection = Math.floor(newtiming/4/(60000/_song.bpm));
						_song.notes[daSection].sectionNotes[daNote][0] = newtiming;
						newSong[futureSection].sectionNotes.push(_song.notes[daSection].sectionNotes[daNote]);
	
						//newSong.notes[daSection].sectionNotes.remove(_song.notes[daSection].sectionNotes[daNote]);
					}
	
			}
			//trace("DONE BITCH");
			_song.notes = newSong;
			updateGrid();
			updateSectionUI();
			updateNoteUI();
		}

	private function addNote(?n:objects.Note):Void
	{
		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime();
		var noteData = Math.floor(FlxG.mouse.x / GRID_SIZE);
		var noteSus = 0;

		var noteStyle = styles[this.noteStyle];

		if (n != null)
			_song.notes[curSection].sectionNotes.push([n.strumTime, n.noteData, n.sustainLength, n.noteStyle]);
		else
			_song.notes[curSection].sectionNotes.push([noteStrum, noteData, noteSus, noteStyle]);

		var thingy = _song.notes[curSection].sectionNotes[_song.notes[curSection].sectionNotes.length - 1];

		curSelectedNote = thingy;

		updateGrid();
		updateNoteUI();

		autosaveSong();
	}

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * funkin.Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, 16 * funkin.Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}

	private var daSpacing:Float = 0.3;

	function loadLevel():Void
	{
		trace(_song.notes);
	}

	function getNotes():Array<Dynamic>
	{
		var noteData:Array<Dynamic> = [];

		for (i in _song.notes)
		{
			noteData.push(i.sectionNotes);
		}

		return noteData;
	}

	function loadJson(song:String):Void
	{
		states.PlayState.SONG = funkin.Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
		
		LoadingState.loadAndSwitchState(new ChartingState());
	}

	function loadAutosave():Void
	{
		states.PlayState.SONG = funkin.Song.parseJSONshit(data.KadeEngineData.other.data.autosave);
		
		LoadingState.loadAndSwitchState(new ChartingState());
	}

	function autosaveSong():Void
	{
		data.KadeEngineData.other.data.autosave = Json.stringify({
			"song": _song
		});
		data.KadeEngineData.flush();
	}

	private function saveLevel()
	{
		var json = {
			"song": _song
		};

		var data:String = Json.stringify(json);

		if ((data != null) && (data.length > 0))
		{
			_file = new openfl.net.FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), _song.song.toLowerCase() + ".json");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}

	private function input():Void
	{
		if (!typingShit.hasFocus)
		{
			if (FlxG.keys.pressed.CONTROL)
				{
					if (FlxG.keys.justPressed.Z && lastNote != null)
					{
						trace(curRenderedNotes.members.contains(lastNote) ? "delete note" : "add note");
						if (curRenderedNotes.members.contains(lastNote))
							deleteNote(lastNote);
						else 
							addNote(lastNote);
					}
				}
	
				var shiftThing:Int = 1;
				if (FlxG.keys.pressed.SHIFT)
					shiftThing = 4;
				if (!FlxG.keys.pressed.CONTROL)
				{
					if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
						changeSection(curSection + shiftThing);
					if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
						changeSection(curSection - shiftThing);
				}	
				if (FlxG.keys.justPressed.SPACE)
				{
					if (FlxG.sound.music.playing)
					{
						FlxG.sound.music.pause();
						vocals.pause();
						claps.splice(0, claps.length);
					}
					else
					{
						vocals.play();
						FlxG.sound.music.play();
					}
				}

				if (FlxG.keys.justPressed.Z || FlxG.keys.justPressed.X)
					{
						var noteStyleString:String;

						if (FlxG.keys.justPressed.Z)
							this.noteStyle--;
						else if (FlxG.keys.justPressed.X)
							this.noteStyle++;

						if (noteStyle < 0)
							noteStyle = styles.length - 1;
						else if (noteStyle > styles.length - 1)
							noteStyle = 0;

						switch(noteStyle)
						{
							case 0:	noteStyleString = "Normal";
							case 1:	noteStyleString = "Poisoned Nugget";
							case 2:	noteStyleString = "Bullet";
							case 3:	noteStyleString = "Apple";
							default:noteStyleString = "NULL";
						}

						noteStyleTxt.text = 'Note Type: $noteStyleString\n(X or Z to change)';
					}
	
				if (FlxG.keys.justPressed.R)
				{
					if (FlxG.keys.pressed.SHIFT)
						resetSection(true);
					else
						resetSection();
				}
	
				if (FlxG.mouse.wheel != 0)
					{
						FlxG.sound.music.pause();
						vocals.pause();
						claps.splice(0, claps.length);
		
						var stepMs = curStep * funkin.Conductor.stepCrochet;
		
						trace(funkin.Conductor.stepCrochet / snap);
		
						if (doSnapShit)
							FlxG.sound.music.time = stepMs - (FlxG.mouse.wheel * funkin.Conductor.stepCrochet / snap);
						else
							FlxG.sound.music.time -= (FlxG.mouse.wheel * funkin.Conductor.stepCrochet * 0.4);
		
						trace(stepMs + " + " + funkin.Conductor.stepCrochet / snap + " -> " + FlxG.sound.music.time);
		
						vocals.time = FlxG.sound.music.time;
					}
		
					if (!FlxG.keys.pressed.SHIFT)
					{
						if (FlxG.keys.pressed.W || FlxG.keys.pressed.S)
						{
							FlxG.sound.music.pause();
							vocals.pause();
							claps.splice(0, claps.length);
		
							var daTime:Float = 700 * FlxG.elapsed;
		
							if (FlxG.keys.pressed.W)
								FlxG.sound.music.time -= daTime;
							else
								FlxG.sound.music.time += daTime;
		
							vocals.time = FlxG.sound.music.time;
						}
					}
					else
					{
						if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S)
						{
							FlxG.sound.music.pause();
							vocals.pause();
		
							var daTime:Float = funkin.Conductor.stepCrochet * 2;
		
							if (FlxG.keys.justPressed.W)
								FlxG.sound.music.time -= daTime;
							else
								FlxG.sound.music.time += daTime;
		
							vocals.time = FlxG.sound.music.time;
						}
					}
		}

		if (FlxG.mouse.justPressed)
			{
				if (FlxG.mouse.overlaps(curRenderedNotes))
				{
					curRenderedNotes.forEach(function(note:objects.Note)
					{
						if (FlxG.mouse.overlaps(note))
						{
							if (FlxG.keys.pressed.CONTROL)
								selectNote(note);
							else
								deleteNote(note);
						}
					});
				}
				else
				{
					if (FlxG.mouse.x > gridBG.x
						&& FlxG.mouse.x < gridBG.x + gridBG.width
						&& FlxG.mouse.y > gridBG.y
						&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
					{
						FlxG.log.add('added note');
						addNote();
					}
				}
			}
	
			if (FlxG.mouse.x > gridBG.x
				&& FlxG.mouse.x < gridBG.x + gridBG.width
				&& FlxG.mouse.y > gridBG.y
				&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
			{
				dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
				if (FlxG.keys.pressed.SHIFT)
					dummyArrow.y = FlxG.mouse.y;
				else
					dummyArrow.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
			}
	
			if (FlxG.keys.justPressed.ENTER)
			{
				lastSection = curSection;
	
				states.PlayState.SONG = _song;
				FlxG.sound.music.stop();
				vocals.stop();

				LoadingState.loadAndSwitchState(new states.PlayState());
			}
	
			if (FlxG.keys.justPressed.E)
				changeNoteSustain(funkin.Conductor.stepCrochet);
			if (FlxG.keys.justPressed.Q)
				changeNoteSustain(-funkin.Conductor.stepCrochet);
	
			if (FlxG.keys.justPressed.TAB)
			{
				if (FlxG.keys.pressed.SHIFT)
				{
					UI_box.selected_tab -= 1;
					if (UI_box.selected_tab < 0)
						UI_box.selected_tab = 2;
				}
				else
				{
					UI_box.selected_tab += 1;
					if (UI_box.selected_tab >= 3)
						UI_box.selected_tab = 0;
				}
			}

		var pressArray = [FlxG.keys.justPressed.ONE, FlxG.keys.justPressed.TWO, FlxG.keys.justPressed.THREE, FlxG.keys.justPressed.FOUR, FlxG.keys.justPressed.FIVE, FlxG.keys.justPressed.SIX, FlxG.keys.justPressed.SEVEN, FlxG.keys.justPressed.EIGHT];
		var delete = false;
		curRenderedNotes.forEach(function(note:objects.Note)
			{
				if (strumLine.overlaps(note) && pressArray[Math.floor(Math.abs(note.noteData))])
				{
					deleteNote(note);
					delete = true;
					trace('deelte note');
				}
			});
		for (p in 0...pressArray.length)
		{
			var i = pressArray[p];
			if (i && !delete)
				addNote(new objects.Note(funkin.Conductor.songPosition,p));
		}
	}

	private function songShit():Void
	{
		curStep = recalculateSteps();
		funkin.Conductor.songPosition = FlxG.sound.music.time;
		if (!typingShit.hasFocus)
			{	
				if (FlxG.sound.music.time < 0 || curStep < 0)
					FlxG.sound.music.time = 0;
			}

		bpmTxt.text = Std.string(FlxMath.roundDecimal(funkin.Conductor.songPosition / 1000, 1))
			+ " / "
			+ Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2))
			+ "\nSection: "
			+ curSection 
			+ "\nCurStep: " 
			+ curStep
			+ "\nCurBeat: " 
			+ curBeat;

		_song.song = typingShit.text;
		_song.bpm = tempBpm;
	}
}