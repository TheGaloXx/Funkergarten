package states;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import funkin.MusicBeatState;
import data.FCs;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxG;
import states.PlayState;
import substates.LockedSongSubstate;

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
			song: 'Staff Only',
			icon: 'janitor'
		},
		{
			song: 'Cash Grab',
			icon: 'monty'
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
		},
		{
			song: 'Petty Petals',
			icon: 'cindy'
		},
		{
			song: 'Lily Song',
			icon: 'lily'
		},
		{
			song: 'Specimen',
			icon: 'monster'
		}
	];

	var songs:Array<SongMetadata> = [];

	private static var curSelected:Int = 0;
	public static var curDifficulty:Int = 2;

	var scoreText:flixel.text.FlxText;
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
			final condition:Null<Bool> = switch(entry.song)
			{
				case 'Nugget de Polla': data.KadeEngineData.other.data.polla;
				case 'Monday Encore':   beatedSongs.contains('Monday');
				default:                beatedSongs.contains(entry.song);
			};

			// If the song meets the condition to be unlocked, add it
			addSong(entry.song, entry.icon, condition);
		}

		var bg = new flixel.FlxSprite().loadGraphic(Paths.image('bg/classroom', 'shared'));
		bg.active = false;
		CoolUtil.size(bg, 0.6, true, true);
		bg.screenCenter();
		bg.scrollFactor.set(0, 0.05);
		add(bg);

		for (i in 0...songs.length)
		{
			var sprite = new objects.DialogueBox.IconBox(songs[i].songName, songs[i].songCharacter, 0, true, songs[i].unlocked);
			sprite.y += 50 + ((sprite.height + 70) * i);
			boxes.push(sprite);
			add(sprite);
		}

		var scoreBG = new FlxSprite().makeGraphic(1, 1);
		scoreBG.scale.set(FlxG.width, 66);
		scoreBG.updateHitbox();
		scoreBG.antialiasing = false;
		scoreBG.active = false;
		scoreBG.scrollFactor.set();
		scoreBG.color = FlxColor.BLACK;
		scoreBG.alpha = 0.8;
		add(scoreBG);

		scoreText = new FlxText(0, 0, FlxG.width, "", 32);
		scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		scoreText.active = false;
		scoreText.scrollFactor.set();
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

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		for (i in 0...boxes.length)
			if (i != curSelected)
				boxes[i].x = flixel.math.FlxMath.lerp(objects.DialogueBox.IconBox.daX, boxes[i].x, 0.3 * (elapsed * 30));

		scoreText.text = '${Language.get('FreeplayState', 'score_text')}$lerpScore\n${CoolUtil.difficultyFromInt(curDifficulty).toUpperCase()} $combo';

		camFollow.y = flixel.math.FlxMath.lerp(camFollow.y, daY, 0.5 * (elapsed * 30));
		FlxG.camera.focusOn(camFollow.getPosition());

		input();
	}

	private inline function addSong(name:String, character:String, unlocked:Bool):Void
	{
		songs.push(new SongMetadata(name, character, unlocked));
	}

	private inline function changeDiff(change:Int = 0)
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

		scoreText.color = [0xefb058, 0x5083fc, 0x9d1137][curDifficulty];

		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		intendedScore = data.Highscore.getScore(songHighscore, curDifficulty);
		combo = data.Highscore.getCombo(songHighscore, curDifficulty);

		bounceText();
	}

	private function bounceText(size:Float = 1.075):Void
	{
		FlxTween.cancelTweensOf(scoreText, ['scale', 'scale.x', 'scale.y']);
		scoreText.scale.set(size, size);
		FlxTween.tween(scoreText.scale, {x: 1, y: 1}, 0.25, {ease: FlxEase.bounceOut});
	}

	private inline function changeSelection(change:Int = 0)
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

		bounceText();
	}

	private function input():Void
	{
		var up = FlxG.mouse.wheel > 0 || FlxG.keys.justPressed.UP;
		var down = FlxG.mouse.wheel < 0 || FlxG.keys.justPressed.DOWN;
		var left = FlxG.keys.justPressed.LEFT;
		var right = FlxG.keys.justPressed.RIGHT;

		if (up && down)
			up = down = false;
		if (left && right)
			left = right = false;

		if (songs.length > 1)
		{
			if (up)
				changeSelection(-1);
			if (down)
				changeSelection(1);
		}

		if (left)
			changeDiff(-1);
		if (right)
			changeDiff(1);

		if (controls.BACK)
		{
			funkin.MusicBeatState.switchState(new MainMenuState());
			CoolUtil.sound('cancelMenu', 'preload', 0.5);
		}

		if (controls.ACCEPT)
		{
			if (!songs[curSelected].unlocked)
			{
				openSubState(new LockedSongSubstate(songs[curSelected].songName));
			}
			else
			{
				if (songs[curSelected].songName != 'Expelled')
				{
					var songFormat = StringTools.replace(songs[curSelected].songName, " ", "-");
					PlayState.SONG = funkin.Song.loadFromJson(data.Highscore.formatSong(songFormat, curDifficulty), songs[curSelected].songName, songs[curSelected].songName == 'Nugget de Polla');
					PlayState.isStoryMode = false;
					PlayState.storyDifficulty = curDifficulty;
					PlayState.tries = 0;

					MusicBeatState.switchState(new PlayState());
				}
				else openSubState(new substates.ExpelledSubState());
			}
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
	public var unlocked:Bool;

	public function new(song:String, songCharacter:String, unlocked:Bool)
	{
		this.songName = song;
		this.songCharacter = songCharacter;
		this.unlocked = unlocked;
	}
}