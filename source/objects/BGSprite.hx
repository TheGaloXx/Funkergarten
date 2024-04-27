package objects;

import flixel.FlxSprite;

class BGSprite extends FlxSprite
{
	public var isAboveChar:Bool = false;

	public function new(image_path:String, isAboveChar:Bool = false, scrollX:Float = 1, scrollY:Float = 1, library:String = 'shared')
    {
		super();

		this.isAboveChar = isAboveChar;

        loadGraphic(Paths.image('bg/' + image_path, library), false);
		screenCenter();

		scrollFactor.set(scrollX, scrollY);

		active = false;
	}
}