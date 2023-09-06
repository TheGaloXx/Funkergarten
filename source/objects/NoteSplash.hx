package objects;

import flixel.FlxG;

class NoteSplash extends flixel.FlxSprite
{
	public function new()
    {
		super();
		
		var frameRate:Int = FlxG.random.int(18, 24);

		frames = Paths.getSparrowAtlas('gameplay/' + (states.PlayState.isPixel ? 'pixel/' : 'notes/') + 'noteSplashes', 'shared');
		animation.addByPrefix('splash 0 0', 'note impact 1 purple', frameRate, false);
		animation.addByPrefix('splash 0 1', 'note impact 1  blue', frameRate, false);
		animation.addByPrefix('splash 0 2', 'note impact 1 green', frameRate, false);
		animation.addByPrefix('splash 0 3', 'note impact 1 red', frameRate, false);
		animation.addByPrefix('splash 1 0', 'note impact 2 purple', frameRate, false);
		animation.addByPrefix('splash 1 1', 'note impact 2 blue', frameRate, false);
		animation.addByPrefix('splash 1 2', 'note impact 2 green', frameRate, false);
		animation.addByPrefix('splash 1 3', 'note impact 2 red', frameRate, false);

		scrollFactor.set();

		kill();
	}

	override function update(elapsed:Float):Void
	{
		// super.update(elapsed);
		updateAnimation(elapsed);
	}

	public function play(Y:Float, note:objects.Note):Void
	{
		setPosition(note.x, Y);

		var anim = 'splash ' + flixel.FlxG.random.int(0, 1) + " " + note.noteData;
		animation.play(anim);
		animation.finishCallback = function(name:String)
		{
			if (name == anim) kill();
		}
	
		final mult = (states.PlayState.isPixel ? 2 : 1);

		offset.set();
		offset.x += 70 * mult;
		offset.y += 80 * mult;

		if (note.noteStyle == 'nuggetP') color = 0x199700;
		else if (note.noteStyle == 'apple') color = flixel.util.FlxColor.RED;
		else color = flixel.util.FlxColor.WHITE;
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
		animation.addByIndices('idle', 'Sticky objects.Note', [0, 1, 2, 3], "", 24, true);
        animation.addByIndices('pre-struggle', 'Sticky objects.Note', [4, 5, 6, 7], "", 24, false);
        animation.addByIndices('struggle', 'Sticky objects.Note', [8, 9, 10, 11], "", 24, true);
        animation.addByIndices('break', 'Sticky objects.Note', [12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28], "", 24, false);
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