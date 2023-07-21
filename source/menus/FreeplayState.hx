package menus;

import flixel.FlxG;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var scoreText:flixel.text.FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var combo:String = '';

	private var boxes:Array<DialogueBox.IconBox> = [];
	private var camFollow:flixel.FlxObject;
	private var daY:Float;

	override function create()
	{
		camFollow = new flixel.FlxObject(0, 0, 1, 1);
		camFollow.screenCenter(X);
		camFollow.active = false;

		CoolUtil.title('Freeplay');
		CoolUtil.presence(null, 'In freeplay', false, 0, null);

		songs = [];

		//fuck da text file
		#if debug
		addSong('DadBattle', 'dad', 1);
		addSong('Monday', 'protagonist', 1);
		addSong('Nugget', 'nugget', 1);
		addSong('Cash Grab', 'monty', 1);
		addSong('Staff Only', 'janitor', 1);
		addSong('Expelled', 'principal', 1);
		addSong('Nugget de Polla', 'polla', 1);
		//addSong('Expelled V1', 'principal', 1);
		#else
		/*
		I know this sucks, but the mod isn't gonna have that many songs so a little of hardcoding can't hurt, right?

		sanco please improve this :sob:
		*/

		if (KadeEngineData.other.data.beatedSongs.contains('Monday'))
			addSong('Monday', 'protagonist', 1);

		if (KadeEngineData.other.data.beatedSongs.contains('Nugget'))
			addSong('Nugget', 'nugget', 1);

		if (KadeEngineData.other.data.beatedSongs.contains('Cash Grab'))
			addSong('Cash Grab', 'monty', 1);

		if (KadeEngineData.other.data.beatedSongs.contains('Staff Only'))
			addSong('Staff Only', 'janitor', 1);

		if (KadeEngineData.other.data.beatedSongs.contains('Expelled'))
			addSong('Expelled', 'principal', 1);

		if (KadeEngineData.other.data.polla)
			addSong('Nugget de Polla', 'polla', 1);

		//addSong('Expelled V1', 'principal', 1);
		#end

		var bg = new flixel.FlxSprite().loadGraphic(Paths.image('bg/classroom', 'shared'));
		bg.active = false;
		CoolUtil.size(bg, 0.6, true, true);
		bg.screenCenter();
		//if (time > 19 || time < 8)
		//	bg.alpha = 0.7;
		bg.scrollFactor.set(0, 0.05);
		add(bg);

		for (i in 0...songs.length)
		{
			var sprite = new DialogueBox.IconBox(songs[i].songName, songs[i].songCharacter, 0, true);
			sprite.y += 50 + ((sprite.height + 70) * i);
			boxes.push(sprite);
			add(sprite);
		}

		var scoreBG = new flixel.FlxSprite(FlxG.width - Std.int(FlxG.width * 0.3), 0).makeGraphic(Std.int(FlxG.width * 0.3), 66, 0xBB000000);
		scoreBG.scrollFactor.set();
		scoreBG.active = false;
		add(scoreBG);

		scoreText = new flixel.text.FlxText(0, 5, FlxG.width, "", 32);
		scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, 0xffffffff, RIGHT);
		scoreText.scrollFactor.set();
		scoreText.active = false;
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

		lerpScore = Math.floor(flixel.math.FlxMath.lerp(lerpScore, intendedScore, 0.4 * (elapsed * 30)));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		for (i in 0...boxes.length)
			if (i != curSelected)
				boxes[i].x = flixel.math.FlxMath.lerp(DialogueBox.IconBox.daX, boxes[i].x, 0.5 * (elapsed * 30));

		scoreText.text = '${Language.get('FreeplayState', 'score_text')} $lerpScore\n${CoolUtil.difficultyFromInt(curDifficulty).toUpperCase()} $combo';

		camFollow.y = flixel.math.FlxMath.lerp(camFollow.y, daY, 0.5 * (elapsed * 30));
		FlxG.camera.focusOn(camFollow.getPosition());

		input();
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

		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);
	}

	function changeSelection(change:Int = 0)
	{
		CoolUtil.sound('scrollMenu', 'preload', 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);

		for (i in 0...boxes.length)
		{
			var spr = boxes[i];
			if (i == curSelected)
			{
				spr.iconBop();
				spr.box.color = flixel.util.FlxColor.YELLOW;
				spr.x = 120;
				daY = spr.box.y + spr.box.height / 2;
			}
			else
				spr.box.color = spr.daColor;
		}
	}

	private function input():Void
	{
		var gamepad:flixel.input.gamepad.FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (songs.length > 1)
			{
				if (gamepad.justPressed.DPAD_UP)
					changeSelection(-1);
				if (gamepad.justPressed.DPAD_DOWN)
					changeSelection(1);
			}

			if (gamepad.justPressed.DPAD_LEFT)
				changeDiff(-1);
			if (gamepad.justPressed.DPAD_RIGHT)
				changeDiff(1);
		}

		if (songs.length > 1)
		{
			if (FlxG.keys.justPressed.UP || FlxG.mouse.wheel > 0)
				changeSelection(-1);
			if (FlxG.keys.justPressed.DOWN || FlxG.mouse.wheel < 0)
				changeSelection(1);
		}

		if (FlxG.keys.justPressed.LEFT)
			changeDiff(-1);
		if (FlxG.keys.justPressed.RIGHT)
			changeDiff(1);

		if (controls.BACK)
			MusicBeatState.switchState(new MainMenuState());

		if (controls.ACCEPT)
		{
			if (songs[curSelected].songName != 'Expelled')
			{
				var songFormat = StringTools.replace(songs[curSelected].songName, " ", "-");
				PlayState.SONG = Song.loadFromJson(Highscore.formatSong(songFormat, curDifficulty), songs[curSelected].songName, songs[curSelected].songName == 'Nugget de Polla');
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;
				PlayState.tries = 0;
				substates.LoadingState.loadAndSwitchState(new PlayState());
			}
			else openSubState(new substates.ExpelledSubState());
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