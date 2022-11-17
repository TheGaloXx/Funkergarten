package;

import flixel.FlxG;
import flixel.FlxSprite;

class HealthIcon extends FlxSprite
{
	/*
		Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	*/
	public var sprTracker:FlxSprite;

	public function new(char:String = 'none', isPlayer:Bool = false)
	{
		super();
		
		loadGraphic(Paths.image('iconGrid'), true, 150, 150);

		antialiasing = FlxG.save.data.antialiasing;
		animation.add('bf', [0, 1], 0, false, isPlayer);
		animation.add('dad', [2, 3], 0, false, isPlayer);
		animation.add('bf-old', [4, 5], 0, false, isPlayer);
		animation.add('none', [6, 7], 0, false, isPlayer);
		animation.add('monty', [8, 9], 0, false, isPlayer);
		animation.add('monster', [10, 11], 0, false, isPlayer);
		animation.add('nugget', [12, 13], 0, false, isPlayer);

		if (char == null)
			char = 'none';

		if (animation != null)
			animation.play(char);
		else
			animation.play('none');

		antialiasing = FlxG.save.data.antialiasing;

		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
