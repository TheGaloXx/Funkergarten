package;

import flixel.FlxSubState;
import flixel.FlxG;

class ResetOptionsMenu extends FlxSubState
{
    //literally a state just for reseting OptionsMenu when changing the language
	override function create()
	{	
        FlxG.resetState();

		super.create();
	}
}