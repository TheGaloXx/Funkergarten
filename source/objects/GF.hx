package objects;

import states.PlayState;
import flixel.FlxSprite;

using StringTools;

class GF extends FlxSprite
{
	private var canIdle:Bool = true;

    public var forceWhat:Bool = false;

	public function new(stage:Stage):Void
	{
		super(stage.positions['gf'][0], stage.positions['gf'][1]);

        frames = Paths.getSparrowAtlas('characters/gf', 'shared');
        animation.addByIndices('idle', 'gf', [0, 2, 4, 6, 8, 10, 10], '', 12, false);
        animation.addByIndices('what', 'gf', [14, 15], '', 12, true);
        animation.addByIndices('cry', 'gf', [16, 18, 20, 22, 24, 26, 28], '', 12, false);
        animation.addByIndices('shock', 'gf', [for (i in 30...46) i], '', 24, false);

        if (['Monday', 'Cash Grab', 'Nugget de Polla'].contains(PlayState.SONG.song))
            scrollFactor.set(0.95, 0.95);

		dance();
	}

	override function update(elapsed:Float):Void
	{
        if (forceWhat)
            animation.play('what');
        else if (animation.curAnim.name == 'what')
            animation.play('idle', true, false, 5);

		updateAnimation(elapsed);

		// super.update(elapsed);
	}

	public inline function dance():Void
	{
		if (!forceWhat && canIdle)
            animation.play('idle');
	}

	public inline function playSpecialAnim(AnimName:String):Void
    {
        if (forceWhat)
            return;

        canIdle = false;

        animation.play(AnimName, true, false, 0);

        animation.finishCallback = function(cock:String)
        {
            if (cock == AnimName)
            {
                canIdle = true;

                if (!forceWhat)
                    animation.play('idle', true, false, animation.getByName('idle').numFrames - 1);
            }
        }
    }
}