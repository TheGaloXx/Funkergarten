package states;

import funkin.Conductor;
import flixel.sound.FlxSound;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import funkin.SongEvents.EpicEvent;
import objects.Objects;
import openfl.events.KeyboardEvent;
import flixel.input.keyboard.FlxKey;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import data.KadeEngineData;

using StringTools;

class PlayState extends funkin.MusicBeatState
{
	public static var instance:states.PlayState = null;

	public static var isStoryMode:Bool = false;
	public static var curStage:String = '';
	public static var SONG:funkin.Song.SwagSong;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var weekScore:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;
	public static var tries:Int = 0;

	var songLength:Float = 0;
	private var vocals:flixel.sound.FlxSound;
	private var inst:flixel.sound.FlxSound;

	public static var dad:objects.Character;

	public static var songHas3Characters:Bool = false;
	public static var thirdCharacter:objects.Character;

	#if GF
	public static var gf:objects.Character;
	#end
	public static var boyfriend:objects.Boyfriend;

	private var events:Array<EpicEvent> = [];
	public var notes:FlxTypedGroup<objects.Note>;
	private var unspawnNotes:Array<objects.Note> = [];
	public var splashGroup:flixel.group.FlxGroup.FlxTypedGroup<objects.NoteSplash>;
	public var ratingsGroup:flixel.group.FlxGroup.FlxTypedGroup<Rating>;
	public var numbersGroup:flixel.group.FlxGroup.FlxTypedGroup<Number>;
	private var ghostsGroup:flixel.group.FlxGroup.FlxTypedGroup<Ghost>;

	private var camFollow:flixel.FlxObject;

	private var playerStrums:FlxTypedGroup<objects.Strum>;
	private var cpuStrums:FlxTypedGroup<objects.Strum>;

	private var curSong:String = "";

	public var health:Float = 1; // making public because sethealth doesnt work without it
	private var lerpHealth:Float = 1; // From the actual full-ass game!!!
	private var combo:Int = 0;
	public static var misses:Int = 0;
	public var accuracy:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalPlayed:Int = 0;

	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var iconP1:objects.HealthIcon; //making these public again because i may be stupid
	private var iconP2:objects.HealthIcon; //what could go wrong?
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	//code from carol and whitty date week
	var notestrumtimes1:Array<Float> = [];
	var notestrumtimes2:Array<Float> = [];

	public var songScore:Int = 0;
	var songScoreDef:Int = 0;
	var scoreTxt:FlxText;

	public static var campaignScore:Int = 0;
	public static var defaultCamZoom:Float = 1;

	var canTweenCam:Bool = true;
	var canDoCamSpot:Bool = true;

	var inCutscene:Bool = false;

	var curBeatText:FlxText;

	var storyDifficultyText:String;

	public static var stage:objects.Stage;

	//shaders
	var filters:Array<openfl.filters.BitmapFilter> = [];
	var chromVal:Float = 0;
	var defaultChromVal:Float = 0;
	var chromTween:FlxTween;

	var shaderFilter:openfl.filters.ShaderFilter;

	private var apples = new FlxTypedGroup<Apple>(); //BETTER CODE LETS GOOOOOOOO, CHECK THE LAST VERSION OF THIS SHIT HAHAHAHA;

	public static var originalSongSpeed:Float;
	public static var changedSpeed:Bool = false;

	//retrospecter goes brrrrrrrrrrrrr
	var poisonStacks:Int = 0;

	//gum mechanic *blushes*
	//var gumTrap:GumTrap;
	var cantPressArray:Array<Bool> = [true, true, true, true];

	var actions:Int;

	public static var isPixel:Bool;
	//public static var prevIsPixel:Bool; //shit for charting state because special notes (except apple notes) dont have a pixel version and are replaced with normal pixel notes so yeah
	//Ok i noticed i dont need that shit lmao

	//var dialogueSpr:objects.DialogueBox;
	//public var dialogue:Array<String> = ['dad:if youre reading this... you fucking suck lmao', 'bf: jk im kidnapped send help'];

	var cameraBopBeat:Float = 2;

	//var difficultiesValues:Map
	var difficultiesStuff:Map<String, Array<Dynamic>> =
		[
			//variable				easy		normal		hard	survivor
			"appleHealthGain"   => [2, 			1.5, 		0.75, 	1],
			"appleHealthLoss"   => [0, 			0.25, 		0.75, 	0.5],
			"gumTrapTime" 	    => [0.1,		3, 			6, 		12],
			"healthDrainPoison" => [0, 			0.25, 		0.2, 	0.3],
			"janitorHits"       => [999999, 	32, 		16, 	8],
			"mopHealthLoss"     => [0, 			-0.5, 		-1, 	-1],
    		"janitorAccuracy"   => [0, 			70, 		90, 	95],
			"principalPixel"	=> [null,		384, 		256, 	128],
			"montyYoyo"			=> [0,			0.75,		1,		1],
			"yoyoFrequency"     => [999999,		50,         35,     10]
		];

	private var janitorKys:Bool = FlxG.random.bool(15);

	private var isExpellinTime:Bool = false;

