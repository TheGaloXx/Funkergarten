package states;

import flixel.util.FlxTimer;
import options.OptionsMenu;
import data.GlobalData;
import flixel.group.FlxSpriteGroup;
import funkin.MusicBeatState;
import openfl.Assets;
import flixel.FlxG;

class LanguageState extends funkin.MusicBeatState
{
	var protagonist:flixel.FlxSprite;
	var canAccept:Bool = true;
	var selectedSomething:Bool = false;

	private var options:Array<String> = ['pl_PL', 'fr_FR', 'en_US', 'es_LA', 'pt_BR'];
	private var books:Array<objects.Objects.LanguageSpr> = [];
	private var isOptions:Bool;

	public function new(isOptions = false)
	{
		super();
		this.isOptions = isOptions;
	}

	override function create()
	{
		CoolUtil.title('Language Menu');
		CoolUtil.presence(null, Language.get('Discord_Presence', 'language_menu'), false, 0, null);

		super.create();

		final offset:Int = 20;
		var daX:Float = (FlxG.width - (307.5 + offset) * options.length) / 2;

		for (i in 0...options.length)
		{
			// Avoid setting directly the language :+1:
			Language.populate(options[i]);

			var book = new objects.Objects.LanguageSpr(daX, 60, Language.get('Global', 'language'));
			add(book);
			books.push(book);

			daX += 307.5 + offset;
		}

		protagonist = new flixel.FlxSprite(0, 460);
		protagonist.frames = Paths.getSparrowAtlas('menu/protagonist', 'preload');
		protagonist.animation.addByIndices('idle', 'protagonist', [0,1,2,3,4,5,6,7], "", 24, true);
        protagonist.animation.addByIndices('walk', 'protagonist', [9,10,11,12,13,14,15,16], "", 30, true);
		protagonist.animation.play('idle', true);
		protagonist.screenCenter(X);
		//CoolUtil.glow(protagonist, 10, 10, 0xffffffff);
		add(protagonist);

		var text = new flixel.text.FlxText(5, FlxG.height, FlxG.width, "LANGUAGE SELECTION", 48);
		text.font = Paths.font('Crayawn-v58y.ttf');
		text.autoSize = false;
        text.alignment = CENTER;
		text.active = false;
		add(text);

		FlxG.camera.zoom = 0.7;
	}

	override function update(elapsed:Float)
	{
		if (canAccept)
		{
			for (spr in books)
			{
				if (FlxG.mouse.overlaps(spr) && !spr.selected)
				{
					selectedSomething = true;
					CoolUtil.sound('scrollMenu', 'preload', 0.5);
					spr.selected = true;
				}
				else if (!FlxG.mouse.overlaps(spr))
					spr.selected = false;

				if (spr.selected)
					protagonist.flipX = (protagonist.x < spr.book.x);
			}

			selectedSomething = false;

			for (spr in books)
			{
				if (FlxG.mouse.overlaps(spr))
				{
					selectedSomething = true;
					break;
				}
			}
		}

		if (FlxG.mouse.justPressed && canAccept && selectedSomething)
		{
			selectedSomething = canAccept = false;

			protagonist.animation.play('walk');
			if (GlobalData.settings.flashingLights) FlxG.camera.flash();
			CoolUtil.sound('confirmMenu', 'preload', 0.7);

			for (spr in books)
				if (spr.selected)
					GlobalData.settings.language = options[books.indexOf(spr)];

			Language.populate();
			protagonist.velocity.x = (protagonist.flipX ? 600 : -600);

			var state:flixel.FlxState = (isOptions ? new OptionsMenu(MISC) : new states.MainMenuState());
			FlxTimer.wait(2, () ->
			{
				Assets.getLibrary("shared");
				MusicBeatState.switchState(state);
			});
		}

		super.update(elapsed);
	}
}
