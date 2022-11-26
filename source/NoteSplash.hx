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

class GumTrap extends FlxSprite
{
    //i really like creating a new .hx for every fucking thing

	public function new(x:Float = 0, y:Float = 0)
    {
		super(x, y);

		var tex = Paths.getSparrowAtlas('gameplay/Gum_trap', 'shared');
		frames = tex;
		animation.addByIndices('idle', 'Sticky Note', [0, 1, 2, 3], "", 24, true);
        animation.addByIndices('pre-struggle', 'Sticky Note', [4, 5, 6, 7], "", 24, false);
        animation.addByIndices('struggle', 'Sticky Note', [8, 9, 10, 11], "", 24, true);
        animation.addByIndices('break', 'Sticky Note', [12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28], "", 24, false);
        animation.play('idle');

		antialiasing = FlxG.save.data.antialiasing;
        setGraphicSize(Std.int(width * 0.8));
        updateHitbox();
		scrollFactor.set();

        offset.x += 50;
		offset.y += 45;
	}

    override function update(elapsed:Float)
        {
            if (animation.curAnim.name == 'pre-struggle' && animation.curAnim.finished)
                {
                    animation.play('struggle', true);
                }
                
            if (animation.curAnim.name == 'break' && animation.curAnim.finished)
                {
                    kill();
                }

            super.update(elapsed);
        }
}