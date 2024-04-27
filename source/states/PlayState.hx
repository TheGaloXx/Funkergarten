package states;

import objects.NoteSplash.GumTrap;
import debug.StageDebug;
import debug.ChartingState;
import debug.AnimationDebug;

import flixel.*;
import flixel.group.*;
import flixel.group.FlxGroup;

import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.sound.FlxSound;
import flixel.input.keyboard.FlxKey;
import flixel.addons.transition.FlxTransitionableState;

import substates.GameOverSubstate;
import substates.CustomFadeTransition;

import data.FCs;
import data.Ratings;
import data.GlobalData;

import funkin.*;
import funkin.Song.SwagSong;
import funkin.SongEvents.EpicEvent;

import objects.*;
import objects.Objects;

import openfl.events.KeyboardEvent;
import openfl.filters.ShaderFilter;

import Shaders;

using StringTools;

class PlayState extends MusicBeatState
{
	// - [ General data]
	// --- [ Static variables (to have access to from other classes) ]
	public static var instance:PlayState = null;
	public static var isStoryMode:Bool = false;
	public static var SONG:SwagSong;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var tries:Int = 0;
	public static var isPixel:Bool;
	public static var scoreData = 
	{
		shits: 0,
		bads: 0,
		goods: 0,
		sicks: 0,
		misses: 0,

		combo: 0,
		accuracy: 0.00
	}

	// --- [ Other data]
	private var songLength:Float = 0;
	public var defaultCamZoom:Float = 1;

	private var events:Array<EpicEvent> = [];
	private var unspawnNotes:Array<Note> = [];

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;
	private var canTweenCam:Bool = true;
	private var canDoCamSpot:Bool = true;
	private var inCutscene:Bool = false;
	private var isExpellinTime:Bool = false;
	private var songFinished:Bool = false;
	private var inChartNoteTypes:Array<String> = [];

	private final janitorKys:Bool = FlxG.random.bool(15);

	//code from carol and whitty date week
	private var notestrumtimes1:Array<Float> = [];
	private var notestrumtimes2:Array<Float> = [];

	private var songScore:Int = 0;
	private var songScoreDef:Int = 0;
	private var storyDifficultyText:String;

	private var cameraBopBeat:Float = 2;
	private var pixelShit:MosaicEffect;
	private var chromVal:Float = 0;
	private var chromTween:FlxTween;

	// --- [ Gameplay stuff]
	private var mechanicsOn(get, default):Bool;
	private var shadersOn(get, default):Bool;
	private var health:Float = 1;
	private var lerpHealth:Float = 1; // From the actual full-ass game!!!
	private var totalNotesHit:Float = 0;
	private var totalPlayed:Int = 0;
	private var poisonStacks:Int = 0;
	private var actions:Int;
	private final difficultiesStuff:Map<String, Array<Dynamic>> =
	[
		//variable				easy		normal		hard	survivor
		"appleHealthGain"   => [2, 			1, 		    0.75, 	1],
		"appleHealthLoss"   => [0, 			0.5, 		0.75, 	0.5],
		"gumTrapTime" 	    => [0.1,		3, 			6, 		12],
		"healthDrainPoison" => [0, 			0.25, 		0.2, 	0.3],
		"janitorHits"       => [999999, 	32, 		16, 	8],
		"mopHealthLoss"     => [0, 			-0.5, 		-1, 	-1],
    	"janitorAccuracy"   => [0, 			70, 		90, 	95],
		"principalPixel"	=> [null,		2, 			6, 	    12],
		"montyYoyo"			=> [0,			0.75,		1,		1],
		"yoyoFrequency"     => [999999,		50,         35,     10],
		"pollaAlpha"        => [0,          0.6,        1,      1],
		"expelledAngle"     => [0,          5,          20,     60],
		"monsterDrain"      => [0,          0.05,       0.1,    0.5],
		"specimenNoteSpeed" => [0,          0.075,      0.125,  0.3]
	];

	//gum mechanic
	private var gumNotes:FlxTypedGroup<GumTrap>;
	private var cantPressArray:Array<Bool> = [true, true, true, true];



	////////////////////////////////////



	// - [ Sprites, cameras, and shit. "Objects" in short words. ]

	public static var stage:Stage;
	public static var dad:Character;
	public static var boyfriend:Character;

	private static var deadBF:Character;
	private var gf:GF;

	// --- [ Recycling (cool!!!) ]
	private var splashGroup:FlxTypedGroup<NoteSplash>;
	private var ratingsGroup:FlxTypedGroup<Rating>;
	private var numbersGroup:FlxTypedGroup<Number>;
	private var ghostsGroup:FlxTypedGroup<Ghost>;
	private var pollasGroup:FlxTypedGroup<FlxSprite>; // lmfao

	private var notes:FlxTypedGroup<Note>;
	private var playerStrums:FlxTypedGroup<Strum>;
	private var cpuStrums:FlxTypedGroup<Strum>;
	private var applesCounter:Apple;

	private var camFollow:FlxObject;
	private var camPoint:FlxPoint;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;

	private var healthBar:FlxBar;
	private var scoreTxt:FlxText;
	private var clock:Clock;
	private var yoyo:Yoyo;

	private var isAngleBopping:Bool = false;
	private var angleBopRight:Bool = true;
	private var mondayBlock:FlxSprite;
	private var pollaBlock:FlxSprite;
	private var traductor:FlxSprite;
	private var spotlightBlack:FlxSprite;
	private var spotlight:FlxSprite;
	private var spotlightSmoke:FlxSprite;
	private var smokes:FlxSpriteGroup;

	// --- [ Cameras ]
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;
	private var camOther:FlxCamera;

	// --- [ Sounds ]
	private var vocals:FlxSound;
	private var inst:FlxSound;



	////////////////////////////////////



	override public function create()
	{
		instance = this;

		CoolUtil.title('Loading...');
		CoolUtil.presence(null, Language.get('Discord_Presence', 'loading_menu'), false, 0, null);

		FlxG.mouse.visible = false;
		if (storyDifficulty == 3 || GlobalData.botplay)
			GlobalData.practice = false;
		
		if (FlxG.sound.music != null || FlxG.sound.music.playing)
			FlxG.sound.music.stop();

		scoreData = 
		{
			shits: 0,
			bads: 0,
			goods: 0,
			sicks: 0,
			misses: 0,

			combo: 0,
			accuracy: 0.00
		}

		addCameras();

		Conductor.mapBPMChanges(SONG);

		SONG.stage ??= 'room';
		isPixel = (SONG.song == 'Monday Encore');
		
		addCharacters();

		Conductor.songPosition = -5000;

		add(playerStrums = new FlxTypedGroup<Strum>());
		add(cpuStrums = new FlxTypedGroup<Strum>());
		add(clock = new Clock(camHUD));

		add(numbersGroup = new FlxTypedGroup<Number>());
		if (!GlobalData.botplay)
		{
			add(ratingsGroup = new FlxTypedGroup<Rating>());
			ratingsGroup.cameras = [camHUD];
			if (GlobalData.settings.lowQuality)
				ratingsGroup.maxSize = 1;

			ratingsGroup.add(new Rating()).kill();
		}
		add(splashGroup = new FlxTypedGroup<NoteSplash>());
		add(notes = new FlxTypedGroup<Note>());

		if (mechanicsOn && SONG.song == 'Petty Petals')
			add(gumNotes = new FlxTypedGroup<GumTrap>());

		for (i in 0...3)
			numbersGroup.add(new Number()).kill();

		for (i in 0...4)
			splashGroup.add(new NoteSplash()).kill();

		if (GlobalData.settings.lowQuality)
		{
			numbersGroup.maxSize = 3;
			splashGroup.maxSize = 4;
		}

		if (gumNotes != null)
		{
			for (i in 0...4)
				gumNotes.add(new GumTrap(camHUD)).kill();
		}

		generateSong(SONG.song);

		storyDifficultyText = ['EASY', 'NORMAL', 'HARD'][storyDifficulty];

		CoolUtil.title('${SONG.song} - [$storyDifficultyText]');

		final disc_song = Language.get('Discord_Presence', 'playing_text') + ' ' + SONG.song;
		final disc_diff = CoolUtil.difficultyFromInt(storyDifficulty).toUpperCase();

		CoolUtil.presence(Language.get('Discord_Presence', 'countdown_text'), disc_song + ' - [$disc_diff]', false, null, (dad.curCharacter == 'janitor' ? (janitorKys ? 'kys' : 'janitor') : dad.curCharacter), true);

		camFollow = new FlxObject();
		camFollow.setPosition(boyfriend.camPos[0], boyfriend.camPos[1]);
		camFollow.active = false;
		camPoint = new FlxPoint().copyFrom(camFollow.getPosition());
		camGame.zoom = defaultCamZoom;
		camGame.focusOn(camPoint);

		var healthBarBG = new FlxSprite(0, (GlobalData.settings.downscroll ? 50 : FlxG.height * 0.9));

		if (!GlobalData.botplay && !GlobalData.practice)
		{
			healthBarBG.makeGraphic(1, 1, FlxColor.BLACK);
			healthBarBG.scale.set(601, 19);
			healthBarBG.updateHitbox();
			healthBarBG.screenCenter(X);
			healthBarBG.scrollFactor.set();
			healthBarBG.active = false;
			add(healthBarBG);
		}

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.scale.x - 8), Std.int(healthBarBG.scale.y - 8), this, 'lerpHealth', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(FlxColor.fromString(dad.curColor), 
		FlxColor.fromString(boyfriend.curColor));
		healthBar.numDivisions = 200;
		healthBar.active = false;
		add(healthBar);

		if (GlobalData.botplay || GlobalData.practice)
		{
			healthBar.visible = false;
			healthBar.alpha = 0;
		}

		var daY = healthBarBG.y + (GlobalData.settings.downscroll ? 100 : -100);
		// Literally copy-paste of the above, fu
		if (GlobalData.botplay)
		{
			var botPlayState = new FlxText(0, daY, FlxG.width, (storyDifficulty == 3 ? "YOU SUCK": "BOTPLAY"), 20);
			botPlayState.autoSize = false;
			botPlayState.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
			botPlayState.scrollFactor.set();
			botPlayState.borderSize = 1.5;
			botPlayState.active = false;
			botPlayState.cameras = [camHUD];
			add(botPlayState);
		}

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		if (GlobalData.botplay || GlobalData.practice)
		{
			iconP1.screenCenter(X);
			iconP2.screenCenter(X);
			iconP1.x += iconP1.width / 1.5;
			iconP2.x -= iconP2.width / 1.5;
		}

		if (GlobalData.settings.lowQuality)
		{
			lerpHealth = health;
			healthBar.update(FlxG.elapsed);
			dumbIcons();
		}

		iconP1.active = false;
		iconP2.active = false;

