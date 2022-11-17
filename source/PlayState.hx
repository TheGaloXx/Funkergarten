package;

import openfl.filters.BitmapFilter;
import openfl.ui.KeyLocation;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import flixel.input.keyboard.FlxKey;
import openfl.Lib;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
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
import lime.app.Application;

#if cpp
import Sys;
import sys.FileSystem;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var weekSong:Int = 0;
	public static var weekScore:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;

	public static var songPosBG:FlxSprite;
	public static var songPosBar:FlxBar;

	var songLength:Float = 0;
	var kadeEngineWatermark:FlxText;

	private var vocals:FlxSound;

	public var originalX:Float;

	public static var dad:Character;

	public static var songHas3Characters:Bool = false;
	public static var thirdCharacter:Character;

	public static var gf:Character;
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

	var camOffset:Int = (FlxG.save.data.camMove ? 30 : 0);
	private var camFollow:FlxObject;

	public static var strumLineNotes:FlxTypedGroup<FlxSprite> = null;
	public static var playerStrums:FlxTypedGroup<FlxSprite> = null;
	public static var cpuStrums:FlxTypedGroup<FlxSprite> = null;

	private var curSong:String = "";

	public var health:Float = 1; // making public because sethealth doesnt work without it
	private var combo:Int = 0;
	public static var misses:Int = 0;
	public static var campaignMisses:Int = 0;
	public var accuracy:Float = 0.00;
	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;


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
	
	// Per song additive offset
	public static var songOffset:Float = 0;
	// BotPlay text
	private var botPlayState:FlxText;

	var curBeatText:FlxText;

	public static var highestCombo:Int = 0;

	private var executeModchart = false;

	var noteSplash:NoteSplash;

	var storyDifficultyText:String;

	public var hpDrain:Float = 0.04;

	//BULLSHIT CODE BRUH
	var lastNumber:Float;
	var trySpr:Try;
	var tries:Try;
	var tries2:Try;

	var noteCombo:NoteCombo;
	var sectionEnd:Bool = false;
	var sectionNoteHits:Int = 0;

	var stage:Stage;

	//shaders
	var filters:Array<BitmapFilter> = [];
	var chromVal:Float = 0;
	var defaultChromVal:Float = 0;

	var originalWindowX:Float = Lib.application.window.x;
	var originalWindowY:Float = Lib.application.window.y;

	var apple1:Apple;
	var apple2:Apple;
	var apple3:Apple;

	public static var originalSongSpeed:Float;
	public static var changedSpeed:Bool = false;

	//retrospecter goes brrrrrrrrrrrrr
	var healthDrainPoison:Float = 0.025;
	var poisonStacks:Int = 0;

	//gum mechanic *blushes*
	//var gumTrap:GumTrap;
	var cantPressArray:Array<Bool> = [true, true, true, true];
	var gumTrapTime:Float;
	
	public function addObject(object:FlxBasic) { add(object); }
	public function removeObject(object:FlxBasic) { remove(object); }

	var actions:Int;

	override public function create()
	{
		instance = this;

		switch (storyDifficulty)
		{
			case 0:
				healthDrainPoison = 0;
			case 1:
				healthDrainPoison = 0.025;
			case 2:
				healthDrainPoison = 0.05;
			case 3:
				healthDrainPoison = 0.1;
		}

		if (FlxG.save.data.flashing && FlxG.save.data.canAddShaders)
		{
			FlxG.game.filtersEnabled = true;
			filters.push(chromaticAberration);
		}

		#if debug
		flixel.addons.studio.FlxStudio.create();
		#end

		Application.current.window.title = (Main.appTitle + ' - Loading...');

		if (FlxG.save.data.botplay)
			FlxG.save.data.practice = false;
		
		if (FlxG.save.data.fpsCap > 290)
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(800);
		
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		if (!isStoryMode)
		{
			sicks = 0;
			bads = 0;
			shits = 0;
			goods = 0;
		}

		misses = 0;

		// pre lowercasing the song name (create)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();

		#if cpp
		executeModchart = FileSystem.exists(Paths.lua(songLowercase  + "/modchart"));
		#end
		#if !cpp
		executeModchart = false; // FORCE disable for non cpp targets
		#end

		print('Mod chart: ' + executeModchart + " - " + Paths.lua(songLowercase + "/modchart"));

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		if (FlxG.save.data.flashing && FlxG.save.data.canAddShaders)
		{
			setChrome(0);
			camGame.setFilters(filters);
			camGame.filtersEnabled = true;
		}

		FlxCamera.defaultCameras = [camGame];

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

		print('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: ' + FlxG.save.data.frames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: ' + Conductor.timeScale + '\nBotPlay : ' + FlxG.save.data.botplay);

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
			default:
				songHas3Characters = false;
		}

		gf = new Character(stage.gfX, stage.gfY, 'gf');
		gf.scrollFactor.set(0.95, 0.95);
		add(gf);

		dad = new Character(stage.dadX, stage.dadY, SONG.player2);
		add(dad);

		if (songHas3Characters)
		{
			thirdCharacter = new Character(stage.thirdCharacterX, stage.thirdCharacterY, 'monty');
			thirdCharacter.turn = false;
			add(thirdCharacter);
		}

		boyfriend = new Boyfriend(stage.bfX, stage.bfY, SONG.player1);
		add(boyfriend);

		switch (curStage)
		{
			case 'room':
				remove(stage.bg2);
				add(stage.bg2);
			case 'newRoom':
				remove(stage.bg2);
				add(stage.bg2);
				remove(stage.bg3);
				add(stage.bg3);
		}

		if (dad.curCharacter == 'nugget' && curStage == 'stage')
			{
				dad.setPosition(184, 366);
			}

		print('uh ' + FlxG.save.data.frames);

		print("SF CALC: " + Math.floor((FlxG.save.data.frames / 60) * 1000));

		Conductor.songPosition = -5000;
		
		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		
		if (FlxG.save.data.downscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		cpuStrums = new FlxTypedGroup<FlxSprite>();

		generateSong(SONG.song);

		print('generated');

		switch(storyDifficulty)
		{
			case 0:
				storyDifficultyText = "EASY";
			case 1:
				storyDifficultyText = "NORMAL";
			case 2:
				storyDifficultyText = "HARD";
			case 3:
				storyDifficultyText = "SURVIVOR";
			default:
				storyDifficultyText = "Difficulty Name";
		}

		Application.current.window.title = (Main.appTitle + ' - ' + SONG.song + " [" + storyDifficultyText + "]");

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(boyfriend.getGraphicMidpoint().x - 300, boyfriend.getGraphicMidpoint().y);

		add(camFollow);


		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('gameplay/healthBar'));
		if (FlxG.save.data.downscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		if (SONG.leftSide)
			{
				healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, LEFT_TO_RIGHT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this, 'health', 0, 2);
				healthBar.scrollFactor.set();
				healthBar.createFilledBar(dad.curColor, boyfriend.curColor);
				add(healthBar);
			}
		else
			{
				healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this, 'health', 0, 2);
				healthBar.scrollFactor.set();
				healthBar.createFilledBar(dad.curColor, boyfriend.curColor);
				add(healthBar);
			}

		// Add Kade Engine watermark
		kadeEngineWatermark = new FlxText(4,healthBarBG.y + 50, 0, SONG.song + " - " + CoolUtil.difficultyFromInt(storyDifficulty), 16);
		kadeEngineWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		add(kadeEngineWatermark);

		if (FlxG.save.data.downscroll)
			kadeEngineWatermark.y = FlxG.height * 0.9 + 45;

		// Literally copy-paste of the above, fu
		botPlayState = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (FlxG.save.data.downscroll ? 100 : -100), 0, "BOTPLAY", 20);
		botPlayState.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		botPlayState.scrollFactor.set();
		botPlayState.borderSize = 1.5;
		if(FlxG.save.data.botplay) 
			add(botPlayState);

		curBeatText = new FlxText(botPlayState.x, botPlayState.y + (FlxG.save.data.downscroll ? 50 : -50), 0, "Beat: ", 20);
		curBeatText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		curBeatText.scrollFactor.set();
		curBeatText.borderSize = 1.25;
		#if debug
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

		scoreTxt = new FlxText(FlxG.width / 2 - 335, healthBarBG.y + 35, 0, "", 20);
		scoreTxt.borderSize = 1.25;
		scoreTxt.scrollFactor.set();
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		add(scoreTxt);

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

		if (isStoryMode)
		{
			switch (StringTools.replace(curSong," ", "-").toLowerCase())
			{
				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					startCountdown();
			}
		}

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN,handleInput);

		//shaders
		if (FlxG.save.data.flashing && FlxG.save.data.canAddShaders)
			{
				switch (curSong)
				{
					default:
						//chromVal = 0.001;
						//defaultChromVal = 0.001;
				}
			}

		if (!FlxG.save.data.distractions)
			FlxG.save.data.camMove = false;

		apple1 = new Apple(0, 0);
		apple2 = new Apple(0, 0);
		apple3 = new Apple(0, 0);

		apple1.cameras = [camHUD];
		apple2.cameras = [camHUD];
		apple3.cameras = [camHUD];

		apple1.setPosition(0, FlxG.height - apple1.height - 1);
		apple2.setPosition(apple1.x + apple1.width + 5, apple1.y);
		apple3.setPosition(apple2.x + apple2.width + 5, apple1.y);

		add(apple1);
		add(apple2);
		add(apple3);

		super.create();
	}

	var startTimer:FlxTimer;

	#if cpp
	public static var luaModchart:ModchartState = null;
	#end

	function startCountdown():Void
	{
		goTries();

		new FlxTimer().start(1.1, function(tmr:FlxTimer)
			{
				inCutscene = false;

				generateStaticArrows(0);
				generateStaticArrows(1);


				#if cpp
				// pre lowercasing the song name (startCountdown)
				var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
				switch (songLowercase) {
					case 'dad-battle': songLowercase = 'dadbattle';
					case 'philly-nice': songLowercase = 'philly';
				}
				if (executeModchart)
				{
					luaModchart = ModchartState.createModchartState();
					luaModchart.executeState('start',[songLowercase]);
				}
				#end

				startedCountdown = true;
				Conductor.songPosition = 0;
				Conductor.songPosition -= Conductor.crochet * 5;

				var swagCounter:Int = 0;

				startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
				{

					switch (swagCounter)
					{
						case 0:
							FlxG.sound.play(Paths.sound('intro3'), 0.6);
							boyfriend.dance();
							dad.dance();
							gf.dance();
							if (songHas3Characters)
								thirdCharacter.dance();
						case 1:
							var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gameplay/ready'));
							ready.scrollFactor.set();
							ready.updateHitbox();
							ready.screenCenter();
							add(ready);

							boyfriend.dance();
							dad.dance();
							if (songHas3Characters)
								thirdCharacter.dance();
							gf.dance();

							FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									ready.destroy();
								}
							});

							FlxG.sound.play(Paths.sound('intro2'), 0.6);

						case 2:
							var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gameplay/set'));
							set.scrollFactor.set();
							set.screenCenter();
							add(set);

							boyfriend.dance();
							dad.dance();
							if (songHas3Characters)
								thirdCharacter.dance();
							gf.dance();
							
							FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									set.destroy();
								}
							});

							FlxG.sound.play(Paths.sound('intro1'), 0.6);

						case 3:
							var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gameplay/go'));
							go.scrollFactor.set();
							go.updateHitbox();
							go.screenCenter();
							add(go);

							boyfriend.dance();
							dad.dance();
							if (songHas3Characters)
								thirdCharacter.dance();
							gf.dance();

							FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									go.destroy();
								}
							});

							FlxG.sound.play(Paths.sound('introGo'), 0.6);
							canPause = true;
					}

					swagCounter += 1;
				}, 5);
			});
	}

	var creditPage:SongCreditsSprite;
	var author:String;
	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	private function handleInput(evt:KeyboardEvent):Void { // this actually handles press inputs

		if (FlxG.save.data.botplay || paused)
			return;

		// first convert it from openfl to a flixel key code
		// then use FlxKey to get the key's name based off of the FlxKey dictionary
		// this makes it work for special characters

		@:privateAccess
		var key = FlxKey.toStringMap.get(Keyboard.__convertKeyCode(evt.keyCode));
	
		var binds:Array<String> = [FlxG.save.data.leftBind,FlxG.save.data.downBind, FlxG.save.data.upBind, FlxG.save.data.rightBind];

		var data = -1;
		
		switch(evt.keyCode) // arrow keys
		{
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}

		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}

		if (evt.keyLocation == KeyLocation.NUM_PAD)
		{
			print(String.fromCharCode(evt.charCode) + " " + key);
		}

		if (data == -1)
			return;

		var dataNotes = [];

		if (notes != null){
		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && daNote.noteData == data)
				dataNotes.push(daNote);
		}); // Collect notes that can be hit
		}


		dataNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime)); // sort by the earliest note
		
		if (dataNotes.length != 0)
		{
			var coolNote = dataNotes[0];

			goodNoteHit(coolNote);
			var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
		}
		
	}

	var songStarted = false;

	function startSong():Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
		{
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		}

		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		if (FlxG.save.data.songPosition)
		{
			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('gameplay/healthBar'));
			if (FlxG.save.data.downscroll)
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
			if (FlxG.save.data.downscroll)
				songName.y -= 3;
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);

			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];
		}

		new FlxTimer().start(3, function(tmr:FlxTimer)
			{
				FlxTween.tween(kadeEngineWatermark, {alpha: 0}, 2, {onComplete: function(twn:FlxTween)
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

		var noteData:Array<SwagSection>;

		noteData = songData.notes;

		// Per song offset check
		#if cpp
			// pre lowercasing the song name (generateSong)
			var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
				switch (songLowercase) {
					case 'dad-battle': songLowercase = 'dadbattle';
					case 'philly-nice': songLowercase = 'philly';
				}

			var songPath = 'assets/data/' + songLowercase + '/';
			
			for(file in sys.FileSystem.readDirectory(songPath))
			{
				var path = haxe.io.Path.join([songPath, file]);
				if(!sys.FileSystem.isDirectory(path))
				{
					if(path.endsWith('.offset'))
					{
						print('Found offset file: ' + path);
						songOffset = Std.parseFloat(file.substring(0, file.indexOf('.off')));
						break;
					}else {
						print('Offset file not found. Creating one @: ' + songPath);
						sys.io.File.saveContent(songPath + songOffset + '.offset', '');
					}
				}
			}
		#end

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + songOffset;
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				//bbpanzu
				var daNoteStyle:String = songNotes[3];

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				//bbpanzu
				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, false, daNoteStyle);

				if (!gottaHitNote && FlxG.save.data.Optimize)
					continue;

				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					//bbpanzu
					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true, false, daNoteStyle);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						if (notestrumtimes1.contains(Math.round(sustainNote.strumTime))){
							sustainNote.doubleNote = true;
						}
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
		for (i in 0...4)
		{
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			babyArrow.frames = Paths.getSparrowAtlas('gameplay/NOTE_assets');
			babyArrow.animation.addByPrefix('green', 'arrowUP');
			babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
			babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
			babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

			babyArrow.antialiasing = FlxG.save.data.antialiasing;
			babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

			switch (Math.abs(i))
			{
				case 0:
					babyArrow.x += Note.swagWidth * 0;
					babyArrow.animation.addByPrefix('static', 'arrowLEFT');
					babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
				case 1:
					babyArrow.x += Note.swagWidth * 1;
					babyArrow.animation.addByPrefix('static', 'arrowDOWN');
					babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
				case 2:
					babyArrow.x += Note.swagWidth * 2;
					babyArrow.animation.addByPrefix('static', 'arrowUP');
					babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
				case 3:
					babyArrow.x += Note.swagWidth * 3;
					babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
					babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			switch (player)
			{
				case 0:
					if (FlxG.save.data.middlescroll)
						babyArrow.visible = false;
					cpuStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 100;
			babyArrow.x += ((FlxG.width / 2) * player);
			
			if (FlxG.save.data.middlescroll)
				{
					babyArrow.x -= 275;
				}
			
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
						// spr.x += 700;
					});
					playerStrums.forEach(function(spr:FlxSprite)
					{
						if (!FlxG.save.data.midscroll)
							FlxTween.tween(spr, {x: spr.x -= 650, y: spr.y}, 1, {ease: FlxEase.quartOut});
						// spr.x -= 600;
					});
			}
	}

	override function openSubState(SubState:FlxSubState)
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
			Application.current.window.title = (Main.appTitle + ' - ' + SONG.song + " [" + storyDifficultyText + "]");
			
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

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

	var healthGain:Float;

	override public function update(elapsed:Float)
	{	
		//curBeatText.text = "Beat: " + curBeat + " | dadCanSing: " + dad.canSing + " | dadCanIdle: " + dad.canIdle;

		//retrospecter goes brrrrrrr
		health -= healthDrainPoison * poisonStacks * elapsed; // Gotta make it fair with different framerates :)

		switch (storyDifficulty)
		{
			case 0: 
				healthGain = 2;
			case 1:
				healthGain = 1.5;
			case 2:
				healthGain = 0.5;
			case 3:
				healthGain = 1;
		}

		if (actions < 0)
			actions = 0;
		if (actions > 3)
			actions = 3;

		switch(actions)
		{
			case 0:
				apple1.visible = false;
				apple2.visible = false;
				apple3.visible = false;
			case 1:
				apple1.visible = true;
				apple2.visible = false;
				apple3.visible = false;
			case 2:
				apple1.visible = true;
				apple2.visible = true;
				apple3.visible = false;
			case 3:
				apple1.visible = true;
				apple2.visible = true;
				apple3.visible = true;

		}

		if (FlxG.keys.justPressed.SPACE && actions > 0 && actions <= 3)
			{
				FlxG.sound.play(Paths.sound('bite'), 1);
				actions--;
				health += healthGain;
				FlxTween.color(boyfriend, 0.5, FlxColor.GREEN, FlxColor.WHITE);
				camSpot(boyfriend.getGraphicMidpoint().x - 100, boyfriend.getGraphicMidpoint().y, defaultCamZoom + 0.3, 0.5);
			}		

		if (FlxG.save.data.flashing && FlxG.save.data.canAddShaders)
			setChrome(chromVal);

		if (FlxG.save.data.botplay && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;
		
		#if cpp
		if (executeModchart && luaModchart != null && songStarted)
		{
			luaModchart.setVar('songPos',Conductor.songPosition);
			luaModchart.setVar('hudZoom', camHUD.zoom);
			luaModchart.setVar('cameraZoom',FlxG.camera.zoom);
			luaModchart.executeState('update', [elapsed]);

			/*for (i in 0...strumLineNotes.length) {
				var member = strumLineNotes.members[i];
				member.x = luaModchart.getVar("strum" + i + "X", "float");
				member.y = luaModchart.getVar("strum" + i + "Y", "float");
				member.angle = luaModchart.getVar("strum" + i + "Angle", "float");
			}*/

			FlxG.camera.angle = luaModchart.getVar('cameraAngle', 'float');
			camHUD.angle = luaModchart.getVar('camHudAngle','float');

			if (luaModchart.getVar("showOnlyStrums",'bool'))
			{
				healthBarBG.visible = false;
				if (kadeEngineWatermark != null)
					kadeEngineWatermark.visible = false;
				healthBar.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				scoreTxt.visible = false;
			}
			else
			{
				healthBarBG.visible = true;
				if (kadeEngineWatermark != null)
					kadeEngineWatermark.visible = true;
				healthBar.visible = true;
				iconP1.visible = true;
				iconP2.visible = true;
				scoreTxt.visible = true;
			}

			var p1 = luaModchart.getVar("strumLine1Visible",'bool');
			var p2 = luaModchart.getVar("strumLine2Visible",'bool');

			for (i in 0...4)
			{
				strumLineNotes.members[i].visible = p1;
				if (i <= playerStrums.length)
					playerStrums.members[i].visible = p2;
			}
		}

		#end

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

		scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, accuracy);

		if (controls.PAUSE && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;
			vocals.pause();
			FlxG.sound.music.pause();

			openSubState(new substates.PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}


		if (FlxG.keys.justPressed.SEVEN)
		{
			if (changedSpeed)
				SONG.speed = originalSongSpeed;
			FlxG.switchState(new substates.ChartingState());
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN,handleInput);
			#if cpp
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		if (FlxG.save.data.distractions)
		{
			var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
			var ass:Float = FlxMath.lerp(1, iconP1.angle, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));

			iconP1.angle = ass;
			iconP1.scale.set(mult, mult);
			iconP1.updateHitbox();

			var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
			var ass:Float = FlxMath.lerp(1, iconP2.angle, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
			iconP2.angle = ass;
			iconP2.scale.set(mult, mult);
			iconP2.updateHitbox();
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

		#if debug
		if (FlxG.keys.justPressed.SIX)
		{
			if (changedSpeed)
				SONG.speed = originalSongSpeed;
			FlxG.switchState(new menus.AnimationDebug(SONG.player2));
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN,handleInput);
			#if cpp
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		if (FlxG.keys.justPressed.ZERO)
		{
			if (changedSpeed)
				SONG.speed = originalSongSpeed;
			FlxG.switchState(new menus.AnimationDebug(SONG.player1));
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN,handleInput);
			#if cpp
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		if (FlxG.keys.justPressed.EIGHT)
			{
				if (changedSpeed)
					SONG.speed = originalSongSpeed;
				FlxG.switchState(new menus.StageDebug(curStage));
				FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN,handleInput);
				#if cpp
				if (luaModchart != null)
				{
					luaModchart.die();
					luaModchart = null;
				}
				#end
			}

		#end

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
					// Conductor.songPosition += FlxG.elapsed * 1000;
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			
			#if cpp
			if (luaModchart != null)
				luaModchart.setVar("mustHit",PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			#end

			if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				//dad turn
				focusOnCharacter('dad');
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				//bf turn
				focusOnCharacter('bf');
			}
		}

		FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
		camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
	
 
		FlxG.watch.addQuick("curBeat:", curBeat);
		FlxG.watch.addQuick("curStep", curStep);
		FlxG.watch.addQuick("Song speed:", SONG.speed);

		if (health <= 0 && !FlxG.save.data.practice && !FlxG.save.data.botplay)
		{
			die();
		}
		else if (health <= 0 && (FlxG.save.data.practice || FlxG.save.data.botplay))
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
				notes.forEachAlive(function(daNote:Note)
				{	

					// instead of doing stupid y > FlxG.height
					// we be men and actually calculate the time :)
					if (daNote.tooLate)
					{
						daNote.active = false;
						daNote.visible = false;
					}
					else
					{
						daNote.visible = true;
						daNote.active = true;
					}
					
					if (!daNote.modifiedByLua)
						{
							if (FlxG.save.data.downscroll)
							{
								if (daNote.mustPress)
									daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2));
								else
									daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2));
								if(daNote.isSustainNote)
								{
									// Remember = minus makes notes go up, plus makes them go down
									if(daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
										daNote.y += daNote.prevNote.height;
									else
										daNote.y += daNote.height / 2;
	
									// If not in botplay, only clip sustain notes when properly hit, botplay gets to clip it everytime
									if(!FlxG.save.data.botplay)
									{
										if((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit) && daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (strumLine.y + Note.swagWidth / 2))
										{
											// Clip to strumline
											var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
											swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
											swagRect.y = daNote.frameHeight - swagRect.height;
	
											daNote.clipRect = swagRect;
										}
									}else {
										var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
										swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
										swagRect.y = daNote.frameHeight - swagRect.height;
	
										daNote.clipRect = swagRect;
									}
								}
							}else
							{
								if (daNote.mustPress)
									daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2));
								else
									daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2));
								if(daNote.isSustainNote)
								{
									daNote.y -= daNote.height / 2;
	
									if(!FlxG.save.data.botplay)
									{
										if((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit) && daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
										{
											// Clip to strumline
											var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
											swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
											swagRect.height -= swagRect.y;
	
											daNote.clipRect = swagRect;
										}
									}else {
										var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
										swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
										swagRect.height -= swagRect.y;
	
										daNote.clipRect = swagRect;
									}
								}
							}
						}
		
					//bbpanzu
					if (!daNote.mustPress && daNote.wasGoodHit && daNote.noteStyle != 'nuggetP')
					{
						if (SONG.notes[Math.floor(curStep / 16)] != null)
							{
								if (health > 0.04 && SONG.songDrains && FlxG.save.data.mechanics)
									health -= hpDrain;
	
								if (SONG.notes[Math.floor(curStep / 16)].altAnim)
									{
										// 0 = left - 1 = down - 2 = up - 3 = right
										// y + = abajo ||| y - = arriba

										dad.altAnimSuffix = '-alt';
									}
								else
									{
										if(!daNote.doubleNote)
											dad.sing(daNote.noteData);
										else
											print("OMG DOUBLE NOTE THANKS CAROL AND WHITTY DATE WEEK FOR THIS CODE");
										
										if (songHas3Characters && thirdCharacter.turn && !daNote.doubleNote)
											thirdCharacter.sing(daNote.noteData);
									}
	
								camSingMove(daNote.noteData, true);
							}

						if (daNote.noteStyle == 'apple')
							{
								if (!daNote.isSustainNote)
									FlxG.sound.play(Paths.sound('bite'), 1);

								switch (storyDifficulty)
								{
									case 1:
										health -= 0.25;
									case 2:
										health -= 0.5;
									case 3:
										health -= 0.5;
								}
								FlxTween.color(dad, 0.5, FlxColor.GREEN, FlxColor.WHITE);
							}
	
						#if cpp
						if (luaModchart != null)
							luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
						#end

						dad.holdTimer = 0;

						if (songHas3Characters && thirdCharacter.turn)
							thirdCharacter.holdTimer = 0;
	
						if (SONG.needsVoices)
							vocals.volume = 1;
	
						daNote.active = false;


						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}

					if (daNote.mustPress && !daNote.modifiedByLua)
					{
						daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
						daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
						if (!daNote.isSustainNote)
							daNote.angle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
						daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}
					else if (!daNote.wasGoodHit && !daNote.modifiedByLua)
					{
						daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
						daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
						if (!daNote.isSustainNote)
							daNote.angle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
						daNote.alpha = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}
					
					if (daNote.isSustainNote)
						daNote.x += daNote.width / 2 + 17;
	
					if ((daNote.mustPress && daNote.tooLate && !FlxG.save.data.downscroll || daNote.mustPress && daNote.tooLate && FlxG.save.data.downscroll) && daNote.mustPress)
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
			keyShit();


		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end

		super.update(elapsed);
	}

	function endSong():Void
	{
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN,handleInput);

		if (isStoryMode)
			campaignMisses = misses;

		if (FlxG.save.data.fpsCap > 290)
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(290);

		#if cpp
		if (luaModchart != null)
		{
			luaModchart.die();
			luaModchart = null;
		}
		#end

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

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;

					paused = true;

					FlxG.sound.music.stop();
					vocals.stop();
					if (FlxG.save.data.scoreScreen){
						openSubState(new substates.ResultsScreen());
						persistentUpdate = false;
						persistentDraw = true;
					}
					else
					{
						FlxG.save.data.tries = 0;
						FlxG.sound.playMusic(Paths.music('freakyMenu'));
						
						FlxG.switchState(new menus.MainMenuState());
					}

					#if cpp
					if (luaModchart != null)
					{
						luaModchart.die();
						luaModchart = null;
					}
					#end

					menus.StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, menus.StoryMenuState.weekUnlocked.length - 1))] = true;

					if (SONG.validScore)
					{
						Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
					}

					FlxG.save.data.weekUnlocked = menus.StoryMenuState.weekUnlocked;
					FlxG.save.flush();
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

				if (FlxG.save.data.scoreScreen){
					openSubState(new substates.ResultsScreen());
					persistentUpdate = false;
					persistentDraw = true;
				}
				else{
					FlxG.save.data.tries = 0;
					
					FlxG.switchState(new menus.FreeplayState());
				}
			}
	}

	private function popUpScore(daNote:Note):Void
		{
			var noteDiff:Float = -(daNote.strumTime - Conductor.songPosition);
			vocals.volume = 1;
			var placement:String = Std.string(combo);
	
			var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
			coolText.screenCenter();
			coolText.x = FlxG.width * 0.55;
			coolText.y -= 350;
			coolText.cameras = [camHUD];
	
			var rating:FlxSprite = new FlxSprite();
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
					ss = false;
					shits++;

					totalNotesHit -= 1;
				case 'bad':
					daRating = 'bad';
					score = 0;

					//bbpanzu
					if (daNote.noteStyle != 'nuggetP' && daNote.noteStyle != 'apple')
						health -= 0.06;
					ss = false;
					bads++;
						
					totalNotesHit += 0.50;
				case 'good':
					daRating = 'good';
					score = 200;
					ss = false;
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
			
					var pixelShitPart1:String = "";
					var pixelShitPart2:String = '';
			
					if (curStage.startsWith('school'))
					{
						pixelShitPart1 = 'weeb/pixelUI/';
						pixelShitPart2 = '-pixel';
					}
			
					rating.loadGraphic(Paths.image('gameplay/' + pixelShitPart1 + daRating + pixelShitPart2));
					rating.screenCenter(Y);
					rating.y += 50;
					rating.x = coolText.x - 225;
					
					if (FlxG.save.data.changedHit)
					{
						rating.x = FlxG.save.data.changedHitX;
						rating.y = FlxG.save.data.changedHitY;
					}
					rating.acceleration.y = 100;
					rating.velocity.y -= 100;
					rating.velocity.x -= FlxG.random.int(0, 10);
	
					if(!FlxG.save.data.botplay) 
						add(rating);
			
					if (!curStage.startsWith('school'))
					{
						rating.setGraphicSize(Std.int(rating.width * 0.5));
						rating.antialiasing = FlxG.save.data.antialiasing;
					}
					rating.updateHitbox();

					rating.cameras = [camHUD];

					var seperatedScore:Array<Int> = [];
			
					var comboSplit:Array<String> = (combo + "").split('');

					if (combo > highestCombo)
						highestCombo = combo;

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
						var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
						numScore.screenCenter();
						numScore.x = rating.x + (43 * daLoop) + 25;
						numScore.y += 150;
						numScore.cameras = [camHUD];

						if (!curStage.startsWith('school'))
						{
							numScore.antialiasing = FlxG.save.data.antialiasing;
							numScore.setGraphicSize(Std.int(numScore.width * 0.4));
						}
						numScore.updateHitbox();
			
						numScore.acceleration.y = FlxG.random.int(200, 300);
						numScore.velocity.y -= FlxG.random.int(150, 160);
						add(numScore);
			
						FlxTween.tween(numScore, {alpha: 0}, 0.1, {
							onComplete: function(tween:FlxTween)
							{
								numScore.destroy();
							},
							startDelay: Conductor.crochet * 0.001
						});
			
						daLoop++;
					}
			
					coolText.text = Std.string(seperatedScore);
					// add(coolText);
			
					FlxTween.tween(rating, {alpha: 0}, 0.1, {startDelay: Conductor.crochet * 0.001, onComplete: function(twen:FlxTween)
					{
						coolText.destroy();
						rating.destroy();
					}});
			
					curSection += 1;
				}
		}	

		// THIS FUNCTION JUST FUCKS WIT HELD NOTES AND BOTPLAY/REPLAY (also gamepad shit)

		private function keyShit():Void // I've invested in emma stocks
			{
				// control arrays, order L D R U
				var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
				var pressArray:Array<Bool> = [
					controls.LEFT_P,
					controls.DOWN_P,
					controls.UP_P,
					controls.RIGHT_P
				];

				#if cpp
				if (luaModchart != null){
				if (controls.LEFT_P){luaModchart.executeState('keyPressed',["left"]);};
				if (controls.DOWN_P){luaModchart.executeState('keyPressed',["down"]);};
				if (controls.UP_P){luaModchart.executeState('keyPressed',["up"]);};
				if (controls.RIGHT_P){luaModchart.executeState('keyPressed',["right"]);};
				};
				#end
		 
				
				// Prevent player input if botplay is on
				if(FlxG.save.data.botplay)
				{
					holdArray = [false, false, false, false];
					pressArray = [false, false, false, false];
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
		 
				if (KeyBinds.gamepad && !FlxG.keys.justPressed.ANY)
				{
					// PRESSES, check for note hits
					if (pressArray.contains(true) && generatedMusic)
					{
						boyfriend.holdTimer = 0;
			
						var possibleNotes:Array<Note> = []; // notes that can be hit
						var directionList:Array<Int> = []; // directions that can be hit
						var dumbNotes:Array<Note> = []; // notes to kill later
						var directionsAccounted:Array<Bool> = [false,false,false,false]; // we don't want to do judgments for more than one presses
						
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
											possibleNotes.push(daNote);
											directionList.push(daNote.noteData);
										}
								}
						});

						for (note in dumbNotes)
						{
							FlxG.log.add("killing dumb ass note at " + note.strumTime);
							note.kill();
							notes.remove(note, true);
							note.destroy();
						}
			
						possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

						if (possibleNotes.length > 0)
						{
							if (!FlxG.save.data.ghost)
							{
								for (shit in 0...pressArray.length)
									{ // if a direction is hit that shouldn't be
										if (pressArray[shit] && !directionList.contains(shit))
											noteMiss(shit, null);
									}
							}
							for (coolNote in possibleNotes)
							{
								if (pressArray[coolNote.noteData])
								{
									if (mashViolations != 0)
										mashViolations--;
									scoreTxt.color = FlxColor.WHITE;
									var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
									goodNoteHit(coolNote);
								}
							}
						}
						else if (!FlxG.save.data.ghost)
							{
								for (shit in 0...pressArray.length)
									if (pressArray[shit])
										noteMiss(shit, null);
							}
					}
				}
				notes.forEachAlive(function(daNote:Note)
				{
					if(FlxG.save.data.downscroll && daNote.y > strumLine.y ||
					!FlxG.save.data.downscroll && daNote.y < strumLine.y)
					{
						// Force good note hit regardless if it's too late to hit it or not as a fail safe
						if(FlxG.save.data.botplay && daNote.canBeHit && daNote.mustPress ||
							FlxG.save.data.botplay && daNote.tooLate && daNote.mustPress)
						{
							goodNoteHit(daNote);
							boyfriend.holdTimer = daNote.sustainLength;
						}
					}
				});

				//FUNCION CHARACTER SING AIOSJFGIOLAJDRIOLFAJ Y AGREGAR CAN SING Y CAN IDLE A CHARACTER
				
				if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || FlxG.save.data.botplay))
				{
					if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')){
						boyfriend.dance();
					}
				}
		 
				playerStrums.forEach(function(spr:FlxSprite)
				{
					if (pressArray[spr.ID] && spr.animation.curAnim.name != 'confirm' && cantPressArray[spr.ID] == true)
						spr.animation.play('pressed');
					if (!holdArray[spr.ID])
						spr.animation.play('static');
		 
					if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
					{
						spr.centerOffsets();
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					}
					else
						spr.centerOffsets();
				});
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
				dad.playAnim('singRIGHT', true);

				FlxG.camera.shake(0.007, 0.25);
		}

		vocals.volume = 0;
		health -= 0.04 + 0.075;

		if (combo > 5 && gf.animOffsets.exists('sad'))
		{
			gf.playAnim('sad');
		}

		combo = 0;
		misses++;

		songScore -= 10;

		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

		// 0 = left - 1 = down - 2 = up - 3 = right
		// y + = abajo ||| y - = arriba
		boyfriend.sing(direction, true);

		#if cpp
		if (luaModchart != null)
			luaModchart.executeState('playerOneMiss', [direction, Conductor.songPosition]);
		#end


		updateAccuracy();
	}

	function updateAccuracy() 
		{
			totalPlayed += 1;
			accuracy = Math.max(0,totalNotesHit / totalPlayed * 100);
			accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
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
	
	var mashing:Int = 0;
	var mashViolations:Int = 0;

	function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
		{
			var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

			note.rating = Ratings.CalculateRating(noteDiff, Math.floor((FlxG.save.data.frames / 60) * 1000));
			
			if (controlArray[note.noteData])
			{
				goodNoteHit(note, (mashing > getKeyPresses(note)));
			}
		}

		function goodNoteHit(note:Note, resetMashViolation = true):Void
			{
				if (cantPressArray[note.noteData] == false)
					return;

				if (!note.isSustainNote)
					sectionNoteHits++;

				vocals.volume = 1;

				//bbpanzu
				switch (note.noteStyle)
				{
					case 'nuggetP':
						if (FlxG.save.data.botplay)
							return;
						else
						{
							FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.2, 0.3));
							poisonStacks++;
							boyfriend.animacion('hurt');
						}
					case 'nuggetN':
						poisonStacks = 0;
					case 'gum':
						boyfriend.animacion('dodge');
					case 'b':
						boyfriend.animacion('dodge');
						dad.playAnim('singRIGHT', true);
						FlxG.camera.shake(0.007, 0.25);
					case 'apple':
						if (!note.isSustainNote)
							actions++;
				}

				if (FlxG.save.data.snap && !note.isSustainNote)
					FlxG.sound.play(Paths.sound('extra/SNAP'), 1);

				if (mashing != 0)
					mashing = 0;

				var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

				note.rating = Ratings.CalculateRating(noteDiff);

				if (note.rating == "miss")
					return;	

				if (!resetMashViolation && mashViolations >= 1)
					mashViolations--;

				if (mashViolations < 0)
					mashViolations = 0;

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
						print("OMG DOUBLE NOTE THANKS CAROL AND WHITTY DATE WEEK FOR THIS CODE");

					camSingMove(note.noteData, false);
		
					#if cpp
					if (luaModchart != null)
						luaModchart.executeState('playerOneSing', [note.noteData, Conductor.songPosition]);
					#end

					playerStrums.forEach(function(spr:FlxSprite)
					{
						if (Math.abs(note.noteData) == spr.ID && cantPressArray[spr.ID] == true)
						{
							spr.animation.play('confirm', true);
						}
					});
					
					note.wasGoodHit = true;
					vocals.volume = 1;
		
					note.kill();
					notes.remove(note, true);
					note.destroy();
					
					updateAccuracy();
				}
			}

	override function stepHit()
	{
		super.stepHit();
		
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		#if cpp
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curStep',curStep);
			luaModchart.executeState('stepHit',[curStep]);
		}
		#end

	}

	var shownCredits:Bool = false;

	override function beatHit()
	{
		super.beatHit();

		#if debug
		curBeatText.text = "Beat: " + curBeat;
		#end

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, (FlxG.save.data.downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));
		}

		#if cpp
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curBeat',curBeat);
			luaModchart.executeState('beatHit',[curBeat]);
		}
		#end

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
		}	 

		bop();

		if (curBeat == 1 && !shownCredits)
			{
				shownCredits = true;

				switch (SONG.song)
				{
					case 'Nugget':
						author = "Enzo & TheGalo X";
					case 'Monday':
						author = "RealG";
					default:
						author = "no author lmao";
				}

				creditPage = new SongCreditsSprite(0, SONG.song, author);
				creditPage.y = -creditPage.height;
				creditPage.cameras = [camHUD];
				creditPage.screenCenter(X);
				creditPage.x -= 200;
				add(creditPage);

				FlxTween.tween(creditPage, {y: -250}, 1, {ease: FlxEase.expoOut, onComplete: function(_)
				{
					new FlxTimer().start(0.5, function(tmr:FlxTimer)
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

		if (curSong == 'DadBattle')
			{
				switch (curBeat)
				{
					case 10:
						chromatic(0.0025, 0.005, true, defaultChromVal, 0.3); 
						thirdCharacter.turn = true; //added lol
						dad.turn = false;
					case 20:
						chromatic(0.0425, 0.015, true, defaultChromVal, 1); 
						dad.turn = true;
						camSpot(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y, defaultCamZoom + 0.25, 5);

					case 35:
						chromatic(0.0025, 0.005, false, defaultChromVal, 0.3); 
						thirdCharacter.turn = false;
					case 30:
						changeSpeed(4);
				}
			}

		if (curSong == 'Monday' && FlxG.save.data.distractions)
			{
				switch (curBeat)
				{
					case 4:
						defaultCamZoom += 0.05;
					case 8:
						defaultCamZoom += 0.05;
					case 12:
						defaultCamZoom += 0.05;
					case 14:
						defaultCamZoom -= 0.15;
					case 20:
						defaultCamZoom += 0.05;
					case 24:
						defaultCamZoom += 0.05;
					case 28:
						defaultCamZoom += 0.05;
					case 30:
						defaultCamZoom -= 0.15;
					case 32:
						defaultCamZoom -= 0.05;
					case 44:
						defaultCamZoom += 0.05;
					case 48:
						defaultCamZoom -= 0.05;
					case 60:
						defaultCamZoom += 0.05;
					case 288:
						boyfriend.animacion('hey');
						camSpot(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100, defaultCamZoom + 0.2, 1);
				}
			}

		if (curSong == 'Bopeebo')
			{
				if (curBeat % 8 == 7)
					{
						hey();
					}

				switch (curBeat)
				{
					/*
					case 1:
						changeSpeed(5);
					case 10:
						//changeCharacter(boyfriend.x, boyfriend.y, false, 'dad');
						changeSpeed(2);
					case 20:
						//changeCharacter(dad.x, dad.y, true, 'bf');
						changeSpeed(7);
					*/
				}
			}

		if (FlxG.save.data.distractions)
			{
				

			}
		
		if (FlxG.save.data.flashing)
			{

			}

		//bbpanzu
		if (FlxG.save.data.mechanics)
			{

			}

		
	}

	function bop():Void
		{
			if (FlxG.save.data.distractions)
			{
				if (FlxG.camera.zoom < FlxG.camera.zoom + 0.015 && curBeat % 4 == 0)
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
			
			if (curBeat % 1 == 0)
			{
				gf.dance();
			}

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

			if (FlxG.save.data.canAddShaders && FlxG.save.data.flashing)
				{
					setChrome(defaultChromVal);
				}

			if (changedSpeed)
				SONG.speed = originalSongSpeed;

			openSubState(new substates.GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

	function hey():Void
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
			boyfriend.animacion('hey', false);
			FlxTween.color(boyfriend, 0.5, boyfriend.curColor, FlxColor.WHITE);
			gf.playAnim('cheer');
		}
		
	function changeSpeed(newSpeed:Float):Void
		{
			print("[Old Speed: " + SONG.speed + " | New speed: " + newSpeed);

			SONG.speed = newSpeed;

			changedSpeed = true;
		}

		/*
		function newDad(x:Float, y:Float, num:Int, character:String, character2:String):Void
			{
				/**
				 * Load an image from an embedded graphic file.
				 *
				 * Function that creates a new `Dad` character.
				 * @param   x   The `x` position of the new character.
				 * @param   y   The `y` position of the new character.
				 * @param   num      The value of the function.
				 *                  `0` for removing both `characters` and replace for `sprites` of the same characters.
				 * 					`1` for removing `Dad 2` and change `Dad 1`.
				 *                  `2` for removing `Dad` and change `Dad 2`.
				 * 					`3` for changing both `Dad`s.
				 * @param   character     The new character.
				 **/

			/**
			 * Function that changes the `character`.
			 * @param   x   The `x` position of the new character.
			 * @param   y   The `y` position of the new character.
			 * @param   isDad      Changes the target, `true` for changing Dad. `false` for changing Boyfriend.
			 * @param   char     The character to change to.
			 **/

			function changeCharacter(x:Float, y:Float, isDad:Bool, char:String):Void
			{
				//si el que cambia es el enemigo
				if (isDad)
					{
						//si el personaje actual es el nuevo personaje la funcion no se realiza
					   	if (dad.curCharacter == char)
							{
								return;
								print("es el mismo personaje bruh");	
							}
			  
					   	remove(dad);
					   	dad = new Character(x, y, char);
					   	add(dad);
						healthBar.createFilledBar(dad.curColor, boyfriend.curColor);
					   	iconP2.animation.play(char);
					}
					else //si el que cambia es bf
					{
						//si el personaje actual es el nuevo personaje la funcion no se realiza
					   	if (boyfriend.curCharacter == char)
							{
								return;
								print("es el mismo personaje bruh");	
							}
			  
					   	remove(boyfriend);
					   	boyfriend = new Boyfriend(x, y, char);
					   	add(boyfriend);
						healthBar.createFilledBar(dad.curColor, boyfriend.curColor);
					   	iconP1.animation.play(char);
					}
			}

			function focusOnCharacter(character:String):Void
				{
					switch(character)
					{
						case 'dad':
							var offsetX = 0;
							var offsetY = 0;
							
							#if cpp
							if (luaModchart != null)
							{
								offsetX = luaModchart.getVar("followXOffset", "float");
								offsetY = luaModchart.getVar("followYOffset", "float");
							}
							#end

							if (canTweenCam)
								{
									camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - 100 + offsetY);

									camFollow.y += dadcamY;
									camFollow.x += dadcamX;
								}

							#if cpp
							if (luaModchart != null)
								luaModchart.executeState('playerTwoTurn', []);
							#end
							
						case 'bf':
							var offsetX = 0;
							var offsetY = 0;
							#if cpp
							if (luaModchart != null)
							{
								offsetX = luaModchart.getVar("followXOffset", "float");
								offsetY = luaModchart.getVar("followYOffset", "float");
							}
							#end

							if (canTweenCam)
								{
									camFollow.setPosition(boyfriend.getMidpoint().x - 100 + offsetX, boyfriend.getMidpoint().y - 100 + offsetY);

									camFollow.x += bfcamX;
									camFollow.y += bfcamY;
								}

							#if cpp
							if (luaModchart != null)
								luaModchart.executeState('playerOneTurn', []);
							#end
						case 'gf':
							
							if (canTweenCam)
								camFollow.setPosition(gf.getMidpoint().x, gf.getMidpoint().y);
						default:
							return;
					}

				}

			function noteSick(daNote:Note, daRating:String = ""):Void
				{
					//bbpanzu
					if (!FlxG.save.data.distractions || (daNote.noteStyle == 'nuggetP' && FlxG.save.data.botplay))
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

						sploosh.animation.finishCallback = function(name) sploosh.kill();
					}
					else if (daNote.noteStyle == 'gum') //because gum splashes should appear everytime and not only if the rating is sick :)
					{
						add(sploosh);
						sploosh.cameras = [camHUD];

						sploosh.animation.play('splash');

						sploosh.animation.finishCallback = function(name) sploosh.kill();
					}

				}

			function gumNoteMechanic(daNote:Note):Void
				{
					if (!FlxG.save.data.mechanics || FlxG.save.data.botplay)
						return;

					if (cantPressArray[daNote.noteData] == false)
						return;
					else
						cantPressArray[daNote.noteData] = false;

					var gumTrap:GumTrap = new GumTrap(daNote.x, playerStrums.members[daNote.noteData].y);
					gumTrap.cameras = [camHUD];
					gumTrap.animation.play('idle');
					add(gumTrap);

					if (daNote.noteStyle == 'gum')
						noteSick(daNote);

					switch(storyDifficulty)
					{
						case 1:
							gumTrapTime = 3;
						case 2:
							gumTrapTime = 6;
						case 3:
							gumTrapTime = 12;
					}

					new FlxTimer().start(gumTrapTime / 2, function (_)
						{
							gumTrap.animation.play('pre-struggle', true);
						});

					new FlxTimer().start(gumTrapTime, function (_)
						{
							new FlxTimer().start(0.1, function (_){		cantPressArray[daNote.noteData] = true;		});
							gumTrap.animation.play('break', true);
						});
				}

			function goTries():Void
				{
					//THIS CODE IS BULLSHIT BRUH
					FlxG.save.data.tries++;

					trySpr = new Try(-435, 0, false);
					trySpr.cameras = [camHUD];
					add(trySpr);

					if (FlxG.save.data.tries < 10)
						{
							tries = new Try(-435, 0, true);
							tries.animation.play(Std.string(FlxG.save.data.tries), true); 
							tries.cameras = [camHUD];
							add(tries);
						}
					else
						{
							tries2 = new Try(-435, 0, true);
							tries2.cameras = [camHUD];
							add(tries2);
							
							tries = new Try(-435, 0, true);
							tries.cameras = [camHUD];
							add(tries);

							//10 - 19
							if (FlxG.save.data.tries > 9 && FlxG.save.data.tries < 20)
								{
									tries.animation.play('1', true);
									lastNumber = FlxG.save.data.tries - 10;
								} //20 - 29
							else if (FlxG.save.data.tries > 19 && FlxG.save.data.tries < 30)
								{
									tries.animation.play('2', true);
									lastNumber = FlxG.save.data.tries - 20;
								} //30 - 39
							else if (FlxG.save.data.tries > 29 && FlxG.save.data.tries < 40)
								{
									tries.animation.play('3', true);
									lastNumber = FlxG.save.data.tries - 30;
								} //40 - 49
							else if (FlxG.save.data.tries > 39 && FlxG.save.data.tries < 50)
								{
									tries.animation.play('4', true);
									lastNumber = FlxG.save.data.tries - 40;
								}
							else if (FlxG.save.data.tries > 49 && FlxG.save.data.tries < 60)
								{
									tries.animation.play('5', true);
									lastNumber = FlxG.save.data.tries - 50;
								}
							else if (FlxG.save.data.tries > 59 && FlxG.save.data.tries < 70)
								{
									tries.animation.play('6', true);
									lastNumber = FlxG.save.data.tries - 60;
								}
							else if (FlxG.save.data.tries > 69 && FlxG.save.data.tries < 80)
								{
									tries.animation.play('7', true);
									lastNumber = FlxG.save.data.tries - 70;
								}
							else if (FlxG.save.data.tries > 79 && FlxG.save.data.tries < 90)
								{
									tries.animation.play('8', true);
									lastNumber = FlxG.save.data.tries - 80;
								}
							else if (FlxG.save.data.tries > 89 && FlxG.save.data.tries < 100)
								{
									tries.animation.play('9', true);
									lastNumber = FlxG.save.data.tries - 90;
								}
							else if (FlxG.save.data.tries >= 100)
								{
									trySpr.destroy();
									tries.destroy();
									tries2.destroy();
								}
						}

						if (FlxG.save.data.tries < 100 && tries2 != null)
							tries2.animation.play(Std.string(lastNumber), true);

						FlxTween.tween(trySpr, {x: 397.55}, 0.375, {ease: FlxEase.sineOut,  startDelay: 0.1, onComplete: function (a:FlxTween)
							{
								FlxTween.tween(trySpr, {x: 448.2}, 0.41666666666, {ease: FlxEase.sineIn, onComplete: function (a:FlxTween)
									{
										FlxTween.tween(trySpr, {x: 1444.05}, 0.375, {ease: FlxEase.sineOut, onComplete: function (a:FlxTween){
											trySpr.destroy();
										}});
									}});
							}});
				
						FlxTween.tween(tries, {x: 643.7 + 150}, 0.375, {ease: FlxEase.sineOut, startDelay: 0.05, onComplete: function (a:FlxTween)
							{
								FlxTween.tween(tries, {x: 694.35 + 150}, 0.41666666666, {ease: FlxEase.sineIn, onComplete: function (a:FlxTween)
									{
										FlxTween.tween(tries, {x: 1690.2 + 150}, 0.375, {ease: FlxEase.sineOut, onComplete: function (a:FlxTween){
											tries.destroy();
										}});
									}});
							}});
				
						if (FlxG.save.data.tries > 9)
							{
								FlxTween.tween(tries2, {x: 643.7 + 250}, 0.375, {ease: FlxEase.sineOut, onComplete: function (a:FlxTween)
									{
										FlxTween.tween(tries2, {x: 694.35 + 250}, 0.41666666666, {ease: FlxEase.sineIn, onComplete: function (a:FlxTween)
											{
												FlxTween.tween(tries2, {x: 1690.2 + 250}, 0.375, {ease: FlxEase.sineOut, onComplete: function(a:FlxTween){
													tries2.destroy();
												}});
											}});
									}});
							}
				}

			function noteComboMechanic():Void
				{
					//si:    no hay distracciones   o   no hay musica generada   o   la seccion es null   o   las notas apretadas de la seccion es menor o igual a 0    o   es el turno de bf   o   hay botplay  :      la funcion no se hace
					if (!FlxG.save.data.distractions || !generatedMusic || PlayState.SONG.notes[Std.int(curStep / 16)] == null || sectionNoteHits <= 0 || PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection || FlxG.save.data.botplay)
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
					FlxTween.tween(noteCombo, {x: noteCombo.x - 300}, 2, {ease: FlxEase.sineOut, onComplete: function(twn:FlxTween)
						{
							print("killing notecombo");
							noteCombo.kill();
						}});

					FlxTween.tween(noteCombo, {alpha: 0}, 1, {ease: FlxEase.sineOut, startDelay: 0.5});
				}

			function camSingMove(direction:Int, isDad:Bool):Void
				{
					if (!FlxG.save.data.camMove)
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
					if (!FlxG.save.data.canAddShaders || !FlxG.save.data.flashing)
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
					defaultCamZoom = zoom;
					
					if (time > 0)
						{
							new FlxTimer().start(time, function(_)
								{
									canDoCamSpot = true;
									canTweenCam = true; 
									defaultCamZoom = prevCamZoom;
								});
						}
				}

			function camZoom(x:Float = 0, y:Float = 0, zoom:Float = null, time:Float = 0):Void
				{
					//camFollow.setPosition(); //OJSDOGAOESRHOIGHOAIEHRIODJVOLAJNERDKLHNTGAHERIOLSHGFKLJSAEDNRFLGKWHNERPOIYHGTOIWEDLRGHJKOLAESDRG FUCK


				}
}