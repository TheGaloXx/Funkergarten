package menus;

import flixel.FlxG;

class LanguageState extends MusicBeatState
{
	var protagonist:flixel.FlxSprite;
	var canAccept:Bool = true;
	var selectedSomething:Bool = false;

	private var options:Array<Array<String>> = [['es_ES', 'Espanol'], ['en_US', 'English'], ['es_BR', 'Portugues']];
	private var books:Array<Objects.LanguageSpr> = [];

	override function create()
	{
		CoolUtil.title('Language Menu');
		CoolUtil.presence(null, 'Selecting language', false, 0, null);
		
		super.create();

		for (i in 0...options.length)
		{
			var book = new Objects.LanguageSpr(50 + (450 * i), 60, options[i][1]);
			add(book);
			books.push(book);
		}

		protagonist = new flixel.FlxSprite(0, 460);
		protagonist.frames = Paths.getSparrowAtlas('menu/protagonist', 'preload');
		protagonist.animation.addByIndices('idle', 'protagonist', [0,1,2,3,4,5,6,7], "", 24, true);
        protagonist.animation.addByIndices('walk', 'protagonist', [9,10,11,12,13,14,15,16], "", 30, true);
		protagonist.animation.play('idle', true);
		protagonist.screenCenter(X);
		//CoolUtil.glow(protagonist, 10, 10, 0xffffffff);
		add(protagonist);

		var text = new flixel.text.FlxText(5, FlxG.height - 75, FlxG.width, "LANGUAGE SELECTION", 48);
		text.font = Paths.font('Crayawn-v58y.ttf');
		text.autoSize = false;
        text.alignment = CENTER;
		text.active = false;
		add(text);
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
					CoolUtil.sound('scrollMenu', 'preload');
					spr.selected = true;
				}
				else if (!FlxG.mouse.overlaps(spr))
					spr.selected = false;

				if (spr.selected)
					protagonist.flipX = (protagonist.x < spr.book.x);
			}
		}

		if (FlxG.mouse.justPressed && canAccept && selectedSomething)
		{
			selectedSomething = canAccept = false;

			protagonist.animation.play('walk');
			FlxG.camera.flash();
			CoolUtil.sound('confirmMenu', 'preload', 0.7);

			for (spr in books)
				if (spr.selected)
					KadeEngineData.settings.data.language =  options[books.indexOf(spr)][0];

			Language.populate();
			protagonist.velocity.x = (protagonist.flipX ? 400 : -400);
			new flixel.util.FlxTimer().start(2, function(_) substates.LoadShared.initial(new menus.MainMenuState()));
		}

		super.update(elapsed);
	}
}
