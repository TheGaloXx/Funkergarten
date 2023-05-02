package menus;

import flixel.FlxG;
import Objects.LanguageSpr;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;

class LanguageState extends MusicBeatState
{
	var protagonist:FlxSprite;
	var	libroEng:LanguageSpr;
	var libroEsp:LanguageSpr; 
	var bg:FlxSprite;
	var text:FlxText;

	var canSelect:Bool = true;
	var canAccept:Bool = true;
	var selectedSomething:Bool = false;

	override function create()
	{
		CoolUtil.title('Language Menu');
		CoolUtil.presence(null, 'Selecting language', false, 0, null);
		
		super.create();

		libroEng = new LanguageSpr(200, 60, 'English');
		add(libroEng);

		libroEsp = new LanguageSpr(FlxG.width - 507.5, 60, 'Espanol');
		add(libroEsp);

		protagonist = new FlxSprite(0, 460);
		protagonist.frames = Paths.getSparrowAtlas('menu/protagonist', 'preload');
		protagonist.animation.addByIndices('idle', 'protagonist', [0,1,2,3,4,5,6,7], "", 24, true);
        protagonist.animation.addByIndices('walk', 'protagonist', [9,10,11,12,13,14,15,16], "", 30, true);
		protagonist.animation.play('idle');
		protagonist.screenCenter(X);
		//CoolUtil.glow(protagonist, 10, 10, 0xffffffff);
		add(protagonist);

		text = new FlxText(5, FlxG.height - 75, FlxG.width, "Elige tu idioma (tambien puedes cambiarlo en el menu de opciones).\nChoose your language (you can change it from the options menu too).", 32);
		text.font = Paths.font('Crayawn-v58y.ttf');
		text.autoSize = false;
        text.alignment = LEFT;
		add(text);
	}

	override function update(elapsed:Float)
	{
		if (canAccept)
			protagonist.animation.play('idle');
		else 
			protagonist.animation.play('walk');

		if (canSelect)
			{
				if (libroEng.selected)
					protagonist.flipX = false;
				else if (libroEsp.selected)
					protagonist.flipX = true;

				if (FlxG.keys.justPressed.LEFT || FlxG.mouse.overlaps(libroEng))
					{
						if (libroEsp.selected || (!libroEsp.selected && !libroEng.selected))
							CoolUtil.sound('scrollMenu', 'preload');
						selectedSomething = true;

						libroEsp.selected = false;
						libroEng.selected = true;
					}
				else if (FlxG.keys.justPressed.RIGHT || FlxG.mouse.overlaps(libroEsp))
					{
						if (libroEng.selected || (!libroEsp.selected && !libroEng.selected))
							CoolUtil.sound('scrollMenu', 'preload');
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

		if ((controls.ACCEPT || (FlxG.mouse.justPressed && (FlxG.mouse.overlaps(libroEsp) || FlxG.mouse.overlaps(libroEng)))) && canAccept && selectedSomething)
		{
			selectedSomething = false;

			canSelect = false;
			canAccept = false;

			FlxG.camera.flash(FlxColor.WHITE, 1);
			CoolUtil.sound('confirmMenu', 'preload', 0.7);

			if (libroEsp.selected)
				KadeEngineData.settings.data.esp = true;
			else if (libroEng.selected)
				KadeEngineData.settings.data.esp = false;

			libroEsp.book.alpha = 1;
			libroEng.book.alpha = 1;
			remove(text);

			if (libroEng.selected)
				protagonist.velocity.x = -400
			else if (libroEsp.selected)
				protagonist.velocity.x = 400;

			new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					
					substates.LoadShared.initial(new menus.MainMenuState());
					//FlxG.switchState(new MainMenuState());
				});
		}

		super.update(elapsed);
	}
}