		scoreTxt = new FlxText(0, healthBarBG.y + 35, FlxG.width, Ratings.CalculateRanking(0, 0, 0), 30);
		scoreTxt.autoSize = false;
		scoreTxt.borderSize = 1.25;
		scoreTxt.scrollFactor.set();
		scoreTxt.setFormat(Paths.font('Crayawn-v58y.ttf'), 30, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		scoreTxt.active = false;
		add(scoreTxt);

		if (SONG.song == 'Nugget de Polla')
		{
			camFollow.screenCenter(X);
			// camFollow.y -= 100;
			iconP1.visible = iconP2.visible = false;
			healthBar.visible = healthBarBG.visible = false;

			setupSpotlights();

			if (!GlobalData.settings.lowQuality)
			{
				pollaBlock = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
				pollaBlock.scale.set(FlxG.width * 2, FlxG.height * 2);
				pollaBlock.screenCenter();
				pollaBlock.scrollFactor.set();
				pollaBlock.active = false;
				pollaBlock.color = FlxColor.BLACK;
				pollaBlock.ID = -1;
				add(pollaBlock);

				traductor = new FlxSprite(0, 0, Paths.image('bg/traductor', 'shit'));
				traductor.antialiasing = false;
				traductor.camera = camHUD;
				traductor.screenCenter();
				traductor.scale.set(0, 0);
				traductor.active = false;
				traductor.alpha = 0;
				add(traductor);
			}
		}

		playerStrums.cameras = cpuStrums.cameras = splashGroup.cameras = numbersGroup.cameras = notes.cameras = healthBar.cameras = healthBarBG.cameras = iconP1.cameras = iconP2.cameras = scoreTxt.cameras = [camHUD];

		if (GlobalData.botplay || GlobalData.practice)
		{
			healthBarBG.destroy();
			healthBarBG = null;
		}

		startingSong = true;

		tries++;

		if (tries <= 1 && isStoryMode && CoolUtil.getDialogue().length > 0) dialogue();
		else startCountdown();

		// im the god of the useless optimizations wahahahahah h
		if (inChartNoteTypes.contains('apple'))
		{
			applesCounter = new Apple();
			applesCounter.setPosition(10, GlobalData.settings.downscroll ? 2.5 : FlxG.height - applesCounter.height - 1);
			applesCounter.camera = camHUD;
			add(applesCounter);

			updateApples();
		}

		add(pollasGroup = new FlxTypedGroup<FlxSprite>());
		pollasGroup.active = false;
		pollasGroup.camera = camHUD;
		pollaJumpscare().kill();

		if (!GlobalData.other.menuCharacters.contains(dad.curCharacter))
		{
			GlobalData.other.menuCharacters.push(dad.curCharacter);
			GlobalData.flush();
		}

		if (SONG.song == 'Nugget') boyfriend.camPos[1] -= 200;
		if (SONG.song.contains('Expelled')) boyfriend.camPos[0] -= 100;
		if (SONG.song == 'Cash Grab') boyfriend.camPos[0] -= 200;
		if (SONG.song == 'Staff Only') boyfriend.camPos[1] -= 50;

		focusOnCharacter(dad);

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);

		super.create();

