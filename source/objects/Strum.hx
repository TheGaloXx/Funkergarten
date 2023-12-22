package objects;

import states.PlayState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import data.KadeEngineData;
import flixel.FlxG;

class Strum extends flixel.FlxSprite
{
    public var isPlayer:Bool;

    public function new(i:Int, num:Int)
    {
        super(0, (KadeEngineData.settings.data.downscroll ? FlxG.height - Note.swagWidth - 40 : 40));

        isPlayer = (num != 0);
		ID = i;

		loadSprite(i);
		scrollFactor.set();
		alpha = 0;
		FlxTween.tween(this, {y: y + 10 * (KadeEngineData.settings.data.downscroll ? -1 : 1), alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 1 + (0.2 * i)});
		centerX(i);
    }

    override function update(elapsed:Float):Void
    {
        // super.update(elapsed);
		updateAnimation(elapsed);
    }

    public function playAnim(name:String, force:Bool):Void
    {
        animation.play(name, force);

        animation.finishCallback = function(xd:String)
        {
            if (xd == 'confirm') animation.play('static');
        }
    }

	private inline function loadSprite(i:Int):Void
	{
		final directions:Array<String> = ['left', 'down', 'up', 'right'];
		final pixelBullshit:Array<Array<Int>> = [[0, 4, 8, 12, 16], [1, 5, 9, 13, 17], [2, 6, 10, 14, 18], [3, 7, 11, 15, 19]];
		final pixelPath:String = (PlayState.isPixel ? 'pixel' : 'notes');

		frames = Paths.getSparrowAtlas('gameplay/$pixelPath/NOTE_assets', 'shared');
		animation.addByIndices('static', 'strum ${directions[i]}', [0], '', 0, false);
		animation.addByIndices('confirm', 'strum ${directions[i]}', [1, 2, 3, 3], '', 24, false);
		animation.addByIndices('pressed', 'strum ${directions[i]}', [4, 5], '', 12, false);
		setGraphicSize(Std.int(width * 0.7));

		updateHitbox();
		animation.play('static');
		updateHitbox();
	}

	private inline function centerX(i:Int):Void
	{
		final groupWidth:Float = 494.2;

		if (KadeEngineData.settings.data.middlescroll)
		{
			if (isPlayer)
				x = (FlxG.width - groupWidth) / 2;
			else
			{
				FlxTween.cancelTweensOf(this);
				alpha = 0;
				visible = false;
				active = false;
				x = -2000;
				kill();
			}
		}
		else
		{
			final halfScreen:Float = FlxG.width / 2;
			final centered:Float = Math.abs((halfScreen - groupWidth) / 2);

			x = (!isPlayer ? centered : halfScreen + centered);

			/*
			else
			{
				final difference:Float = groupWidth - FlxG.width / 2;
				x = (!isPlayer ? difference / 2 : FlxG.width - groupWidth - difference / 2);
			}
			*/
		}

		x += Note.swagWidth * Math.abs(i);
	}
}