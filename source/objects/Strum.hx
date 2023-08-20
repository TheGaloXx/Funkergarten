package objects;

import flixel.FlxG;

class Strum extends flixel.FlxSprite
{
    public var isPlayer:Bool;

    public function new(i:Int, num:Int)
    {
        super(0, (data.KadeEngineData.settings.data.downscroll ? FlxG.height - 165 : 40));

        isPlayer = (num != 0);
        var directions:Array<String> = ['left', 'down', 'up', 'right'];
		var pixelBullshit:Array<Array<Int>> = [[0, 4, 8, 12, 16], [1, 5, 9, 13, 17], [2, 6, 10, 14, 18], [3, 7, 11, 15, 19]];
	
		if (states.PlayState.isPixel)
		{
			loadGraphic(Paths.image('gameplay/pixel/NOTE_assets', 'shared'), true, 17, 17);
			setGraphicSize(Std.int(width * 6));
			antialiasing = false;
			animation.add('static', [pixelBullshit[i][0]]);
			animation.add('pressed', [pixelBullshit[i][1], pixelBullshit[i][2]], 12, false);
			animation.add('confirm', [pixelBullshit[i][3], pixelBullshit[i][4]], 24, false);
		}
		else
		{
			frames = Paths.getSparrowAtlas('gameplay/notes/NOTE_assets', 'shared');
			setGraphicSize(Std.int(width * 0.7));
			animation.addByIndices('static', 'strum ${directions[i]}', [0], '', 0, false);
			animation.addByIndices('confirm', 'strum ${directions[i]}', [1, 2, 3, 3], '', 24, false);
			animation.addByIndices('pressed', 'strum ${directions[i]}', [4, 5], '', 12, false);
		}
	
		updateHitbox();
        ID = i;
		scrollFactor.set();
		alpha = 0;
		flixel.tweens.FlxTween.tween(this, {y: y + 10, alpha: 1}, 1, {ease: flixel.tweens.FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});

		if (!isPlayer && data.KadeEngineData.settings.data.middlescroll)
		{
            flixel.tweens.FlxTween.cancelTweensOf(this);
			alpha = 0;
			visible = active = false;
			x -= 1000;
            kill();
        }
	
		animation.play('static');
		x += (objects.Note.swagWidth * Math.abs(i) + 100 + ((FlxG.width / 2) * (isPlayer ? 1 : 0))) - (data.KadeEngineData.settings.data.middlescroll ? 275 : 0);
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);
    }

    public function playAnim(name:String, force:Bool):Void
    {
        animation.play(name, force);

        animation.finishCallback = function(xd:String)
        {
            if (xd == 'confirm') animation.play('static');
        }
    }
}