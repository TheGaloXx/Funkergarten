package menus;

import flixel.util.FlxTimer;
import flixel.input.gamepad.FlxGamepad;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import lime.app.Application;
import flixel.util.FlxColor;

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var comboText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var combo:String = '';

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	override function create()
	{
		CoolUtil.title('Freeplay');
		CoolUtil.presence(null, 'In freeplay', false, 0, null);

		songs = [];

		//fuck da text file
		#if debug
		addSong('DadBattle', 'dad', 1);
		#end

		/*
		I know this sucks, but the mod isn't gonna have that many songs so a little of hardcoding can't hurt, right?

		sanco please improve this :sob:
		*/

		if (KadeEngineData.other.data.beatedSongs.contains('Nugget'))
			addSong('Nugget', 'nugget', 1);

		if (KadeEngineData.other.data.beatedSongs.contains('Monday'))
			addSong('Monday', 'protagonist', 1);

		if (KadeEngineData.other.data.beatedSongs.contains('Cash Grab'))
			addSong('Cash Grab', 'monty', 1);

		if (KadeEngineData.other.data.beatedSongs.contains('Staff Only'))
			addSong('Staff Only', 'janitor', 1);

		if (KadeEngineData.other.data.beatedSongs.contains('Expelled'))
			addSong('Expelled', 'principal', 1);

		if (KadeEngineData.other.data.polla)
			addSong('Nugget de Polla', 'polla', 1);

		var bbbbbbbbbbbbbbbbbbbbbbbbbbbb:Array<String> = [];

		for (i in songs)
			bbbbbbbbbbbbbbbbbbbbbbbbbbbb.push(i.songName);

		trace(bbbbbbbbbbbbbbbbbbbbbbbbbbbb);

		var time = Date.now().getHours();
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menu/paper', 'preload'));
		bg.active = false;
		if (time > 19 || time < 8)
			bg.alpha = 0.7;
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false, true);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			if (songs[i].songCharacter == 'polla')
			{
				icon.loadGraphic(Paths.image('characters/nugget', 'shit'));
				icon.setGraphicSize(150);
				icon.updateHitbox();
			}
			icon.sprTracker = songText;

			iconArray.push(icon);
			add(icon);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		comboText = new FlxText(diffText.x + 100, diffText.y, 0, "", 24);
		comboText.font = diffText.font;
		add(comboText);

		add(scoreText);

		changeSelection();
		changeDiff();

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < (0.7 * KadeEngineData.settings.data.musicVolume))
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = (KadeEngineData.settings.data.esp ? 'PUNTUACION:' : 'HIGHSCORE:') + lerpScore;
		comboText.text = combo + '\n';

		var upP = FlxG.keys.justPressed.UP;
		var downP = FlxG.keys.justPressed.DOWN;
		var accepted = controls.ACCEPT;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.DPAD_UP)
				changeSelection(-1);
			if (gamepad.justPressed.DPAD_DOWN)
				changeSelection(1);

			if (gamepad.justPressed.DPAD_LEFT)
				changeDiff(-1);
			if (gamepad.justPressed.DPAD_RIGHT)
				changeDiff(1);
		}

		if (upP || FlxG.mouse.wheel > 0)
			changeSelection(-1);
		if (downP || FlxG.mouse.wheel < 0)
			changeSelection(1);

		if (FlxG.keys.justPressed.LEFT)
			changeDiff(-1);
		if (FlxG.keys.justPressed.RIGHT)
			changeDiff(1);

		if (controls.BACK)
			MusicBeatState.switchState(new MainMenuState());

		if (accepted)
		{
			// adjusting the song name to be compatible
			var songFormat = StringTools.replace(songs[curSelected].songName, " ", "-");
			switch (songFormat) {
				case 'Dad-Battle': songFormat = 'Dadbattle';
				case 'Philly-Nice': songFormat = 'Philly';
			}
			
			trace(songs[curSelected].songName);

			var poop:String = Highscore.formatSong(songFormat, curDifficulty);

			trace(poop);
			
			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;
			PlayState.storyWeek = songs[curSelected].week;
			trace('CUR WEEK' + PlayState.storyWeek);

			PlayState.tries = 0;

			switch (songs[curSelected].songName)
			{
				//case 'DadBattle' | 'Dadbattle' | 'dadbattle' | 'Dad Battle':	mp4 videos seem to be broken right now
				//	cutscene((FlxG.random.bool(50) ? 'bl' : 'Me llamo sans'), new PlayState()); 	
				default:
					substates.LoadingState.loadAndSwitchState(new PlayState());
			}
		}
	}

	function addSong(name:String, character:String, weekNum:Int = 1):Void
		{
			songs.push(new SongMetadata(name, character, weekNum));
		}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		/* relgaoh told me to remove survivor difficulty :(
		if (curDifficulty < 0)
			curDifficulty = 3;
		if (curDifficulty > 3)
			curDifficulty = 0;
		*/

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		// adjusting the highscore song name to be compatible (changeDiff)
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		switch (songHighscore) {
			case 'Dad-Battle': songHighscore = 'Dadbattle';
			case 'Philly-Nice': songHighscore = 'Philly';
		}
		
		#if !switch
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);
		#end

		diffText.text = CoolUtil.difficultyFromInt(curDifficulty).toUpperCase() + " ";
	}

	function changeSelection(change:Int = 0)
	{
		// NGio.logEvent('Fresh');
		CoolUtil.sound('scrollMenu', 'preload', 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;
		
		// adjusting the highscore song name to be compatible (changeSelection)
		// would read original scores if we didn't change packages
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		switch (songHighscore) {
			case 'Dad-Battle': songHighscore = 'Dadbattle';
			case 'Philly-Nice': songHighscore = 'Philly';
		}

		#if !switch
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			item.color = FlxColor.WHITE;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				item.color = FlxColor.YELLOW;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public function new(song:String, songCharacter:String, week:Int)
	{
		this.songName = song;
		this.songCharacter = songCharacter;
		this.week = week;
	}
}
