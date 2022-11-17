package;

import flixel.FlxSprite;
import flixel.FlxG;

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