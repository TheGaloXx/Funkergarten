package states;

import funkin.Conductor;
import openfl.Assets;
import funkin.MusicBeatState;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import data.KadeEngineData;

class TitleState extends MusicBeatState
{
	private var logo:FlxSprite;
	private var bf:FlxSprite;
	private var protagonist:FlxSprite;
	private var bucket:FlxSprite;
	private var screen:FlxSprite;

	private var canPressSomething:Bool = false;

	override public function create():Void
	{
		super.create();

		CoolUtil.title("Main Menu");
		CoolUtil.presence(null, Language.get('Discord_Presence', 'title_menu'), false, 0, null);

		FlxG.sound.playMusic(Paths.music('freakyMenu', 'preload'), 0);
		FlxG.sound.music.fadeIn(3, 0, 0.7);
		Conductor.changeBPM(91 * 2);

		createSprites();

		FlxG.camera.fade(FlxColor.BLACK, 1, true, function() canPressSomething = true);
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		iconShit();

		if ((controls.ACCEPT || FlxG.mouse.justPressed) && canPressSomething)
		{
			canPressSomething = false;

			FlxTween.tween(protagonist, {x: -600}, 1, {ease: FlxEase.sineIn});
			FlxTween.tween(bf, {x: FlxG.width + 575}, 1, {ease: FlxEase.sineIn});
			FlxTween.tween(bucket, {y: FlxG.height}, 1, {ease: FlxEase.sineOut});
			FlxG.camera.fade(FlxColor.BLACK, 1, false);

			CoolUtil.sound('confirmMenu', 'preload', 0.7);

			new FlxTimer().start(1, function(_)
			{
				if (KadeEngineData.settings.data.language == null)
					funkin.MusicBeatState.switchState(new LanguageState());
				else
				{
					Language.populate();
					Assets.getLibrary("shared");
					MusicBeatState.switchState(new states.MainMenuState());
				}
			});
		}

		super.update(elapsed);
	}

	private function iconShit():Void
	{
		final isFullscreen = Std.string(KadeEngineData.settings.data.fullscreen);
		final isSelected = Std.string(CoolUtil.overlaps(screen));

		screen.animation.play(isFullscreen + isSelected);
		
		if (CoolUtil.overlaps(screen))
		{
			if (FlxG.mouse.justPressed && canPressSomething)
			{
				canPressSomething = false;
				KadeEngineData.settings.data.fullscreen = !KadeEngineData.settings.data.fullscreen;
				FlxG.fullscreen = KadeEngineData.settings.data.fullscreen;
				KadeEngineData.flush();

				new FlxTimer().start(1, function(_) canPressSomething = true);
			}
		}
	}

	private function createSprites():Void
	{
		final tex = Paths.getSparrowAtlas('menu/title_assets', 'preload');

		var bg = new FlxSprite();
		bg.frames = tex;
		bg.animation.addByPrefix('idle', 'bg', 0, false);
		bg.animation.play('idle');
		bg.updateHitbox();
		bg.screenCenter();
		bg.active = false;
		add(bg);

		logo = new FlxSprite(0, -50).loadGraphic(Paths.image('menu/logo', 'preload'));
		logo.screenCenter(X);
		logo.active = false;
		add(logo);

		bf = new FlxSprite();
		bf.frames = tex;
		bf.animation.addByPrefix('idle', 'bf', 0, false);
		bf.animation.play('idle');
		bf.updateHitbox();
		bf.setPosition(FlxG.width + 600, FlxG.height - bf.height + 5);
		bf.active = false;
		add(bf);
		FlxTween.tween(bf, {x: FlxG.width - bf.width + 25}, 1, {ease: FlxEase.sineOut});

		protagonist = new FlxSprite();
		protagonist.frames = tex;
		protagonist.animation.addByPrefix('idle', 'protagonist', 0, false);
		protagonist.animation.play('idle');
		protagonist.updateHitbox();
		protagonist.setPosition(-600, FlxG.height - protagonist.height + 5);
		protagonist.active = false;
		add(protagonist);
		FlxTween.tween(protagonist, {x: 0}, 1, {ease: FlxEase.sineOut, onComplete: function(_) CoolUtil.sound('yay', 'preload', 0.3)});

		bucket = new FlxSprite(0, FlxG.height);
		bucket.frames = tex;
		bucket.animation.addByPrefix('idle', 'bucket', 0, false);
		bucket.animation.play('idle');
		bucket.updateHitbox();
		bucket.screenCenter(X);
		bucket.active = false;
		add(bucket);
		FlxTween.tween(bucket, {y: FlxG.height - bucket.height}, 1, {ease: FlxEase.sineOut});
		// CoolUtil.glow(bucket);

		// update this sprite later
		screen = new FlxSprite(FlxG.width - 110, FlxG.height - 110);
		screen.frames = Paths.getSparrowAtlas('menu/screen', 'preload');
		screen.animation.addByIndices('truefalse', 'screen', [0], "", 0, false);
		screen.animation.addByIndices('truetrue', 'screen', [1], "", 0, false);
		screen.animation.addByIndices('falsefalse', 'screen', [2], "", 0, false);
		screen.animation.addByIndices('falsetrue', 'screen', [3], "", 0, false);
		screen.animation.play((KadeEngineData.settings.data.fullscreen ? 'truefalse' : 'falsefalse'));
		screen.active = false;
		add(screen);
	}
}