		CustomFadeTransition.nextCamera = camOther;
	}

	function startCountdown():Void
	{
		inCutscene = false;
		startedCountdown = true;

		if (SONG.song != 'Nugget de Polla')
		{
			Conductor.songPosition = -Conductor.crochet * 5;
			if (camHUD.alpha != 1) FlxTween.tween(camHUD, {alpha: 1}, 0.5, {startDelay: 1});
		}
		else
		{
			Conductor.songPosition = -Conductor.crochet * 1;
			if (camHUD.alpha != 1) FlxTween.tween(camHUD, {alpha: 1}, 2.5, {startDelay: 1});
		}

		generateStaticArrows();
		addYoyo();
		doCountdown();
	}

	var previousFrameTime:Int = 0;
	var songTime:Float = 0;

	var binds:Array<String> = [GlobalData.controls.leftBind.toLowerCase(),
		GlobalData.controls.downBind.toLowerCase(), 
		GlobalData.controls.upBind.toLowerCase(), 
		GlobalData.controls.rightBind.toLowerCase()];
	var keys = [false, false, false, false];

	// kind of rewritten the input ig
	private function handleInput(evt:KeyboardEvent):Void { // this actually handles press inputs

		if (GlobalData.botplay || paused)
			return;

		// first convert it from openfl to a flixel key code
		// then use FlxKey to get the key's name based off of the FlxKey dictionary
		// this makes it work for special characters

		@:privateAccess
		var openFLKey = openfl.ui.Keyboard.__convertKeyCode(evt.keyCode);
		var key = FlxKey.toStringMap.get(openFLKey).toLowerCase();

		var data:Int = (binds.contains(key) ? binds.indexOf(key) : getArrowKey(evt.keyCode));

		if (keys[data] || data == -1)
			return;

		keys[data] = true;

		var possibleNotes:Array<Note> = [];
		var directionList:Array<Int> = [];
		var dumbNotes:Array<Note> = [];

		//notes.forEachAlive(function(daNote:Note)
		for (daNote in notes.members)
		{
			if (!daNote.alive) continue;

			if ((daNote.noteData == data) && daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote)
			{
				if (directionList.contains(data))
				{
					for (coolNote in possibleNotes)
					{
						if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
						{
							dumbNotes.push(daNote);
							break;
						}
						else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
						{
							possibleNotes.remove(coolNote);
							possibleNotes.push(daNote);
							break;
						}
					}
				}
				else
				{
					possibleNotes.push(daNote);
					directionList.push(data);
				}
			}
		};
		//});

		for (note in dumbNotes)
		{
			// trace("Killing dumb note");
			destroyNote(note);
		}

		possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

		if (possibleNotes.length > 0)
		{
			for (coolNote in possibleNotes)
			{
				if (keys[coolNote.noteData] && coolNote.canBeHit && !coolNote.tooLate)
					goodNoteHit(coolNote);
			}
		}
		else if (!GlobalData.settings.ghostTapping)
		{
			noteMissPress(data);
		}
	}

	private function releaseInput(evt:KeyboardEvent):Void {
		@:privateAccess
		var openFLKey = openfl.ui.Keyboard.__convertKeyCode(evt.keyCode);
		var key = FlxKey.toStringMap.get(openFLKey).toLowerCase();

		var data:Int = (binds.contains(key) ? binds.indexOf(key) : getArrowKey(evt.keyCode));

		keys[data] = false;
	}

	// convierte una tecla de OpenFL a una direccion
	private inline function getArrowKey(rawKey:Int):Int
    {
		final keyboard = openfl.ui.Keyboard;

        return switch(rawKey)
        {
            default:
                return -1;
            case keyboard.LEFT:
                return 0;
            case keyboard.DOWN:
                return 1;
            case keyboard.UP:
                return 2;
            case keyboard.RIGHT:
                return 3;
        }
    }

	function startSong():Void
	{
		startingSong = false;
		previousFrameTime = FlxG.game.ticks;

		if (!paused) inst.play();
		vocals.play();

		// Song duration in a float, useful for the time left feature
		songLength = inst.length;
		if (clock != null) clock.songLength = songLength;
		
		bop(true);
	}

	private function generateSong(dataPath:String):Void
	{
		Conductor.changeBPM(SONG.bpm);

		vocals = new FlxSound();
		if (SONG.needsVoices)
			vocals.loadEmbedded(Paths.voices(states.PlayState.SONG.song));

		FlxG.sound.list.add(vocals);

		inst = new FlxSound();
		inst.loadEmbedded(Paths.inst(states.PlayState.SONG.song));
		inst.onComplete = endSong;
		FlxG.sound.list.add(inst);

		final daSong:String = CoolUtil.normalize(SONG.song);

		var eventsFile:Array<Dynamic> = SongEvents.loadJson(daSong); // only load the events once pls

		// Load events
		if (eventsFile != null)
		{
			for (event in eventsFile)
			{
				for (i in 0...event[1].length)
				{
					var data:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];

					var daEvent:EpicEvent = 
					{
						strumTime: data[0],
						name: data[1],
						value: data[2],
						value2: data[3]
					};

					events.push(daEvent);
				}

				events.sort(sortEvents);
			}
		}

		// check and remove notes placed in the same spot as others. otherwise you would get double score if you hit them, or double misses if you miss them. a bad thing to happen, generally speaking.
		var duplicateNotes:Array<{strumTime:Float, noteData:Int}> = [];
		var duplicateAmount:Int = 0;

		//Load notes
		for (section in SONG.notes)
			{
				for (songNotes in section.sectionNotes)
				{
					var daStrumTime:Float = (songNotes[0] < 0 ? 0 : songNotes[0]);
					var rawNoteData:Int = Std.int(songNotes[1]);
					var daNoteData:Int = rawNoteData % 4;
					var daNoteStyle:String = (songNotes[3] == null ? 'n' : songNotes[3]);
					var gottaHitNote:Bool = (songNotes[1] > 3 ? !section.mustHitSection : section.mustHitSection);
					var oldNote:Note = (unspawnNotes.length > 0 ? unspawnNotes[Std.int(unspawnNotes.length - 1)] : null);
					var susLength:Float = songNotes[2] / Conductor.stepCrochet;

					// dont create the special note if mechanics are disabled
					if (daNoteStyle != null && daNoteStyle != 'n')
					{
						if (!mechanicsOn)
							continue;
						else
							susLength = 0;
					}

					var found:Bool = false;
					for (duplicate in duplicateNotes)
					{
						if (duplicate.strumTime == daStrumTime && duplicate.noteData == rawNoteData)
						{
							// trace('FOUND DUPLICATE!!! ${daStrumTime}');
							duplicateAmount++;
							found = true;
							break;
						}
					}
					if (found)
						continue;

					duplicateNotes.push({strumTime: daStrumTime, noteData: rawNoteData});

					var swagNote = new Note(daStrumTime, daNoteData, oldNote, false, false, daNoteStyle);
					swagNote.sustainLength = susLength * Conductor.stepCrochet;
					swagNote.mustPress = gottaHitNote;
					swagNote.scrollFactor.set();
					unspawnNotes.push(swagNote);

					if (mechanicsOn && SONG.song == 'Specimen' && dad.curCharacter == 'monster')
					{
						var curSpeed:Float = difficultiesStuff.get('specimenNoteSpeed')[storyDifficulty];

						swagNote.speed = 1 + FlxG.random.float(0 - Math.abs(curSpeed), curSpeed);
					}
	
					for (susNote in 0...Math.floor(susLength)) // Aparently this code creates sustain notes, i dont really care
					{
						oldNote = unspawnNotes[unspawnNotes.length - 1];

						var sustainNote = new Note(daStrumTime + (Conductor.stepCrochet * (susNote + 1)), daNoteData, oldNote, true, false, daNoteStyle);
						sustainNote.scrollFactor.set();
						sustainNote.parent = swagNote;
						sustainNote.speed = swagNote.speed;
						sustainNote.mustPress = gottaHitNote;
						unspawnNotes.push(sustainNote);
	
						if (sustainNote.mustPress)
						{
							sustainNote.doubleNote = notestrumtimes1.contains(Math.round(sustainNote.strumTime));
							notestrumtimes1.push(Math.round(sustainNote.strumTime));
							sustainNote.x += FlxG.width / 2; // general offset
						}
						else
						{
							sustainNote.doubleNote = notestrumtimes2.contains(Math.round(sustainNote.strumTime));
							notestrumtimes2.push(Math.round(sustainNote.strumTime));

							if (GlobalData.settings.middlescroll)
								sustainNote.visible = false; // this should skip all the calculation made when checking if the note is on camera
						}
					}
	
					if (swagNote.mustPress)
					{
						swagNote.doubleNote = notestrumtimes1.contains(Math.round(swagNote.strumTime));
						notestrumtimes1.push(Math.round(swagNote.strumTime));
						swagNote.x += FlxG.width / 2; // general offset
					}
					else
					{
						swagNote.doubleNote = notestrumtimes2.contains(Math.round(swagNote.strumTime));
						notestrumtimes2.push(Math.round(swagNote.strumTime));

						if (GlobalData.settings.middlescroll)
							swagNote.visible = false; // this should skip all the calculation made when checking if the note is on camera
					}

					if (!inChartNoteTypes.contains(daNoteStyle))
						inChartNoteTypes.push(daNoteStyle);
				}
			}
		trace('Notes length: ${unspawnNotes.length} - Note types: $inChartNoteTypes.');

		if (duplicateAmount > 0)
			trace('DUPLICATED NOTES FOUND: $duplicateAmount.');
		duplicateNotes = null;
		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	private inline function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private inline function sortEvents(Obj1:EpicEvent, Obj2:EpicEvent):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows():Void
	{
		for (player in 0...2)
		{
			for (i in 0...4)
			{
				var babyArrow = new Strum(i, player);
				babyArrow.cameras = [camHUD];
				var group = (babyArrow.isPlayer ? playerStrums : cpuStrums).add(babyArrow);
			}
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (inst != null)
			{
				inst.pause();
				vocals.pause();
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		@:privateAccess
		for (i in FlxTween.globalManager._tweens)
			i.active = true;

		FlxG.mouse.visible = false;

		if (yoyo != null) FlxG.mouse.visible = true;

		if (paused)
		{
			CoolUtil.title('${SONG.song} - [$storyDifficultyText]');

			if (inst != null && !startingSong)
				resyncVocals();

			paused = false;
		}

		super.closeSubState();
	}
	

	private inline function resyncVocals():Void
	{
		vocals.pause();
		inst.play();

		Conductor.songPosition = inst.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = false;

	override public function update(elapsed:Float)
	{
		FlxG.watch.addQuick("Notes", unspawnNotes.length);
		FlxG.watch.addQuick('Members:', length);
		FlxG.watch.addQuick('Camera scroll:', camGame.scroll);

		updateSongPosition();
		super.update(elapsed);
		updateNotes();
		checkEventNote(); // uses strumTime now so it has to update every frame lol
		updateLerps(elapsed);
		checkJanitorAnim();
		// updateHealth();
		focusOnCharacter((daSection != null && daSection.mustHitSection) ? boyfriend : dad);
		setChrome(chromVal);
		input();

		//retrospecter goes brrrrrrr
		if (SONG.song != 'Nugget de Polla' && inChartNoteTypes.contains('nuggetP'))
			changeHealth((difficultiesStuff["healthDrainPoison"][storyDifficulty] * poisonStacks * elapsed) * -1); // Gotta make it fair with different framerates :)

		if (isExpellinTime)
		{
			final convertedTime:Float = ((Conductor.songPosition / (Conductor.crochet * 2)) * Math.PI);
			final newAngle:Float = Math.sin(convertedTime) * difficultiesStuff["pollaAlpha"][storyDifficulty];

			camGame.angle = newAngle;
			camHUD.angle = newAngle;
		}
		else
		{
			if (camGame.angle != 0)
				camGame.angle = 0;
			if (camHUD.angle != 0 && !isAngleBopping)
				camHUD.angle = 0;
		}

		// update cindy shader
		if (SONG.song == 'Petty Petals' && shadersOn)
		{
			var filter:ShaderFilter = cast camHUD.filters[0];

			if (filter != null)
			{
				var shader:VHSShader = cast filter.shader;
				shader.update();
			}
		}
	}

	var didDamage:Bool = false;

	// esto revisa el evento que viene
	private function checkEventNote()
	{
		if (songFinished)
			return;

		while (events.length > 0) 
		{
			if (Conductor.songPosition < events[0].strumTime) break;

			triggerEvent(events[0]);
			events.shift();
		}
	}

	private var dumbAppleBG:FlxSprite;
	private var topBar:FlxSprite;
	private var bottomBar:FlxSprite;

	/*
	Little note to remind myself that if I need to play an "instant" event I can just do:
	`triggerEvent(SongEvents.makeEvent('event name', 'value1', 'value2'));
	*/

	private function triggerEvent(event:EpicEvent)
	{
		// trace('Attempting to play ${event.name.toLowerCase()} event. Strum time: ${FlxMath.roundDecimal(event.strumTime, 1)}.');

		final daEvent = event.name.toLowerCase();
		final excludeEvents:Array<String> = 
		[
			'bop', "camera zoom", 'add camera zoom', 'zoom change', 'animation', 
			'flash camera', 'flash white', 'camera flash', 'cinematics', 
			'cinematics(v3.1)', "camera bop", 'badapplelol', "dadbattle spotlight",
			'bf fade', 'blackout', 'arrow flip', 'traductor', 'blackscreen', "cindy move",
			"Bopping HUD"
		];

		if (excludeEvents.contains(daEvent) && GlobalData.settings.lowQuality)
		{
			trace('Can\'t trigger $daEvent event, low quality option is enabled.');
			return;
		}

		switch (daEvent)
		{
			default:
				trace('$daEvent was not found in the trigger event function.');

			case "camera bop":
				camGame.zoom += 0.02;
				camHUD.zoom += 0.05;
				cameraBopBeat = Std.parseFloat(event.value);

			case "bop" | 'add camera zoom':
				camGame.zoom += 0.04;
				camHUD.zoom += 0.12;

			case "zoom change":
				if (GlobalData.settings.camZoomsEnabled)
					defaultCamZoom += Std.parseFloat(event.value);

			case "camera zoom":
				if (GlobalData.settings.camZoomsEnabled)
					defaultCamZoom = stage.camZoom * Std.parseFloat(event.value);

			case "flash camera" | "flash white" | "camera flash":
				if (GlobalData.settings.flashingLights) camGame.flash(FlxColor.WHITE, Std.parseFloat(event.value));

			case "turn pixel":
				turnPixel(!isExpellinTime);

				if (SONG.song == 'Expelled V0')
				{
					Main.changeFPS(20);
				}

			case "animation" | "play animation":
				if (event.value2 == 'bf') boyfriend.playSpecialAnim(event.value);
				else dad.playSpecialAnim(event.value);

			case "monday time":
				// mondayTime((event.value == 'true' ? true : false));

			case "shot":
				dad.playSpecialAnim('shooting');
				if (!GlobalData.settings.lowQuality)
				{
					camGame.zoom += 0.08;
					camHUD.zoom += 0.24;
					camGame.shake(0.007, 1);
				}
				chromatic(0.05, 0, true, 0, 0.5);
				if (GlobalData.settings.flashingLights && !GlobalData.settings.lowQuality) camGame.flash(0x7effffff, 0.5);

				if (!mechanicsOn)
					boyfriend.playSpecialAnim('dodge');

			case "alt":
				dad.altAnimSuffix = (dad.altAnimSuffix == 'alt-' ? '' : 'alt-');

			case "polla alt":
				dad.altAnimSuffix = (event.value == 'true' ? 'alt-' : '');

				gf.forceWhat = dad.altAnimSuffix != '';

			case "polla guitar":
				dad.altAnimSuffix = (event.value == 'true' ? 'guitar-' : '');

				gf.forceWhat = dad.altAnimSuffix != '';

			case 'hey!':
				boyfriend.playSpecialAnim('hey');
				triggerEvent(SongEvents.makeEvent('bop'));

				if (event.value2 != null && event.value2 != '' && event.value2.length > 2)
				{
					new FlxTimer().start(getTimeFromBeats(SECTIONS, 1), function(_) boyfriend.animation.play('idle', true));
				}

			case 'cinematics' | 'cinematics(v3.1)':
				// Creator: RamenDominoes (https://gamebanana.com/members/2135195)
    			// Version: Like 3.1 or something idk I fucked up making the versions cuz I used to not know how the numbers for versions worked lol
				// Translated to Haxe by me (Galo)

				var barStuff = event.value.split(','); // Thickness, Speed
				var firstTime = topBar == null && bottomBar == null;

				if (firstTime)
				{
					topBar = new FlxSprite(0, -1).makeGraphic(1, 1, FlxColor.BLACK);
					topBar.scale.set(FlxG.width, 1);
					topBar.updateHitbox();
					topBar.camera = camHUD;
					topBar.active = topBar.antialiasing = false;
					insert(members.indexOf(playerStrums) - 1, topBar);

					bottomBar = new FlxSprite(0, FlxG.height).makeGraphic(1, 1, FlxColor.BLACK);
					bottomBar.scale.set(FlxG.width, 1);
					bottomBar.updateHitbox();
					bottomBar.camera = camHUD;
					bottomBar.active = bottomBar.antialiasing = false;
					insert(members.indexOf(playerStrums) - 1, bottomBar);
				}

				FlxTween.tween(topBar, {y: (Std.parseFloat(barStuff[0]) * 0.5) - 1, 'scale.y': Std.parseFloat(barStuff[0])}, Std.parseFloat(barStuff[1]), {ease: FlxEase.quadOut});
				FlxTween.tween(bottomBar, {y: FlxG.height - (Std.parseFloat(barStuff[0]) * 0.5), 'scale.y': Std.parseFloat(barStuff[0])}, Std.parseFloat(barStuff[1]), {ease: FlxEase.quadOut, onComplete: function(_)
				{
					var times:Int = 0;

					for (i in events)
					{
						if (i.name.contains('cinematics')) times++;
					}

					if (!firstTime && times > 1)
					{
						trace('removing bars');
						remove(topBar);
						remove(bottomBar);
						topBar.destroy();
						bottomBar.destroy();
					}
				}});
			
			case 'chrom':
				if (event.value2 != null && Std.parseFloat(event.value2) > 0)
					chromatic(Std.parseFloat(event.value), 0, true, 0, Std.parseFloat(event.value2));
				else
					chromatic(Std.parseFloat(event.value), 0, false);

			case 'badapplelol':
				// Creator: Saltyboii#2461
    			// Description: Does the shadow thing like in Indie Cross.
				// Translated to Haxe by me (Galo)

				if (event.value == 'a')
				{
					dumbAppleBG = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
					dumbAppleBG.scale.set(FlxG.width * 3, FlxG.height * 3);
					dumbAppleBG.updateHitbox();
					dumbAppleBG.screenCenter();
					dumbAppleBG.active = dumbAppleBG.antialiasing = false;
					dumbAppleBG.scrollFactor.set();
					insert(members.indexOf(dad) - 1, dumbAppleBG);

					FlxTween.cancelTweensOf(dad, ["color"]);
					FlxTween.cancelTweensOf(boyfriend, ["color"]);

					dad.setColorTransform(0, 0, 0, 1, 0, 0, 0, 0);
					boyfriend.setColorTransform(0, 0, 0, 1, 0, 0, 0, 0);
				}
				else if (event.value == 'b')
				{
					if (dumbAppleBG != null)
					{
						dumbAppleBG.destroy();
						dumbAppleBG = null;
					}

					FlxTween.cancelTweensOf(dad, ["color"]);
					FlxTween.cancelTweensOf(boyfriend, ["color"]);

					dad.setColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
					boyfriend.setColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
				}

			case "blackout":
				pollaBlock.visible = event.value == 'true';

			case "dadbattle spotlight":
				doSpotlights(event);

			case "bf fade":
				// nah i changed my mind about this
				/*
				var duration = Std.parseInt(event.value);
				final newAlpha = Std.parseFloat(event.value2);
				if (duration < 0)
					duration = 0;

				if (duration <= 0)
					boyfriend.alpha = newAlpha;
				else
					FlxTween.tween(boyfriend, {alpha: newAlpha}, duration);
				*/

			case "arrow flip":
				for (group in [cpuStrums, playerStrums])
				{
					if (group != null)
					{
						group.forEachExists(function(strum:Strum)
						{
							FlxTween.tween(strum, {angle: 360 * 2}, 1, {ease: FlxEase.backOut});
						});
					}
				}

			case "traductor":
				FlxTween.tween(traductor, {alpha: 1, "scale.x": 0.9, "scale.y": 0.9}, getTimeFromBeats(SECTIONS, 1), {ease: FlxEase.sineOut});

			case "blackscreen":
				if (mondayBlock == null)
				{
					mondayBlock = new FlxSprite().makeGraphic(1, 1);
					mondayBlock.color = FlxColor.BLACK;
					mondayBlock.scale.set(FlxG.width * 1.5, FlxG.width * 1.5);
					mondayBlock.updateHitbox();
					mondayBlock.active = false;
					mondayBlock.antialiasing = false;
					mondayBlock.camera = camHUD;
					mondayBlock.scrollFactor.set();
					add(mondayBlock);
				}
				
				if (event.value != null)
				{
					FlxTween.tween(mondayBlock, {alpha: 0}, Std.parseFloat(event.value), {onComplete: function(_)
					{
						mondayBlock.destroy();
						mondayBlock = null;
					}});
				}

			case "cindy ending":
				iconP2.animation.play('cindy-bloody');
				healthBar.createFilledBar(FlxColor.fromRGB(114, 0, 25, 255), FlxColor.fromString(boyfriend.curColor));

				if (!GlobalData.settings.lowQuality)
				{
					dad.playSpecialAnim('scared');
					gf.forceWhat = true;

					var i:Int = 0;
					for (strums in [cpuStrums.members, playerStrums.members])
					{
						for (strum in strums)
						{
							FlxTween.tween(strum, {alpha: 0}, 2.5, {startDelay: i / 10});

							i++;
						}
					}

					for (basic in [clock, iconP1])
					{
						FlxTween.tween(basic, {alpha: 0}, 2);
					}
				}
				else
				{
					var black = new FlxSprite();
					black.makeGraphic(1, 1);
					black.scale.set(FlxG.width * 2, FlxG.height * 3);
					black.color = FlxColor.BLACK;
					black.updateHitbox();
					black.camera = camGame;
					black.screenCenter();
					black.active = false;
					add(black);

					dad.visible = dad.active = false;
					boyfriend.visible = boyfriend.active = false;
					stage.visible = stage.active = false;
				}

			case "cindy move":
				dad.playSpecialAnim('run');

				FlxTween.cancelTweensOf(dad, ['x']);
				FlxTween.tween(dad, {x: dad.x - 1500}, 1.3, {onComplete: (_) -> 
				{
					camGame.pixelPerfectShake = true;
					camGame.shake(0.02);
					camHUD.shake(0.005);

					dad.visible = dad.active = false;
				}});

			case "bopping hud":
				if (isExpellinTime)
					return;

				isAngleBopping = !isAngleBopping;

				if (!isAngleBopping)
				{
					FlxTween.cancelTweensOf(camHUD, ['angle']);
					camHUD.angle = 0;
				}
		}
	}

	private function endSong():Void
	{
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);

		tries = 0;

		clearNotes();

		canPause = false;
		paused = true;
		songFinished = true;

		inst.volume = 0;
		vocals.volume = 0;
		inst.pause();
		vocals.pause();
		inst.stop();
		vocals.stop();

		setChrome(0);
		camGame.filters = [];
		camHUD.filters = [];

		if (yoyo != null)
			yoyo.die();
		clock.ring();

		if (!GlobalData.practice && !GlobalData.botplay)
		{
			var songHighscore = StringTools.replace(states.PlayState.SONG.song, " ", "-");

			data.Highscore.saveScore(songHighscore, Math.round(songScore), storyDifficulty);
			data.Highscore.saveCombo(songHighscore, data.Ratings.GenerateLetterRank(scoreData.accuracy), storyDifficulty);
			FCs.save();
		}

		new FlxTimer().start(2.5, function (_)
		{
			if (isStoryMode)
			{
				if (!GlobalData.botplay && !GlobalData.other.beatenSongs.contains(SONG.song))
					GlobalData.other.beatenSongs.push(SONG.song);

				GlobalData.flush();

				storyPlaylist.shift();

				if (storyPlaylist.length <= 0)
				{
					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;

					if (!GlobalData.botplay && GlobalData.other.beatenSongs.contains('Expelled'))
					{
						GlobalData.other.beatenStoryMode = true;
						GlobalData.flush();
					}

					FlxG.sound.playMusic(Paths.music('freakyMenu', 'preload'), 0.7);
					funkin.Conductor.changeBPM(91 * 2);
					MusicBeatState.switchState(new states.MainMenuState());
				}
				else
				{
					var poop:String = data.Highscore.formatSong(StringTools.replace(storyPlaylist[0], " ", "-"), storyDifficulty);

					trace('LOADING NEXT SONG: $poop!');

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					SONG = Song.loadFromJson(poop, storyPlaylist[0]);
					MusicBeatState.switchState(new states.PlayState());
				}
			}
			else
			{
				trace('Back to Freeplay.');

				FlxG.sound.playMusic(Paths.music('freakyMenu', 'preload'), 0.7);
				funkin.Conductor.changeBPM(91 * 2);
				MusicBeatState.switchState(new states.FreeplayState());
			}
		});
	}

	private function popUpScore(daNote:Note):Void
	{
		vocals.volume = 1;
		var score:Float = 0;
		var daRating = daNote.rating;

		if (daNote.noteStyle != 'nuggetP' && daNote.noteStyle != 'apple')
			changeHealth(0.023);

		switch(daRating)
		{
			case 'shit':
				score = 50;
				scoreData.shits++;
				totalNotesHit += 0.25;
			case 'bad':
				score = 100;
				scoreData.bads++;
				totalNotesHit += 0.50;
			case 'good':
				score = 200;
				scoreData.goods++;
				totalNotesHit += 0.75;
			case 'sick':
				score = 350;
				totalNotesHit += 1;
				scoreData.sicks++;
		}

		songScore += Math.round(score);
		songScoreDef += Math.round(data.Highscore.convertScore(-(daNote.strumTime - Conductor.songPosition)));

		addRating(daNote, daRating);

		if ((daNote.noteStyle != 'gum' && daRating == 'sick') || (daNote.noteStyle == 'gum'))
			doNoteSplash(daNote);
	}

	// THIS FUNCTION JUST FUCKS WIT HELD NOTES AND BOTPLAY/REPLAY (also gamepad shit)

	private function keyShit():Void // I've invested in emma stocks - now with kade engine 1.6.2 input :sunglasses: -sanco
		{
			// control arrays, order L D R U
			var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
			var pressArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
			var releaseArray:Array<Bool> = [controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R];
			
			if (GlobalData.botplay)
			{
				holdArray = [false, false, false, false];
				pressArray = [false, false, false, false];
				releaseArray = [false, false, false, false];
			}
	
			// HOLDS, check for sustain notes
			if (holdArray.contains(true) && generatedMusic)
			{
				for (daNote in notes.members)
				{
					if (!daNote.alive) continue;

					if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData])
						goodNoteHit(daNote);
				};
			}

			if (GlobalData.botplay)
			{
				for (daNote in notes.members)
				{
					if (!daNote.alive) continue;

					if ((daNote.mustPress && daNote.canBeHit) && (daNote.isSustainNote || (!daNote.isSustainNote && (daNote.strumTime <= Conductor.songPosition || daNote.isSustainNote))))
					{
						goodNoteHit(daNote);
						boyfriend.holdTimer = daNote.sustainLength;
					}
				};
			}
	
			if (boyfriend.holdTimer >= boyfriend.getHoldTime() && (!holdArray.contains(true) || GlobalData.botplay))
			{
				if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
					boyfriend.dance();
			}
	
			if (!GlobalData.botplay)
			{
				for (spr in playerStrums.members)
				{
					if (keys[spr.ID] && spr.animation.curAnim.name != 'confirm' && cantPressArray[spr.ID])
						spr.animation.play('pressed', true);
					if (!keys[spr.ID])
						spr.animation.play('static');
				};
			}
		}

	private inline function input():Void
	{
		if (inCutscene || songFinished) return;

		if (FlxG.keys.justPressed.ANY && SONG.song.contains('Expelled') && !GlobalData.other.didV0)
			expelledCode();

		keyShit();
		
		#if debug
		if (FlxG.keys.justPressed.ONE) endSong();

		// psych engineeee
		if (FlxG.keys.justPressed.TWO)
		{
			if (Conductor.songPosition + 10000 < inst.length)
			{
				inst.pause();
				vocals.pause();

				inst.time = Conductor.songPosition + 10000;
				inst.play();

				if (Conductor.songPosition <= vocals.length)
				{
					vocals.time = Conductor.songPosition + 10000;
				}
				vocals.play();
				Conductor.songPosition = Conductor.songPosition + 10000; 

				var i:Int = unspawnNotes.length - 1;
				while (i >= 0)
				{
					var daNote:Note = unspawnNotes[i];
					if(daNote.strumTime - 350 < Conductor.songPosition)
					{
						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						unspawnNotes.remove(daNote);
						daNote.destroy();
					}
					--i;
				}

				i = notes.length - 1;
				while (i >= 0)
				{
					var daNote:Note = notes.members[i];
					if(daNote.strumTime - 350 < Conductor.songPosition)
					{
						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
					--i;
				}
			}
		}

		debugEditors();
		#end

		if (FlxG.keys.justPressed.SPACE && !GlobalData.botplay)
			eatApple(true);	

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');

			if (iconP1.animation.curAnim != null) iconP1.animation.curAnim.curFrame = (health < 0.4 ? 1 : 0);
		}

		if (controls.PAUSE)
		{
			pause();
		}
	}

	private function noteMiss(direction:Int = 1, daNote:Note = null):Void
	{
		if (GlobalData.botplay || died || (daNote.noteStyle == 'nuggetP' || daNote.noteStyle == 'apple'))
			return;

		switch (daNote.noteStyle)
		{
			case 'gum':
				gumNoteMechanic(daNote);
			case 'b': //b is for BULLET
				changeHealth(-1);
				boyfriend.playSpecialAnim('hurt');
				if (gf != null)
					gf.playSpecialAnim('shock');
		}

		vocals.volume = 0;
		changeHealth(-0.05);

		if (gf != null && scoreData.combo > 10)
			gf.playSpecialAnim('cry');

		scoreData.combo = 0;
		scoreData.misses++;

		songScore -= 10;

		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3, 'shared'), FlxG.random.float(0.1, 0.2));

		boyfriend.sing(direction, true);

		updateAccuracy();
	}

	function noteMissPress(direction:Int = 0)
		{
			vocals.volume = 0;
			changeHealth(-0.05);

			if (gf != null && scoreData.combo > 10)
				gf.playSpecialAnim('cry');

			scoreData.combo = 0;
			scoreData.misses++;
			songScore -= 10;
			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3, 'shared'), FlxG.random.float(0.1, 0.2));
			boyfriend.sing(direction, true);
			updateAccuracy();
		}
	
		function updateAccuracy() 
		{
			totalPlayed += 1;
			scoreData.accuracy = Math.max(0,totalNotesHit / totalPlayed * 100);

			scoreTxt.text = data.Ratings.CalculateRanking(songScore, songScoreDef, scoreData.accuracy);
		}
	
		function getKeyPresses(note:Note):Int
		{
			var possibleNotes:Array<Note> = []; // copypasted but you already know that
	
			for (daNote in notes.members)
			{
				if (!daNote.alive) continue;

				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
				{
					possibleNotes.push(daNote);
					possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
				}
			};

			if (possibleNotes.length == 1)
				return possibleNotes.length + 1;
			return possibleNotes.length;
		}
	
		function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
		{
			var noteDiff:Float = -(note.strumTime - Conductor.songPosition);
	
			note.rating = data.Ratings.CalculateRating(noteDiff, Math.floor((Conductor.safeFrames / 60) * 1000));
			
			if (controlArray[note.noteData])
				goodNoteHit(note);
		}
	
		function goodNoteHit(note:Note):Void
			{
				if (!cantPressArray[note.noteData])
					return;

				vocals.volume = 1;

				switch (note.noteStyle)
				{
					case 'nuggetP':
						if (GlobalData.botplay)
							return;
						else
						{
							if (SONG.song == 'Nugget de Polla')
							{
								pollaJumpscare();
							}
							else
							{
								FlxG.sound.play(Paths.soundRandom('missnote', 1, 3, 'shared'), FlxG.random.float(0.2, 0.3));
								poisonStacks++;
								boyfriend.playSpecialAnim('hurt');
								if (gf != null)
									gf.playSpecialAnim('shock');
							}
						}
					case 'nuggetN':
						poisonStacks = 0;
					case 'gum':
						boyfriend.playSpecialAnim('dodge');
					case 'b':
						boyfriend.playSpecialAnim('dodge');
					case 'apple':
						if (!note.isSustainNote){
							actions++;
							updateApples();
							CoolUtil.sound('scrollMenu', 'preload', 0.6);
						}
				}
	
				var noteDiff:Float = -(note.strumTime - Conductor.songPosition);
	
				note.rating = data.Ratings.CalculateRating(noteDiff);
	
				if (note.rating == "miss")
					return;

				if (!note.wasGoodHit)
				{
					if (!note.isSustainNote)
					{
						scoreData.combo++;
						popUpScore(note);
					}
					else
						totalNotesHit += 1;
	
					if (!note.doubleNote)
						boyfriend.sing(note.noteData);
					else
					{
						if (!note.isSustainNote)
							trail(boyfriend, getMultNotes(false, note));
					}
	
					for (spr in playerStrums.members)
					{
						if (Math.abs(note.noteData) == spr.ID && cantPressArray[spr.ID])
						{
							if (GlobalData.botplay) spr.playAnim('confirm', true);
							else spr.animation.play('confirm', true);
						}
					};
					
					note.wasGoodHit = true;
					vocals.volume = 1;
		
					// do not remove or destroy sustains as it might seem bad when playing sustains
					if (!note.isSustainNote)
						destroyNote(note);

					updateAccuracy();
				}
			}

	// helper function for single liner destroy notes
	function destroyNote(note:Note)
	{
		note.visible = false;
		note.active = false;
		note.exists = false;

		note.kill();
		notes.remove(note, true);
		note.destroy();
		note = null;
	}

	override function stepHit()
	{
		final disc_misses = Language.get('Ratings', 'misses') + ' ' + scoreData.misses;
		final disc_tries = Language.get('Discord_Presence', 'tries_text') + ' ' + tries;
		final disc_song = Language.get('Discord_Presence', 'playing_text') + ' ' + SONG.song;
		final disc_diff = CoolUtil.difficultyFromInt(storyDifficulty).toUpperCase();

		CoolUtil.presence(disc_misses + ' | ' + disc_tries, disc_song + ' - [$disc_diff]', true, songLength - Conductor.songPosition, (dad.curCharacter == 'janitor' ? (janitorKys ? 'kys' : 'janitor') : dad.curCharacter), true);

		if (inst.time > Conductor.songPosition + 20 || inst.time < Conductor.songPosition - 20)
			resyncVocals();

		if (cameraBopBeat == 0.5)
		{
			camGame.zoom += 0.02;
			camHUD.zoom += 0.05;
		}

		super.stepHit();
	}

	override function sectionHit()
	{
		super.sectionHit();

		// i realized this has to update all the time because the cam sing move thing wont work :(
		// focusOnCharacter((daSection != null && daSection.mustHitSection) ? boyfriend : dad); 

		// trace('Song position: ${inst.time} (${Conductor.songPosition}) - Unspawn notes: ${unspawnNotes.length} - Notes: ${notes.members.length}');
	}

	var shownCredits:Bool = false;

	override function beatHit()
	{
		if (yoyo != null && curBeat % difficultiesStuff["yoyoFrequency"][storyDifficulty] == 0) yoyo.play();

		if (SONG.song == "Nugget de Polla" && !GlobalData.settings.lowQuality)
		{
			if (curBeat >= 8 && pollaBlock.ID == -1){
				pollaBlock.visible = false;
				pollaBlock.ID = 0;
				if (GlobalData.settings.flashingLights) FlxG.cameras.flash();
			}

			if (curBeat >= 8 && traductor != null)
			{
				FlxTween.cancelTweensOf(traductor);
				traductor.destroy();
				traductor = null;
			}
		}

		if (mechanicsOn && SONG.song == 'Staff Only') //if mechanics are enabled and its janitor song
		{
			final isAttackTime:Bool = curBeat % difficultiesStuff["janitorHits"][storyDifficulty] == 0;
			final badAccuracy:Bool = scoreData.accuracy < difficultiesStuff['janitorAccuracy'][storyDifficulty];
			final accuracy_not_0:Bool = scoreData.accuracy > 0;
			final doing_nothing:Bool = scoreData.accuracy <= 0 && scoreData.misses > 0;
			final isAbleToHit:Bool = accuracy_not_0 || doing_nothing;

			if (isAttackTime && badAccuracy && isAbleToHit)
			{
				canPause = false;
				trace('Janitor hit - [Accuracy: ${scoreData.accuracy} - accuracy intended: ${ difficultiesStuff['janitorAccuracy'][storyDifficulty]} - current health: $health - damage: ${difficultiesStuff['mopHealthLoss'][storyDifficulty]}]');
				dad.playSpecialAnim('attack');
			}
		}

		if (shadersOn && SONG.song == 'Petty Petals' && curBeat >= (16 * 8) / 4)
		{
			var shader = camHUD.filters.shift();
			camGame.filters.remove(shader);
			shader = null;
		}

		if (generatedMusic)
			notes.sort(FlxSort.byY, (GlobalData.settings.downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));

		if (daSection != null && daSection.changeBPM)
		{
			Conductor.changeBPM(daSection.bpm);
			FlxG.log.add('CHANGED BPM!');
		}

		bop();

		if (curBeat >= 4 && !shownCredits)
		{
			shownCredits = true;

			var author:String = switch (SONG.song)
			{
				case 'Nugget':				   								   							   "TheGalo X";
				case 'Expelled' | 'Expelled V1' | 'Expelled V2' | 'Nugget de Polla' | 'Monday': 		   "KrakenPower";
				case 'Monday Encore' | 'Staff Only':										   			   "Saul Goodman & TheGalo X";
				case 'Cash Grab' | 'Expelled V0':											   			   Language.get('Global', 'cash_grab_credits'); // we dont talk about cash grab
				case 'Petty Petals':																	   'ItzTamago';
				default:					                                   							   "no author lmao";
			}

			var creditPage = new PageSprite('${SONG.song}\n${Language.get('Global', 'song_author_by')} $author', true);
			creditPage.cameras = [camHUD];
			add(creditPage);
		}

		if (SONG.song == 'Monday' && mechanicsOn)
		{
			if (curBeat == 32)
			{
				var text:String = (GlobalData.settings.downscroll ? '' : '<--') + Language.get('Global', 'apples_advice');
				var page = new PageSprite(text, false, getTimeFromBeats(SECTIONS, 1.5));
				page.cameras = [camHUD];
				if (!GlobalData.settings.downscroll) page.x -= 115;
				add(page);
			}
		}
	}

	function bop(force:Bool = false):Void
	{
		if (!GlobalData.settings.lowQuality && cameraBopBeat < 99)
		{
			if (force || curBeat % cameraBopBeat == 0)
			{
				camGame.zoom += 0.02;
				camHUD.zoom += 0.05;
			}

			if (force || curBeat % 2 == 0)
			{
				iconP1.scale.set(1.1, 1.1);
				iconP2.scale.set(1.1, 1.1);

				if (healthBar.percent < 20)
					FlxTween.color(iconP1, 0.25, FlxColor.RED, FlxColor.WHITE);
				else if (healthBar.percent > 80)
					FlxTween.color(iconP2, 0.25, FlxColor.RED, FlxColor.WHITE);

				iconP1.updateHitbox();
				iconP2.updateHitbox();
			}

			if (!isExpellinTime && isAngleBopping)
			{
				FlxTween.cancelTweensOf(camHUD, ['angle']);
				camHUD.angle = 1.8 * (angleBopRight ? 1 : -1);
				FlxTween.tween(camHUD, {angle: 0}, 1.2, {ease: FlxEase.backOut});

				angleBopRight = !angleBopRight;
			}
		}

		for (character in [dad, boyfriend])
		{
			if (cameraBopBeat < 99)
			{
				character.dance();

				if (gf != null && character == boyfriend)
					gf.dance();
			}
			else
			{
				if (curBeat % 4 == 0 && unspawnNotes.length <= 0 && character.animation.curAnim.name != 'idle')
					character.playAnim('idle', false, false, 10);
			}

			if (character.animation.curAnim != null && character.animation.curAnim.name == 'idle')
				character.camSingPos.set();
		}
	}

	private var died:Bool = false;

	function die(?clearEverything:Bool = true):Void
	{
		//if (died) return; i just spammed pause and it bugged and made bf inmortal so uhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh

		if (clearEverything)
		{
			died = true;

			clearNotes();

			paused = true;
			canPause = false;
			songFinished = true;

			//retrospecter goes brrrrrr
			poisonStacks = 0;

			vocals.volume = 0;
			vocals.pause();
			vocals.stop();

			if (!GlobalData.settings.lowQuality && SONG.song == 'Specimen' && dad.curCharacter == 'monster')
			{
				monsterDeath();
				return;
			}
		}

		inst.volume = 0;
		inst.pause();
		inst.stop();

		persistentUpdate = false;
		persistentDraw = false;

		setChrome(0);
		camGame.filters = [];
		camHUD.filters = [];

		openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y, deadBF));
	}

	function monsterDeath():Void
	{
		FlxTween.tween(camHUD, {alpha: 0}, 0.25);
		FlxTween.tween(camGame, {zoom: stage.camZoom + 0.1}, 1, {ease: FlxEase.sineOut});

		inline function setOffsets(name:String, char:Character)
		{
			var daOffset = char.animOffsets.get(name);

			if (char.animOffsets.exists(name)) char.offset.set(daOffset[0], daOffset[1]);
			else char.offset.set(0, 0);
		}

		var anim:String = 'kill';

		dad.animation.play(anim, true);
		setOffsets(anim, dad);

		boyfriend.playSpecialAnim('surprise');
		gf.playSpecialAnim('what');

		dad.animation.finishCallback = (curAnim:String) -> 
		{
			if (curAnim == anim)
			{
				if (shadersOn)
				{
					var shader = new Aberration2(0);
					add(shader);

					camGame.filters.push(new ShaderFilter(shader.shader));

					FlxTween.num(shader.amount, 2.5, 1.5, function(num) { shader.amount = num; });
				}

				anim = 'attack-loop';

				dad.animation.play(anim, true);
				setOffsets(anim, dad);

				boyfriend.playSpecialAnim('gonna die');
				gf.playSpecialAnim('shock');

				new FlxTimer().start(1.5, (_) -> 
				{
					die(false);
				});
			}
		} 
	}

	function focusOnCharacter(character:Character):Void
	{
		if (!canTweenCam || character == null /* || !generatedMusic || daSection == null */)
			return;

		if (SONG.song == 'Nugget de Polla')
		{
			camFollow.screenCenter(X);
			camFollow.x += character.camSingPos.x * camGame.zoom;
			camFollow.y = 705 + character.camSingPos.y * camGame.zoom;
		}
		else
			camFollow.setPosition(character.camPos[0] + character.camSingPos.x * camGame.zoom, character.camPos[1] + character.camSingPos.y * camGame.zoom);
	}

	function doNoteSplash(daNote:Note):Void
	{
		if (GlobalData.settings.lowQuality || (daNote.noteStyle == 'nuggetP' && GlobalData.botplay))
			return;

		if (daNote.noteStyle == 'gum')
		{
			var gumTrap:GumTrap = gumNotes.recycle(GumTrap.new.bind(camHUD));
			gumTrap.setup(playerStrums.members[daNote.noteData], true);
			gumNotes.add(gumTrap);
		}
		else
		{
			var sploosh = splashGroup.recycle(NoteSplash.new);
			sploosh.play(playerStrums.members[daNote.noteData], daNote);
			splashGroup.add(sploosh);
		}
	}

	function gumNoteMechanic(daNote:Note):Void
	{
		var time:Float = Math.abs(difficultiesStuff["gumTrapTime"][storyDifficulty]);

		if (!cantPressArray[daNote.noteData] || time <= 0)
			return;

		cantPressArray[daNote.noteData] = false;

		var curStrum:Strum = playerStrums.members[daNote.noteData];

		var gumTrap:GumTrap = gumNotes.recycle(GumTrap.new.bind(camHUD));
		gumTrap.setup(curStrum);
		gumNotes.add(gumTrap);

		doNoteSplash(daNote);

		new FlxTimer().start(time / 2, (_) -> gumTrap.struggle());

		new FlxTimer().start(time, function (_)
		{
			gumTrap.die();

			new FlxTimer().start(0.1, function (_)
			{
				cantPressArray[daNote.noteData] = true;	
				curStrum.alpha = 1;
			});
		});
	}

	/**
	 * Function that sets the chromatic aberration `shader`.
	 * @param   value   The shader `value`.
	 * @param   shakeValue   The camera `shake` (set to 0 to disable).
	 * @param   tween      If it will `tween` or stay with that `value`.
	 * @param   toValue     The new value after the tween.
	 * @param   time     How much time it takes for the tween to end.
	 **/

	function chromatic(value:Float = 0.0025, shakeValue:Float = 0.005, tween:Bool = true, toValue:Float = 0, time:Float = 0.3):Void
	{
		if (!shadersOn)
		{
			trace("woops, no shaders");
			return;
		}

		camGame.shake(shakeValue);

		if (chromTween != null)
			chromTween.cancel();

		chromVal = value;

		if (tween)
		{
			chromTween = FlxTween.tween(this, {chromVal: toValue}, time);
		}
	}

	function camSpot(x:Float = 0, y:Float = 0, zoom:Float = null, time:Float = 0):Void
	{
		//camFollow.setPosition(); //OJSDOGAOESRHOIGHOAIEHRIODJVOLAJNERDKLHNTGAHERIOLSHGFKLJSAEDNRFLGKWHNERPOIYHGTOIWEDLRGHJKOLAESDRG FUCK

		if (!canDoCamSpot)
			return;

		canDoCamSpot = false;

		var prevCamZoom:Float = defaultCamZoom;

		if (canTweenCam)
			canTweenCam = false;

		camFollow.setPosition(x, y);
		if (zoom != null)
			defaultCamZoom = zoom;
		
		if (time > 0)
			{
				new FlxTimer().start(time, function(_)
					{
						canDoCamSpot = true;
						canTweenCam = true; 
						if (zoom != null)
							defaultCamZoom = prevCamZoom; //defaultCamZoom = stage.camZoom; 
					});
			}
	}

	function dialogue():Void
	{
		var dialogueCam = new FlxCamera();
		dialogueCam.bgColor.alpha = 0;
		FlxG.cameras.add(dialogueCam, false);

		new FlxTimer().start(0.25, function(_)
		{
			trace("Before dialogue created");

			inCutscene = true;
			var dialogueSpr:DialogueBox = new DialogueBox(CoolUtil.getDialogue());
			dialogueSpr.scrollFactor.set();
			dialogueSpr.finishThing = function()
			{
				FlxG.cameras.remove(dialogueCam);
				startCountdown();
			};
			dialogueSpr.cameras = [dialogueCam];
			dialogueSpr.alpha = 1;

			if (dialogueSpr != null)
				{
					add(dialogueSpr);
					trace("Added dialogue");
				}
		});
	}

	private function debugEditors():Void //this instead of the same code copied over and over 
	{
		//maybe update it only when you pressed any of the buttons because i guess that would make it better optimised i dont fucking know???
		if (FlxG.keys.anyJustPressed([SIX, SEVEN, EIGHT]))
		{
			var editorState:FlxState = null;

			switch (FlxG.keys.firstJustPressed())
			{
				// case TWO:   editorState = new debug.NotesDebug();
				case SIX:   editorState = new AnimationDebug(SONG.player2);
				case SEVEN: editorState = new ChartingState();
				case EIGHT: editorState = new StageDebug();
				default: return;
			}

			clearNotes();

			canPause = false;
			paused = true;
			songFinished = true;

			inst.volume = 0;
			vocals.volume = 0;
			inst.pause();
			vocals.pause();
			inst.stop();
			vocals.stop();

			setChrome(0);
			camGame.filters = [];
			camHUD.filters = [];

			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			MusicBeatState.switchState(editorState);
		}
	}

	//idea from impostor v4 BUT, in a different way because the way they made it in impostor v4 sucks (love u clowfoe) - alr this was way better before in terms of performance but now its better in visual terms
	function trail(char:Character, howManyNotes:Int):Ghost
	{
		if (GlobalData.settings.lowQuality || didDamage || dad.animation.curAnim.name == 'attack' || dumbAppleBG != null) return null;
		// trace('Applying trail $howManyNotes times.');

		var ghost = ghostsGroup.recycle(Ghost.new);
		ghost.setup(char);
		ghostsGroup.add(ghost);

		return ghost;
	}

	function turnPixel(enable:Bool)
	{
		if (pixelShit == null)
			return;

		canPause = false;

		var pixelValue = difficultiesStuff["principalPixel"][storyDifficulty];
		isExpellinTime = enable;

		if (enable)
		{
			final shaderFilter = new ShaderFilter(pixelShit.shader);
			shaderFilter.shader.precisionHint = FAST;
			camHUD.filters.push(shaderFilter);
			camGame.filters.push(shaderFilter);

			FlxTween.num(MosaicEffect.DEFAULT_STRENGTH, pixelValue, getTimeFromBeats(SECTIONS, 1), {onComplete: function(_)
			{
				canPause = true;
				scoreTxt.visible = false;

				if (GlobalData.settings.flashingLights && SONG.song == 'Expelled V2') FlxG.cameras.flash();

			}}, function(v)
			{
				pixelShit.setStrength(v, v);
			});
		}
		else
		{
			FlxTween.num(pixelValue, 1, getTimeFromBeats(SECTIONS, 2), {onComplete: function(_)
			{
				canPause = true;
				scoreTxt.visible = true;

				camHUD.filters.pop();
				camGame.filters.pop();
				pixelShit = null;

			}}, function(v)
			{
				pixelShit.setStrength(v, v);
			});
		}
	}

	//sanco is gonna laugh his ass off when he sees this - galo
	// what the fuck is this shit galo - sanco
	// ... - galo
	// Ok we're replacing this for a Monday remix so uhh, epic!!
	// If anyone is reading, this function was supposed to change everything to pixel

	//private function mondayTime(turnOn:Bool):Void //shitty name

	private function updateHealth():Void
	{
		health = FlxMath.bound(health, (GlobalData.practice || GlobalData.botplay) ? 0.001 : 0, 2);

		if (health <= 0)
		{
			die();
			return;
		}

		if (songFinished)
		{
			lerpHealth = health;
			return;
		}

		if (GlobalData.settings.lowQuality)
		{
			lerpHealth = health;
			healthBar.update(FlxG.elapsed);
			dumbIcons();
		}

		if (iconP1.animation.curAnim != null) iconP1.animation.curAnim.curFrame = (health < 0.4 ? 1 : 0);
		if (iconP2.animation.curAnim != null) iconP2.animation.curAnim.curFrame = (health > 1.6 ? 1 : 0);
	}

	private function eatApple(isPlayer:Bool):Void
	{
		if (isPlayer)
		{
			if (actions <= 0 || actions > 3) return;

			CoolUtil.sound('bite', 'shared');
			poisonStacks = 0; //bye bye good nuggets :(
			actions--;
			changeHealth(difficultiesStuff["appleHealthGain"][storyDifficulty]);
			if (dumbAppleBG == null) FlxTween.color(boyfriend, 0.5, FlxColor.GREEN, FlxColor.WHITE);
			camSpot(boyfriend.getGraphicMidpoint().x - 100, boyfriend.getGraphicMidpoint().y, defaultCamZoom + 0.3, 0.5);

			updateApples();
		}
		else
		{
			CoolUtil.sound('bite', 'shared');
			changeHealth(difficultiesStuff["appleHealthLoss"][storyDifficulty] * -1);
			if (dumbAppleBG == null) FlxTween.color(dad, 0.5, FlxColor.GREEN, FlxColor.WHITE);
		}
	}

	private function updateApples():Void
	{
		if (actions < 0) actions = 0;
		if (actions > 3) actions = 3;

		applesCounter.updateCounter(actions);
	}

	private function updateLerps(elapsed:Float):Void
	{
		if (songFinished)
			return;

		if (!GlobalData.settings.lowQuality)
		{
			var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9)));

			iconP1.scale.set(mult, mult);
			iconP2.scale.set(mult, mult);

			lerpHealth = FlxMath.lerp(health, lerpHealth, CoolUtil.boundTo(1 - elapsed * 10));
			if (Math.abs(lerpHealth - health) < 0.01)
				lerpHealth = health; // it never actually reaches that fucking value
			healthBar.update(FlxG.elapsed);
			dumbIcons();

			camGame.zoom = FlxMath.lerp(defaultCamZoom, camGame.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125)));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125)));
		}

		camGame.focusOn(camPoint.set(FlxMath.lerp(camPoint.x, camFollow.x, 0.5 * (elapsed * 5)), FlxMath.lerp(camPoint.y, camFollow.y, 0.5 * (elapsed * 5))));
	}

	private function updateNotes():Void
	{
		if (songFinished)
			return;

		if (generatedMusic)
		{
			var downMult:Int = (!GlobalData.settings.downscroll ? 1 : -1);

			for (daNote in notes.members)
			{
				if (!daNote.alive) continue;

				if (daNote.tooLate)
				{
					daNote.active = false;
					daNote.alpha = 0.5;
				}
				else
					daNote.visible = daNote.active = true;

				var strums:FlxTypedGroup<Strum> = (daNote.mustPress) ? playerStrums : cpuStrums;
				var receptorX = strums.members[Math.floor(Math.abs(daNote.noteData))].x;
				var receptorY = strums.members[Math.floor(Math.abs(daNote.noteData))].y + (Note.swagWidth / 6);

				var pseudoY:Float = daNote.offsetY + (downMult * -((Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)) * daNote.speed));

				daNote.y = receptorY
					+ (Math.cos(FlxAngle.asRadians(daNote.direction)) * pseudoY)
					+ (Math.sin(FlxAngle.asRadians(daNote.direction)) * daNote.offsetX);

				daNote.x = receptorX
					+ (Math.cos(FlxAngle.asRadians(daNote.direction)) * daNote.offsetX)
					+ (Math.sin(FlxAngle.asRadians(daNote.direction)) * pseudoY);

				daNote.angle = -daNote.direction;

				var center:Float = receptorY + Note.swagWidth / 2;
				if (daNote.isSustainNote)
				{
					daNote.y -= ((daNote.height / 2) * downMult);
					if (daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
					{
						daNote.y -= ((daNote.prevNote.height / 2) * downMult);
						if (GlobalData.settings.downscroll)
						{
							daNote.y += (daNote.height * 2);

							if (daNote.endHoldOffset == Math.NEGATIVE_INFINITY)
								daNote.endHoldOffset = (daNote.prevNote.y - (daNote.y + daNote.height)) + 2;
							else
								daNote.y += ((daNote.height / 2) * downMult);
						}
						else
							daNote.y += ((daNote.height / 2) * downMult);
					}
				}

				if (GlobalData.settings.downscroll)
				{
					//daNote.flipY = true;
					if ((daNote.parent != null && daNote.parent.wasGoodHit) && daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center && (GlobalData.botplay || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						daNote.updateRect(center);
					}
				}
				else
				{
					if ((daNote.parent != null && daNote.parent.wasGoodHit) && daNote.y + daNote.offset.y * daNote.scale.y <= center && (GlobalData.botplay || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						daNote.updateRect(center);
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit && daNote.noteStyle != 'nuggetP')
				{
					if (!daNote.doubleNote) 
					{
						dad.sing(daNote.noteData);

						if (SONG.song == 'Specimen' && dad.curCharacter == 'monster' && mechanicsOn)
						{
							health -= difficultiesStuff.get('monsterDrain')[storyDifficulty];

							if (health <= 0)
								health = 0.001;

							updateHealth();
						}
					}
					else if (!daNote.isSustainNote)
					{
						trail(dad, getMultNotes(true, daNote));
					}

					if (daNote.noteStyle == 'apple' && SONG.player2.startsWith('protagonist') && !daNote.isSustainNote) 
						eatApple(false);

					if (SONG.needsVoices)
						vocals.volume = 1;

					for (spr in cpuStrums.members) 
						if (Math.abs(daNote.noteData) == spr.ID) 
							spr.playAnim('confirm', true);

					destroyNote(daNote);
				}

				if ((daNote.mustPress && daNote.tooLate && !GlobalData.settings.downscroll || daNote.mustPress && daNote.tooLate && GlobalData.settings.downscroll) && daNote.mustPress)
				{
					if (!daNote.isSustainNote || !daNote.wasGoodHit)
						noteMiss(daNote.noteData, daNote);
	
					destroyNote(daNote);
				}
			};
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 3500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}
	}

	private function updateSongPosition():Void
	{
		if (songFinished)
			return;

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;
	
			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}
			}

			if (clock != null) clock.updateTime();
		}
	}

	private function checkJanitorAnim():Void
	{
		if (songFinished)
			return;

		if (mechanicsOn && SONG.song == 'Staff Only') //if mechanics are enabled and its janitor song
		{
			if (dad.animation.curAnim.name == 'attack' && dad.animation.curAnim.curFrame >= 18 && !didDamage)
				{
					didDamage = true;
					changeHealth(difficultiesStuff['mopHealthLoss'][storyDifficulty]);
					boyfriend.playSpecialAnim('hurt');
					boyfriend.animation.curAnim.curFrame = 3;
					if (gf != null)
						gf.playSpecialAnim('shock');
					camGame.shake(0.007, 0.25);
					CoolUtil.sound('janitorHit', 'shared');
					new FlxTimer().start(1, function(_){ 
						didDamage = false; 
						canPause = true;});
				}
		}
	}

	private function addRating(daNote:Note, daRating:String)
	{
		var offsetX:Float = 480;
		var offsetY:Float = 270;

		if (GlobalData.settings.changedHit)
		{
			offsetX = GlobalData.settings.changedHitX;
			offsetY = GlobalData.settings.changedHitY;
		}

		var seperatedScore:Array<Int> = [];
		if(scoreData.combo >= 1000)  seperatedScore.push(Math.floor(scoreData.combo / 1000) % 10);
		seperatedScore.push(Math.floor(scoreData.combo / 100) % 10);
		seperatedScore.push(Math.floor(scoreData.combo / 10) % 10);
		seperatedScore.push(scoreData.combo % 10);

		for (i in 0...seperatedScore.length)
		{
			var numScore = numbersGroup.recycle(Number.new);
			numScore.setPosition(offsetX + (43 * i) + 50, offsetY + 115 + (isPixel ? 60 : 0));
			numScore.play(Std.int(seperatedScore[i]));
			numScore.visible = !isExpellinTime;
			numbersGroup.add(numScore);
		}

		if (!GlobalData.botplay)
		{
			var rating = ratingsGroup.recycle(Rating.new);
			rating.play(daRating);
			ratingsGroup.add(rating);

			if (Math.abs(daNote.strumTime - Conductor.songPosition) == 0)
				rating.color = FlxColor.YELLOW;
			else
				rating.color = FlxColor.WHITE;
		}
	}

	private function addCharacters():Void
	{
		// LMFAO NICE TRY MODIFYING FILE'S SHIT LOSER - nvm you still can fuck up the game playing around with the chart files

		if (GlobalData.other.beatenStoryMode && GlobalData.other.gotSkin)
			SONG.player1 = (GlobalData.other.usingSkin ? 'bf-alt' : 'bf');
		else
			SONG.player1 = 'bf';

		#if !debug
		switch (SONG.song)
		{
			case 'Monday':	SONG.player2 = 'protagonist';
			case 'Nugget':  SONG.player2 = 'nugget';
			case 'Cash Grab':  SONG.player2 = 'monty';
			case 'Staff Only':  SONG.player2 = 'janitor';
			case 'Expelled' | 'Expelled V0' | 'Expelled V1' | 'Expelled V2':  SONG.player2 = 'principal';
			case 'Nugget de Polla': SONG.player2 = 'polla';
			case 'Monday Encore': SONG.player2 = 'protagonist-pixel'; SONG.player1 = 'bf-pixel';
			case 'Petty Petals': SONG.player2 = 'cindy';
		}
		#end

		add(stage = new Stage());

		if (!['Nugget', 'Monday Encore'].contains(SONG.song))
		{
			gf = new GF(stage);
			add(gf);

			if (SONG.song == 'Staff Only')
			{
				gf.setGraphicSize(gf.width * 0.9);
				gf.updateHitbox();
			}
		}

		add(ghostsGroup = new FlxTypedGroup<Ghost>());

		add(dad = new Character(stage.positions['dad'][0], stage.positions['dad'][1], SONG.player2));
		add(boyfriend = new Character(stage.positions['bf'][0], stage.positions['bf'][1], SONG.player1, true));

		var curDeadChar:String = boyfriend.curCharacter.replace('-alt', '') + '-dead';

		if (deadBF == null || deadBF.curCharacter != curDeadChar)
		{
			if (deadBF != null && deadBF.curCharacter != curDeadChar)
			{
				FlxG.bitmap.remove(deadBF.graphic);
			}

			deadBF = new Character(0, 0, curDeadChar, true); // precaching deadBF makes the change to the gameOver smoother
			deadBF.graphic.persist = true;
		}

		if (!GlobalData.settings.lowQuality)
			trail(dad, 0).kill();

		stage.forEach(function(i:BGSprite)
		{
			if (i.isAboveChar)
			{
				remove(i);
				insert(members.indexOf(boyfriend) + 1, i); //LOVE YOU SANCO 	//add(i);
			}
		});

		if (SONG.song == 'Expelled V1' && FlxG.random.bool(100 / 3))
			add(new Sackboy(boyfriend));
	}

	private inline function dumbIcons():Void
	{
		if (GlobalData.botplay || GlobalData.practice)
			return;

		//icons shit
		var iconOffset:Int = 18;
		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
	}

	private function changeHealth(amount:Float):Void
	{
		health += amount;

		updateHealth();
	}

	private function getMultNotes(isDad:Bool, note:Note):Int
	{
		var doubleNotes:Array<Float> = (isDad ? notestrumtimes2 : notestrumtimes1);
		var count = 0;

		for (i in doubleNotes)
		{
			if (i == Math.round(note.strumTime)) count++;
		}

		return count;
	}

	private function doCountdown():Void
	{
		if (SONG.song == 'Nugget de Polla')
		{
			canPause = true;
			return;
		}

		var swagCounter:Int = 0;

		new FlxTimer().start(getTimeFromBeats(BEATS, 1), function(_)
		{
			boyfriend.dance();
			dad.dance();
			if (gf != null)
				gf.dance();

			bop(true);

			if (swagCounter > 0)
			{
				var spr = new FlxSprite();
				if (!isPixel) spr.frames = Paths.ui();
				else
				{
					spr.frames = Paths.pixel();
					spr.antialiasing = false;
					spr.setGraphicSize(Std.int(spr.width * 8));
				}

				spr.animation.addByIndices('idle', 'countdown', [swagCounter - 1], '', 0, false);
				spr.animation.play('idle');
				spr.scrollFactor.set();
				spr.updateHitbox();
				spr.screenCenter();
				spr.active = false;
				add(spr);

				FlxTween.tween(spr, {y: spr.y += 100, alpha: 0}, Conductor.crochet / 1000, {
					ease: FlxEase.cubeInOut,
					onComplete: function(_)
					{
						spr.destroy();
					}
				});
			}

			var daSound:String = null;

			switch (swagCounter)
			{
				case 0:	daSound = '3';
				case 1: daSound = '2';
				case 2: daSound = '1';
				case 3: daSound = 'Go';
				canPause = true;
			}

			if (daSound != null)
				CoolUtil.sound('intro' + daSound + (isPixel ? "-pixel" : ""), 'shared', 0.6);

			swagCounter += 1;
		}, 4);
	}

	override function destroy():Void
	{
		if (chromTween != null)
			chromTween.destroy();

		super.destroy();
	}

	private function pause():Void
	{
		if (!startedCountdown || !canPause || paused)
			return;

		paused = true;

		@:privateAccess
		for (i in FlxTween.globalManager._tweens)
			i.active = false;

		persistentUpdate = false;
		persistentDraw = true;

		vocals.pause();
		inst.pause();

		FlxG.mouse.visible = true;

		openSubState(new substates.PauseSubState());
	}

	override function onFocusLost()
	{
		super.onFocusLost();

		pause();
	}

	private function addYoyo():Void
	{
		if (SONG.song != 'Cash Grab' || !mechanicsOn)
			return;

		add(yoyo = new Yoyo(playerStrums, camHUD, difficultiesStuff['montyYoyo'][storyDifficulty]));
		FlxG.mouse.visible = true;
	}

	private inline function setChrome(daChrome:Float):Void
	{
		if (!['Expelled', 'Expelled V1', 'Expelled V2', 'Nugget de Polla'].contains(SONG.song) || !shadersOn)
			return;

		if (daChrome == chromVal && daChrome > 0)
		{
			if (chromTween != null)
				daChrome += (chromVal / (chromTween.finished ? FlxG.random.float(1.5, 2.5) : 10)) * (FlxG.random.bool() ? 1 : -1);
			else
				daChrome += (chromVal / FlxG.random.float(1.5, 2.5)) * (FlxG.random.bool() ? 1 : -1);
		}

		ChromaHandler.setChrome(daChrome);
	}

	private function addCameras():Void
	{
		camGame = new FlxCamera();
		FlxG.cameras.reset(camGame);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		camGame.filters = [];

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camHUD.alpha = 0;
		camHUD.filters = [];
		FlxG.cameras.add(camHUD, false);

		if (shadersOn)
		{
			switch (SONG.song)
			{
				case 'Expelled' | 'Expelled V1' | 'Expelled V2' | 'Nugget de Polla':
					camHUD.filters = camGame.filters = [ChromaHandler.chromaticAberration];
				case 'Petty Petals':
					camHUD.filters = camGame.filters = [new ShaderFilter(new VHSShader())];
			}
		}

		if ((['Expelled V1', 'Expelled V2'].contains(SONG.song) && mechanicsOn) || SONG.song == 'Expelled V0')
		{
			pixelShit = new MosaicEffect();
		}

		camOther = new FlxCamera();
		camOther.bgColor.alpha = 0;
		FlxG.cameras.add(camOther, false);

		setChrome(0);
	}

	private function clearNotes():Void
	{
		var destroyed:Int = 0;
		var i:Int = unspawnNotes.length - 1;

		while (i >= 0)
		{
			var daNote:Note = unspawnNotes[i];
			daNote.active = false;
			daNote.visible = false;
			daNote.exists = false;

			daNote.kill();
			unspawnNotes.remove(daNote);
			daNote.destroy();
			daNote = null;

			--i;
			destroyed++;
		}
	
		trace('Removed $destroyed notes.');

		destroyed = 0;
		i = notes.length - 1;

		while (i >= 0)
		{
			destroyNote(notes.members[i]);

			--i;
			destroyed++;
		}
	
		trace('Destroyed $destroyed notes.');
	}

	private function pollaJumpscare():FlxSprite
	{
		if (pollasGroup.length > 0)
			CoolUtil.sound('vine', 'shit');

		var nugget = pollasGroup.recycle(FlxSprite.new.bind(0,0, Paths.image('characters/nugget', 'shit')));
		nugget.setGraphicSize(FlxG.width, FlxG.height);
		nugget.updateHitbox();
		nugget.screenCenter();
		nugget.active = false;
		pollasGroup.add(nugget);

		FlxTween.cancelTweensOf(nugget);
		nugget.alpha = difficultiesStuff["pollaAlpha"][storyDifficulty];
		nugget.blend = ADD;
		FlxTween.tween(nugget, {alpha: 0}, 2, {startDelay: 0.2, onComplete: function(_) nugget.kill()});

		return nugget;
	}

	// Original from Psych Engine
	private function setupSpotlights():Void
	{
		if (SONG.song != 'Nugget de Polla' || GlobalData.settings.lowQuality)
			return;

		spotlightBlack = new FlxSprite().makeGraphic(1, 1);
		spotlightBlack.color = FlxColor.BLACK;
		spotlightBlack.scale.set(FlxG.width * 2, FlxG.width * 2);
		spotlightBlack.active = false;
		spotlightBlack.alpha = 0.25;
		spotlightBlack.visible = false;
		spotlightBlack.scrollFactor.set();
		spotlightBlack.screenCenter();
		add(spotlightBlack);

		spotlight = new FlxSprite(400, -400, Paths.image('bg/spotlight', 'shit'));
		spotlight.alpha = 0.375;
		spotlight.blend = ADD;
		spotlight.visible = false;
		spotlight.active = false;
		add(spotlight);

		smokes = new FlxSpriteGroup();
		smokes.alpha = 0;
		smokes.blend = ADD;
		smokes.visible = false;
		smokes.active = false;
		add(smokes);

		var smoke = new FlxSprite(0, 0, Paths.image('bg/smoke', 'shit'));
		smoke.scrollFactor.set(1.2, 1.05);
		smoke.setGraphicSize(smoke.width * FlxG.random.float(1.1, 1.22));
		smoke.updateHitbox();
		smoke.velocity.x = FlxG.random.float(15, 22);
		smokes.add(smoke);
		smoke.setPosition(dad.x - spotlight.width, dad.y + dad.height - spotlight.height / 2 + FlxG.random.float(-20, 20) + 270);

		var smoke = new FlxSprite(0, 0, Paths.image('bg/smoke', 'shit'));
		smoke.scrollFactor.set(1.2, 1.05);
		smoke.setGraphicSize(smoke.width * FlxG.random.float(1.1, 1.22));
		smoke.updateHitbox();
		smoke.velocity.x = FlxG.random.float(-15, -22);
		smoke.flipX = true;
		smokes.add(smoke);
		smoke.setPosition(boyfriend.x + boyfriend.width - spotlight.width / 2, boyfriend.y + boyfriend.height - spotlight.height / 2 + FlxG.random.float(-20, 20) + 270);
	}

	// Original from Psych Engine
	private function doSpotlights(event:EpicEvent):Void
	{
		if (SONG.song != 'Nugget de Polla' || GlobalData.settings.lowQuality)
			return;

		var val:Null<Int> = Std.parseInt(event.value);
		val ??= 0;

		switch(val)
		{
			case 1, 2:
				spotlightBlack.visible = true;
				spotlight.visible = true;
				smokes.visible = true;
				smokes.active = true;
				FlxTween.cancelTweensOf(smokes);
				FlxTween.tween(smokes, {alpha: 0.5}, 1, {ease: FlxEase.sineOut});

				var who:Character = (val == 2 ? boyfriend : dad);
				spotlight.setPosition(who.getGraphicMidpoint().x - spotlight.width / 2, who.y + who.height - spotlight.height);

			default:
				spotlightBlack.visible = false;
				spotlight.visible = false;
				FlxTween.cancelTweensOf(smokes);
				FlxTween.tween(smokes, {alpha: 0}, 1, {onComplete: function(_) smokes.visible = smokes.active = false });
		}
	}

	// Im using the code from the main menu cuz the bugfix releases today and im too lazy to make it better
	private var daExpelledCode:Array<String> = ['S', 'H', 'I', 'T'];

	private inline function expelledCode():Void
	{
		var key:FlxKey = FlxG.keys.firstJustPressed();

		if (daExpelledCode[0] == key)
			daExpelledCode.shift();
		else if (daExpelledCode[0] != 'S')
			daExpelledCode = ['S', 'H', 'I', 'T'];

		trace('[ Just pressed $daExpelledCode - code: $daExpelledCode ]');

		if (daExpelledCode.length <= 0)
		{
			GlobalData.other.didV0 = true;
			GlobalData.flush();

			clearNotes();

			canPause = false;
			paused = true;
			songFinished = true;

			inst.volume = 0;
			vocals.volume = 0;
			inst.pause();
			vocals.pause();
			inst.stop();
			vocals.stop();

			setChrome(0);
			camGame.filters = [];
			camHUD.filters = [];

			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);

			new FlxTimer().start(1, function(_)
			{
				secretSong('expelled-v0', 2);
			});
		}
	}

	function get_mechanicsOn():Bool
	{
		return GlobalData.settings.mechanicsEnabled && storyDifficulty != 0; // mechanics are enabled if the setting is set to ON and the difficulty isn't easy
	}

	function get_shadersOn():Bool
	{
		return GlobalData.settings.shadersEnabled && GlobalData.settings.flashingLights; // mechanics are enabled if the setting is set to ON and the difficulty isn't easy
	}
}