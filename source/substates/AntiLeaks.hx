package substates;

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
        Application.current.window.title = '...';

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
																FlxG.switchState(new substates.Caching());
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