package;

import flixel.FlxSprite;
import flixel.FlxG;

class NoteSplash extends FlxSprite
{
    //balls

	public function new(x:Float = 0, y:Float = 0, type:String = "n")
    {
		super(x, y);

		switch(type)
		{
			case 'gum':
				var tex = Paths.getSparrowAtlas('gameplay/gumSplash', 'shared');
				frames = tex;
				animation.addByPrefix('splash', 'Gum Splash', 24, false);

				offset.x += 80;
				offset.y += 70;
				//perfect offsets		x += 80,  y += 70

			default:
				var tex = Paths.getSparrowAtlas('gameplay/' + (PlayState.isPixel ? 'pixel/' : '') + 'noteSplashes', 'shared');
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

				if (PlayState.isPixel)
					{
						offset.x += 110;
						offset.y += 120;
					}
				else
					{
						offset.x += 70;
						offset.y += 80;
					}
				//perfect offsets		x += 70,  y += 80

		}

		antialiasing = FlxG.save.data.antialiasing;
		scrollFactor.set();
	}

	override function update(elapsed:Float)
        {       
            if (animation.curAnim != null && animation.curAnim.finished)
                {
                    kill();
                }

            super.update(elapsed);
        }
}