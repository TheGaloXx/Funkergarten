package;

import SongEvents.EpicEvent;
import Objects;
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

using StringTools;

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;

	public static var isStoryMode:Bool = false;
	public static var curStage:String = '';
	public static var SONG:Song.SwagSong;
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

	public static var dad:Character;

	public static var songHas3Characters:Bool = false;
	public static var thirdCharacter:Character;

	#if GF
	public static var gf:Character;
	#end
	public static var boyfriend:Boyfriend;

	public var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];
	public var splashGroup = new flixel.group.FlxGroup.FlxTypedGroup<NoteSplash>(4);
	public var numbersGroup = new flixel.group.FlxGroup.FlxTypedGroup<Number>();

	private var camFollow:flixel.FlxObject;

	public static var strumLineNotes:FlxTypedGroup<FlxSprite> = null;
	public static var playerStrums:FlxTypedGroup<FlxSprite> = null;
	public static var cpuStrums:FlxTypedGroup<FlxSprite> = null;

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

	private var iconP1:HealthIcon; //making these public again because i may be stupid
	private var iconP2:HealthIcon; //what could go wrong?
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

	public static var stage:Stage;

	//shaders
	var filters:Array<openfl.filters.BitmapFilter> = [];
	var chromVal:Float = 0;
	var defaultChromVal:Float = 0;

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
	var pixelFolder:String = "";

	//var dialogueSpr:DialogueBox;
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
			"principalPixel"	=> [null,		384, 		256, 	128]
		];

	private var janitorKys:Bool = FlxG.random.bool(15);

	private var isExpellinTime:Bool = false;

	var pixelShit:Shaders.PixelEffect;
	private var pollaBlock = new FlxSprite().makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);

	private var ratingSpr:Rating;
	private var hasNuggets:Bool = false;
	private var clock:Clock;
	private var camPoint = new flixel.math.FlxPoint();

	override public function create()
	{
		instance = this;

		CoolUtil.title('Loading...');
		CoolUtil.presence(null, 'Loading...', false, 0, null);

		FlxG.mouse.visible = false;
		if (storyDifficulty == 3 || KadeEngineData.botplay)
			KadeEngineData.practice = false;
		
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		sicks = bads = shits = goods = misses = 0;

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		if (KadeEngineData.settings.data.flashing && KadeEngineData.settings.data.shaders)
		{
			filters.push(chromaticAberration);
			FlxG.game.setFilters(filters);
		}

		setChrome(0);

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		print('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: ' + Conductor.safeFrames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: ' + Conductor.timeScale + '\nBotPlay : ' + KadeEngineData.botplay);

		if (SONG.stage == null) 
		{
			trace("da fuck the song stage is null why i dont know???????????????????????");
			SONG.stage == 'void';
		}

		switch (SONG.song)
		{
			case 'DadBattle':
				songHas3Characters = true;
				isPixel = true;
			default:
				songHas3Characters = false;
				isPixel = false;
		}
		
		addCharacters();

		Conductor.songPosition = -5000;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		add(splashGroup);
		add(numbersGroup);
		if (!KadeEngineData.botplay)
		{
			ratingSpr = new Rating();
			ratingSpr.cameras = [camHUD];
			add(ratingSpr);
		}

		playerStrums = new FlxTypedGroup<FlxSprite>();
		cpuStrums = new FlxTypedGroup<FlxSprite>();

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

		var healthBarBG = new FlxSprite(0, (KadeEngineData.settings.data.downscroll ? 50 : FlxG.height * 0.9)).loadGraphic(Paths.image('gameplay/healthBar'));
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

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		iconP1.active = false;
		iconP2.active = false;

		scoreTxt = new FlxText(0, healthBarBG.y + 35, FlxG.width, Ratings.CalculateRanking(0, 0, 0), 20);
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

		strumLineNotes.cameras = splashGroup.cameras = numbersGroup.cameras = notes.cameras = healthBar.cameras = healthBarBG.cameras = iconP1.cameras = iconP2.cameras = scoreTxt.cameras = [camHUD];

		startingSong = true;
		
		print('starting');

		pixelFolder = (isPixel ? 'pixel/' : '');
		tries++;

		if (tries <= 1 && isStoryMode) dialogue();
		else startCountdown();

		if (!KadeEngineData.settings.data.distractions) KadeEngineData.settings.data.camMove = false;

		for (i in 0...3)
		{
			var spr = new Apple(0, 0);
			spr.cameras = [camHUD];
			spr.x = spr.width * i;
			spr.y = FlxG.height - spr.height - 1;
			spr.ID = i + 1;
			spr.alpha = 0; // apparently setting alpha to 0 is better than setting visible to false because it prevents the sprite from calling `draw`
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

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);

		super.create();
	}

	var startTimer:FlxTimer;

	function startCountdown():Void
	{
		inCutscene = false;

		if (camHUD.alpha != 1) FlxTween.tween(camHUD, {alpha: 1}, 0.5, {startDelay: 1});

		generateStaticArrows(0);
		generateStaticArrows(1);

		startedCountdown = true;
		Conductor.songPosition = -Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(getTimeFromBeats(BEATS, 1), function(_)
		{
			boyfriend.dance();
			dad.dance();
			if (songHas3Characters)
				thirdCharacter.dance();
			#if GF
			gf.dance();
			#end

			var sprites = ['ready', 'set', 'go'];
			var suffix:String = (isPixel ? "-pixel" : "");

			if (swagCounter > 0)
			{
				var spr = new FlxSprite().loadGraphic(Paths.image('gameplay/' + pixelFolder + sprites[swagCounter - 1], 'shared'));
				spr.scrollFactor.set();
				if (isPixel && sprites[swagCounter - 1] != 'go'){
					spr.antialiasing = false;
					spr.setGraphicSize(Std.int(spr.width * 6));
				}
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
				CoolUtil.sound('intro' + daSound + suffix, 'shared', 0.6);

			swagCounter += 1;
		}, 4);
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

		var possibleNotes:Array<Note> = [];
		var directionList:Array<Int> = [];
		var dumbNotes:Array<Note> = [];

		notes.forEachAlive(function(daNote:Note)
		{
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
		});

		for (note in dumbNotes)
		{
			trace("Killing dumb note");
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

	var songStarted = false;

	function startSong():Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;

		if (!paused) FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), (KadeEngineData.settings.data.lockSong ? 1 : KadeEngineData.settings.data.musicVolume), false);

		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		clock.songLength = songLength;
	}

	private function generateSong(dataPath:String):Void
	{
		Conductor.changeBPM(SONG.bpm);
		originalSongSpeed = SONG.speed;
		curSong = SONG.song;

		vocals = (SONG.needsVoices ? new flixel.sound.FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song)) : new flixel.sound.FlxSound());
		FlxG.sound.list.add(vocals);

		add(notes = new FlxTypedGroup<Note>());

		if (!substates.ChartingState.hasCharted)
			SongEvents.loadJson("events", StringTools.replace(SONG.song, " ", "-").toLowerCase());

		for (i in SongEvents.eventList)
			if (i.name == 'Change Character')
				addCharacterToList(i.value2, i.value);

		for (section in SONG.notes)
			{
				for (songNotes in section.sectionNotes)
				{
					var daStrumTime:Float = (songNotes[0] < 0 ? 0 : songNotes[0]);
					var daNoteData:Int = Std.int(songNotes[1] % 4);
					var daNoteStyle:String = songNotes[3];
					var gottaHitNote:Bool = (songNotes[1] > 3 ? !section.mustHitSection : section.mustHitSection);
					var oldNote:Note = (unspawnNotes.length > 0 ? unspawnNotes[Std.int(unspawnNotes.length - 1)] : null);
					var susLength:Float = songNotes[2] / Conductor.stepCrochet;

					var swagNote = new Note(daStrumTime, daNoteData, oldNote, false, false, daNoteStyle);
					swagNote.sustainLength = susLength * Conductor.stepCrochet;
					swagNote.mustPress = gottaHitNote;
					swagNote.scrollFactor.set();
					unspawnNotes.push(swagNote);
	
					for (susNote in 0...Math.floor(susLength)) // Aparently this code creates sustain notes, i dont really care
					{
						oldNote = unspawnNotes[unspawnNotes.length - 1];

						var sustainNote = new Note(daStrumTime + (Conductor.stepCrochet * (susNote + 1)), daNoteData, oldNote, true, false, daNoteStyle);
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
		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		var directions:Array<String> = ['left', 'down', 'up', 'right'];
		var pixelBullshit:Array<Array<Int>> = [[0, 4, 8, 12, 16], [1, 5, 9, 13, 17], [2, 6, 10, 14, 18], [3, 7, 11, 15, 19]];

		for (i in 0...4)
			{
				var babyArrow = new FlxSprite(0, (KadeEngineData.settings.data.downscroll ? FlxG.height - 165 : 40));
	
				if (isPixel)
					{
						babyArrow.loadGraphic(Paths.image('gameplay/pixel/NOTE_assets', 'shared'), true, 17, 17);
						babyArrow.setGraphicSize(Std.int(babyArrow.width * 6));
						babyArrow.antialiasing = false;
						babyArrow.animation.add('static', [pixelBullshit[i][0]]);
						babyArrow.animation.add('pressed', [pixelBullshit[i][1], pixelBullshit[i][2]], 12, false);
						babyArrow.animation.add('confirm', [pixelBullshit[i][3], pixelBullshit[i][4]], 24, false);
					}
				else
					{
						babyArrow.frames = Paths.getSparrowAtlas('gameplay/notes/NOTE_assets', 'shared');
						babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
						babyArrow.animation.addByPrefix('static', 'arrow${directions[i].toUpperCase()}');
						babyArrow.animation.addByPrefix('pressed', '${directions[i]} press', 24, false);
						babyArrow.animation.addByPrefix('confirm', '${directions[i]} confirm', 24, false);
					}
	
				babyArrow.updateHitbox();
				babyArrow.scrollFactor.set();
				babyArrow.ID = i;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
	
				switch (player)
				{
					case 0:
						if (KadeEngineData.settings.data.middlescroll)
						{
							FlxTween.cancelTweensOf(babyArrow);
							babyArrow.alpha = 0;
							babyArrow.visible = false;
							babyArrow.x -= 1000;
							babyArrow.active = false;
						}
						cpuStrums.add(babyArrow);
					case 1:
						playerStrums.add(babyArrow);
				}
	
				babyArrow.animation.play('static');
				babyArrow.x += (Note.swagWidth * Math.abs(i) + 100 + ((FlxG.width / 2) * player)) - (KadeEngineData.settings.data.middlescroll ? 275 : 0);
				
				cpuStrums.forEach(function(spr:FlxSprite)
				{					
					spr.centerOffsets(); //CPU arrows start out slightly off-center
				});
	
				strumLineNotes.add(babyArrow);
			}
	}

	override function openSubState(SubState:flixel.FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished) startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		FlxG.mouse.visible = false;

		if (paused)
		{
			CoolUtil.title('${SONG.song} - [$storyDifficultyText]');
			
			if (FlxG.sound.music != null && !startingSong)
				resyncVocals();

			if (!startTimer.finished) startTimer.active = true;

			paused = false;
		}

		super.closeSubState();
	}
	

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = false;
	private var cock:Bool = false;

	override public function update(elapsed:Float)
	{
		FlxG.watch.addQuick("curBeat:", curBeat);
		FlxG.watch.addQuick("curStep", curStep);
		FlxG.watch.addQuick("Notes", unspawnNotes.length);
		FlxG.watch.addQuick('Members:', length);
		FlxG.watch.addQuick('Camera scroll:', camGame.scroll);

		updateNotes();
		updateSongPosition();
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

	// esto revisa el evento que viene (no he probado los steps pero deberia ir)
	private function checkEventNote()
	{
		while (SongEvents.eventList.length > 0)
		{
			var event:EpicEvent = SongEvents.eventList[0];
			
			if (curStep < event.step)
				break;

			triggerEvent(event); // se ejecuta el evento
			SongEvents.eventList.shift(); // se borra 1 elemento del array
		}
	}

	// pon tus funciones aqui siguiendo el nombre del evento que pusiste en el json, agarrando el valor y haciendo lo que quieras
	private function triggerEvent(event:EpicEvent)
	{
		trace('Attempting to play ${event.name.toLowerCase()} event. Step: $curStep.');

		var daEvent = event.name.toLowerCase();

		if ((daEvent == 'bop' || daEvent == 'zoom change' || daEvent == 'animation') && !KadeEngineData.settings.data.distractions)
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

			case "bop":
				camGame.zoom += 0.04;
				camHUD.zoom += 0.12;

			case "zoom change":
				defaultCamZoom += Std.parseFloat(event.value);

			case "turn pixel":
				turnPixel(!isExpellinTime);

			case "animation":
				if (event.value2 == 'bf') boyfriend.animacion(event.value);
				else dad.animacion(event.value);

			case "monday time":
				// mondayTime((event.value == 'true' ? true : false));

			case "change character":
				changeCharacter(event.value2, event.value);

			case "shot":
				dad.animacion('shooting');
				camGame.zoom += 0.08;
				camHUD.zoom += 0.24;
				camGame.shake(0.007, 2);
				chromatic(0.05, 0, true, 0, 0.5);
		}
	}

	function endSong():Void
	{
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);

		tries = 0;

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		FlxG.sound.music.pause();
		vocals.pause();

		if (changedSpeed)
			SONG.speed = originalSongSpeed;

		if (SONG.validScore)
		{
			// adjusting the highscore song name to be compatible
			// would read original scores if we didn't change packages
			var songHighscore = StringTools.replace(PlayState.SONG.song, " ", "-");
			switch (songHighscore) {
				case 'Dad-Battle': songHighscore = 'Dadbattle';
				case 'Philly-Nice': songHighscore = 'Philly';
			}

			#if !switch
			Highscore.saveScore(songHighscore, Math.round(songScore), storyDifficulty);
			Highscore.saveCombo(songHighscore, Ratings.GenerateLetterRank(accuracy), storyDifficulty);
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

					FlxG.sound.music.stop();
					vocals.stop();

					FlxG.sound.playMusic(Paths.music('freakyMenu', 'preload'), KadeEngineData.settings.data.musicVolume);
					MusicBeatState.switchState(new menus.MainMenuState());

					if (SONG.validScore)
						Highscore.saveWeekScore(0, campaignScore, storyDifficulty);
				}
				else
				{
					var poop:String = Highscore.formatSong(StringTools.replace(PlayState.storyPlaylist[0], " ", "-"), storyDifficulty);

					print('LOADING NEXT SONG');
					print(poop);

					flixel.addons.transition.FlxTransitionableState.skipNextTransIn = true;
					flixel.addons.transition.FlxTransitionableState.skipNextTransOut = true;


					PlayState.SONG = Song.loadFromJson(poop, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();
					
					substates.LoadingState.loadAndSwitchState(new PlayState());
				}
			}
			else
			{
				print('WENT BACK TO FREEPLAY??');

				paused = true;

				FlxG.sound.music.stop();
				vocals.stop();

				FlxG.sound.playMusic(Paths.music('freakyMenu', 'preload'), KadeEngineData.settings.data.musicVolume);
	
				MusicBeatState.switchState(new menus.FreeplayState());
			}
	}

	private function popUpScore(daNote:Note):Void
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
		songScoreDef += Math.round(ConvertScore.convertScore(-(daNote.strumTime - Conductor.songPosition)));

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
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData])
						goodNoteHit(daNote);
				});
			}
	
			if ((KeyBinds.gamepad && !FlxG.keys.justPressed.ANY))
			{
				// PRESSES, check for note hits
				if (pressArray.contains(true) && generatedMusic)
				{
					boyfriend.holdTimer = 0;
	
					var possibleNotes:Array<Note> = []; // notes that can be hit
					var directionList:Array<Int> = []; // directions that can be hit
					var dumbNotes:Array<Note> = []; // notes to kill later
					var directionsAccounted:Array<Bool> = [false, false, false, false]; // we don't want to do judgments for more than one presses
	
					var hit = [false, false, false, false];
	
					notes.forEachAlive(function(daNote:Note)
					{
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
					});
	
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
	
					if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || KadeEngineData.botplay))
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
				notes.forEachAlive(function(daNote:Note)
				{
					goodNoteHit(daNote);
					boyfriend.holdTimer = daNote.sustainLength;
					playerStrums.forEach(function(spr:FlxSprite)
					{
						if (Math.abs(daNote.noteData) == spr.ID)
							spr.animation.play('confirm', true);
	
						if (spr.animation.curAnim.name == 'confirm' && !isPixel)
						{
							spr.centerOffsets();
							spr.offset.x -= 13;
							spr.offset.y -= 13;
						}
						else
							spr.centerOffsets();
					});
				});
			}
	
			if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || KadeEngineData.botplay))
			{
				if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
					boyfriend.dance();
			}
	
			if (!KadeEngineData.botplay)
			{
				playerStrums.forEach(function(spr:FlxSprite)
				{
					if (keys[spr.ID] && spr.animation.curAnim.name != 'confirm' && cantPressArray[spr.ID])
						spr.animation.play('pressed', true);
					if (!keys[spr.ID])
						spr.animation.play('static');
			
					if (spr.animation.curAnim.name == 'confirm' && !isPixel)
					{
						spr.centerOffsets();
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					}
					else
						spr.centerOffsets();
				});
			}
		}

	function input():Void
	{
		if (inCutscene) return;

		keyShit();

		#if debug
		//funny joke for croop x
		if (FlxG.keys.justPressed.U) cock = !cock;
		if (cock) misses++;

		if (FlxG.keys.justPressed.ONE)
			endSong();

		debugEditors();

		if (FlxG.mouse.wheel != 0)
		{
			camGame.zoom += (FlxG.mouse.wheel / 10);
			camHUD.zoom += (FlxG.mouse.wheel / 10);
		}
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

		if (controls.PAUSE && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;
			vocals.pause();
			FlxG.sound.music.pause();

			openSubState(new substates.PauseSubState());
		}
	}

	function noteMiss(direction:Int = 1, daNote:Note = null):Void
	{
		//bbpanzu
		if (died || (daNote.noteStyle == 'nuggetP' || daNote.noteStyle == 'apple'))
			return;

		//bbpanzu
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

			scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, accuracy);
		}
	
		function getKeyPresses(note:Note):Int
		{
			var possibleNotes:Array<Note> = []; // copypasted but you already know that
	
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
				{
					possibleNotes.push(daNote);
					possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
				}
			});
			if (possibleNotes.length == 1)
				return possibleNotes.length + 1;
			return possibleNotes.length;
		}
	
		function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
		{
			var noteDiff:Float = -(note.strumTime - Conductor.songPosition);
	
			note.rating = Ratings.CalculateRating(noteDiff, Math.floor((Conductor.safeFrames / 60) * 1000));
			
			if (controlArray[note.noteData])
				goodNoteHit(note);
		}
	
		function goodNoteHit(note:Note):Void
			{
				if (!cantPressArray[note.noteData])
					return;
	
				vocals.volume = (KadeEngineData.settings.data.lockSong ? 1 : KadeEngineData.settings.data.musicVolume);
	
				//bbpanzu
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
	
				if (KadeEngineData.settings.data.snap && !note.isSustainNote)
					CoolUtil.sound('extra/SNAP', 'shared');
	
				var noteDiff:Float = -(note.strumTime - Conductor.songPosition);
	
				note.rating = Ratings.CalculateRating(noteDiff);
	
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
	
					if (!note.doubleNote) boyfriend.sing(note.noteData);
					else trail(boyfriend);
	
					playerStrums.forEach(function(spr:FlxSprite)
					{
						if (Math.abs(note.noteData) == spr.ID && cantPressArray[spr.ID])
							spr.animation.play('confirm', true);
					});
					
					note.wasGoodHit = true;
					vocals.volume = (KadeEngineData.settings.data.lockSong ? 1 : KadeEngineData.settings.data.musicVolume);
		
					// do not remove or destroy sustains as it might seem bad when playing sustains
					if (!note.isSustainNote)
						destroyNote(note);

					updateAccuracy();
				}
			}

	// helper function for single liner destroy notes
	function destroyNote(note:Note)
		{
			note.updateTime = false;
			note.exists = false;

			note.kill();
			notes.remove(note, true);
			note.destroy();
		}

	var stepOfLast = 0;

	override function stepHit()
	{
		CoolUtil.presence('Misses: $misses | Tries: $tries', 'Playing: ${SONG.song} - [$storyDifficultyText]', true, songLength - Conductor.songPosition, (dad.curCharacter == 'janitor' ? (janitorKys ? 'kys' : 'janitor') : dad.curCharacter), true);
		
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
			resyncVocals();

		checkEventNote();

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
			Conductor.changeBPM(daSection.bpm);
			FlxG.log.add('CHANGED BPM!');
		}

		bop();

		if (curBeat >= 4 && !shownCredits)
			{
				shownCredits = true;

				var author:String = switch (SONG.song)
				{
					case 'Nugget':				   								   "Enzo & TheGalo X";
					case 'Monday' | 'Staff Only':                                  "RealG";
					case 'Expelled' | 'Expelled V1' | 'Expelled V2' | 'Cash Grab': "KrakenPower";
					case 'Nugget de Polla':                                        "TheGalo X & KrakenPower";
					case 'Monday Encore':										   "RealG & TheGalo X";
					default:					                                   "no author lmao";
				}

				var creditPage = new PageSprite('${SONG.song}\nby $author', true);
				creditPage.cameras = [camHUD];
				add(creditPage);
			}

		if (curSong == 'Monday' && KadeEngineData.settings.data.mechanics && storyDifficulty != 0)
		{
			if (curBeat == 32 || curBeat == 64)
			{
				var text:String = (curBeat == 32 ? '<-- Use collected apples\nto heal yourself with SPACEBAR' : 'oh shit he can do that too\nwatch out!');
				var page = new PageSprite(text, false, getTimeFromBeats(SECTIONS, 1.5));
				page.cameras = [camHUD];
				if (curBeat == 32) page.x -= 150;
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

	function bop():Void
		{
			if (KadeEngineData.settings.data.distractions)
			{
				if (curBeat % cameraBopBeat == 0)
					{
						camGame.zoom += 0.02;
						camHUD.zoom += 0.06;
					}

				if (curBeat % 2 == 0)
					{
						iconP1.scale.set(1.1, 1.1);
						iconP1.angle = -10;
						iconP2.scale.set(1.1, 1.1);
						iconP2.angle = 10;

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
			if (died) return;
			died = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			//retrospecter goes brrrrrr
			poisonStacks = 0;

			vocals.stop();
			FlxG.sound.music.stop();

			setChrome(defaultChromVal);
			filters.remove(shaderFilter);
			FlxG.game.setFilters(filters);

			if (changedSpeed) SONG.speed = originalSongSpeed;

			openSubState(new substates.GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		// so cringe

		//psych engineee
		private var boyfriendMap:Map<String, Boyfriend> = new Map();
		private var dadMap:Map<String, Character> = new Map();

		private function addCharacterToList(target:String, char:String) 
		{
			if (target == 'bf' || target == 'boyfriend')
			{
				if(!boyfriendMap.exists(char)) 
				{
					var newBoyfriend:Boyfriend = new Boyfriend(boyfriend.x, boyfriend.y, char);
					boyfriendMap.set(char, newBoyfriend);
					newBoyfriend.alpha = 0.00001;
				}
			}
			else
			{
				if(!dadMap.exists(char)) 
				{
					var newDad:Character = new Character(dad.x, dad.y, char);
					dadMap.set(char, newDad);
					newDad.alpha = 0.00001;
				}
			}
		}

		function changeCharacter(target:String, char:String):Void
		{
			if (target == 'bf' || target == 'boyfriend')
			{
				if(!boyfriendMap.exists(char))
					addCharacterToList(char, char);
				
				boyfriend.alpha = 0.00001;
				boyfriend = boyfriendMap.get(char);
				boyfriend.alpha = 1;
				healthBar.createFilledBar(FlxColor.fromString(dad.curColor), FlxColor.fromString(boyfriend.curColor));
				iconP1.animation.play(char);
			}
			else
			{
				if(!dadMap.exists(char))
					addCharacterToList(char, char);

				dad.alpha = 0.00001;
				dad = dadMap.get(char);
				dad.alpha = 1;
				healthBar.createFilledBar(FlxColor.fromString(dad.curColor), FlxColor.fromString(boyfriend.curColor));
				iconP2.animation.play(char);
			}
		}

			function focusOnCharacter(character:Character):Void
			{
				if (!canTweenCam || SONG.song == 'Nugget de Polla' || character == null || !generatedMusic || daSection == null)
					return;

				camFollow.setPosition(character.camPos[0] + character.camSingPos.x, character.camPos[1] + character.camSingPos.y);
			}

			function doNoteSplash(daNote:Note, daRating:String = ""):Void
				{
					//bbpanzu
					if (!KadeEngineData.settings.data.distractions || (daNote.noteStyle == 'nuggetP' && KadeEngineData.botplay) || daRating != 'sick')
						return;

					NoteSplash.data = [daNote.x, playerStrums.members[daNote.noteData].y, daNote.noteData];
					splashGroup.add(splashGroup.recycle(NoteSplash.new));
				}

			function gumNoteMechanic(daNote:Note):Void
				{
					if (!KadeEngineData.settings.data.mechanics || KadeEngineData.botplay || storyDifficulty == 0)
						return;

					if (!cantPressArray[daNote.noteData])
						return;
					else
					{
						cantPressArray[daNote.noteData] = false;
						playerStrums.forEach(function(spr:FlxSprite)
							{
								if (spr.ID == daNote.noteData)
									spr.alpha = 0.75;
							});
					}

					var gumTrap:NoteSplash.GumTrap = new NoteSplash.GumTrap(daNote.x, playerStrums.members[daNote.noteData].y);
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
								playerStrums.forEach(function(spr:FlxSprite)
									{
										if (spr.ID == daNote.noteData)
											spr.alpha = 1;
									});
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
						FlxTween.tween(this, {chromVal: toValue}, time);
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
					camHUD.alpha = 0;
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
							MusicBeatState.switchState(editorState);
							FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN,handleInput);
						}
				}
			}

			//idea from impostor v4 BUT, in a different way because the way they made it in impostor v4 sucks (love u clowfoe)
			function trail(char:FlxSprite):Void
			{
				if (!KadeEngineData.settings.data.distractions)	return;
				trace('TRAILLLLLLLLLLLLLLLLLLLLLLLLL');

				var trail:flixel.addons.effects.FlxTrail = new flixel.addons.effects.FlxTrail(char, null, 1, 100, 1);
				insert(members.indexOf(char) - 1, trail); //LOVE YOU SANCO
				FlxTween.tween(trail, {alpha: 0}, 1.5, {onComplete: function(_)	trail.destroy()	});
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

							if (KadeEngineData.settings.data.flashing && SONG.song != 'Expelled V1') FlxG.cameras.flash();
	
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
		
				apples.forEach(function(apple:Apple)
				{
					if (apple.ID <= actions) apple.alpha = 1;
					else apple.alpha = 0;
				});
			}

			private function updateLerps(elapsed:Float):Void
			{
				if (KadeEngineData.settings.data.distractions)
				{
					var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9)));
					var ass:Float = FlxMath.lerp(1, iconP1.angle, CoolUtil.boundTo(1 - (elapsed * 9)));
					var ass2:Float = FlxMath.lerp(1, iconP2.angle, CoolUtil.boundTo(1 - (elapsed * 9)));

					iconP1.angle = ass;
					iconP1.scale.set(mult, mult);

					iconP2.angle = ass2;
					iconP2.scale.set(mult, mult);

					lerpHealth = FlxMath.lerp(health, lerpHealth, CoolUtil.boundTo(1 - elapsed * 5));
				}
			
				if (!cock)
				{
					camGame.zoom = FlxMath.lerp(defaultCamZoom, camGame.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125)));
					camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125)));
				}

				camGame.focusOn(camPoint.set(flixel.math.FlxMath.lerp(camPoint.x, camFollow.x, 0.5 * (elapsed * 5)), flixel.math.FlxMath.lerp(camPoint.y, camFollow.y, 0.5 * (elapsed * 5))));
			}

			private function updateNotes():Void
			{
				if (generatedMusic)
				{
					var downMult:Int = (!KadeEngineData.settings.data.downscroll ? 1 : -1);

					for (spr in cpuStrums.members)
					{
						if (spr.animation.finished)
						{
							spr.animation.play('static');
							spr.centerOffsets();
						}
					}

					notes.forEachAlive(function(daNote:Note)
					{
						if (daNote.tooLate)
						{
							daNote.updateTime = false;
							daNote.alpha = 0.5;
						}
						else
							daNote.visible = daNote.updateTime = true;

						var strums:FlxTypedGroup<FlxSprite> = (daNote.mustPress) ? playerStrums : cpuStrums;
						var receptorX = strums.members[Math.floor(Math.abs(daNote.noteData))].x;
						var receptorY = strums.members[Math.floor(Math.abs(daNote.noteData))].y + (Note.swagWidth / 6);

						var pseudoY:Float = daNote.offsetY + (downMult * -((Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2))));

						daNote.y = receptorY
							+ (Math.cos(flixel.math.FlxAngle.asRadians(daNote.direction)) * pseudoY)
							+ (Math.sin(flixel.math.FlxAngle.asRadians(daNote.direction)) * daNote.offsetX);

						daNote.x = receptorX
							+ (Math.cos(flixel.math.FlxAngle.asRadians(daNote.direction)) * daNote.offsetX)
							+ (Math.sin(flixel.math.FlxAngle.asRadians(daNote.direction)) * pseudoY);

						daNote.angle = -daNote.direction;

						var center:Float = receptorY + Note.swagWidth / 2;
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
							if (daSection != null)
							{
								if (health > 0.04 && SONG.songDrains && KadeEngineData.settings.data.mechanics) changeHealth(-0.04);
		
								if (daSection.altAnim)
									dad.altAnimSuffix = '-alt';
								else
									dad.altAnimSuffix = '';

								if(!daNote.doubleNote) dad.sing(daNote.noteData);
								else trail(dad);
									
								if (songHas3Characters && thirdCharacter.turn && !daNote.doubleNote)
									thirdCharacter.sing(daNote.noteData);
							}

							if (daNote.noteStyle == 'apple' && !daNote.isSustainNote) eatApple(false);

							dad.holdTimer = 0;

							if (songHas3Characters && thirdCharacter.turn)
								thirdCharacter.holdTimer = 0;
		
							if (SONG.needsVoices)
								vocals.volume = (KadeEngineData.settings.data.lockSong ? 1 : KadeEngineData.settings.data.musicVolume);
		
							cpuStrums.forEach(function(spr:FlxSprite)
							{
								if (Math.abs(daNote.noteData) == spr.ID && spr.animation.curAnim.name != 'confirm')
									spr.animation.play('confirm', true);
				
								if (spr.animation.curAnim.name == 'confirm' && !isPixel)
								{
									spr.centerOffsets();
									spr.offset.x -= 13;
									spr.offset.y -= 13;
								}
								else
									spr.centerOffsets();
							});

							daNote.updateTime = false;

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

						//this is from Note.hx
						if (daNote.updateTime && daNote.mustPress)
							{
								var curHitBox:Float;
								var curHitBox2:Float;

								//bbpanzu
								switch (daNote.noteStyle)
								{
									case 'nuggetP':
										curHitBox = 0.4;
										curHitBox2 = 0.3;
									case 'gum':
										curHitBox = 0.5;
										curHitBox2 = 0.4;
									case  'b': //| 'apple':
										curHitBox = 1.5;
										curHitBox2 = 1.5;
									default:
										curHitBox = daNote.lateHitMult;
										curHitBox2 = daNote.earlyHitMult;
								}
					
								if (daNote.strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * curHitBox) //bbpanzu
									&& daNote.strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * curHitBox2)) //bbpanzu
									daNote.canBeHit = true;
								else
									daNote.canBeHit = false;
					
								if (daNote.strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !daNote.wasGoodHit)
									daNote.tooLate = true;
							}
							else
							{
								daNote.canBeHit = false;
					
								if (daNote.strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * daNote.earlyHitMult))
								{
									if((daNote.isSustainNote && daNote.prevNote.wasGoodHit) || daNote.strumTime <= Conductor.songPosition)
										daNote.wasGoodHit = true;
								}
							}
					
							if (daNote.tooLate || (daNote.parent != null && daNote.parent.tooLate))
							{
								if (daNote.alpha > 0.3)
									daNote.alpha = 0.3;
							}
					});
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
				var comboSplit:Array<String> = (combo + "").split('');

				if (comboSplit.length == 1)
				{
					seperatedScore.push(0);
					seperatedScore.push(0);
				}
				else if (comboSplit.length == 2)
					seperatedScore.push(0);

				for(i in 0...comboSplit.length)
					seperatedScore.push(Std.parseInt(comboSplit[i]));

				for (i in 0...seperatedScore.length)
				{
					var numScore = numbersGroup.recycle(Number.new);
					if (KadeEngineData.settings.data.changedHit)
						numScore.setPosition(KadeEngineData.settings.data.changedHitX + (43 * i) + 50, KadeEngineData.settings.data.changedHitY + 90);
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
					ratingSpr.play(daRating);
			}

			private function addCharacters():Void
			{
				stage = new Stage(SONG.stage);
				add(stage);

				#if GF
				gf = new Character(stage.positions['gf'][0], stage.positions['gf'][1], 'gf');
				gf.scrollFactor.set(0.95, 0.95);
				add(gf);
				#end

				// LMFAO NICE TRY MODIFYING FILE'S SHIT LOSER
				#if !debug
				if (KadeEngineData.other.data.beatedMod)
					SONG.player1 = (menus.MainMenuState.bfSkin ? 'bf-suit' : 'bf');
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
				}
				#end

				dad = new Character(stage.positions['dad'][0], stage.positions['dad'][1], SONG.player2);
				add(dad);

				if (songHas3Characters)
				{
					thirdCharacter = new Character(stage.positions['third'][0], stage.positions['third'][1], 'monty');
					thirdCharacter.turn = false;
					add(thirdCharacter);
				}

				boyfriend = new Boyfriend(stage.positions['bf'][0], stage.positions['bf'][1], SONG.player1);
				add(boyfriend);

				stage.backgroundSprites.forEach(function(i:BGSprite)
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
}