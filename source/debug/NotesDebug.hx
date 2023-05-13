package debug;

import flixel.FlxG;

//	THIS CLASS WAS TAKEN AND MODIFIED FROM INDIE CROSS https://github.com/brightfyregit/Indie-Cross-Public/blob/master/source/offsetMenus/NotesplashOffsets.hx
//  actually its totally different lmfao

class NotesDebug extends flixel.FlxState
{
	var note:DebugNote;
    var text:flixel.text.FlxText;

	override function create()
	{
		FlxG.sound.music.stop();

		var gridBG = flixel.addons.display.FlxGridOverlay.create(10, 10);
		gridBG.scrollFactor.set();
		add(gridBG);

		var bg = new flixel.FlxSprite().makeGraphic(1, 1, 0xFF000000);
		bg.active = false;
		bg.alpha = 0.1;
		add(bg);

		var babyArrow = new flixel.FlxSprite();
		babyArrow.frames = Paths.getSparrowAtlas('gameplay/notes/NOTE_assets', 'shared');
		babyArrow.animation.addByPrefix('static', 'left0');
		babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
		babyArrow.updateHitbox();
		babyArrow.x += flixel.FlxG.width / 2;
		babyArrow.animation.play('static');
		babyArrow.active = false;
		babyArrow.alpha = 0.5;
		babyArrow.screenCenter(Y);
		add(babyArrow);

		bg.setGraphicSize(Std.int(babyArrow.width), Std.int(babyArrow.height));
		bg.updateHitbox();
		bg.screenCenter(Y);
		bg.x += flixel.FlxG.width / 2;

		note = new DebugNote('n');
		note.screenCenter(Y);
		add(note);

        text = new flixel.text.FlxText(0, 205, FlxG.width, "X: " + note.x + " - Offset X: " + note.offset.x, 15);
		text.autoSize = false;
		text.alignment = CENTER;
        text.color = 0xff0026ff;
        add(text);

        var types:Array<String> = ['Normal note', 'Poisoned nugget', 'Normal nugget', 'Gum note', 'Bullet note', 'Apple note'];

		var typeMenu = new flixel.addons.ui.FlxUIDropDownMenu(360, 235, flixel.addons.ui.FlxUIDropDownMenu.makeStrIdLabelArray(types, true), function(index:String)
        {
			note.resetNote(types[Std.parseInt(index)]);
			updateTxt();
        });
        add(typeMenu);

		FlxG.camera.zoom = 2.25;

		updateTxt();

		super.create();
	}

	override function update(elapsed:Float)
	{
		input();

		super.update(elapsed);
	}

	private function updateTxt():Void
	{
		note.offset.x = Math.round(note.offset.x);
        text.text = "X: " + note.x + " - Offset X: " + note.offset.x;  
	}

	private function input():Void
	{
		if (FlxG.keys.justPressed.ESCAPE)
			MusicBeatState.switchState(new PlayState());

		var right = FlxG.keys.anyJustPressed([RIGHT, D]);
		var left = FlxG.keys.anyJustPressed([LEFT, A]);

		if (right || left)
		{
			note.offset.x += (FlxG.keys.pressed.SHIFT ? 10 : 1) * (left ? 1 : -1);
			updateTxt();
		}
	}
}