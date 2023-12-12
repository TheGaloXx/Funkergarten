package states;

import input.Controls.ActionType;
import data.FCs;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxG;
import states.PlayState;

class FreeplayState extends funkin.MusicBeatState
{
	// if you dont want a dedicated file for it, just make a custom struct array lol
	var songData:Array<{song:String, icon:String}> = [
		{
			song: "Monday",
			icon: 'protagonist',
		},
		{
			song: 'Nugget',
			icon: 'nugget',
		},
		{
			song: 'Cash Grab',
			icon: 'monty'
		},
		{
			song: 'Staff Only',
			icon: 'janitor'
		},
		{
			song: 'Expelled',
			icon: 'principal'
		},
		{
			song: 'Nugget de Polla',
			icon: 'polla'
		},
		{
			song: 'Monday Encore',
			icon: 'protagonist-pixel'
		}
	];

	var songs:Array<SongMetadata> = [];

	private static var curSelected:Int = 0;
	public static var curDifficulty:Int = 1;

	var scoreText:flixel.text.FlxText;
	var scoreBG:FlxSprite;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var combo:String = '';

	private var boxes:Array<objects.DialogueBox.IconBox> = [];
	private var camFollow:flixel.FlxObject;
	private var daY:Float;

	override function create()
	{
		Cache.clear();

		camFollow = new flixel.FlxObject(0, 0, 1, 1);
		camFollow.screenCenter(X);
		camFollow.active = false;

		CoolUtil.title('Freeplay');
		CoolUtil.presence(null, Language.get('Discord_Presence', 'freeplay_menu'), false, 0, null);

		songs = [];

		//fuck da text file
		// fuck you too - sanco
		// fuck you too - galo
		#if debug
		for (entry in songData)
		{
			addSong(entry.song, entry.icon);
		}
		#else
		/*
		I know this sucks, but the mod isn't gonna have that many songs so a little of hardcoding can't hurt, right?

		sanco please improve this :sob:

		what the actual fuck - sanco
		slac wanted to be here too - sanco
		*/

		var beatedSongs:Array<Dynamic> = cast data.KadeEngineData.other.data.beatedSongs;

		// lmfao
		for (entry in songData)
		{
			if (beatedSongs.contains(entry.song) && entry.song != "Nugget de Polla")
				addSong(entry.song, entry.icon);

			if (entry.song == "Nugget de Polla" && data.KadeEngineData.other.data.polla) //idk if its workin lol
				addSong(entry.song, entry.icon);

			if (entry.song == "Monday Encore" && beatedSongs.contains('Monday'))
				addSong(entry.song, entry.icon);
		}

		//addSong('Expelled V1', 'principal');
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
			var sprite = new objects.DialogueBox.IconBox(songs[i].songName, songs[i].songCharacter, 0, true);
			sprite.y += 50 + ((sprite.height + 70) * i);
			boxes.push(sprite);
			add(sprite);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		scoreText.active = false;
		scoreText.scrollFactor.set();

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 1, 0xD2000000);
		scoreBG.scale.y = 66;
		scoreBG.updateHitbox();
		scoreBG.antialiasing = false;
		scoreBG.active = false;
		scoreBG.scrollFactor.set();
		add(scoreBG);

		add(scoreText);

		changeSelection();
		changeDiff();

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			funkin.Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);

		lerpScore = Math.floor(flixel.math.FlxMath.lerp(lerpScore, intendedScore, 0.4 * (elapsed * 30)));

		scoreText.x = FlxG.width - scoreText.width - 6;
		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - scoreBG.scale.x / 2;

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		for (i in 0...boxes.length)
			if (i != curSelected)
				boxes[i].x = flixel.math.FlxMath.lerp(objects.DialogueBox.IconBox.daX, boxes[i].x, 0.5 * (elapsed * 30));

		scoreText.text = '${Language.get('FreeplayState', 'score_text')}$lerpScore\n${CoolUtil.difficultyFromInt(curDifficulty).toUpperCase()} $combo';

		camFollow.y = flixel.math.FlxMath.lerp(camFollow.y, daY, 0.5 * (elapsed * 30));
		FlxG.camera.focusOn(camFollow.getPosition());

		input();
	}

	function addSong(name:String, character:String):Void
	{
		songs.push(new SongMetadata(name, character));
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
		intendedScore = data.Highscore.getScore(songHighscore, curDifficulty);
		combo = data.Highscore.getCombo(songHighscore, curDifficulty);
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
		intendedScore = data.Highscore.getScore(songHighscore, curDifficulty);
		combo = data.Highscore.getCombo(songHighscore, curDifficulty);

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
		if (songs.length > 1)
		{
			if (FlxG.mouse.wheel > 0)
				changeSelection(-1);
			if (FlxG.mouse.wheel < 0)
				changeSelection(1);
		}
	}

	override function onActionPressed(action:ActionType)
	{
		switch(action)
		{
			case UI_UP:
				if (songs.length > 1)
					changeSelection(-1);
			case UI_DOWN:
				if (songs.length > 1)
					changeSelection(1);

			case UI_LEFT:
				changeDiff(-1);
			case UI_RIGHT:
				changeDiff(1);

			case BACK:
				funkin.MusicBeatState.switchState(new MainMenuState());
				CoolUtil.sound('cancelMenu', 'preload', 0.5);

			case CONFIRM:
				if (songs[curSelected].songName != 'Expelled')
				{
					var songFormat = StringTools.replace(songs[curSelected].songName, " ", "-");
					PlayState.SONG = funkin.Song.loadFromJson(data.Highscore.formatSong(songFormat, curDifficulty), songs[curSelected].songName, songs[curSelected].songName == 'Nugget de Polla');
					PlayState.isStoryMode = false;
					PlayState.storyDifficulty = curDifficulty;
					PlayState.tries = 0;
					substates.LoadingState.loadAndSwitchState(new PlayState());
				}
				else openSubState(new substates.ExpelledSubState());

			default:
				return;
		}
	}

	override function beatHit() 
	{
		super.beatHit();

		if (curBeat % 2 == 0 && ((curBeat >= 64 && curBeat <= 124) || (curBeat >= 192 && curBeat <= 252)))
			for (spr in boxes) spr.iconBop();
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var songCharacter:String = "";

	public function new(song:String, songCharacter:String)
	{
		this.songName = song;
		this.songCharacter = songCharacter;
	}
}