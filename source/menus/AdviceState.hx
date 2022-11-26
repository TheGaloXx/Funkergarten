package menus;

import flixel.FlxG;
import Objects.LanguageSpr;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;

class AdviceState extends MusicBeatState
{
	var light:FlxSprite;
	var bf:FlxSprite;
	var	libroEng:LanguageSpr;
	var libroEsp:LanguageSpr; 
	var bg:FlxSprite;
	var text:FlxText;

	var canSelect:Bool = true;
	var canAccept:Bool = true;
	var selectedSomething:Bool = false;

	override function create()
	{
		Application.current.window.title = (Main.appTitle);
		
		super.create();

		libroEsp = new LanguageSpr(560, 60, 'español');
		add(libroEsp);
		
		libroEng = new LanguageSpr(200, 65, 'english');
		add(libroEng);

		bf = new FlxSprite(770, 290);
		bf.frames = Paths.getSparrowAtlas('menu/bf');
		bf.animation.addByIndices('idle', 'bf', [0, 1], "", 24, true);
		bf.animation.addByIndices('hey', 'bf', [2, 3], "", 24, true);
		bf.animation.play('idle');
		bf.antialiasing = FlxG.save.data.antialiasing;
		add(bf);

		light = new FlxSprite(700, -45).loadGraphic(Paths.image('menu/light'));
		light.antialiasing = FlxG.save.data.antialiasing;
		light.alpha = 0.2;
		light.blend = ADD;

		text = new FlxText(5, FlxG.height - 75, 0, "Elige tu idioma (tambien puedes cambiarlo en el menu de opciones).\n\nChoose your language (you can change it from the options menu too).", 12);
		text.scrollFactor.set();
        text.size = 16;
        text.color = FlxColor.BLACK;
        text.alignment = LEFT;
        text.borderStyle = FlxTextBorderStyle.OUTLINE;
		text.borderSize = 1.5;
        text.borderColor = FlxColor.WHITE;
		add(text);
	}

	override function update(elapsed:Float)
	{
		if (canSelect)
			{
				if (FlxG.keys.justPressed.LEFT)
					{
						if (libroEsp.selected)
							FlxG.sound.play(Paths.sound('scrollMenu'));
						selectedSomething = true;

						libroEsp.selected = false;
						libroEng.selected = true;
					}
				else if (FlxG.keys.justPressed.RIGHT)
					{
						if (libroEng.selected)
							FlxG.sound.play(Paths.sound('scrollMenu'));
						selectedSomething = true;

						libroEsp.selected = true;
						libroEng.selected = false;
					}
				else if (FlxG.keys.justPressed.LEFT && FlxG.keys.justPressed.RIGHT)
					{
						selectedSomething = false;

						libroEsp.selected = false;
						libroEng.selected = false;
					}
			}

		if (controls.ACCEPT && canAccept && selectedSomething)
		{
			selectedSomething = false;

			canSelect = false;
			canAccept = false;

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			if (libroEsp.selected)
				FlxG.save.data.esp = true;
			else if (libroEng.selected)
				FlxG.save.data.esp = false;

			add(light);

			bg = new FlxSprite(0, 0).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
			bg.alpha = 0;
			FlxTween.tween(bg, {alpha: 1}, 2);
			add(bg);

			libroEsp.alpha = 1;
			libroEng.alpha = 1;
			FlxTween.tween(libroEsp, {alpha: 0}, 2);
			FlxTween.tween(libroEng, {alpha: 0}, 2);
			remove(text);
			FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom * 4}, 2, {ease: FlxEase.backIn});
			
			bf.animation.play('hey', true);

			new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					
					substates.LoadShared.initial(new menus.MainMenuState());
					//FlxG.switchState(new MainMenuState());
				});
		}

		super.update(elapsed);
	}
}
