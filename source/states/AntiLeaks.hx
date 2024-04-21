package states;

import data.GlobalData;
import flixel.FlxG;
import flixel.util.FlxTimer;

var canPress:Bool = true;

class AntiLeaks extends funkin.MusicBeatState //I think i have to add this because oopsie doopsie  C R A S H
{
	override function create()
	{
		CoolUtil.title(null, true);

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
								if (GlobalData.settings.flashingLights) FlxG.camera.flash();

								new FlxTimer().start(1, function(_)
								{
									funkin.MusicBeatState.switchState(new states.Caching());
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