package;

import flixel.FlxSprite;
import flixel.FlxG;

class Try extends FlxSprite
{
    //aaaaaaaaaaaaa
	//i really like creating a new .hx for every fucking thing that i make

	public function new(x:Float = 0, y:Float = 0, animated:Bool)
    {
		super(x, y);

        if (animated)
            {
                var tex = Paths.getSparrowAtlas('tries');
                frames = tex;
                animation.addByPrefix('0', '0', 0);
                animation.addByPrefix('1', '1', 0);
                animation.addByPrefix('2', '2', 0);
                animation.addByPrefix('3', '3', 0);
                animation.addByPrefix('4', '4', 0);
                animation.addByPrefix('5', '5', 0);
                animation.addByPrefix('6', '6', 0);
                animation.addByPrefix('7', '7', 0);
                animation.addByPrefix('8', '8', 0);
                animation.addByPrefix('9', '9', 0);
                animation.play('0');
            }
        else
            {
                loadGraphic(Paths.image('try'));
            }

		antialiasing = FlxG.save.data.antialiasing;
        setGraphicSize(Std.int(this.width * 1.5));
        updateHitbox();
        screenCenter(Y);
	}

    /*
    var trySpr:FlxSprite;
		trySpr = new FlxSprite(-435, 0).loadGraphic(Paths.image('try'));
		trySpr.setGraphicSize(Std.int(trySpr.width * 1.5));
		trySpr.updateHitbox();
		trySpr.antialiasing = FlxG.save.data.antialiasing;
		trySpr.cameras = [camHUD];
		trySpr.screenCenter(Y);
		add(trySpr);

		if (FlxG.save.data.tries < 10)
			{
				tries = new FlxSprite(-435, 0);
				tries.frames = Paths.getSparrowAtlas('tries');
				tries.animation.addByPrefix(Std.string(FlxG.save.data.tries), Std.string(FlxG.save.data.tries), 0, true);
				tries.animation.play(Std.string(FlxG.save.data.tries), true); 
				tries.setGraphicSize(Std.int(tries.width * 1.5));
				tries.updateHitbox();
				tries.cameras = [camHUD];
				tries.antialiasing = FlxG.save.data.antialiasing;
				tries.screenCenter(Y);
				add(tries);
			}
		else
			{
				var lastNumber:Float = FlxG.save.data.tries - 10;

				tries2 = new FlxSprite(-435, 0);
				tries2.frames = Paths.getSparrowAtlas('tries');
				tries2.animation.addByPrefix(Std.string(lastNumber), Std.string(lastNumber), 0, true);
				tries2.animation.play(Std.string(lastNumber), true); 
				tries2.setGraphicSize(Std.int(tries2.width * 1.5));
				tries2.updateHitbox();
				tries2.screenCenter(Y);
				tries2.cameras = [camHUD];
				tries2.antialiasing = FlxG.save.data.antialiasing;
				add(tries2);
				
				tries = new FlxSprite(-435, 0);
				tries.frames = Paths.getSparrowAtlas('tries');
				tries.animation.addByPrefix(Std.string(FlxG.save.data.tries), Std.string(FlxG.save.data.tries), 0, true);
				tries.animation.play(Std.string(FlxG.save.data.tries), true); 
				tries.setGraphicSize(Std.int(tries.width * 1.5));
				tries.updateHitbox();
				tries.cameras = [camHUD];
				tries.antialiasing = FlxG.save.data.antialiasing;
				tries.screenCenter(Y);
				add(tries);
			}
    */
}