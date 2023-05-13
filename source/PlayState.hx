package;

import Shaders.PixelEffect;
import SongEvents.EpicEvent;
import Objects;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import flixel.input.keyboard.FlxKey;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
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
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var weekSong:Int = 0;
	public static var weekScore:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;
	public static var tries:Int = 0;

	public static var songPosBG:FlxSprite;
	public static var songPosBar:FlxBar;

	var songLength:Float = 0;
	var kadeEngineWatermark:FlxText;

	private var vocals:FlxSound;

	public static var dad:Character;

	public static var songHas3Characters:Bool = false;
	public static var thirdCharacter:Character;

	#if GF
	public static var gf:Character;
	#end
	public static var boyfriend:Boyfriend;

	/*3 PLAYERS AAAAAA
	var dad2:Character;
	var spriteDad:FlxSprite;
	var spriteDad2:FlxSprite;

	public var has2Dads:Bool = false;
	*/

	public var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;
	private var curSection:Int = 0;

	//camera movement, fuck it ill do it myself
	//i couldnt do it myself, this code is from sonic.exe mod :(
	var dadcamX:Int = 0;
	var dadcamY:Int = 0;
	var bfcamX:Int = 0;
	var bfcamY:Int = 0;

	private var camOffset:Int = (KadeEngineData.settings.data.camMove ? 30 : 0);
	private var camFollow:flixel.FlxObject;

	public static var strumLineNotes:FlxTypedGroup<FlxSprite> = null;
	public static var playerStrums:FlxTypedGroup<FlxSprite> = null;
	public static var cpuStrums:FlxTypedGroup<FlxSprite> = null;

	private var curSong:String = "";

	public var health:Float = 1; // making public because sethealth doesnt work without it
	private var combo:Int = 0;
	public static var misses:Int = 0;
	public var accuracy:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalPlayed:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	private var songPositionBar:Float = 0;
	
	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	public var iconP1:HealthIcon; //making these public again because i may be stupid
	public var iconP2:HealthIcon; //what could go wrong?
	public var camHUD:FlxCamera;
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

	public var hpDrain:Float = 0.04;

	var noteCombo:NoteCombo;
	var sectionEnd:Bool = false;
	var sectionNoteHits:Int = 0;

	public static var stage:Stage;

	//shaders
	var filters:Array<openfl.filters.BitmapFilter> = [];
	var chromVal:Float = 0;
	var defaultChromVal:Float = 0;

	var shaderFilter:openfl.filters.ShaderFilter;

	var apple1:Apple;
	var apple2:Apple;
	var apple3:Apple;

	var apples:FlxTypedGroup<Apple> = null;

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

	var pixelShit:PixelEffect;
	private var pollaBlock = new FlxSprite().makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);

	override public function create()
	{
		instance = this;

		FlxG.mouse.visible = false;

		if (storyDifficulty == 3 || KadeEngineData.botplay)
			KadeEngineData.practice = false;

		CoolUtil.title('Loading...');
		CoolUtil.presence(null, 'Loading...', false, 0, null);
		
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		sicks = bads = shits = goods = misses = 0;

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		setChrome(0);
		
		if (KadeEngineData.settings.data.flashing && KadeEngineData.settings.data.shaders)
		{
			filters.push(chromaticAberration);
			FlxG.game.setFilters(filters);
		}

		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			{
				print('song is null???');
				SONG = Song.loadFromJson('tutorial', 'tutorial');
			}
		else
			print('song looks gucci');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		print('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: ' + Conductor.safeFrames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: ' + Conductor.timeScale + '\nBotPlay : ' + KadeEngineData.botplay);

		if (SONG.stage == null) 
		{
			print("da fuck the song stage is null why i dont know???????????????????????");
			SONG.stage == 'stage';
		}
		else
		{
			print("the song stage is gud !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
		}

		
		stage = new Stage(SONG.stage);
		add(stage);

		switch (SONG.song)
		{
			case 'DadBattle':
				songHas3Characters = true;
				isPixel = true;
			default:
				songHas3Characters = false;
				isPixel = false;
		}

		//prevIsPixel = isPixel;

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

		print('uh ' + Conductor.safeFrames);

		print("SF CALC: " + Math.floor((Conductor.safeFrames / 60) * 1000));


		Conductor.songPosition = -5000;
		
		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		
		if (KadeEngineData.settings.data.downscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		cpuStrums = new FlxTypedGroup<FlxSprite>();

		generateSong(SONG.song);

		print('generated');

		var difficultiesEpic = ['easy', 'normal', 'hard', 'survivor'];
		storyDifficultyText = difficultiesEpic[storyDifficulty].toUpperCase(); //to uppercase because im so fucking cool to do it in directly in the array like a virgin

		CoolUtil.title('${SONG.song} - [$storyDifficultyText]');
		CoolUtil.presence('Starting countdown...', 'Playing: ${SONG.song} - [$storyDifficultyText]', false, null, (dad.curCharacter == 'janitor' ? (janitorKys ? 'kys' : 'janitor') : dad.curCharacter), true);

		camFollow = new flixel.FlxObject(0, 0, 1, 1);
		camFollow.setPosition(boyfriend.camPos[0], boyfriend.camPos[1]);

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / FlxG.updateFramerate));
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('gameplay/healthBar'));
		if (KadeEngineData.settings.data.downscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		if (SONG.leftSide)
			{
				healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, LEFT_TO_RIGHT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this, 'health', 0, 2);
				healthBar.scrollFactor.set();
				healthBar.createFilledBar(FlxColor.fromString(dad.curColor), FlxColor.fromString(boyfriend.curColor));
				add(healthBar);
			}
		else
			{
				healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this, 'health', 0, 2);
				healthBar.scrollFactor.set();
				healthBar.createFilledBar(FlxColor.fromString(dad.curColor), 
					FlxColor.fromString(boyfriend.curColor));
				add(healthBar);
			}

		// Add Kade Engine watermark
		kadeEngineWatermark = new FlxText(4,healthBarBG.y + 50, 0, SONG.song + " - " + CoolUtil.difficultyFromInt(storyDifficulty), 16);
		kadeEngineWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		add(kadeEngineWatermark);

		if (KadeEngineData.settings.data.downscroll)
			kadeEngineWatermark.y = FlxG.height * 0.9 + 45;

		// Literally copy-paste of the above, fu
		var botPlayState = new FlxText(0, healthBarBG.y + (KadeEngineData.settings.data.downscroll ? 100 : -100), FlxG.width, (storyDifficulty == 3 ? "YOU SUCK": "BOTPLAY"), 20);
		botPlayState.autoSize = false;
		botPlayState.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		botPlayState.scrollFactor.set();
		botPlayState.borderSize = 1.5;
		if(KadeEngineData.botplay)
			add(botPlayState);

		#if debug
		curBeatText = new FlxText(0, botPlayState.y + (KadeEngineData.settings.data.downscroll ? 50 : -50), FlxG.width, "Beat: ", 20);
		curBeatText.autoSize = false;
		curBeatText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		curBeatText.scrollFactor.set();
		curBeatText.borderSize = 1.25;
		add(curBeatText);
		#end

		if (SONG.leftSide)
			{
				iconP2 = new HealthIcon(SONG.player1, false);
				iconP2.y = healthBar.y - (iconP2.height / 2);
				add(iconP2);
		
				iconP1 = new HealthIcon(SONG.player2, true);
				iconP1.y = healthBar.y - (iconP1.height / 2);
				add(iconP1);
			}
		else 
			{
				iconP1 = new HealthIcon(SONG.player1, true);
				iconP1.y = healthBar.y - (iconP1.height / 2);
				add(iconP1);

				iconP2 = new HealthIcon(SONG.player2, false);
				iconP2.y = healthBar.y - (iconP2.height / 2);
				add(iconP2);
			}

		scoreTxt = new FlxText(0, healthBarBG.y + 35, FlxG.width, "", 20);
		scoreTxt.autoSize = false;
		scoreTxt.borderSize = 1.25;
		scoreTxt.scrollFactor.set();
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		add(scoreTxt);

		if (SONG.song == 'Nugget de Polla'){
			camFollow.screenCenter(X);
			camFollow.y -= 150;
			iconP1.visible = iconP2.visible = kadeEngineWatermark.visible = false;

			if (KadeEngineData.settings.data.distractions){
			pollaBlock.screenCenter();
			pollaBlock.scrollFactor.set();
			pollaBlock.active = false;
			add(pollaBlock);
			}
		}

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		botPlayState.cameras = [camHUD];
		curBeatText.cameras = [camHUD];
		kadeEngineWatermark.cameras = [camHUD];

		startingSong = true;
		
		print('starting');

		pixelFolder = (isPixel ? 'pixel/' : '');

		tries++;

		if (isStoryMode)
		{
			switch (SONG.song)
			{
				case 'DadBattle':
					startCountdown();
				default:
					if (tries <= 1)
						dialogue();
					else
						startCountdown();
			}
		}
		else //if is freeplay
		{
			startCountdown();
			/*switch (SONG.song)
			{
				case 'DadBattle':
					startCountdown();
				default:
					if (tries <= 0)
						dialogue();
					else
						startCountdown();
			}*/
		}

		//shaders
		switch (SONG.song)
			{
				default:
					//chromVal = 0.001;
					//defaultChromVal = 0.001;
			}

		if (!KadeEngineData.settings.data.distractions)
			KadeEngineData.settings.data.camMove = false;

		apples = new FlxTypedGroup<Apple>(); //BETTER CODE LETS GOOOOOOOO, CHECK THE LAST VERSION OF THIS SHIT HAHAHAHA

		for (i in 0...3)
		{
			var spr:Apple = new Apple(0, 0);
			spr.cameras = [camHUD];
			spr.x = spr.width * i;
			spr.y = FlxG.height - spr.height - 1;
			spr.ID = i + 1;
			spr.visible = false;
			apples.add(spr);
		}

		add(apples);

		if (!cast(KadeEngineData.other.data.showCharacters, Array<Dynamic>).contains(dad.curCharacter)){
			cast(KadeEngineData.other.data.showCharacters,  Array<Dynamic>).push(dad.curCharacter);
			KadeEngineData.flush();
		}

		if (SONG.song == 'Nugget')
			boyfriend.camPos[1] -= 200;
		if (SONG.song == 'Expelled' #if debug || stage.stage == 'principal' #end)
			boyfriend.camPos[0] -= 100;

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);

		super.create();
	}

	var startTimer:FlxTimer;

	function startCountdown():Void
	{
		inCutscene = false;

		if (camHUD.alpha != 1) FlxTween.tween(camHUD, {alpha: 1}, 0.5);

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
				var spr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gameplay/' + pixelFolder + sprites[swagCounter - 1], 'shared'));
				spr.scrollFactor.set();
				if (isPixel && sprites[swagCounter - 1] != 'go'){
					spr.antialiasing = false;
					spr.setGraphicSize(Std.int(spr.width * 6));
				}
				spr.updateHitbox();
				spr.screenCenter();
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
		var openFLKey = Keyboard.__convertKeyCode(evt.keyCode);
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
			note.kill();
			notes.remove(note, true);
			note.destroy();
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
		var openFLKey = Keyboard.__convertKeyCode(evt.keyCode);
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

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), (KadeEngineData.settings.data.lockSong ? 1 : KadeEngineData.settings.data.musicVolume), false);

		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		if (KadeEngineData.settings.data.songPosition)
		{
			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('gameplay/healthBar', 'shared'));
			if (KadeEngineData.settings.data.downscroll)
				songPosBG.y = FlxG.height * 0.9 + 45; 
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, songLength - 1000);
			songPosBar.numDivisions = 100;
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.BLACK, FlxColor.WHITE);
			add(songPosBar);

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (SONG.song.length * 5),songPosBG.y,0,SONG.song, 16);
			if (KadeEngineData.settings.data.downscroll)
				songName.y -= 3;
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);

			if (SONG.song == 'Nugget de Polla')
				songPosBG.visible = songPosBar.visible = songName.visible = false;

			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];
		}

		new FlxTimer().start(3, function(_)
			{
				FlxTween.tween(kadeEngineWatermark, {alpha: 0}, getTimeFromBeats(SECTIONS, 1), {onComplete: function(_)
				{
					kadeEngineWatermark.destroy();
				}});
			});
	}

	private function generateSong(dataPath:String):Void
	{
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		print('loaded vocals');

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var folderLowercase = StringTools.replace(songData.song, " ", "-").toLowerCase();
		if (!substates.ChartingState.hasCharted)
			SongEvents.loadJson("events", folderLowercase);

		for (i in SongEvents.eventList)
			if (i.name == 'Change Character')
				addCharacterToList(i.value2, i.value);

		var noteData:Array<Section.SwagSection>;
		noteData = songData.notes;

		for (section in noteData)
			{
				for (songNotes in section.sectionNotes)
				{
					var daStrumTime:Float = songNotes[0];
					if (daStrumTime < 0)
						daStrumTime = 0;
					var daNoteData:Int = Std.int(songNotes[1] % 4);
	
					//bbpanzu
					var daNoteStyle:String = songNotes[3];
	
					var gottaHitNote:Bool = section.mustHitSection;
	
					if (songNotes[1] > 3)
						gottaHitNote = !section.mustHitSection;
	
					var oldNote:Note;
					if (unspawnNotes.length > 0)
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
					else
						oldNote = null;
	
					//bbpanzu
					var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, false, daNoteStyle);
	
					swagNote.sustainLength = songNotes[2];
					swagNote.scrollFactor.set(0, 0);
	
					var susLength:Float = swagNote.sustainLength;
	
					susLength = susLength / Conductor.stepCrochet;
					unspawnNotes.push(swagNote);
	
					for (susNote in 0...Math.floor(susLength))
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
	
						//bbpanzu
						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * (susNote + 1)), daNoteData, oldNote, true, false, daNoteStyle);
						sustainNote.scrollFactor.set();
						unspawnNotes.push(sustainNote);
	
						sustainNote.parent = swagNote;
						sustainNote.mustPress = gottaHitNote;
	
						if (sustainNote.mustPress)
						{
							if (notestrumtimes1.contains(Math.round(sustainNote.strumTime)))
								sustainNote.doubleNote = true;
		
							notestrumtimes1.push(Math.round(sustainNote.strumTime));
	
							sustainNote.x += FlxG.width / 2; // general offset
						}else
						{
							if (notestrumtimes2.contains(Math.round(sustainNote.strumTime))){
								sustainNote.doubleNote = true;
								notestrumtimes2.push(Math.round(sustainNote.strumTime));
							}
							notestrumtimes2.push(Math.round(sustainNote.strumTime));
						}
					}
	
					swagNote.mustPress = gottaHitNote;
	
					if (swagNote.mustPress)
					{
						if (notestrumtimes1.contains(Math.round(swagNote.strumTime))){
							swagNote.doubleNote = true;
							notestrumtimes1.push(Math.round(swagNote.strumTime));
						}
						notestrumtimes1.push(Math.round(swagNote.strumTime));
	
						swagNote.x += FlxG.width / 2; // general offset
					}
					else
					{
						if (notestrumtimes2.contains(Math.round(swagNote.strumTime))){
							swagNote.doubleNote = true;
							notestrumtimes2.push(Math.round(swagNote.strumTime));
						}
						notestrumtimes2.push(Math.round(swagNote.strumTime));
					}
				}
			}

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;

		originalSongSpeed = SONG.speed;

		print("generated song lol  |  Song: " + curSong);
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
				var babyArrow = new FlxSprite(0, strumLine.y - 10);
	
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
							babyArrow.visible = false;
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
	
			if (SONG.leftSide)
			{
				cpuStrums.forEach(function(spr:FlxSprite)
				{
					FlxTween.tween(spr, {x: spr.x += 315, y: spr.y}, 1, {ease: FlxEase.quartOut});
				});
				playerStrums.forEach(function(spr:FlxSprite)
				{
					if (!KadeEngineData.settings.data.middlescroll)
						FlxTween.tween(spr, {x: spr.x -= 650, y: spr.y}, 1, {ease: FlxEase.quartOut});
				});
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

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			CoolUtil.title('${SONG.song} - [$storyDifficultyText]');
			
			if (FlxG.sound.music != null && !startingSong)
				resyncVocals();

			if (!startTimer.finished)
				startTimer.active = true;

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

	public static var songRate = 1.5;
	private var cock:Bool = false;

	override public function update(elapsed:Float)
	{	
		//curBeatText.text = "Beat: " + curBeat + " | dadCanSing: " + dad.canSing + " | dadCanIdle: " + dad.canIdle;

		//retrospecter goes brrrrrrr
		health -= difficultiesStuff["healthDrainPoison"][storyDifficulty] * poisonStacks * elapsed; // Gotta make it fair with different framerates :)

		if (actions < 0)
			actions = 0;
		if (actions > 3)
			actions = 3;

		apples.forEach(function(apple:Apple)
		{
			if (apple.ID <= actions)
				apple.visible = true;
			else
				apple.visible = false;
		});

		setChrome(chromVal);

		scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, accuracy);

		if (controls.PAUSE && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;
			vocals.pause();
			FlxG.sound.music.pause();

			openSubState(new substates.PauseSubState());
		}

		if (KadeEngineData.settings.data.distractions)
		{
			var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
			var ass:Float = FlxMath.lerp(1, iconP1.angle, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
			var ass2:Float = FlxMath.lerp(1, iconP2.angle, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));

			iconP1.angle = ass;
			iconP1.scale.set(mult, mult);
			//iconP1.updateHitbox();

			iconP2.angle = ass2;
			iconP2.scale.set(mult, mult);
			//iconP2.updateHitbox();
		}

		var iconOffset:Int = 26;

		if (SONG.leftSide)
			{
				iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(-healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset) - 587;
				iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(-healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset) - 600;
			}
		else
			{
				iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
				iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
			}

		if (health > 2)
			health = 2;

		if (SONG.leftSide)
			{
				if (iconP1.animation.curAnim != null)
					{
						if (healthBar.percent > 80)
							iconP1.animation.curAnim.curFrame = 1;
						else
							iconP1.animation.curAnim.curFrame = 0;
					}
		
				if (iconP2.animation.curAnim != null)
					{
						if (healthBar.percent < 20)
							iconP2.animation.curAnim.curFrame = 1;
						else
							iconP2.animation.curAnim.curFrame = 0;
					}
			}
		else
			{
				if (iconP1.animation.curAnim != null)
					{
						if (healthBar.percent < 20)
							iconP1.animation.curAnim.curFrame = 1;
						else
							iconP1.animation.curAnim.curFrame = 0;
					}
		
				if (iconP2.animation.curAnim != null)
					{
						if (healthBar.percent > 80)
							iconP2.animation.curAnim.curFrame = 1;
						else
							iconP2.animation.curAnim.curFrame = 0;
					}
			}

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
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;
			/*@:privateAccess
			{
				FlxG.sound.music._channel.
			}*/
			songPositionBar = Conductor.songPosition;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
				focusOnCharacter('dad');

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
				focusOnCharacter('bf');
		}

		FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
		camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);

		FlxG.watch.addQuick("curBeat:", curBeat);
		FlxG.watch.addQuick("curStep", curStep);
		FlxG.watch.addQuick("Notes", notes.length);

		if (health <= 0 && !KadeEngineData.practice && !KadeEngineData.botplay)
			die();
		else if (health <= 0 && (KadeEngineData.practice || KadeEngineData.botplay))
			health = 0.001;

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
						daNote.active = false;
						daNote.alpha = 0.5;
					}
					else
					{
						daNote.visible = true;
						daNote.active = true;
					}

					var strums:FlxTypedGroup<FlxSprite> = (daNote.mustPress) ? playerStrums : cpuStrums;
					var receptorX = strums.members[Math.floor(Math.abs(daNote.noteData))].x;
					var receptorY = strums.members[Math.floor(Math.abs(daNote.noteData))].y + (Note.swagWidth / 6);

					var pseudoY:Float = daNote.offsetY + (downMult * -((Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2))));

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
						daNote.flipY = true;
						if ((daNote.parent != null && daNote.parent.wasGoodHit)
							&& daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center
							&& (KadeEngineData.botplay || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
						{
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
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
							var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
							swagRect.y = (center - daNote.y) / daNote.scale.y;
							swagRect.height -= swagRect.y;
							daNote.clipRect = swagRect;
						}
					}

					//bbpanzu
					if (!daNote.mustPress && daNote.wasGoodHit && daNote.noteStyle != 'nuggetP')
					{
						if (SONG.notes[Math.floor(curStep / 16)] != null)
						{
							if (health > 0.04 && SONG.songDrains && KadeEngineData.settings.data.mechanics)
								health -= hpDrain;
	
							if (SONG.notes[Math.floor(curStep / 16)].altAnim)
									dad.altAnimSuffix = '-alt';
							else
									dad.altAnimSuffix = '';

							if(!daNote.doubleNote)
								dad.sing(daNote.noteData);
							else{
								print("OMG DOUBLE NOTE THANKS CAROL AND WHITTY DATE WEEK FOR THIS CODE");
								trail(dad);
							}
								
							if (songHas3Characters && thirdCharacter.turn && !daNote.doubleNote)
								thirdCharacter.sing(daNote.noteData);
	
							camSingMove(daNote.noteData, true);
						}

						if (daNote.noteStyle == 'apple')
						{
							if (!daNote.isSustainNote)
								CoolUtil.sound('bite', 'shared');
							health -= difficultiesStuff["appleHealthLoss"][storyDifficulty];

							FlxTween.color(dad, 0.5, FlxColor.GREEN, FlxColor.WHITE);
						}

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
						{
							noteMiss(daNote.noteData, daNote);
						}
		
						daNote.visible = false;
						daNote.kill();
						notes.remove(daNote, true);
					}
				});
			}

		if (!inCutscene)
			input();

		if (KadeEngineData.settings.data.mechanics && SONG.song == 'Staff Only') //if mechanics are enabled and its janitor song
		{
			if (dad.animation.curAnim.name == 'attack' && dad.animation.curAnim.curFrame >= 6 && !didDamage)
				{
					didDamage = true;
					health += difficultiesStuff['mopHealthLoss'][storyDifficulty];
					boyfriend.animacion('hurt');
					FlxG.camera.shake(0.007, 0.25);
					CoolUtil.sound('janitorHit', 'shared');
					new FlxTimer().start(1, function(_){ 
						didDamage = false; 
						canPause = true;});
				}
		}

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
				FlxG.camera.zoom += 0.02;
				camHUD.zoom += 0.06;
				cameraBopBeat = Std.parseFloat(event.value);

			case "bop":
				FlxG.camera.zoom += 0.04;
				camHUD.zoom += 0.12;

			case "zoom change":
				defaultCamZoom += Std.parseFloat(event.value);

			case "turn pixel":
				turnPixel(!isExpellinTime);

			case "animation":
				if (event.value2 == 'bf') boyfriend.animacion(event.value);
				else dad.animacion(event.value);

			case "monday time":
				mondayTime((event.value == 'true' ? true : false));

			case "change character":
				changeCharacter(event.value2, event.value);

			case "shot":
				dad.animacion('shooting');
				FlxG.camera.zoom += 0.08;
				camHUD.zoom += 0.24;
				FlxG.camera.shake(0.007, 2);
				chromatic(0.05, 0, true, 0, 0.5);

			// im autistic ok
			/*case "Speed Change":
			{
				var targetSpeed:Float = SONG.speed + event.value;
				print("[Old Speed: " + SONG.speed + " | New speed: " + targetSpeed);
				if (songStarted)
				{
					notes.forEach((daNote) -> {
						daNote.updateSustainScale(targetSpeed / SONG.speed);
					});
				}
				SONG.speed += event.value;
			}*/

			// not autistic anymore :)  - Galo
			// fuck you - sanco
			// i was being nice you piece of shit - galo

			//case "Speed Change Neg":
			//	changeSpeed(SONG.speed -= event.value);

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
					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;

					paused = true;

					FlxG.sound.music.stop();
					vocals.stop();

					FlxG.sound.playMusic(Paths.music('freakyMenu', 'preload'), KadeEngineData.settings.data.musicVolume);
					MusicBeatState.switchState(new menus.MainMenuState());

					if (SONG.validScore)
						Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}
				else
				{
					
					// adjusting the song name to be compatible
					var songFormat = StringTools.replace(PlayState.storyPlaylist[0], " ", "-");
					switch (songFormat) {
						case 'Dad-Battle': songFormat = 'Dadbattle';
						case 'Philly-Nice': songFormat = 'Philly';
					}

					var poop:String = Highscore.formatSong(songFormat, storyDifficulty);

					print('LOADING NEXT SONG');
					print(poop);

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;


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
			var noteDiff:Float = -(daNote.strumTime - Conductor.songPosition);
			vocals.volume = (KadeEngineData.settings.data.lockSong ? 1 : KadeEngineData.settings.data.musicVolume);
			var placement:String = Std.string(combo);
	
			var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
			coolText.screenCenter();
			coolText.x = FlxG.width * 0.55;
			coolText.y -= 350;
			coolText.cameras = [camHUD];
	
			var rating:FlxSprite = new FlxSprite();
			rating.visible = !isExpellinTime;
			var score:Float = 350;

			var daRating = daNote.rating;

			switch(daRating)
			{
				case 'shit':
					score = -300;
					combo = 0;
					misses++;
					
					//bbpanzu
					if (daNote.noteStyle != 'nuggetP' && daNote.noteStyle != 'apple')
						health -= 0.2;
					shits++;

					totalNotesHit -= 1;
				case 'bad':
					daRating = 'bad';
					score = 0;

					//bbpanzu
					if (daNote.noteStyle != 'nuggetP' && daNote.noteStyle != 'apple')
						health -= 0.06;
					bads++;
						
					totalNotesHit += 0.50;
				case 'good':
					daRating = 'good';
					score = 200;
					goods++;
					if (health < 2 && daNote.noteStyle != 'nuggetP' && daNote.noteStyle != 'apple')
						health += 0.04;

					totalNotesHit += 0.75;
				case 'sick':
					if (health < 2 && daNote.noteStyle != 'nuggetP' && daNote.noteStyle != 'apple')
						health += 0.1;
						
					totalNotesHit += 1;
					sicks++;
			}

			noteSick(daNote, daRating);

			if (daRating != 'shit' || daRating != 'bad')
				{
					songScore += Math.round(score);
					songScoreDef += Math.round(ConvertScore.convertScore(noteDiff));
			
					if (!isPixel)
					{
						rating.frames = Paths.getSparrowAtlas('gameplay/ratings', 'shared');
						rating.animation.addByPrefix('idle', daRating, 0, true);
						rating.animation.play('idle', true);
					}
					else
						rating.loadGraphic(Paths.image('gameplay/pixel/' + daRating, 'shared'));
					
					if (KadeEngineData.settings.data.changedHit)
					{
						rating.x = KadeEngineData.settings.data.changedHitX;
						rating.y = KadeEngineData.settings.data.changedHitY;
					}
					else
					{
						rating.screenCenter(Y);
						rating.y += 50;
						rating.x = coolText.x - 225;
					}
					rating.acceleration.y = 100;
					rating.velocity.y -= 100;
					rating.velocity.x -= FlxG.random.int(0, 10);
	
					if(!KadeEngineData.botplay) 
						add(rating);
			
					if (!isPixel)
							rating.setGraphicSize(Std.int(rating.width * 0.7));
						else{
							rating.antialiasing = false;
							rating.setGraphicSize(Std.int(rating.width * 6 * 0.7));
						}

					rating.cameras = [camHUD];

					var seperatedScore:Array<Int> = [];
			
					var comboSplit:Array<String> = (combo + "").split('');

					// make sure we have 3 digits to display (looks weird otherwise lol)
					if (comboSplit.length == 1)
					{
						seperatedScore.push(0);
						seperatedScore.push(0);
					}
					else if (comboSplit.length == 2)
						seperatedScore.push(0);

					for(i in 0...comboSplit.length)
					{
						var str:String = comboSplit[i];
						seperatedScore.push(Std.parseInt(str));
					}
			
					var daLoop:Int = 0;
					for (i in seperatedScore)
					{
						var numScore = new FlxSprite();
						if (!isPixel)
						{
							numScore.frames = Paths.getSparrowAtlas((isPixel ? 'gameplay/pixel/' : 'gameplay/') + 'numbers', 'shared');
							numScore.animation.addByPrefix('idle', 'numbers', 0, true);
							numScore.animation.play('idle', true, false, Std.int(i));
						}
						else
							numScore.loadGraphic(Paths.image('gameplay/pixel/num' + Std.int(i)));
						numScore.screenCenter();
						numScore.x = rating.x + (43 * daLoop) + 25;
						numScore.y += 150;
						numScore.cameras = [camHUD];
						numScore.visible = !isExpellinTime;

						if (!isPixel)
								numScore.setGraphicSize(Std.int(numScore.width * 0.5));
							else{
								numScore.antialiasing = false;
								numScore.setGraphicSize(Std.int(numScore.width * 6));
							}
						
						numScore.updateHitbox();
			
						numScore.acceleration.y = FlxG.random.int(200, 300);
						numScore.velocity.y -= FlxG.random.int(150, 160);
						add(numScore);
			
						FlxTween.tween(numScore, {alpha: 0}, 0.1, {
							onComplete: function(_)
							{
								numScore.destroy();
							},
							startDelay: Conductor.crochet * 0.001
						});
			
						daLoop++;
					}
			
					FlxTween.tween(rating, {alpha: 0}, 0.1, {startDelay: Conductor.crochet * 0.001, onComplete: function(twen:FlxTween)
					{
						rating.destroy();
					}});
			
					curSection += 1;
				}
		}	

		// THIS FUNCTION JUST FUCKS WIT HELD NOTES AND BOTPLAY/REPLAY (also gamepad shit)

	private function keyShit():Void // I've invested in emma stocks - now with kade engine 1.6.2 input :sunglasses: -sanco
		{
			// control arrays, order L D R U
			var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
			var pressArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
			var releaseArray:Array<Bool> = [controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R];
			var keynameArray:Array<String> = ['left', 'down', 'up', 'right'];
			
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
						note.kill();
						notes.remove(note, true);
						note.destroy();
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
		keyShit();

		#if debug
		//funny joke for croop x
		if (FlxG.keys.justPressed.U) cock = !cock;
		if (cock) misses++;

		if (FlxG.keys.justPressed.ONE)
			endSong();

		debugEditors();
		#end

		if (FlxG.keys.justPressed.SPACE && !KadeEngineData.botplay)
			eatApple();	

		if (KadeEngineData.botplay && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;

		if (FlxG.keys.justPressed.NINE)
			{
				if (iconP1.animation.curAnim.name == 'bf-old')
					iconP1.animation.play(SONG.player1);
				else
					iconP1.animation.play('bf-old');
			}
	}

	function noteMiss(direction:Int = 1, daNote:Note = null):Void
	{
		//bbpanzu
		if (boyfriend.stunned || (daNote.noteStyle == 'nuggetP' || daNote.noteStyle == 'apple'))
			return;

		//bbpanzu
		switch (daNote.noteStyle)
		{
			case 'gum':
				gumNoteMechanic(daNote);
			case 'b': //b is for BULLET
				health -= 1;
				boyfriend.animacion('hurt');
		}

		vocals.volume = 0;
		health -= 0.04 + 0.075;

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
			health -= 0.04 + 0.075;
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
	
				if (!note.isSustainNote)
					sectionNoteHits++;
	
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
						if (!note.isSustainNote)
							actions++;
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
	
					if (!note.doubleNote)
						boyfriend.sing(note.noteData);
					else{
						print("OMG DOUBLE NOTE THANKS CAROL AND WHITTY DATE WEEK FOR THIS CODE");
						trail(boyfriend);
					}
	
					camSingMove(note.noteData, false);
	
					playerStrums.forEach(function(spr:FlxSprite)
					{
						if (Math.abs(note.noteData) == spr.ID && cantPressArray[spr.ID])
							spr.animation.play('confirm', true);
					});
					
					note.wasGoodHit = true;
					vocals.volume = (KadeEngineData.settings.data.lockSong ? 1 : KadeEngineData.settings.data.musicVolume);
		
					note.kill();
					notes.remove(note, true);
					note.destroy();
	
					updateAccuracy();
				}
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
				FlxG.camera.zoom += 0.02;
				camHUD.zoom += 0.06;
			}

		super.stepHit();
	}

	var shownCredits:Bool = false;

	override function beatHit()
	{
		super.beatHit();

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

			if (curBeat >= 108)
			{
				var sans = stage.backgroundSprites.members[1];

				if (sans.alpha == 0 && sans != null)
					FlxTween.tween(sans, {alpha: 0.25}, 1, {ease:FlxEase.sineOut});

				if (curBeat >= 112)
					sans.destroy();
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

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
		}	 

		bop();

		if (curBeat >= 4 && !shownCredits)
			{
				shownCredits = true;

				var author:String = switch (SONG.song)
				{
					case 'Nugget':				   "Enzo & TheGalo X";
					case 'Monday' | 'Staff Only':  "RealG";
					case 'Expelled' | 'Cash Grab': "KrakenPower";
					case 'Nugget de Polla':        "TheGalo X";
					default:					   "no author lmao";
				}

				var creditPage = new SongCreditsSprite(0, SONG.song, author);
				creditPage.y = -creditPage.height;
				creditPage.cameras = [camHUD];
				creditPage.screenCenter(X);
				creditPage.x -= 200;
				add(creditPage);

				FlxTween.tween(creditPage, {y: -250}, 1, {ease: FlxEase.expoOut, onComplete: function(_)
				{
					new FlxTimer().start(0.5, function(_)
						{
							FlxTween.tween(creditPage, {y: -600}, 1, {ease: FlxEase.expoIn, onComplete: function(_)
								{
									creditPage.destroy();
								}});
						});
				}});
			}

		if (curBeat % 8 == 0)
			{
				print("section");

				noteComboMechanic();
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
						forceNoteComboMechanic();
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
					case 260:
						forceNoteComboMechanic();
				}
			}
	}

	var blackScreenForNuggetOmgLongAssVariable:FlxSprite;

	function bop():Void
		{
			if (KadeEngineData.settings.data.distractions)
			{
				if (FlxG.camera.zoom < FlxG.camera.zoom + 0.015 && curBeat % cameraBopBeat == 0)
					{
						FlxG.camera.zoom += 0.02;
						camHUD.zoom += 0.06;
					}

				if (curBeat % 2 == 0)
					{
						iconP1.scale.set(1.1, 1.1);
						iconP1.angle = -10;
						iconP2.scale.set(1.1, 1.1);
						iconP2.angle = 10;
						
						if (SONG.leftSide)
							{
								if (healthBar.percent > 80)
									FlxTween.color(iconP1, 0.25, FlxColor.RED, FlxColor.WHITE);
						
								if (healthBar.percent < 20)
									FlxTween.color(iconP2, 0.25, FlxColor.RED, FlxColor.WHITE);
							}
						else
							{
								if (healthBar.percent < 20)
									FlxTween.color(iconP1, 0.25, FlxColor.RED, FlxColor.WHITE);
						
								if (healthBar.percent > 80)
									FlxTween.color(iconP2, 0.25, FlxColor.RED, FlxColor.WHITE);
							}
						
						iconP1.updateHitbox();
						iconP2.updateHitbox();
					}
			}
			
			#if GF
			if (curBeat % 1 == 0)
				gf.dance();
			#end

			dad.dance();

			if (songHas3Characters)
				thirdCharacter.dance();
			
			if(dad.canIdle){
				dadcamX = 0;
				dadcamY = 0;
			}

			boyfriend.dance();

			if(boyfriend.canIdle){
				bfcamX = 0;
				bfcamY = 0;
			}
		}

	function die():Void
		{
			boyfriend.stunned = true;

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

			if (changedSpeed)
				SONG.speed = originalSongSpeed;

			if (SONG.song == 'Staff Only')
				openSubState(new substates.JanitorDeathSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			else
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

			function focusOnCharacter(character:String):Void
				{
					if (!canTweenCam || SONG.song == 'Nugget de Polla')
						return;

					switch(character)
					{
						case 'dad':
							camFollow.setPosition(dad.camPos[0], dad.camPos[1]);
							camFollow.y += dadcamY;
							camFollow.x += dadcamX;
						case 'bf':
							camFollow.setPosition(boyfriend.camPos[0], boyfriend.camPos[1]);
							camFollow.x += bfcamX;
							camFollow.y += bfcamY;
						#if GF	
						case 'gf':	camFollow.setPosition(gf.getMidpoint().x, gf.getMidpoint().y);	
						#end
						default:
							return;
					}

				}

			function noteSick(daNote:Note, daRating:String = ""):Void
				{
					//bbpanzu
					if (!KadeEngineData.settings.data.distractions || (daNote.noteStyle == 'nuggetP' && KadeEngineData.botplay))
						return;

					var sploosh:NoteSplash = new NoteSplash(daNote.x, playerStrums.members[daNote.noteData].y, daNote.noteStyle);

					//bbpanzu
					if (daNote.noteStyle == 'nuggetP')
						sploosh.color = 0x199700;

					if (daNote.noteStyle == 'apple')
						sploosh.color = FlxColor.RED;

					if (daRating == 'sick' && daNote.noteStyle != 'gum')
					{
						add(sploosh);
						sploosh.cameras = [camHUD];

						sploosh.animation.play('splash ' + FlxG.random.int(0, 1) + " " + daNote.noteData);
					}
					else if (daNote.noteStyle == 'gum') //because gum splashes should appear everytime and not only if the rating is sick :)
					{
						add(sploosh);
						sploosh.cameras = [camHUD];

						sploosh.animation.play('splash');
					}

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
						noteSick(daNote);

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

			function noteComboMechanic():Void
				{
					//si:    no hay distracciones   o   no hay musica generada   o   la seccion es null   o   las notas apretadas de la seccion es menor o igual a 0    o   es el turno de bf   o   hay botplay  :      la funcion no se hace
					if (!KadeEngineData.settings.data.distractions || !generatedMusic || PlayState.SONG.notes[Std.int(curStep / 16)] == null || sectionNoteHits <= 0 || PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection || KadeEngineData.botplay || isExpellinTime)
						return;

					print("sectionEnd, doing combo mechanic");
	
					//i really like creating a new .hx for every fucking thing that i make
					noteCombo = new NoteCombo();
					noteCombo.cameras = [camHUD];
					noteCombo.text = sectionNoteHits + " Note Combo!";
					add(noteCombo);

					sectionNoteHits = 0;

					//i want to make this a sprite but i dont know how :(
					//i think i have to make the numbers a font and the "Note Combo!" a sprite
					//no that will look crappy
					//ill just keep it as a font, its a less crappy and easier way 

					//goes to the left
					FlxTween.tween(noteCombo, {x: noteCombo.x - 300}, 2, {ease: FlxEase.sineOut, onComplete: function(_)
						{
							print("killing notecombo");
							noteCombo.kill();
						}});

					FlxTween.tween(noteCombo, {alpha: 0}, 1, {ease: FlxEase.sineOut, startDelay: 0.5});
				}

			function forceNoteComboMechanic():Void //duplicated, im such a funny guy
				{
					//si:    no hay distracciones   o   no hay musica generada   o   la seccion es null   o   las notas apretadas de la seccion es menor o igual a 0    o   es el turno de bf   o   hay botplay  :      la funcion no se hace
					if (!KadeEngineData.settings.data.distractions || !generatedMusic || PlayState.SONG.notes[Std.int(curStep / 16)] == null || sectionNoteHits <= 0 || KadeEngineData.botplay || isExpellinTime)
						return;

					trace('Notes left: ${notes.length}.');

					print("sectionEnd, doing combo mechanic");
	
					//i really like creating a new .hx for every fucking thing that i make
					noteCombo = new NoteCombo();
					noteCombo.cameras = [camHUD];
					noteCombo.text = sectionNoteHits + " Note Combo!";
					add(noteCombo);

					sectionNoteHits = 0;

					//i want to make this a sprite but i dont know how :(
					//i think i have to make the numbers a font and the "Note Combo!" a sprite
					//no that will look crappy
					//ill just keep it as a font, its a less crappy and easier way 

					//goes to the left
					FlxTween.tween(noteCombo, {x: noteCombo.x - 300}, 2, {ease: FlxEase.sineOut, onComplete: function(_)
						{
							print("killing notecombo");
							noteCombo.kill();
						}});

					FlxTween.tween(noteCombo, {alpha: 0}, 1, {ease: FlxEase.sineOut, startDelay: 0.5});
				}

			function camSingMove(direction:Int, isDad:Bool):Void
				{
					if (!KadeEngineData.settings.data.camMove)
						return;
					
					//    0 = left   -   1 = down   -   2 = up   -   3 = right
					// y + = abajo ||| y - = arriba

					if (isDad)
						{
							switch (direction)
							{
								case 2: 
									dadcamX = 0;
									dadcamY = -camOffset;
								case 3:
									dadcamX = camOffset;
									dadcamY = 0;
								case 1:
									dadcamX = 0;
									dadcamY = camOffset;
								case 0:
									dadcamX = -camOffset;
									dadcamY = 0;
							}
						}
					else
						{
							switch (direction)
							{
								case 2:
									bfcamX = 0;
									bfcamY = -camOffset;
								case 3:
									bfcamX = camOffset;
									bfcamY = 0;
								case 1:
									bfcamX = 0;
									bfcamY = camOffset;
								case 0:
									bfcamX = -camOffset;
									bfcamY = 0;
							}
						}
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

					FlxG.camera.shake(shakeValue);

					chromVal = value;

					if (tween)
						FlxTween.tween(this, {chromVal: toValue}, time);
				}

			function print(v:Dynamic)
				{
					//i dunno Niz told me that removing trace's would improve performance
			
					return;

					//trace(v);
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

			function camZoom(x:Float = 0, y:Float = 0, zoom:Float = null, time:Float = 0):Void
				{
					//camFollow.setPosition(); //OJSDOGAOESRHOIGHOAIEHRIODJVOLAJNERDKLHNTGAHERIOLSHGFKLJSAEDNRFLGKWHNERPOIYHGTOIWEDLRGHJKOLAESDRG FUCK


				}

			function eatApple():Void
				{
					if (actions <= 0 || actions > 3)
						return;

					CoolUtil.sound('bite', 'shared');
					actions--;
					health += difficultiesStuff["appleHealthGain"][storyDifficulty];
					FlxTween.color(boyfriend, 0.5, FlxColor.GREEN, FlxColor.WHITE);
					camSpot(boyfriend.getGraphicMidpoint().x - 100, boyfriend.getGraphicMidpoint().y, defaultCamZoom + 0.3, 0.5);
				}

			function dialogue():Void
			{
				var dialogueCam:FlxCamera;
				dialogueCam = new FlxCamera();
				dialogueCam.bgColor.alpha = 0;
				FlxG.cameras.add(dialogueCam);

				new FlxTimer().start(0.25, function(_)
				{
					trace("Before dialogue created");

					inCutscene = true;
					camHUD.alpha = 0;
					var dialogueSpr:DialogueBox = new DialogueBox(CoolUtil.getDialogue());
					dialogueSpr.scrollFactor.set();
					dialogueSpr.finishThing = startCountdown;
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

				var trail:flixel.addons.effects.FlxTrail = new flixel.addons.effects.FlxTrail(char, null, 1, 100, 1);
				insert(members.indexOf(char) - 1, trail); //LOVE YOU SANCO
				FlxTween.tween(trail, {alpha: 0}, 1, {onComplete: function(_)	trail.destroy()	});
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

						if (KadeEngineData.settings.data.flashing) FlxG.cameras.flash();

						scoreTxt.visible = false;

					}});
				}
				else
				{
					FlxTween.tween(pixelShit, {PIXEL_FACTOR: 256 * 8}, getTimeFromBeats(SECTIONS, 2), {onComplete: function(_)
						{
							canPause = true;

							trace("Pixel Shader disabled.");

							if (KadeEngineData.settings.data.flashing) FlxG.cameras.flash();
	
							filters.remove(shaderFilter);
							FlxG.game.setFilters(filters);

							scoreTxt.visible = true;
						}});
				}
			}

			//sanco is gonna laugh his ass off when he sees this - galo
			// what the fuck is this shit galo - sanco
			// ... - galo
			
			private function mondayTime(turnOn:Bool):Void //shitty name
			{
				if (SONG.song != 'Monday' || !KadeEngineData.settings.data.distractions)
					return;

				/*
				bg0 = room
				bg1 = light
				bg2 = pixelRoom
				bg3 = pixelLight
				*/

				#if sys
				sys.thread.Thread.create(() ->
				{
				#end

				if (turnOn)
					{
						isPixel = true;
						pixelFolder = 'pixel/';

						stage.backgroundSprites.members[0].alpha = 0.0001;
						stage.backgroundSprites.members[1].alpha = 0.0001;
	
						stage.backgroundSprites.members[2].alpha = 1;
						stage.backgroundSprites.members[3].alpha = 0.6;
	
						changeCharacter('dad', 'protagonist-pixel');
						changeCharacter('bf', 'bf-pixel');

						//changeCharacter(200, 312, true, 	'protagonist-pixel', stage.backgroundSprites.members[3]);
						//changeCharacter(922, 276, false,	'bf-pixel');
	
						dad.setPosition(200, 312);
						boyfriend.setPosition(922, 276);

						/*help sanco
						remove(strumLineNotes);
						strumLineNotes = new FlxTypedGroup<FlxSprite>();
						strumLineNotes.cameras = [camHUD];
						add(strumLineNotes);

						generateStaticArrows(0);
						generateStaticArrows(1);
						*/
					}
					else
					{
						isPixel = false;
						pixelFolder = '';

						stage.backgroundSprites.members[2].alpha = 0.0001;
						//stage.backgroundSprites.members[3].alpha = 0.0001; //shit crashes with alpha 0.0001 for some reason. I believe it is because of the blend effect
	
						stage.backgroundSprites.members[0].alpha = 1;
						stage.backgroundSprites.members[1].alpha = 0.9;
	
						changeCharacter('dad', 'protagonist');
						changeCharacter('bf', 'bf');

						//changeCharacter(100, 250, true, 	'protagonist', stage.backgroundSprites.members[1]);
						//changeCharacter(680, 212, false,	'bf');
	
						dad.setPosition(100, 250);
						boyfriend.setPosition(680, 212);

						/*help sanco
						remove(strumLineNotes);
						strumLineNotes = new FlxTypedGroup<FlxSprite>();
						strumLineNotes.cameras = [camHUD];
						add(strumLineNotes);

						generateStaticArrows(0);
						generateStaticArrows(1);
						*/
					}

				#if sys
				});
				#end
			}
}