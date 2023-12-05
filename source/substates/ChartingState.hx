package substates;

import flixel.util.FlxStringUtil;
import funkin.Song;
import states.PlayState;
import data.KadeEngineData;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.display.FlxGridOverlay;
import flixel.sound.FlxSound;
import flixel.addons.ui.FlxInputText;
import funkin.Song.SwagSong;
import objects.ChartNote;
import objects.HealthIcon;
import flixel.addons.ui.FlxUITabMenu;
import funkin.Conductor;
import openfl.net.FileReference;
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
	private inline static final GRID_SIZE:Int = 40;
	public static var lastSection:Int = 0;

	private var _file:FileReference;
	private var UI_box:FlxUITabMenu;
	private var curSection:Int = 0;
	private var bpmTxt:FlxText;
	private var strumLine:FlxSprite;
	private var dummyArrow:FlxSprite;

	private var notes:FlxTypedGroup<ChartNote>;
	private var sustains:FlxTypedGroup<ChartSustain>;

	private var gridBG:FlxSprite;
	private var _song:SwagSong;

	private var songTitleTxt:FlxInputText;
	private var curSelectedNote:Array<Dynamic>;

	private var tempBpm:Float = 0;
	private var gridBlackLine:FlxSprite;

	private var inst:FlxSound;
	private var vocals:FlxSound;

	private var leftIcon:HealthIcon;
	private var rightIcon:HealthIcon;

	private var noteStyle:Int = 0;
	private var styles:Array<String> = ['n', 'nuggetP', /* 'nuggetN', 'gum', */ 'b', 'apple'];
	private var noteStyleTxt:FlxText;

	private var check_mustHitSection:FlxUICheckBox;
	private var check_changeBPM:FlxUICheckBox;
	private var stepperSectionBPM:FlxUINumericStepper;

	override function create()
	{
		ChartNote.daFrames = Paths.getSparrowAtlas('gameplay/notes/NOTE_assets', 'shared');
		curSection = lastSection;

		if (PlayState.SONG != null)
			_song = PlayState.SONG;
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
				speed: 1
			};
		}

		var saul = new FlxSprite();
		saul.frames = Paths.getSparrowAtlas('menu/credits_assets', 'preload');
		saul.animation.addByPrefix('idle', 'saul hombre bueno', 0, false);
		saul.animation.play('idle');
		saul.active = false;
		saul.screenCenter();
		saul.scrollFactor.set();
		saul.color = FlxColor.GRAY;
		add(saul);

		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);
		gridBG.active = false;
		add(gridBG);

		var gridBlackLine = new FlxSprite(gridBG.x + gridBG.width / 2).makeGraphic(1, 1, FlxColor.BLACK);
		gridBlackLine.scale.set(2, Std.int(gridBG.height));
		gridBlackLine.updateHitbox();
		gridBlackLine.active = false;
		add(gridBlackLine);

		// create chartnote and chartsustain or both n the same oney
		notes = new FlxTypedGroup<ChartNote>();
		sustains = new FlxTypedGroup<ChartSustain>();

		tempBpm = _song.bpm;

		addSection();
		updateGrid();

		loadSong(_song.song);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		leftIcon = new HealthIcon(_song.player1);
		rightIcon = new HealthIcon(_song.player2);
		leftIcon.scrollFactor.set(1, 1);
		rightIcon.scrollFactor.set(1, 1);
		leftIcon.active = false;
		rightIcon.active = false;

		leftIcon.setGraphicSize(0, 45);
		rightIcon.setGraphicSize(0, 45);

		add(leftIcon);
		add(rightIcon);

		leftIcon.setPosition(0, -100);
		rightIcon.setPosition(gridBG.width / 2, -100);

		bpmTxt = new FlxText(20, 90, FlxG.width, "", 40);
		bpmTxt.autoSize = false;
		bpmTxt.active = false;
		bpmTxt.setFormat(Paths.font('vcr.ttf'), 30, FlxColor.BLACK, LEFT, OUTLINE, FlxColor.WHITE);
		bpmTxt.scrollFactor.set();
		bpmTxt.borderSize = 1.5;
		bpmTxt.active = false;
		bpmTxt.antialiasing = false;
		add(bpmTxt);

		strumLine = new FlxSprite(0, 50).makeGraphic(1, 1);
		strumLine.scale.set(GRID_SIZE * 8, 4);
		strumLine.updateHitbox();
		strumLine.active = false;
		add(strumLine);
		FlxG.camera.follow(strumLine);

		dummyArrow = new FlxSprite().makeGraphic(1, 1);
		dummyArrow.scale.set(GRID_SIZE, GRID_SIZE);
		dummyArrow.updateHitbox();
		dummyArrow.active = false;
		add(dummyArrow);

		UI_box = new FlxUITabMenu(null, [{name: "Song", label: 'Song Data'},
			{name: "Section", label: 'Section Data'}
		], true);
		UI_box.resize(300, 200);
		UI_box.setPosition(FlxG.width - 385, 50);
		UI_box.scrollFactor.set();
		add(UI_box);

		addSongUI();
		addSectionUI();

		add(notes);
		add(sustains);

		noteStyleTxt = new FlxText(20, 0, FlxG.width, "Note Type: Normal\n(X or Z to change)", 20);
		noteStyleTxt.autoSize = false;
		noteStyleTxt.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.BLACK, LEFT, OUTLINE, FlxColor.WHITE);
		noteStyleTxt.scrollFactor.set();
		noteStyleTxt.borderSize = 1.50;
		noteStyleTxt.active = false;
		noteStyleTxt.antialiasing = false;
		noteStyleTxt.y = FlxG.height - noteStyleTxt.height - 20;
		add(noteStyleTxt);

		var infoText = new FlxText(0, 0, FlxG.width, '[Controls]:\n\nSPACE: Pause/resume\n\nR: Restart section (Hold shift to restart song)\n\nA/D/Left/Right:\nChange 1 section (Hold shift for 4)\n\nW/S/Up/Down/Mouse wheel:\nGo backwards/forward (Hold shift = faster)\n\nE/Q: Increase/decrease hold note\n\nENTER: Test chart', 32);
        infoText.autoSize = false;
        infoText.alignment = RIGHT;
		infoText.scrollFactor.set();
        infoText.font = Paths.font('Crayawn-v58y.ttf');
        infoText.active = false;
		infoText.setPosition(FlxG.width - 10 - infoText.width, FlxG.height - 10 - infoText.height);
		add(infoText);

		resetSection();

		super.create();
	}

	private function addSongUI():Void
	{
		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";


		songTitleTxt = new FlxUIInputText(10, 10, 70, _song.song, 8);
		tab_group_song.add(songTitleTxt);


		var check_mute_inst = new FlxUICheckBox(10, 130, null, null, 'Mute Instrumental', 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_inst.checked)
				vol = 0;

			inst.volume = vol;
		};
		tab_group_song.add(check_mute_inst);


		var saveButton = new FlxButton(110, 8, 'Save', saveLevel);
		tab_group_song.add(saveButton);


		var reloadSong = new FlxButton(saveButton.x + saveButton.width + 10, saveButton.y, 'Reload Audio', function() loadSong(_song.song) );
		tab_group_song.add(reloadSong);


		var reloadSongJson = new FlxButton(reloadSong.x, saveButton.y + 30, 'Reload JSON', function() loadJson(_song.song.toLowerCase()) );
		tab_group_song.add(reloadSongJson);


		var restart = new FlxButton(110, reloadSongJson.y, 'Reset Chart', function()
		{
			for (ii in 0..._song.notes.length)
				for (i in 0..._song.notes[ii].sectionNotes.length)
					_song.notes[ii].sectionNotes = [];

			resetSection(true);
		});
		tab_group_song.add(restart);


		var loadAutosaveBtn = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'Load Autosave', loadAutosave);
		tab_group_song.add(loadAutosaveBtn);


		var stepperBPM = new FlxUINumericStepper(10, 65, 1, 100, 1, 999, 0);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';
		tab_group_song.add(stepperBPM);

		var stepperBPMTxt = new FlxText(74,65, 'BPM');
		stepperBPMTxt.active = false;
		tab_group_song.add(stepperBPMTxt);


		var stepperSpeed = new FlxUINumericStepper(10, 80, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';
		tab_group_song.add(stepperSpeed);

		var stepperSpeedTxt = new FlxText(74,80, 'Scroll Speed');
		stepperSpeedTxt.active = false;
		tab_group_song.add(stepperSpeedTxt);


		var stepperSongVol = new FlxUINumericStepper(10, 95, 0.1, 1, 0.1, 1, 1);
		stepperSongVol.value = inst.volume;
		stepperSongVol.name = 'song_instvol';
		tab_group_song.add(stepperSongVol);

		var stepperSongVolTxt = new FlxText(74, 95, 'Instrumental Volume');
		stepperSongVolTxt.active = false;
		tab_group_song.add(stepperSongVolTxt);


		final stages:Array<String> = ['stage', 'room', 'newRoom', 'room-pixel', 'cave', 'closet', 'principal', 'void', 'cafeteria'];

		var stageDropDown = new FlxUIDropDownMenu(140, check_mute_inst.y, FlxUIDropDownMenu.makeStrIdLabelArray(stages, true), function(stage:String) _song.stage = stages[Std.parseInt(stage)] );
		stageDropDown.selectedLabel = _song.stage;
		stageDropDown.active = false;
		tab_group_song.add(stageDropDown);
		
		var stageTxt = new FlxText(140, check_mute_inst.y - 15,64, 'Stage');
		stageTxt.active = false;
		tab_group_song.add(stageTxt);


		UI_box.addGroup(tab_group_song);
	}

	private function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';


		stepperSectionBPM = new FlxUINumericStepper(10, 50, 1, Conductor.bpm, 0.1, 999, 0);
		stepperSectionBPM.value = Conductor.bpm;
		stepperSectionBPM.name = 'section_bpm';
		tab_group_section.add(stepperSectionBPM);


		var stepperCopy = new FlxUINumericStepper(110, stepperSectionBPM.y + stepperSectionBPM.height + 10, 1, 1, -999, 999, 0);
		tab_group_section.add(stepperCopy);

		var stepperCopyLabel = new FlxText(174, stepperSectionBPM.y + stepperSectionBPM.height + 15, 'Sections back');
		stepperCopyLabel.active = false;
		tab_group_section.add(stepperCopyLabel);


		var copyButton = new FlxButton(10, stepperSectionBPM.y + stepperSectionBPM.height + 10, 'Copy Section', function() copySection(Std.int(stepperCopy.value)) );
		tab_group_section.add(copyButton);


		var clearSectionButton = new FlxButton(10, copyButton.y + copyButton.height, 'Clear Section', clearSection);
		tab_group_section.add(clearSectionButton);


		var swapSection = new FlxButton(10, clearSectionButton.y + clearSectionButton.height, 'Swap Section', function()
		{
			for (i in 0..._song.notes[curSection].sectionNotes.length)
			{
				var note = _song.notes[curSection].sectionNotes[i];
				note[1] = (note[1] + 4) % 8;
				_song.notes[curSection].sectionNotes[i] = note;
				updateGrid();
			}
		});
		tab_group_section.add(swapSection);


		check_mustHitSection = new FlxUICheckBox(10, 10, null, null, 'BF Turn', 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = _song.notes[curSection].mustHitSection;
		tab_group_section.add(check_mustHitSection);


		check_changeBPM = new FlxUICheckBox(10, 30, null, null, 'Change BPM', 100);
		check_changeBPM.name = 'check_changeBPM';
		tab_group_section.add(check_changeBPM);


		UI_box.addGroup(tab_group_section);
	}

	private function loadSong(daSong:String):Void
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		if (inst != null)
			inst.stop();

		inst = new FlxSound().loadEmbedded(Paths.inst(daSong));
		FlxG.sound.list.add(inst);

		vocals = new FlxSound().loadEmbedded(Paths.voices(daSong));

		FlxG.sound.list.add(vocals);

		inst.pause();
		vocals.pause();

		inst.onComplete = function()
		{
			vocals.pause();
			vocals.time = 0;
			inst.pause();
			inst.time = 0;
			changeSection();
		};
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;

			switch (check.getLabel().text)
			{
				case 'BF Turn':
					_song.notes[curSection].mustHitSection = check.checked;
					updateSectionUI();
				case 'Change BPM':
					_song.notes[curSection].changeBPM = check.checked;
					updateSectionUI();
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;

			switch (nums.name)
			{
				case 'song_speed':
					if (nums.value <= 0)
						nums.value = 0;

					_song.speed = nums.value;

				case 'song_bpm':
					if (nums.value <= 0)
						nums.value = 1;

					tempBpm = Std.int(nums.value);

					Conductor.mapBPMChanges(_song);
					Conductor.changeBPM(Std.int(nums.value));

				case 'section_bpm':
					if (nums.value <= 0.1)
						nums.value = 0.1;

					_song.notes[curSection].bpm = Std.int(nums.value);

					updateGrid();
					updateSectionUI();

				case 'song_instvol':
					if (nums.value <= 0.1)
						nums.value = 0.1;

					inst.volume = nums.value;
			}
		}
	}

	private inline function sectionStartTime():Float
	{
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;

		for (i in 0...curSection)
		{
			if (_song.notes[i].changeBPM)
				daBPM = _song.notes[i].bpm;

			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}

	override function update(elapsed:Float)
	{
		updateSongPosition();
		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps));

		super.update(elapsed);

		input();
	}

	private function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}

		updateGrid();
	}

	private inline function recalculateSteps():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (inst.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((inst.time - lastChange.songTime) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	private function resetSection(songBeginning:Bool = false):Void
	{
		updateGrid();

		inst.pause();
		vocals.pause();

		// Basically old shit from changeSection???
		inst.time = sectionStartTime();

		if (songBeginning)
		{
			inst.time = 0;
			curSection = 0;
		}

		vocals.time = inst.time;
		updateCurStep();

		updateGrid();
		updateSectionUI();
	}

	private function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		if (_song.notes[sec] != null)
		{
			trace('Changing to section: $sec.');

			curSection = sec;
			if (updateMusic)
			{
				inst.pause();
				vocals.pause();

				inst.time = sectionStartTime();
				vocals.time = inst.time;
				updateCurStep();
			}

			updateGrid();
			updateSectionUI();
		}
		else
			trace('Section $sec is null!');
	}

	private function copySection(?sectionNum:Int = 1)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (note in _song.notes[daSec - sectionNum].sectionNotes)
		{
			var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);

			_song.notes[daSec].sectionNotes.push([strum, note[1], note[2], note[3]]);
		}

		updateGrid();
	}

	private inline function updateSectionUI():Void
	{
		var sec = _song.notes[curSection];

		check_mustHitSection.checked = sec.mustHitSection;
		check_changeBPM.checked = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;

		updateHeads();
	}

	private inline function updateHeads():Void
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

	private function updateGrid():Void
	{
		if (gridBG == null || gridBlackLine == null || gridBG.height != GRID_SIZE * _song.notes[curSection].lengthInSteps)
		{
			trace('Recreating grid.');

			remove(gridBG);
			gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * _song.notes[curSection].lengthInSteps);
			add(gridBG);

			if (gridBlackLine == null)
			{
				gridBlackLine = new FlxSprite(gridBG.x + gridBG.width / 2).makeGraphic(1, 1, FlxColor.BLACK);
				gridBlackLine.scale.set(2, Std.int(gridBG.height));
				gridBlackLine.updateHitbox();
				add(gridBlackLine);
			}
			else
			{
				gridBlackLine.setPosition(gridBG.x + gridBG.width / 2);
				gridBlackLine.scale.set(2, Std.int(gridBG.height));
				gridBlackLine.updateHitbox();
			}
		}

		notes.forEachAlive(function(spr:ChartNote) spr.kill());
		sustains.forEachAlive(function(spr:ChartSustain) spr.kill());

		var sectionInfo:Array<Dynamic> = _song.notes[curSection].sectionNotes;

		if (_song.notes[curSection].changeBPM && _song.notes[curSection].bpm > 0)
		{
			Conductor.changeBPM(_song.notes[curSection].bpm);
		}
		else
		{
			var daBPM:Float = _song.bpm;

			for (i in 0...curSection)
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;

			Conductor.changeBPM(daBPM);
		}

		for (i in sectionInfo)
		{
			var daStrumTime:Float = i[0];
			var daNoteInfo:Int = i[1];
			var daSus:Float = i[2];
			var daStyle:String = i[3];

			var note = notes.recycle(ChartNote.new);
			note.play(daStrumTime, daNoteInfo % 4, daSus, daStyle, Math.floor(daNoteInfo * GRID_SIZE), Math.floor(getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps))), GRID_SIZE);
			notes.add(note);

			if (daSus > 0)
			{
				var sustainVis = sustains.recycle(ChartSustain.new);
				sustainVis.play(daNoteInfo % 4, daSus, note.x + (GRID_SIZE / 2) - 4, note.y + GRID_SIZE, gridBG.height);
				sustains.add(sustainVis);
			}
		}
	}

	private function addSection(lengthInSteps:Int = 16):Void
	{
		var sec:SwagSection = 
		{
			lengthInSteps: lengthInSteps,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			sectionNotes: [],
			typeOfSection: 0
		};

		_song.notes.push(sec);
	}

	private function deleteNote(note:ChartNote):Void
	{
		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i[0] == note.strumTime && i[1] % 4 == note.noteData)
			{
				_song.notes[curSection].sectionNotes.remove(i);
			}
		}

		updateGrid();
	}

	private function clearSection():Void
	{
		_song.notes[curSection].sectionNotes = [];

		updateGrid();
	}

	private function addNote(?n:ChartNote):Void
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
		autosaveSong();
	}

	private inline function getStrumTime(yPos:Float):Float
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);

	private inline function getYfromStrum(strumTime:Float):Float
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);

	private function loadJson(song:String):Void
	{
		PlayState.SONG = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
		LoadingState.loadAndSwitchState(new ChartingState());
	}

	private function loadAutosave():Void
	{
		KadeEngineData.flush();

		PlayState.SONG = Song.parseJSONshit(KadeEngineData.other.data.autosave);
		LoadingState.loadAndSwitchState(new ChartingState());
	}

	private function autosaveSong():Void
	{
		KadeEngineData.other.data.autosave = Json.stringify({
			"song": _song
		});

		// data SHOULD be saved when the game is closed so there's no need to save it everytime you place a note because that increases memory usage
		// KadeEngineData.flush();
	}

	private function saveLevel()
	{
		var json = 
		{
			"song": _song
		};

		var data:String = Json.stringify(json, "\t");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), _song.song.toLowerCase() + ".json");
		}
	}

	private function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	private function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	private function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	private function input():Void
	{
		dummyArrow.visible = FlxG.mouse.overlaps(gridBG) && !songTitleTxt.hasFocus;

		if (!songTitleTxt.hasFocus)
		{
			final shiftThing:Int = (FlxG.keys.pressed.SHIFT ? 4 : 1);

			if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
				changeSection(curSection + shiftThing);
			if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
				changeSection(curSection - shiftThing);

			if (FlxG.keys.justPressed.SPACE)
			{
				if (inst.playing)
				{
					inst.pause();
					vocals.pause();
				}
				else
				{
					vocals.play();
					inst.play();
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
	
			final up:Bool = FlxG.keys.pressed.W || FlxG.keys.pressed.UP;
			final down:Bool = FlxG.keys.pressed.S || FlxG.keys.pressed.DOWN;

			if (up || down || FlxG.mouse.wheel != 0)
			{
				inst.pause();
				vocals.pause();

				var daTime:Float = ((700 * FlxG.elapsed) * (FlxG.keys.pressed.SHIFT ? 4 : 1)) * (FlxG.mouse.wheel != 0 ? 13 : 1);

				if (up || FlxG.mouse.wheel > 0)
					inst.time -= daTime;
				else if (down || FlxG.mouse.wheel < 0)
					inst.time += daTime;

				vocals.time = inst.time;
			}

			final overlaping_grid:Bool = FlxG.mouse.x > gridBG.x && FlxG.mouse.x < gridBG.x + gridBG.width && FlxG.mouse.y > gridBG.y && FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps);

			if (FlxG.mouse.justPressed)
			{
				if (FlxG.mouse.overlaps(notes))
				{
					notes.forEach(function(note:ChartNote)
					{
						if (FlxG.mouse.overlaps(note))
							deleteNote(note);
					});
				}
				else
				{
					if (overlaping_grid)
						addNote();
				}
			}
		
			if (overlaping_grid)
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
	
				PlayState.SONG = _song;
				inst.stop();
				vocals.stop();
	
				LoadingState.loadAndSwitchState(new PlayState());
			}
	
			if (FlxG.keys.justPressed.E)
				changeNoteSustain(Conductor.stepCrochet);
			if (FlxG.keys.justPressed.Q)
				changeNoteSustain(-Conductor.stepCrochet);
		}
	}

	private function updateSongPosition():Void
	{
		curStep = recalculateSteps();
		Conductor.songPosition = inst.time;

		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		if (Conductor.songPosition < sectionStartTime())
		{
			if (_song.notes[curSection - 1] == null)
				addSection();

			changeSection(curSection - 1, false);
		}

		if (curBeat % 4 == 0 && curStep >= 16 * (curSection + 1))
		{
			if (_song.notes[curSection + 1] == null)
				addSection();
	
			changeSection(curSection + 1, false);
		}

		if (!songTitleTxt.hasFocus)
		{	
			if (inst.time < 0 || curStep < 0)
				inst.time = 0;
		}

		var currentTime = FlxStringUtil.formatTime(Conductor.songPosition / 1000, true);
		var duration    = FlxStringUtil.formatTime(inst.length / 1000, true);
		bpmTxt.text = 'Time: $currentTime - $duration\nSection: $curSection\nSection notes: ${_song.notes[curSection].sectionNotes.length}\n\nCurBeat: $curBeat\nCurStep: $curStep';

		_song.song = songTitleTxt.text;
		_song.bpm = tempBpm;

		notes.forEachAlive(function(note:ChartNote)
		{
			note.alpha = (note.strumTime < Conductor.songPosition ? 0.6 : 1);
		});

		sustains.forEachAlive(function(note:ChartSustain)
		{
			note.alpha = (note.y < strumLine.y ? 0.6 : 1);
		});
	}
}