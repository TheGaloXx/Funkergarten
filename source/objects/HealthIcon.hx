package objects;

class HealthIcon extends flixel.FlxSprite
{
	public var sprTracker:flixel.FlxSprite;

	public function new(char:String = 'none', isPlayer:Bool = false)
	{
		super();
		
		loadGraphic(Paths.image('iconGrid', 'preload'), true, 150, 150);
		addAnims();

		if (animation != null)
			animation.play(char);
		else
			animation.play('none');

		flipX = isPlayer;
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		// super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}

	private function addAnims():Void
	{
		animation.add('bf', [0, 1], 0, false);
		animation.add('dad', [2, 3], 0, false);
		animation.add('bf-old', [4, 5], 0, false);
		animation.add('none', [6, 7], 0, false);
		animation.add('monty', [8, 9], 0, false);
		animation.add('monster', [10, 11], 0, false);
		animation.add('nugget', [12, 13], 0, false);
		animation.add('bf-pixel', [14, 15], 0, false);
		animation.add('protagonist-pixel', [16, 17], 0, false);
		animation.add('protagonist', [18, 19], 0, false);
		animation.add('janitor', [20, 21], 0, false);
		animation.add('principal', [22, 23], 0, false);
		animation.add('bf-alt', [0, 1], 0, false);
	}
}