	var pixelShit:Shaders.PixelEffect;
	private var pollaBlock = new FlxSprite().makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);

	private var hasNuggets:Bool = false;
	private var clock:Clock;
	private var camPoint = new flixel.math.FlxPoint();
	private var yoyo:objects.Yoyo;

	override public function create()
	{
		instance = this;

		Cache.clear();
		CoolUtil.title('Loading...');
		CoolUtil.presence(null, 'Loading...', false, 0, null);

		FlxG.mouse.visible = false;
		if (storyDifficulty == 3 || KadeEngineData.botplay)
			KadeEngineData.practice = false;
		
		if (FlxG.sound.music != null || FlxG.sound.music.playing)
			FlxG.sound.music.stop();

		sicks = bads = shits = goods = misses = 0;

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camHUD.alpha = 0;
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		if (KadeEngineData.settings.data.flashing && KadeEngineData.settings.data.shaders)
		{
			filters.push(chromaticAberration);
			FlxG.game.setFilters(filters);
		}

		setChrome(0);

		funkin.Conductor.mapBPMChanges(SONG);
		funkin.Conductor.changeBPM(SONG.bpm);

		if (SONG.stage == null) 
		{
			trace("da fuck the song stage is null why i dont know???????????????????????");
			SONG.stage == 'void';
		}

		switch (SONG.song)
		{
			case 'Monday Encore':
				songHas3Characters = false;
				isPixel = true;
			default:
				songHas3Characters = false;
				isPixel = false;
		}
		
		addCharacters();

		funkin.Conductor.songPosition = -5000;

		add(playerStrums = new FlxTypedGroup<objects.Strum>());
		add(cpuStrums = new FlxTypedGroup<objects.Strum>());
		add(numbersGroup = new flixel.group.FlxGroup.FlxTypedGroup<Number>());
		if (!KadeEngineData.botplay)
		{
			add(ratingsGroup = new flixel.group.FlxGroup.FlxTypedGroup<Rating>());
			ratingsGroup.cameras = [camHUD];
		}

		add(splashGroup = new flixel.group.FlxGroup.FlxTypedGroup<objects.NoteSplash>());
		add(notes = new FlxTypedGroup<objects.Note>());

		generateSong(SONG.song);

		print('generated');

		storyDifficultyText = CoolUtil.difficultyFromInt(storyDifficulty).toUpperCase(); //to uppercase because im so fucking cool to do it in directly in the array like a virgin

		CoolUtil.title('${SONG.song} - [$storyDifficultyText]');
		CoolUtil.presence('Starting countdown...', 'Playing: ${SONG.song} - [$storyDifficultyText]', false, null, (dad.curCharacter == 'janitor' ? (janitorKys ? 'kys' : 'janitor') : dad.curCharacter), true);

		camFollow = new flixel.FlxObject();
		camFollow.setPosition(boyfriend.camPos[0], boyfriend.camPos[1]);
		camFollow.active = false;
		camPoint.set(camFollow.getPosition().x, camFollow.getPosition().y);
		camGame.zoom = defaultCamZoom;

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		FlxG.fixedTimestep = false;

		var healthBarBG = new FlxSprite(0, (KadeEngineData.settings.data.downscroll ? 50 : FlxG.height * 0.9)).makeGraphic(601, 19, FlxColor.BLACK);
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.active = false;
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this, 'lerpHealth', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(FlxColor.fromString(dad.curColor), 
		FlxColor.fromString(boyfriend.curColor));
		add(healthBar);

		healthBar.numDivisions = 200;

		if (KadeEngineData.settings.data.songPosition) add(clock = new Clock(camHUD));

		var daY = healthBarBG.y + (KadeEngineData.settings.data.downscroll ? 100 : -100);
		// Literally copy-paste of the above, fu
		if(KadeEngineData.botplay)
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

		#if debug
		curBeatText = new FlxText(0, daY + (KadeEngineData.settings.data.downscroll ? 50 : -50), FlxG.width, "Beat: ", 20);
		curBeatText.autoSize = false;
		curBeatText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		curBeatText.scrollFactor.set();
		curBeatText.borderSize = 1.25;
		curBeatText.active = false;
		add(curBeatText);
		curBeatText.cameras = [camHUD];
		#end

		iconP1 = new objects.HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new objects.HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		iconP1.active = false;
		iconP2.active = false;

		scoreTxt = new FlxText(0, healthBarBG.y + 35, FlxG.width, data.Ratings.CalculateRanking(0, 0, 0), 20);
		scoreTxt.autoSize = false;
		scoreTxt.borderSize = 1.25;
		scoreTxt.scrollFactor.set();
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		scoreTxt.active = false;
		add(scoreTxt);

		if (SONG.song == 'Nugget de Polla'){
			camFollow.screenCenter(X);
			camFollow.y -= 150;
			iconP1.visible = iconP2.visible = false;
			healthBar.visible = healthBarBG.visible = false;

			if (KadeEngineData.settings.data.distractions){
			pollaBlock.screenCenter();
			pollaBlock.scrollFactor.set();
			pollaBlock.active = false;
			add(pollaBlock);
			}
		}

		playerStrums.cameras = cpuStrums.cameras = splashGroup.cameras = numbersGroup.cameras = notes.cameras = healthBar.cameras = healthBarBG.cameras = iconP1.cameras = iconP2.cameras = scoreTxt.cameras = [camHUD];

		startingSong = true;
		
		print('starting');

		tries++;

		if (tries <= 1 && isStoryMode && CoolUtil.getDialogue().length > 0) dialogue();
		else startCountdown();

		if (SONG.song == 'Cash Grab' && KadeEngineData.settings.data.mechanics && storyDifficulty != 0)
		{
			add(yoyo = new objects.Yoyo(playerStrums, camHUD, difficultiesStuff['montyYoyo'][storyDifficulty]));
			FlxG.mouse.visible = true;
		}

		for (i in 0...3)
		{
			var spr = new Apple(0, 0);
			spr.cameras = [camHUD];
			spr.x = spr.width * i;
			spr.y = FlxG.height - spr.height - 1;
			spr.ID = i + 1;
			spr.alpha = 0; // apparently setting alpha to 0 is better than setting visible to false because it prevents the sprite from calling `draw` - no dumbass both do that
			spr.active = false;
			apples.add(spr);
		}

		add(apples);

		if (!cast(KadeEngineData.other.data.showCharacters, Array<Dynamic>).contains(dad.curCharacter)){
			cast(KadeEngineData.other.data.showCharacters,  Array<Dynamic>).push(dad.curCharacter);
			KadeEngineData.flush();
		}

		if (SONG.song == 'Nugget') boyfriend.camPos[1] -= 200;
		if (SONG.song == 'Expelled') boyfriend.camPos[0] -= 100;
		if (SONG.song == 'Cash Grab') boyfriend.camPos[0] -= 200;

		focusOnCharacter(dad);

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);

		super.create();
	}

	function startCountdown():Void
	{
		inCutscene = false;
		startedCountdown = true;

		if (curSong != 'Nugget de Polla')
		{
			funkin.Conductor.songPosition = -funkin.Conductor.crochet * 5;
			if (camHUD.alpha != 1) FlxTween.tween(camHUD, {alpha: 1}, 0.5, {startDelay: 1});
		}
		else
		{
			funkin.Conductor.songPosition = -funkin.Conductor.crochet * 1;
			if (camHUD.alpha != 1) FlxTween.tween(camHUD, {alpha: 1}, 2.5, {startDelay: 1});
		}

		generateStaticArrows();
		doCountdown();
	}

	var previousFrameTime:Int = 0;
	var songTime:Float = 0;

	var binds:Array<String> = [KadeEngineData.controls.data.leftBind.toLowerCase(),
		KadeEngineData.controls.data.downBind.toLowerCase(), 
		KadeEngineData.controls.data.upBind.toLowerCase(), 
		KadeEngineData.controls.data.rightBind.toLowerCase()];
	var keys = [false, false, false, false];

	// kind of rewritten the input ig
	private function handleInput(evt:KeyboardEvent):Void { // this actually handles press inputs

		if (KadeEngineData.botplay || paused)
			return;

		// first convert it from openfl to a flixel key code
		// then use FlxKey to get the key's name based off of the FlxKey dictionary
		// this makes it work for special characters

		@:privateAccess
		var openFLKey = openfl.ui.Keyboard.__convertKeyCode(evt.keyCode);
		var key = FlxKey.toStringMap.get(openFLKey).toLowerCase();

		var data:Int = (binds.contains(key) ? binds.indexOf(key) : getArrowKey(openFLKey));

		if (keys[data] || data == -1)
			return;

		keys[data] = true;

		var possibleNotes:Array<objects.Note> = [];
		var directionList:Array<Int> = [];
		var dumbNotes:Array<objects.Note> = [];

		//notes.forEachAlive(function(daNote:objects.Note)
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
		else if (!KadeEngineData.settings.data.ghostTap)
		{
			noteMissPress(data);
		}
	}

	private function releaseInput(evt:KeyboardEvent):Void {
		@:privateAccess
		var openFLKey = openfl.ui.Keyboard.__convertKeyCode(evt.keyCode);
		var key = FlxKey.toStringMap.get(openFLKey).toLowerCase();

		var data:Int = (binds.contains(key) ? binds.indexOf(key) : getArrowKey(openFLKey));

		keys[data] = false;
	}

	// convierte una tecla de OpenFL a una direccion
	private function getArrowKey(flKey:Int):Int
	{
		return switch(flKey)
		{
			default:
				return -1;
			case 53:
				return 0;
			case 57:
				return 1;
			case 55:
				return 2;
			case 222:
				return 3;
		}
	}

	function startSong():Void
	{
		startingSong = false;
		previousFrameTime = FlxG.game.ticks;

		if (!paused) inst.play();
		vocals.play();

		// funkin.Song duration in a float, useful for the time left feature
		songLength = inst.length;
		if (clock != null) clock.songLength = songLength;
		
		bop(true);
	}

	private function generateSong(dataPath:String):Void
	{
		funkin.Conductor.changeBPM(SONG.bpm);
		originalSongSpeed = SONG.speed;
		curSong = SONG.song;

		vocals = new flixel.sound.FlxSound();
		if (SONG.needsVoices)
			vocals.loadEmbedded(Paths.voices(states.PlayState.SONG.song));

		FlxG.sound.list.add(vocals);

		inst = new FlxSound();
		inst.loadEmbedded(Paths.inst(states.PlayState.SONG.song));
		inst.onComplete = endSong;
		FlxG.sound.list.add(inst);

		final daSong:String = CoolUtil.normalize(SONG.song);

		// Load events
		if (funkin.SongEvents.loadJson(daSong) != null)
			for (event in funkin.SongEvents.loadJson(daSong))
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
			}

		//Load notes
		for (section in SONG.notes)
			{
				for (songNotes in section.sectionNotes)
				{
					var daStrumTime:Float = (songNotes[0] < 0 ? 0 : songNotes[0]);
					var daNoteData:Int = Std.int(songNotes[1] % 4);
					var daNoteStyle:String = (songNotes[3] == null ? 'n' : songNotes[3]);
					var gottaHitNote:Bool = (songNotes[1] > 3 ? !section.mustHitSection : section.mustHitSection);
					var oldNote:objects.Note = (unspawnNotes.length > 0 ? unspawnNotes[Std.int(unspawnNotes.length - 1)] : null);
					var susLength:Float = songNotes[2] / funkin.Conductor.stepCrochet;

					// dont create the special note if mechanics are disabled
					if (daNoteStyle != null && daNoteStyle != 'n')
					{
						final mechanics:Bool = cast KadeEngineData.settings.data.mechanics;

						if (!mechanics)
							continue;
						else
							susLength = 0;
					}

					var swagNote = new objects.Note(daStrumTime, daNoteData, oldNote, false, false, daNoteStyle);
					swagNote.sustainLength = susLength * funkin.Conductor.stepCrochet;
					swagNote.mustPress = gottaHitNote;
					swagNote.scrollFactor.set();
					unspawnNotes.push(swagNote);
	
					for (susNote in 0...Math.floor(susLength)) // Aparently this code creates sustain notes, i dont really care
					{
						oldNote = unspawnNotes[unspawnNotes.length - 1];

						var sustainNote = new objects.Note(daStrumTime + (funkin.Conductor.stepCrochet * (susNote + 1)), daNoteData, oldNote, true, false, daNoteStyle);
						sustainNote.scrollFactor.set();
						sustainNote.parent = swagNote;
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
					}

					if (daNoteStyle.contains('nugget')) hasNuggets = true;
				}
			}
		trace('Notes length: ${unspawnNotes.length}.');

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:objects.Note, Obj2:objects.Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows():Void
	{
		for (player in 0...2)
		{
			for (i in 0...4)
			{
				var babyArrow = new objects.Strum(i, player);
				babyArrow.cameras = [camHUD];
				var group = (babyArrow.isPlayer ? playerStrums : cpuStrums).add(babyArrow);
			}
		}
	}

	override function openSubState(SubState:flixel.FlxSubState)
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
	

	function resyncVocals():Void
	{
		vocals.pause();
		inst.play();

		funkin.Conductor.songPosition = inst.time;
		vocals.time = funkin.Conductor.songPosition;
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

		updateNotes();
		updateSongPosition();
		checkEventNote(); // uses strumTime now so it has to update every frame lol
		updateLerps(elapsed);
		checkJanitorAnim();
		updateHealth();
		focusOnCharacter((daSection != null && daSection.mustHitSection) ? boyfriend : dad);
		setChrome(chromVal);
		input();

		//retrospecter goes brrrrrrr
		if (hasNuggets) changeHealth((difficultiesStuff["healthDrainPoison"][storyDifficulty] * poisonStacks * elapsed) * -1); // Gotta make it fair with different framerates :)

		super.update(elapsed);
	}

	var didDamage:Bool = false;

	// esto revisa el evento que viene
	private function checkEventNote()
	{
		while (events.length > 0) 
		{
			if (funkin.Conductor.songPosition < events[0].strumTime) break;

			triggerEvent(events[0]);
			events.shift();
		}
	}

	private var topBar:FlxSprite;
	private var bottomBar:FlxSprite;


	/*
	Little note to remind myself that if I need to play an "instant" event I can just do:
	`triggerEvent(funkin.SongEvents.makeEvent('event name', 'value1', 'value2'));
	*/

	private function triggerEvent(event:EpicEvent)
	{
		trace('Attempting to play ${event.name.toLowerCase()} event. Strum time: ${FlxMath.roundDecimal(event.strumTime, 1)}.');

		final daEvent = event.name.toLowerCase();
		final excludeEvents:Array<String> = ['bop', 'add camera zoom', 'zoom change', 'camera zoom', 'animation', 'play animation', 'flash white'];

		if (excludeEvents.contains(daEvent) && !KadeEngineData.settings.data.distractions)
		{
			trace('Can\'t trigger $daEvent event, distractions are disabled.');
			return;
		}

		switch (daEvent)
		{
			default:
				trace('$daEvent was not found in the trigger event function.');

			case "camera bop":
				camGame.zoom += 0.02;
				camHUD.zoom += 0.06;
				cameraBopBeat = Std.parseFloat(event.value);

			case "bop" | 'add camera zoom':
				camGame.zoom += 0.04;
				camHUD.zoom += 0.12;

			case "zoom change":
				defaultCamZoom += Std.parseFloat(event.value);

			case "camera zoom":
				defaultCamZoom = stage.camZoom * Std.parseFloat(event.value);

			case "flash white":
				if (KadeEngineData.settings.data.flashing) camGame.flash(FlxColor.WHITE, Std.parseFloat(event.value));

			case "turn pixel":
				turnPixel(!isExpellinTime);

			case "animation" | "play animation":
				if (event.value2 == 'bf') boyfriend.animacion(event.value);
				else dad.animacion(event.value);

			case "monday time":
				// mondayTime((event.value == 'true' ? true : false));

			case "shot":
				dad.animacion('shooting');
				camGame.zoom += 0.08;
				camHUD.zoom += 0.24;
				camGame.shake(0.007, 2);
				chromatic(0.05, 0, true, 0, 0.5);
				if (KadeEngineData.settings.data.flashing) camGame.flash(0x7effffff, 0.5);

			case "alt":
				dad.altAnimSuffix = (dad.altAnimSuffix == 'alt-' ? '' : 'alt-');

			case 'hey!':
				boyfriend.animacion('hey');
				triggerEvent(funkin.SongEvents.makeEvent('bop'));

			case 'cinematics(v3.1)':
				// Creator: RamenDominoes (https://gamebanana.com/members/2135195)
    			// Version: Like 3.1 or something idk I fucked up making the versions cuz I used to not know how the numbers for versions worked lol
				// Translated to Haxe by me (Galo)

				var barStuff = event.value.split(','); // Thickness, Speed
				var firstTime = topBar == null && bottomBar == null;

				if (firstTime)
				{
					topBar = new FlxSprite(0, -1).makeGraphic(FlxG.width, 1, FlxColor.BLACK);
					topBar.camera = camHUD;
					topBar.active = topBar.antialiasing = false;
					insert(members.indexOf(clock) - 1, topBar);

					bottomBar = new FlxSprite(0, FlxG.height).makeGraphic(FlxG.width, 1, FlxColor.BLACK);
					bottomBar.camera = camHUD;
					bottomBar.active = bottomBar.antialiasing = false;
					insert(members.indexOf(clock) - 1, bottomBar);
				}

				FlxTween.tween(topBar, {y: (Std.parseFloat(barStuff[0]) * 0.5) - 1, 'scale.y': Std.parseFloat(barStuff[0])}, Std.parseFloat(barStuff[1]), {ease: FlxEase.quadOut});
				FlxTween.tween(bottomBar, {y: FlxG.height - (Std.parseFloat(barStuff[0]) * 0.5), 'scale.y': Std.parseFloat(barStuff[0])}, Std.parseFloat(barStuff[1]), {ease: FlxEase.quadOut, onComplete: function(_)
				{
					var times:Int = 0;

					for (i in events)
					{
						if (i.name == 'cinematics(v3.1)') times++;
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
		}
	}

	function endSong():Void
	{
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);

		tries = 0;

		canPause = false;
		inst.volume = 0;
		vocals.volume = 0;
		inst.pause();
		vocals.pause();
		setChrome(0);

		if (changedSpeed)
			SONG.speed = originalSongSpeed;

		if (KadeEngineData.practice)
			songScore = 0;

		if (SONG.validScore)
		{
			// adjusting the highscore song name to be compatible
			// would read original scores if we didn't change packages
			var songHighscore = StringTools.replace(states.PlayState.SONG.song, " ", "-");

			#if !switch
			data.Highscore.saveScore(songHighscore, Math.round(songScore), storyDifficulty);
			data.Highscore.saveCombo(songHighscore, data.Ratings.GenerateLetterRank(accuracy), storyDifficulty);
			#end
		}

			if (isStoryMode)
			{
				campaignScore += Math.round(songScore);

				if (!KadeEngineData.other.data.beatedSongs.contains(SONG.song))
					KadeEngineData.other.data.beatedSongs.push(SONG.song);

				KadeEngineData.flush();

				storyPlaylist.shift();

				if (storyPlaylist.length <= 0)
				{
					transIn = flixel.addons.transition.FlxTransitionableState.defaultTransIn;
					transOut = flixel.addons.transition.FlxTransitionableState.defaultTransOut;

					paused = true;

					inst.stop();
					vocals.stop();

					FlxG.sound.playMusic(Paths.music('freakyMenu', 'preload'), KadeEngineData.settings.data.musicVolume);
					funkin.MusicBeatState.switchState(new states.MainMenuState());

					if (SONG.validScore)
						data.Highscore.saveWeekScore(0, campaignScore, storyDifficulty);
				}
				else
				{
					var poop:String = data.Highscore.formatSong(StringTools.replace(states.PlayState.storyPlaylist[0], " ", "-"), storyDifficulty);

					print('LOADING NEXT SONG');
					print(poop);

					flixel.addons.transition.FlxTransitionableState.skipNextTransIn = true;
					flixel.addons.transition.FlxTransitionableState.skipNextTransOut = true;


					states.PlayState.SONG = funkin.Song.loadFromJson(poop, states.PlayState.storyPlaylist[0]);
					inst.stop();
					
					substates.LoadingState.loadAndSwitchState(new states.PlayState());
				}
			}
			else
			{
				print('WENT BACK TO FREEPLAY??');

				paused = true;

				inst.stop();
				vocals.stop();

				FlxG.sound.playMusic(Paths.music('freakyMenu', 'preload'), KadeEngineData.settings.data.musicVolume);
	
				funkin.MusicBeatState.switchState(new states.FreeplayState());
			}
	}

	private function popUpScore(daNote:objects.Note):Void
	{
		vocals.volume = (KadeEngineData.settings.data.lockSong ? 1 : KadeEngineData.settings.data.musicVolume);
		var score:Float = 0;
		var daRating = daNote.rating;

		if (daNote.noteStyle != 'nuggetP' && daNote.noteStyle != 'apple')
			changeHealth(0.023);

		switch(daRating)
		{
			case 'shit':
				score = 50;
				shits++;
				totalNotesHit += 0.25;
			case 'bad':
				score = 100;
				bads++;
				totalNotesHit += 0.50;
			case 'good':
				score = 200;
				goods++;
				totalNotesHit += 0.75;
			case 'sick':
				score = 350;
				totalNotesHit += 1;
				sicks++;
		}

		songScore += Math.round(score);
		songScoreDef += Math.round(data.Highscore.convertScore(-(daNote.strumTime - funkin.Conductor.songPosition)));

		addRating(daRating);
		doNoteSplash(daNote, daRating);
	}

	// THIS FUNCTION JUST FUCKS WIT HELD NOTES AND BOTPLAY/REPLAY (also gamepad shit)

	private function keyShit():Void // I've invested in emma stocks - now with kade engine 1.6.2 input :sunglasses: -sanco
		{
			// control arrays, order L D R U
			var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
			var pressArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
			var releaseArray:Array<Bool> = [controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R];
			
			if (KadeEngineData.botplay)
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
	
			if ((data.KeyBinds.gamepad && !FlxG.keys.justPressed.ANY))
			{
				// PRESSES, check for note hits
				if (pressArray.contains(true) && generatedMusic)
				{
					boyfriend.holdTimer = 0;
	
					var possibleNotes:Array<objects.Note> = []; // notes that can be hit
					var directionList:Array<Int> = []; // directions that can be hit
					var dumbNotes:Array<objects.Note> = []; // notes to kill later
					var directionsAccounted:Array<Bool> = [false, false, false, false]; // we don't want to do judgments for more than one presses
	
					var hit = [false, false, false, false];
	
					for (daNote in notes.members)
					{
						if (!daNote.alive) continue;

						if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !directionsAccounted[daNote.noteData])
						{
							if (directionList.contains(daNote.noteData))
							{
								directionsAccounted[daNote.noteData] = true;
								for (coolNote in possibleNotes)
								{
									if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
									{ // if it's the same note twice at < 10ms distance, just delete it
										// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
										dumbNotes.push(daNote);
										break;
									}
									else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
									{ // if daNote is earlier than existing note (coolNote), replace
										possibleNotes.remove(coolNote);
										possibleNotes.push(daNote);
										break;
									}
								}
							}
							else
							{
								directionsAccounted[daNote.noteData] = true;
								possibleNotes.push(daNote);
								directionList.push(daNote.noteData);
							}
						}
					};
	
					for (note in dumbNotes)
					{
						destroyNote(note);
					}
		
					possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
	
					if (possibleNotes.length > 0)
					{
						//(!KadeEngineData.settings.data.ghostTap)
						if (!KadeEngineData.settings.data.ghostTap)
						{
							for (shit in 0...pressArray.length)
							{ // if a direction is hit that shouldn't be
								if (pressArray[shit] && !directionList.contains(shit))
									noteMissPress(shit);
							}
						}
	
						for (coolNote in possibleNotes)
						{
							if (pressArray[coolNote.noteData] && !hit[coolNote.noteData])
							{
								hit[coolNote.noteData] = true;
								goodNoteHit(coolNote);
							}
						}
					};
	
					if (boyfriend.holdTimer > funkin.Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || KadeEngineData.botplay))
					{
						if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
							boyfriend.playAnim('idle');
					}
					else if (!KadeEngineData.settings.data.ghostTap)
					{
						for (shit in 0...pressArray.length)
							if (pressArray[shit])
								noteMissPress(shit);
					}
				}
			}

			if (KadeEngineData.botplay)
			{
				for (daNote in notes.members)
				{
					if (!daNote.alive) continue;

					if ((daNote.mustPress && daNote.canBeHit) && (daNote.isSustainNote || (!daNote.isSustainNote && (daNote.strumTime <= funkin.Conductor.songPosition || daNote.isSustainNote))))
					{
						goodNoteHit(daNote);
						boyfriend.holdTimer = daNote.sustainLength;
					}
				};
			}
	
			if (boyfriend.holdTimer > funkin.Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || KadeEngineData.botplay))
			{
				if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
					boyfriend.dance();
			}
	
			if (!KadeEngineData.botplay)
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

	function input():Void
	{
		if (inCutscene) return;

		keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE) endSong();

		debugEditors();
		#end

		if (FlxG.keys.justPressed.SPACE && !KadeEngineData.botplay)
			eatApple(true);	

		if (KadeEngineData.botplay && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

		if (controls.PAUSE)
		{
			pause();
		}
	}

	function noteMiss(direction:Int = 1, daNote:objects.Note = null):Void
	{
		if (died || (daNote.noteStyle == 'nuggetP' || daNote.noteStyle == 'apple'))
			return;

		switch (daNote.noteStyle)
		{
			case 'gum':
				gumNoteMechanic(daNote);
			case 'b': //b is for BULLET
				changeHealth(-1);
				boyfriend.animacion('hurt');
		}

		vocals.volume = 0;
		changeHealth(-0.05);

		#if GF
		if (combo > 5 && gf.animOffsets.exists('sad'))
			gf.playAnim('sad');
		#end

		combo = 0;
		misses++;

		songScore -= 10;

		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3, 'shared'), FlxG.random.float(0.1, 0.2) * KadeEngineData.settings.data.soundVolume);

		// 0 = left - 1 = down - 2 = up - 3 = right
		// y + = abajo ||| y - = arriba
		boyfriend.sing(direction, true);

		updateAccuracy();
	}

	function noteMissPress(direction:Int = 0)
		{
			vocals.volume = 0;
			changeHealth(-0.05);
			#if GF
			if (combo > 5 && gf.animOffsets.exists('sad'))
				gf.playAnim('sad');
			#end
			combo = 0;
			misses++;
			songScore -= 10;
			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3, 'shared'), FlxG.random.float(0.1, 0.2) * KadeEngineData.settings.data.soundVolume);
			boyfriend.sing(direction, true);
			updateAccuracy();
		}
	
		function updateAccuracy() 
		{
			totalPlayed += 1;
			accuracy = Math.max(0,totalNotesHit / totalPlayed * 100);

			scoreTxt.text = data.Ratings.CalculateRanking(songScore, songScoreDef, accuracy);
		}
	
		function getKeyPresses(note:objects.Note):Int
		{
			var possibleNotes:Array<objects.Note> = []; // copypasted but you already know that
	
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
	
		function noteCheck(controlArray:Array<Bool>, note:objects.Note):Void // sorry lol
		{
			var noteDiff:Float = -(note.strumTime - funkin.Conductor.songPosition);
	
			note.rating = data.Ratings.CalculateRating(noteDiff, Math.floor((funkin.Conductor.safeFrames / 60) * 1000));
			
			if (controlArray[note.noteData])
				goodNoteHit(note);
		}
	
		function goodNoteHit(note:objects.Note):Void
			{
				if (!cantPressArray[note.noteData])
					return;

				vocals.volume = (KadeEngineData.settings.data.lockSong ? 1 : KadeEngineData.settings.data.musicVolume);

				switch (note.noteStyle)
				{
					case 'nuggetP':
						if (KadeEngineData.botplay)
							return;
						else
						{
							FlxG.sound.play(Paths.soundRandom('missnote', 1, 3, 'shared'), FlxG.random.float(0.2, 0.3) * KadeEngineData.settings.data.soundVolume);
							poisonStacks++;
							boyfriend.animacion('hurt');
						}
					case 'nuggetN':
						poisonStacks = 0;
					case 'gum':
						boyfriend.animacion('dodge');
					case 'b':
						boyfriend.animacion('dodge');
					case 'apple':
						if (!note.isSustainNote){
							actions++;
							updateApples();
						}
				}
	
				#if debug
				if (KadeEngineData.settings.data.snap && !note.isSustainNote)
					CoolUtil.sound('extra/SNAP', 'shared');
				#end
	
				var noteDiff:Float = -(note.strumTime - funkin.Conductor.songPosition);
	
				note.rating = data.Ratings.CalculateRating(noteDiff);
	
				if (note.rating == "miss")
					return;

				if (!note.wasGoodHit)
				{
					if (!note.isSustainNote)
					{
						popUpScore(note);
						combo += 1;
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
							if (KadeEngineData.botplay) spr.playAnim('confirm', true);
							else spr.animation.play('confirm', true);
						}
					};
					
					note.wasGoodHit = true;
					vocals.volume = (KadeEngineData.settings.data.lockSong ? 1 : KadeEngineData.settings.data.musicVolume);
		
					// do not remove or destroy sustains as it might seem bad when playing sustains
					if (!note.isSustainNote)
						destroyNote(note);

					updateAccuracy();
				}
			}

	// helper function for single liner destroy notes
	function destroyNote(note:objects.Note)
		{
			note.active = false;
			note.exists = false;

			note.kill();
			notes.remove(note, true);
			note.destroy();
		}

	var stepOfLast = 0;

	override function stepHit()
	{
		CoolUtil.presence('Misses: $misses | Tries: $tries', 'Playing: ${SONG.song} - [$storyDifficultyText]', true, songLength - funkin.Conductor.songPosition, (dad.curCharacter == 'janitor' ? (janitorKys ? 'kys' : 'janitor') : dad.curCharacter), true);
		
		if (inst.time > funkin.Conductor.songPosition + 20 || inst.time < funkin.Conductor.songPosition - 20)
			resyncVocals();

		if (curSong == 'Monday' && curStep != stepOfLast && KadeEngineData.settings.data.distractions)
			{
				switch(curStep)
				{
					case 824 | 826:
						defaultCamZoom += 0.25;
					case 828:
						defaultCamZoom = stage.camZoom;
						boyfriend.animacion('hey');
					case 830:
						defaultCamZoom = stage.camZoom;
				}

				stepOfLast = curStep;
			}

			if (cameraBopBeat == 0.5)
			{
				camGame.zoom += 0.02;
				camHUD.zoom += 0.06;
			}

		super.stepHit();
	}

	override function sectionHit()
	{
		super.sectionHit();

		// i realized this has to update all the time because the cam sing move thing wont work :(
		// focusOnCharacter((daSection != null && daSection.mustHitSection) ? boyfriend : dad); 

		trace('Song position: ${inst.time} (${Conductor.songPosition})');
	}

	var shownCredits:Bool = false;

	override function beatHit()
	{
		/*
			#if sys
			sys.thread.Thread.create(() ->
			{
				changeCharacter(dad.x, dad.y, true, 'monty');
				changeCharacter(boyfriend.x, boyfriend.y, false, 'protagonist');
			});
			#end*/

		//if (curBeat == 10)
		//	turnPixel(true);
		//if (curBeat == 30)
		//	turnPixel(false);

		if (yoyo != null && curBeat % difficultiesStuff["yoyoFrequency"][storyDifficulty] == 0) yoyo.play();

		if (SONG.song == "Nugget de Polla" && KadeEngineData.settings.data.distractions)
		{
			if (curBeat >= 32 && pollaBlock != null){
				pollaBlock.destroy();
				pollaBlock = null;
				if (KadeEngineData.settings.data.flashing) FlxG.cameras.flash();
			}
		}

		if (KadeEngineData.settings.data.mechanics && SONG.song == 'Staff Only') //if mechanics are enabled and its janitor song
		{
			// every some beats janitor attacks if accuracy is less than the set and accuracy isn't 0 (otherwise he would hit you at the start of the song lmao)
			if (curBeat % difficultiesStuff["janitorHits"][storyDifficulty] == 0 && accuracy < difficultiesStuff['janitorAccuracy'][storyDifficulty] && accuracy != 0)
			{
				canPause = false;
				trace('Janitor hit - [Accuracy: $accuracy - accuracy intended: ${ difficultiesStuff['janitorAccuracy'][storyDifficulty]} - current health: $health - damage: ${difficultiesStuff['mopHealthLoss'][storyDifficulty]}]');
				dad.animacion('attack');
			}
		}

		#if debug
		curBeatText.text = "Beat: " + curBeat;
		#end

		if (generatedMusic)
			notes.sort(FlxSort.byY, (KadeEngineData.settings.data.downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));

		if (daSection != null && daSection.changeBPM)
		{
			funkin.Conductor.changeBPM(daSection.bpm);
			FlxG.log.add('CHANGED BPM!');
		}

		bop();

		if (curBeat >= 4 && !shownCredits)
			{
				shownCredits = true;

				var author:String = switch (SONG.song)
				{
					case 'Nugget':				   								   "Enzo & TheGalo X";
					case 'Monday' | 'Staff Only':				                   "RealG";
					case 'Expelled' | 'Expelled V1' | 'Expelled V2': 			   "KrakenPower";
					case 'Nugget de Polla':                                        "TheGalo X & KrakenPower";
					case 'Monday Encore':										   "RealG & TheGalo X";
					case 'Cash Grab':											   "your mama"; // we dont talk about cash grab
					default:					                                   "no author lmao";
				}

				var creditPage = new PageSprite('${SONG.song}\nby $author', true);
				creditPage.cameras = [camHUD];
				add(creditPage);
			}

		if (curSong == 'Monday' && KadeEngineData.settings.data.mechanics && storyDifficulty != 0)
		{
			if (curBeat == 32)
			{
				var text:String = '<-- Use collected apples\nto heal yourself with SPACEBAR';
				var page = new PageSprite(text, false, getTimeFromBeats(SECTIONS, 1.5));
				page.cameras = [camHUD];
				page.x -= 150;
				add(page);
			}
		}

		if (curSong == 'Monday' && KadeEngineData.settings.data.distractions)
			{
				switch (curBeat)
				{
					case 4 | 8 | 12 | 20 | 24 | 28 | 44 | 60:
						defaultCamZoom += 0.05;
					case 16:
						//mondayTime(true);
					case 14 | 30:
						defaultCamZoom -= 0.15;
					case 25:
						//mondayTime(false);
					case 32 | 48:
						defaultCamZoom -= 0.05;
					case 288:
						boyfriend.animacion('hey');
						camSpot(boyfriend.camPos[0], boyfriend.camPos[1], defaultCamZoom + 0.2, 1);
				}
			}

		if (curSong == 'Nugget' && KadeEngineData.settings.data.distractions)
			{
				switch (curBeat) // I. Hate. This.
				{
					case 158:
						boyfriend.camPos[1] += 200;
						dad.camPos[1] += 200;
						blackScreenForNuggetOmgLongAssVariable = new FlxSprite().makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackScreenForNuggetOmgLongAssVariable.scrollFactor.set();
                		blackScreenForNuggetOmgLongAssVariable.alpha = 0;
						blackScreenForNuggetOmgLongAssVariable.screenCenter();
						blackScreenForNuggetOmgLongAssVariable.active = false;
                		insert(members.indexOf(dad) - 1, blackScreenForNuggetOmgLongAssVariable); //LOVE YOU SANCO
	
						camSpot(dad.camPos[0] - 100, dad.camPos[1], defaultCamZoom += 0.3, 0);
						FlxTween.tween(camHUD, {alpha: 0.25}, 0.7);
						FlxTween.tween(blackScreenForNuggetOmgLongAssVariable, {alpha: 1}, 0.7);
					case 160:
						camHUD.alpha = 1;
						blackScreenForNuggetOmgLongAssVariable.destroy();
						if (KadeEngineData.settings.data.flashing)
							FlxG.cameras.flash();
						canDoCamSpot = true;
						canTweenCam = true; 
					case 192:
						boyfriend.camPos[1] -= 200;
						dad.camPos[1] -= 200;
						defaultCamZoom = stage.camZoom;
					case 256:
						camSpot(stage.backgroundSprites.members[0].getGraphicMidpoint().x, stage.backgroundSprites.members[0].getGraphicMidpoint().y, null, 0);
				}
			}
	}

	var blackScreenForNuggetOmgLongAssVariable:FlxSprite;

	function bop(force:Bool = false):Void
		{
			if (KadeEngineData.settings.data.distractions)
			{
				if (force || curBeat % cameraBopBeat == 0)
					{
						camGame.zoom += 0.02;
						camHUD.zoom += 0.06;
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
			}
			
			#if GF
			if (curBeat % 1 == 0) gf.dance();
			#end

			dad.dance();
			if(dad.canIdle) dad.camSingPos.set();

			boyfriend.dance();
			if(boyfriend.canIdle) boyfriend.camSingPos.set();

			if (songHas3Characters)
		 	{ 
				thirdCharacter.dance();
				if(thirdCharacter.canIdle) thirdCharacter.camSingPos.set();
			}
		}

	private var died:Bool = false;

	function die():Void
		{
			//if (died) return; i just spammed pause and it bugged and made bf inmortal so uhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
			died = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			//retrospecter goes brrrrrr
			poisonStacks = 0;

			vocals.stop();
			inst.stop();

			setChrome(0);
			filters.remove(shaderFilter);
			FlxG.game.setFilters(filters);

			if (changedSpeed) SONG.speed = originalSongSpeed;

			openSubState(new substates.GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

			function focusOnCharacter(character:objects.Character):Void
			{
				if (!canTweenCam || SONG.song == 'Nugget de Polla' || character == null /* || !generatedMusic || daSection == null */)
					return;

				camFollow.setPosition(character.camPos[0] + character.camSingPos.x * camGame.zoom, character.camPos[1] + character.camSingPos.y * camGame.zoom);
			}

			function doNoteSplash(daNote:objects.Note, daRating:String = ""):Void
				{
					if (!KadeEngineData.settings.data.distractions || (daNote.noteStyle == 'nuggetP' && KadeEngineData.botplay) || daRating != 'sick')
						return;

					var sploosh = splashGroup.recycle(objects.NoteSplash.new);
					sploosh.play(playerStrums.members[daNote.noteData].y, daNote);
					splashGroup.add(sploosh);
				}

			function gumNoteMechanic(daNote:objects.Note):Void
				{
					if (!KadeEngineData.settings.data.mechanics || KadeEngineData.botplay || storyDifficulty == 0)
						return;

					if (!cantPressArray[daNote.noteData])
						return;
					else
					{
						cantPressArray[daNote.noteData] = false;
						for (spr in playerStrums.members)
						{
							if (spr.ID == daNote.noteData)
								spr.alpha = 0.75;
						};
					}

					var gumTrap:objects.NoteSplash.GumTrap = new objects.NoteSplash.GumTrap(daNote.x, playerStrums.members[daNote.noteData].y);
					gumTrap.cameras = [camHUD];
					gumTrap.animation.play('idle');
					add(gumTrap);

					if (daNote.noteStyle == 'gum')
						doNoteSplash(daNote);

					new FlxTimer().start(difficultiesStuff["gumTrapTime"][storyDifficulty] / 2, function (_)
						{
							gumTrap.animation.play('pre-struggle', true);
						});

					new FlxTimer().start(difficultiesStuff["gumTrapTime"][storyDifficulty], function (_)
						{
							new FlxTimer().start(0.1, function (_){
								cantPressArray[daNote.noteData] = true;	
								for (spr in playerStrums.members)
								{
									if (spr.ID == daNote.noteData)
										spr.alpha = 1;
								};
							});
							gumTrap.animation.play('break', true);
						});
				}

			/**
			 * Function that sets the chromatic aberration `shader`.
			 * @param   value   The shader `value`.
			 * @param   shakeValue   The camera `shake` (set to 0 to disable).
			 * @param   tween      If it will `tween` or stay with that `value`.
			 * @param   toValue     The new value after the tween (recommended: `defaultChromVal`).
			 * @param   time     How much time it takes for the tween to end.
			 **/

			function chromatic(value:Float = 0.0025, shakeValue:Float = 0.005, tween:Bool = true, toValue:Float = 0, time:Float = 0.3):Void
				{
					if (!KadeEngineData.settings.data.flashing || !KadeEngineData.settings.data.shaders)
						{
							print("woops, no shaders");
							return;
						}

					camGame.shake(shakeValue);

					chromVal = value;

					if (tween)
					{
						if (chromTween != null)
							chromTween.cancel();

						chromTween = FlxTween.tween(this, {chromVal: toValue}, time);
					}
				}

			function print(v:Dynamic)
				{
					//i dunno Niz told me that removing trace's would improve performance
			
					//return;

					trace(v);
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
					var dialogueSpr:objects.DialogueBox = new objects.DialogueBox(CoolUtil.getDialogue());
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

			var editorState:flixel.FlxState;

			function debugEditors():Void //this instead of the same code copied over and over 
			{
				#if !debug
				return;
				#end 

				//maybe update it only when you pressed any of the buttons because i guess that would make it better optimised i dont fucking know???
				if (FlxG.keys.anyJustPressed([TWO, FOUR, SIX, SEVEN, EIGHT]))
				{
					if (FlxG.keys.justPressed.TWO) // 2, 4, 6, 7, 8
						editorState = new debug.NotesDebug();
					else if (FlxG.keys.justPressed.FOUR)
						editorState = new debug.CameraDebug(SONG.player2);
					else if (FlxG.keys.justPressed.SIX)
						editorState = new debug.AnimationDebug(SONG.player2);
					else if (FlxG.keys.justPressed.SEVEN)
						editorState = new substates.ChartingState();
					else if (FlxG.keys.justPressed.EIGHT)
						editorState = new debug.StageDebug(curStage);

					if (editorState != null)
						{
							if (changedSpeed)
								SONG.speed = originalSongSpeed;
							if (editorState == new substates.ChartingState() && isPixel)
									isPixel = false;
							setChrome(0);
							funkin.MusicBeatState.switchState(editorState);

							FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN,handleInput);
						}
				}
			}

			//idea from impostor v4 BUT, in a different way because the way they made it in impostor v4 sucks (love u clowfoe) - alr this was way better before in terms of performance but now its better in visual terms
			function trail(char:objects.Character, howManyNotes:Int):Void
			{
				if (!KadeEngineData.settings.data.distractions)	return;
				// trace('Applying trail $howManyNotes times.');

				var ghost = ghostsGroup.recycle(Ghost.new);
				ghost.setup(char);
				ghostsGroup.add(ghost);
			}

			function turnPixel(enable:Bool)
			{
				if (!KadeEngineData.settings.data.mechanics || storyDifficulty == 0)
					return;

				canPause = false;

				var pixelValue = difficultiesStuff["principalPixel"][storyDifficulty];
				isExpellinTime = enable;

				if (enable)
				{
					pixelShit = new Shaders.PixelEffect();
					pixelShit.PIXEL_FACTOR = 256 * 8;
					shaderFilter = new openfl.filters.ShaderFilter(pixelShit.shader);
					filters.push(shaderFilter);
					FlxG.game.setFilters(filters);

					//FlxTween.num(shaderFilter)
					FlxTween.tween(pixelShit, {PIXEL_FACTOR: pixelValue}, getTimeFromBeats(SECTIONS, 1), {onComplete: function(_)
					{
						canPause = true;

						trace("Pixel Factor changed to " + pixelValue);

						if (KadeEngineData.settings.data.flashing && SONG.song != 'Expelled V1') FlxG.cameras.flash();

						scoreTxt.visible = false;

					}});
				}
				else
				{
					FlxTween.tween(pixelShit, {PIXEL_FACTOR: 256 * 8}, getTimeFromBeats(SECTIONS, 2), {onComplete: function(_)
						{
							canPause = true;

							trace("Pixel Shader disabled.");

							//if (KadeEngineData.settings.data.flashing && SONG.song != 'Expelled V1') FlxG.cameras.flash();
	
							filters.remove(shaderFilter);
							FlxG.game.setFilters(filters);

							scoreTxt.visible = true;
						}});
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
				if (!KadeEngineData.settings.data.distractions) lerpHealth = health;

				if (health > 2) health = 2;
				else if (health <= 0 && !KadeEngineData.practice && !KadeEngineData.botplay) die();
				else if (health <= 0 && (KadeEngineData.practice || KadeEngineData.botplay)) health = 0.001;

				//icons shit
				var iconOffset:Int = 18;
				iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
				iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

				if (iconP1.animation.curAnim != null) iconP1.animation.curAnim.curFrame = (healthBar.percent < 20 ? 1 : 0);
				if (iconP2.animation.curAnim != null) iconP2.animation.curAnim.curFrame = (healthBar.percent > 80 ? 1 : 0);
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
					FlxTween.color(boyfriend, 0.5, FlxColor.GREEN, FlxColor.WHITE);
					camSpot(boyfriend.getGraphicMidpoint().x - 100, boyfriend.getGraphicMidpoint().y, defaultCamZoom + 0.3, 0.5);

					updateApples();
				}
				else
				{
					CoolUtil.sound('bite', 'shared');
					changeHealth(difficultiesStuff["appleHealthLoss"][storyDifficulty] * -1);
					FlxTween.color(dad, 0.5, FlxColor.GREEN, FlxColor.WHITE);
				}
			}

			private function updateApples():Void
			{
				if (actions < 0) actions = 0;
				if (actions > 3) actions = 3;
		
				for (apple in apples.members)
				{
					if (apple.ID <= actions) apple.alpha = 1;
					else apple.alpha = 0;
				};
			}

			private function updateLerps(elapsed:Float):Void
			{
				if (KadeEngineData.settings.data.distractions)
				{
					var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9)));

					iconP1.scale.set(mult, mult);
					iconP2.scale.set(mult, mult);

					lerpHealth = FlxMath.lerp(health, lerpHealth, CoolUtil.boundTo(1 - elapsed * 5));
				}

				camGame.zoom = FlxMath.lerp(defaultCamZoom, camGame.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125)));
				camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125)));

				camGame.focusOn(camPoint.set(flixel.math.FlxMath.lerp(camPoint.x, camFollow.x, 0.5 * (elapsed * 5)), flixel.math.FlxMath.lerp(camPoint.y, camFollow.y, 0.5 * (elapsed * 5))));
			}

			private function updateNotes():Void
			{
				if (generatedMusic)
				{
					var downMult:Int = (!KadeEngineData.settings.data.downscroll ? 1 : -1);

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

						var strums:FlxTypedGroup<objects.Strum> = (daNote.mustPress) ? playerStrums : cpuStrums;
						var receptorX = strums.members[Math.floor(Math.abs(daNote.noteData))].x;
						var receptorY = strums.members[Math.floor(Math.abs(daNote.noteData))].y + (objects.Note.swagWidth / 6);

						var pseudoY:Float = daNote.offsetY + (downMult * -((funkin.Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2))));

						daNote.y = receptorY
							+ (Math.cos(flixel.math.FlxAngle.asRadians(daNote.direction)) * pseudoY)
							+ (Math.sin(flixel.math.FlxAngle.asRadians(daNote.direction)) * daNote.offsetX);

						daNote.x = receptorX
							+ (Math.cos(flixel.math.FlxAngle.asRadians(daNote.direction)) * daNote.offsetX)
							+ (Math.sin(flixel.math.FlxAngle.asRadians(daNote.direction)) * pseudoY);

						daNote.angle = -daNote.direction;

						var center:Float = receptorY + objects.Note.swagWidth / 2;
						if (daNote.isSustainNote)
						{
							daNote.y -= ((daNote.height / 2) * downMult);
							if (daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
							{
								daNote.y -= ((daNote.prevNote.height / 2) * downMult);
								if (KadeEngineData.settings.data.downscroll)
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

						if (KadeEngineData.settings.data.downscroll)
						{
							//daNote.flipY = true;
							if ((daNote.parent != null && daNote.parent.wasGoodHit)
								&& daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center
								&& (KadeEngineData.botplay || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
							{
								var swagRect = new flixel.math.FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
								swagRect.height = (center - daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;
								daNote.clipRect = swagRect;
							}
						}
						else
						{
							if ((daNote.parent != null && daNote.parent.wasGoodHit)
								&& daNote.y + daNote.offset.y * daNote.scale.y <= center
								&& (KadeEngineData.botplay || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
							{
								var swagRect = new flixel.math.FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (center - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;
								daNote.clipRect = swagRect;
							}
						}

						if (!daNote.mustPress && daNote.wasGoodHit && daNote.noteStyle != 'nuggetP')
						{
							// if (daSection != null)
							{
								// if (health > 0.04 && SONG.songDrains && KadeEngineData.settings.data.mechanics) changeHealth(-0.04);
		
								//if (daSection.altAnim) dad.altAnimSuffix = 'alt-';
								//else dad.altAnimSuffix = '';

								if (!daNote.doubleNote) 
									dad.sing(daNote.noteData);
								else
								{
									if (!daNote.isSustainNote)
										trail(dad, getMultNotes(true, daNote));
								}

								if (songHas3Characters && thirdCharacter.turn && !daNote.doubleNote)
									thirdCharacter.sing(daNote.noteData);
							}

							if (daNote.noteStyle == 'apple' && SONG.player2.startsWith('protagonist') && !daNote.isSustainNote) eatApple(false);

							dad.holdTimer = 0;

							if (songHas3Characters && thirdCharacter.turn)
								thirdCharacter.holdTimer = 0;
		
							if (SONG.needsVoices)
								vocals.volume = (KadeEngineData.settings.data.lockSong ? 1 : KadeEngineData.settings.data.musicVolume);
		
							for (spr in cpuStrums.members) if (Math.abs(daNote.noteData) == spr.ID) spr.playAnim('confirm', true);

							daNote.active = false;
							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}

						if ((daNote.mustPress && daNote.tooLate && !KadeEngineData.settings.data.downscroll || daNote.mustPress && daNote.tooLate && KadeEngineData.settings.data.downscroll) && daNote.mustPress)
						{
							if (daNote.isSustainNote && daNote.wasGoodHit)
							{
								daNote.kill();
								notes.remove(daNote, true);
							}
							else
								noteMiss(daNote.noteData, daNote);
			
							daNote.visible = false;
							daNote.kill();
							notes.remove(daNote, true);
						}
					};
				}

				if (unspawnNotes[0] != null)
				{
					if (unspawnNotes[0].strumTime - funkin.Conductor.songPosition < 3500)
					{
						var dunceNote:objects.Note = unspawnNotes[0];
						notes.add(dunceNote);

						var index:Int = unspawnNotes.indexOf(dunceNote);
						unspawnNotes.splice(index, 1);
					}
				}
			}

			private function updateSongPosition():Void
			{
				if (startingSong)
				{
					if (startedCountdown)
					{
						funkin.Conductor.songPosition += FlxG.elapsed * 1000;
						if (funkin.Conductor.songPosition >= 0)
							startSong();
					}
				}
				else
				{
					funkin.Conductor.songPosition += FlxG.elapsed * 1000;
			
					if (!paused)
					{
						songTime += FlxG.game.ticks - previousFrameTime;
						previousFrameTime = FlxG.game.ticks;

						if (funkin.Conductor.lastSongPos != funkin.Conductor.songPosition)
						{
							songTime = (songTime + funkin.Conductor.songPosition) / 2;
							funkin.Conductor.lastSongPos = funkin.Conductor.songPosition;
						}
					}

					if (clock != null) clock.updateTime();
				}
			}

			private function checkJanitorAnim():Void
			{
				if (KadeEngineData.settings.data.mechanics && SONG.song == 'Staff Only') //if mechanics are enabled and its janitor song
				{
					if (dad.animation.curAnim.name == 'attack' && dad.animation.curAnim.curFrame >= 6 && !didDamage)
						{
							didDamage = true;
							changeHealth(difficultiesStuff['mopHealthLoss'][storyDifficulty]);
							boyfriend.animacion('hurt');
							camGame.shake(0.007, 0.25);
							CoolUtil.sound('janitorHit', 'shared');
							new FlxTimer().start(1, function(_){ 
								didDamage = false; 
								canPause = true;});
						}
				}
			}

			private function addRating(daRating:String)
			{
				var seperatedScore:Array<Int> = [];
				if(combo >= 1000)  seperatedScore.push(Math.floor(combo / 1000) % 10);
				seperatedScore.push(Math.floor(combo / 100) % 10);
				seperatedScore.push(Math.floor(combo / 10) % 10);
				seperatedScore.push(combo % 10);

				for (i in 0...seperatedScore.length)
				{
					var numScore = numbersGroup.recycle(Number.new);
					if (KadeEngineData.settings.data.changedHit)
						numScore.setPosition(KadeEngineData.settings.data.changedHitX + (43 * i) + 50, KadeEngineData.settings.data.changedHitY + 115);
					else
					{
						numScore.screenCenter(Y);
						numScore.y += 200;
						numScore.x += (FlxG.width * 0.55) - 225 + (43 * i) + 115;
					}
					numScore.play(Std.int(seperatedScore[i]));
					numScore.visible = !isExpellinTime;
					numbersGroup.add(numScore);
				}

				if(!KadeEngineData.botplay)
				{
					var rating = ratingsGroup.recycle(Rating.new);
					rating.play(daRating);
					ratingsGroup.add(rating);
				}
			}

			private function addCharacters():Void
			{
				add(stage = new objects.Stage(SONG.stage));

				#if GF
				gf = new objects.Character(stage.positions['gf'][0], stage.positions['gf'][1], 'gf');
				gf.scrollFactor.set(0.95, 0.95);
				add(gf);
				#end

				// LMFAO NICE TRY MODIFYING FILE'S SHIT LOSER
				#if !debug
				if (KadeEngineData.other.data.beatedMod)
					SONG.player1 = (states.MainMenuState.bfSkin ? 'bf-suit' : 'bf');
				else
					SONG.player1 = 'bf';

				switch (SONG.song)
				{
					case 'Monday':	SONG.player2 = 'protagonist';
					case 'Nugget':  SONG.player2 = 'nugget';
					case 'Cash Grab':  SONG.player2 = 'monty';
					case 'Staff Only':  SONG.player2 = 'janitor';
					case 'Expelled':  SONG.player2 = 'principal';
					case 'Nugget de Polla': SONG.player2 = 'polla';
					case 'Monday Encore': SONG.player2 = 'protagonist-pixel'; SONG.player1 = 'bf-pixel';
				}
				#end

				add(ghostsGroup = new flixel.group.FlxGroup.FlxTypedGroup<Ghost>());

				add(dad = new objects.Character(stage.positions['dad'][0], stage.positions['dad'][1], SONG.player2));

				if (songHas3Characters)
				{
					thirdCharacter = new objects.Character(stage.positions['third'][0], stage.positions['third'][1], 'monty');
					thirdCharacter.turn = false;
					add(thirdCharacter);
				}

				add(boyfriend = new objects.Boyfriend(stage.positions['bf'][0], stage.positions['bf'][1], SONG.player1));

				stage.backgroundSprites.forEach(function(i:objects.BGSprite)
				{
					if (i != null && !i.destroyed && i.isAboveChar)
					{
						remove(i);
						insert(members.indexOf(boyfriend) + 1, i); //LOVE YOU SANCO 	//add(i);
					}
				});
			}

			private function changeHealth(amount:Float):Void
			{
				health += amount;

				//updateHealth();
			}

			private function getMultNotes(isDad:Bool, note:objects.Note):Int
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
				if (curSong == 'Nugget de Polla')
			 	{
					canPause = true;
					return;
				}

				var swagCounter:Int = 0;

				new FlxTimer().start(getTimeFromBeats(BEATS, 1), function(_)
				{
					boyfriend.dance();
					dad.dance();
					if (songHas3Characters)
						thirdCharacter.dance();
					#if GF
					gf.dance();
					#end

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

						FlxTween.tween(spr, {y: spr.y += 100, alpha: 0}, funkin.Conductor.crochet / 1000, {
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
}