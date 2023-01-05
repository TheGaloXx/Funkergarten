package substates;

import flixel.input.keyboard.FlxKey;
import flixel.FlxState;
import flixel.FlxG;
import lime.app.Application;
import flixel.util.FlxTimer;

var canPress:Bool = false;
var char:Int = 0;

class AntiLeaks extends FlxState
{
	override function create()
	{
        Application.current.window.title = '';

		canPress = true;
		trace("do combination");

        super.create();
    }

	// key code and if it has been pressed
	private static var keyChecks:Map<Int, Bool> =
	[
		16 => false,
		80 => false,
		73 => false,
		74 => false,
		68 => false
	];

	override function update(elapsed:Float) 
	{
		if (canPress)
		{
			if (keyChecks.exists(FlxG.keys.firstJustPressed()))
				keyChecks.remove(FlxG.keys.firstJustPressed());

			if (keyChecks.toString() == "{}")
			{
				trace("nice");
				canPress = false;
				FlxG.camera.flash();

				new FlxTimer().start(1, function(_)
				{
					MusicBeatState.switchState(new substates.Caching());
				});
			}
			/*
			if (FlxG.keys.pressed.SHIFT)
			{
				if (FlxG.keys.pressed.P)
				{
					if (FlxG.keys.pressed.I)
					{
						if (FlxG.keys.pressed.J)
						{
							if (FlxG.keys.justPressed.D)
							{
								trace("nice");
								canPress = false;
								FlxG.camera.flash();

								new FlxTimer().start(1, function(_)
								{
									MusicBeatState.switchState(new substates.Caching());
								});
							}
						}
					}
				}
			}*/
		}

		super.update(elapsed);	
	}
}