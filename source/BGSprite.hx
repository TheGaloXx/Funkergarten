package;

import flixel.FlxSprite;
import flixel.FlxG;

class BGSprite extends FlxSprite
{
    //original from Psych Engine
    //actually its modified but whatever

    public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var name:String;
    public var animated:Bool = false;

	public var destroyed:Bool = false;

	public function new(name:String, x:Float = 0, y:Float = 0, animated:Bool, scrollX:Float = 1, scrollY:Float = 1)
    {
		super(x, y);

        animOffsets = new Map<String, Array<Dynamic>>();

		this.name = name;
        this.animated = animated;

        if (animated)
        {
            frames = Paths.getSparrowAtlas('bg/' + name, 'shared');
			//addOffset('firstDeath', 37, 11);
        }
        else
        {
            loadGraphic(Paths.image('bg/' + name, 'shared'), false);
        }
		
		scrollFactor.set(scrollX, scrollY);

		antialiasing = FlxG.save.data.antialiasing;
	}

	public function dance() 
    {
		if (destroyed || this == null)
			{
				trace(this.name + " no existe lol");
				return;
			}

		playAnim('idle', true);
	}

    public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
		{
			if (destroyed || this == null)
				{
					trace(this.name + " no existe lol");
					return;
				}

			if (!animOffsets.exists(AnimName))
				{
					return;
					trace("LA ANIMACION NO EXISTE");
				}
		
			//THIS CODE IS TAKEN FROM INDIE CROSS
			
			animation.play(AnimName, Force, Reversed, Frame);
	
			var daOffset = animOffsets.get(AnimName);
			if (animOffsets.exists(AnimName))
			{
				offset.set(daOffset[0], daOffset[1]);
			}
			else
				offset.set(0, 0);
		}

	public function destruir():Void
	{
		if (this != null && !destroyed)
		{
			destroyed = true;
			destroy();
		}
	}

    public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
}