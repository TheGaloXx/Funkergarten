package substates;

import flixel.FlxG;
import flixel.util.FlxTimer;

var canPress:Bool = false;

class AntiLeaks extends MusicBeatState //I think i have to add this because oopsie doopsie  C R A S H
{
	override function create()
	{
		CoolUtil.title(null, true);

		canPress = true;
		trace("do combination");

        super.create();
    }

	override function update(elapsed:Float) 
	{
		if (canPress)
		{
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
			}
		}

		super.update(elapsed);	
	}
}