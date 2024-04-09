package objects;

import flixel.FlxSprite;
import states.PlayState;
import flixel.FlxG;

class NoteSplash extends FlxSprite
{
	private var animations:Null<Array<Int>>;

	public function new()
    {
		super();

		if (PlayState.isPixel)
		{
			loadGraphic(Paths.image('gameplay/pixel/noteSplashes', 'shared'), true, 40, 42);
			animations = [1];
			antialiasing = false;

			animation.add('type_1', [0, 1, 2, 3, 4], 24, false);
			animation.play('type_1');
			setGraphicSize(width * 7);
			updateHitbox();
			animation.stop();
		}
		else
		{
			frames = Paths.getSparrowAtlas('gameplay/notes/noteSplashes', 'shared');
			animations = [1, 2];

			animation.addByPrefix('type_1', 'type_1', 24, false);
			animation.addByPrefix('type_2', 'type_2', 24, false);
		}

		scrollFactor.set();
	}

	override function update(elapsed:Float):Void
	{
		// super.update(elapsed);
		updateAnimation(elapsed);
	}

	public function play(strum:Strum, note:objects.Note):Void
	{
		animation.stop();

		final anim = 'type_' + FlxG.random.getObject(animations);

		animation.play(anim);
		animation.finishCallback = function(name:String)
		{
			if (name == anim)
				kill();
		}

		updateHitbox();

		if (PlayState.isPixel)
		{
			CoolUtil.middleSprite(strum, this, XY);
		}
		else
		{
			setPosition(note.x, strum.y);
			offset.set();
			offset.x += 70;
			offset.y += 80;
		}

		switch (note.noteStyle)
		{
			case 'nuggetP':
				color = 0x199700;
			case 'apple':
				color = 0xE53C34;
			default:
				color = [0xC24B99, 0x00FFFF, 0x12FA05, 0xF9393F][note.noteData];
		}
	}

	override function destroy():Void
	{
		super.destroy();

		animations = null;
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