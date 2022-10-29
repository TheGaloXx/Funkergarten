package;

import flixel.FlxSprite;
import flixel.FlxG;

class NoteSplash extends FlxSprite
{
    //balls

	public function new(x:Float = 0, y:Float = 0)
    {
		super(x, y);

        var tex = Paths.getSparrowAtlas('gameplay/noteSplashes', 'shared');
		frames = tex;
		animation.addByPrefix('splash 0 0', 'note impact 1 purple', 24, false);
		animation.addByPrefix('splash 0 1', 'note impact 1  blue', 24, false);
		animation.addByPrefix('splash 0 2', 'note impact 1 green', 24, false);
		animation.addByPrefix('splash 0 3', 'note impact 1 red', 24, false);
		animation.addByPrefix('splash 1 0', 'note impact 2 purple', 24, false);
		animation.addByPrefix('splash 1 1', 'note impact 2 blue', 24, false);
		animation.addByPrefix('splash 1 2', 'note impact 2 green', 24, false);
		animation.addByPrefix('splash 1 3', 'note impact 2 red', 24, false);
        
        alpha = 0.7;

		antialiasing = FlxG.save.data.antialiasing;
	}
}