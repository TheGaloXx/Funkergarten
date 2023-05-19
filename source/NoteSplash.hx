package;

import flixel.FlxG;

class NoteSplash extends flixel.FlxSprite
{
	public static var data:Array<Dynamic> = [];

	public function new()
    {
		super(data[0], data[1]);
		
		var frameRate:Int = FlxG.random.int(18, 24);

		frames = Paths.getSparrowAtlas('gameplay/' + (PlayState.isPixel ? 'pixel/' : 'notes/') + 'noteSplashes', 'shared');
		animation.addByPrefix('splash 0 0', 'note impact 1 purple', frameRate, false);
		animation.addByPrefix('splash 0 1', 'note impact 1  blue', frameRate, false);
		animation.addByPrefix('splash 0 2', 'note impact 1 green', frameRate, false);
		animation.addByPrefix('splash 0 3', 'note impact 1 red', frameRate, false);
		animation.addByPrefix('splash 1 0', 'note impact 2 purple', frameRate, false);
		animation.addByPrefix('splash 1 1', 'note impact 2 blue', frameRate, false);
		animation.addByPrefix('splash 1 2', 'note impact 2 green', frameRate, false);
		animation.addByPrefix('splash 1 3', 'note impact 2 red', frameRate, false);

		var anim = 'splash ' + flixel.FlxG.random.int(0, 1) + " " + data[2];
		animation.play(anim);
		animation.finishCallback = function(name:String) kill();

		if (data[2] == 'nuggetP')
			color = 0x199700;
		else if (data[2] == 'apple')
			color = flixel.util.FlxColor.RED;

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

		scrollFactor.set();

		kill();
	}

	override public function revive()
	{
		setPosition(data[0], data[1]);
		var anim = 'splash ' + flixel.FlxG.random.int(0, 1) + " " + data[2];
		animation.play(anim);
		animation.finishCallback = function(name:String) kill();
	
		offset.set();
		offset.x += 70;
		offset.y += 80;
	
		super.revive();
	}
}

class GumTrap extends flixel.FlxSprite
{
    //i really like creating a new .hx for every fucking thing

	public function new(x:Float = 0, y:Float = 0)
    {
		super(x, y);

		var tex = Paths.getSparrowAtlas('gameplay/notes/Gum_trap', 'shared');
		frames = tex;
		animation.addByIndices('idle', 'Sticky Note', [0, 1, 2, 3], "", 24, true);
        animation.addByIndices('pre-struggle', 'Sticky Note', [4, 5, 6, 7], "", 24, false);
        animation.addByIndices('struggle', 'Sticky Note', [8, 9, 10, 11], "", 24, true);
        animation.addByIndices('break', 'Sticky Note', [12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28], "", 24, false);
        animation.play('idle');

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