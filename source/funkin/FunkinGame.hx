package funkin;

import flixel.FlxGame;

class FunkinGame extends FlxGame
{
    // if the game crashes while being fullscreen your pc will fucking die
	// ok that wasn't the problem but im keeping this cuz im lazy

	public static var crashed:Bool = false;

	@:allow(flixel.FlxG)
	override function resizeGame(width:Int, height:Int):Void
		if (!crashed)
			super.resizeGame(width, height);

    override function updateInput():Void
        if (!crashed)
            super.updateInput();

    override function draw():Void
		if (!crashed)
			super.draw();

	override function update():Void 
		if (!crashed)
			super.update();

	@:allow(flixel.FlxG)
	override function onResize(_):Void
		if (!crashed)
			super.onResize(_);
}