package objects;

// ALL OF THIS IS COPIED FROM SANCO'S FNF ENGINE: https://github.com/SanicBTW/Just-Another-FNF-Engine/tree/master

import openfl.display.Shape;
import openfl.display.Sprite;
import flixel.FlxG;

using StringTools;

class VolumeTray extends Tray
{
	private var _visibleTime:Float = 0.0;
	private var _width:Int = 120;
	private var _height:Int = 30;
	private var targetY:Float = 0.0;
	private var _volTracker:openfl.text.TextField;
	private var _volBar:Shape;
	private var volume(get, null):Float;

	@:noCompletion
	private function get_volume():Float
		return FlxG.sound != null ? FlxG.sound.volume : 1;

	override public function create()
	{
		y = -openfl.Lib.current.stage.stageHeight;

		var bg = drawRound(0, 0, _width, _height, [0, 0, 5, 5], flixel.util.FlxColor.BLACK, 0.6);
		screenCenter();
		addChild(bg);

		var volText = new openfl.text.TextField();
		setTxtFieldProperties(volText);
		volText.text = "Volume";
		volText.defaultTextFormat.align = LEFT;
		volText.x = 5;
		addChild(volText);

		_volTracker = new openfl.text.TextField();
		setTxtFieldProperties(_volTracker);
		_volTracker.text = '${volume * 100}%';
		_volTracker.defaultTextFormat.align = RIGHT;
		_volTracker.x = (_width - _volTracker.textWidth) - 10;
		addChild(_volTracker);

		_volBar = drawRound(0, 0, _width - 10, 5, [5]);
		_volBar.x = 5;
		_volBar.y = (_height - _volBar.height) - 5;
		addChild(_volBar);
	}

	override public function update(elapsed:Float)
	{
		var lerpVal:Float = boundTo(1 - (elapsed * 9), 0, 1);

		y = flixel.math.FlxMath.lerp(targetY, y, lerpVal);

		_volBar.scaleX = flixel.math.FlxMath.lerp((FlxG.sound.muted ? 0 : volume), _volBar.scaleX, lerpVal);
		_volTracker.text = '${Math.round(_volBar.scaleX * 100)}%';
		_volTracker.x = flixel.math.FlxMath.lerp((_width - _volTracker.textWidth) - 10, _volTracker.x, lerpVal);

		if (_visibleTime > 0)
			_visibleTime -= elapsed;
		else if (_visibleTime <= 0)
		{
			if (targetY > -gHeight)
				targetY -= elapsed * gHeight * _defaultScale;
			else
			{
				visible = active = false;
			}
		}
	}

	public function show()
	{
		_visibleTime = 1.8;
		targetY = 0;
		visible = active = true;
	}

	private function setTxtFieldProperties(field:openfl.text.TextField)
	{
		field.defaultTextFormat = new openfl.text.TextFormat(openfl.utils.Assets.getFont(Paths.font('Crayawn-v58y.ttf')).fontName, 15, 0xFFFFFF);
		field.width = _width;
		field.height = _height;
		field.multiline = field.wordWrap = field.embedFonts = true;
		field.selectable = false;
		#if !html5
		field.y = 2.5;
		#end
	}
}

class OFLSprite extends Sprite
{
	public var active:Bool = true;
	public var rawElapsed:Float = 0;

	public function new()
	{
		super();

		create();
	}

	private function create() {}

	@:noCompletion
	private override function __enterFrame(deltaTime:Float):Void
	{
		if (!active || !visible)
			return;

		screenCenter();
		rawElapsed = deltaTime;
		update(deltaTime / 1000);
	}

	private function update(elapsed:Float) {}

	public function destroy() {}

	public function screenCenter()
	{
		x = (0.5 * (openfl.Lib.current.stage.stageWidth - width));
	}

	private function drawRound(X:Float = 0, Y:Float = 0, Width:Float = 50, Height:Float = 50, CornerRadius:Array<Float>, Color = flixel.util.FlxColor.WHITE,
			Alpha:Float = 1):Shape
	{
		var shape = new Shape();
		shape.graphics.beginFill(Color, Alpha);

		if (CornerRadius.length < 3)
			shape.graphics.drawRoundRect(X, Y, Width, Height, CornerRadius[0]);
		else
			shape.graphics.drawRoundRectComplex(X, Y, Width, Height, CornerRadius[0], CornerRadius[1], CornerRadius[2], CornerRadius[3]);

		shape.graphics.endFill();

		return shape;
	}

	private inline function boundTo(value:Float, min:Float, max:Float):Float
		return Math.max(min, Math.min(max, value));

	private function lerpTrack<T:openfl.display.DisplayObject>(sprite:T, property:String, track:Float, ratio:Float)
	{
		var field = Reflect.getProperty(sprite, property);
		var lerp:Float = flixel.math.FlxMath.lerp(track, field, ratio);
		Reflect.setProperty(sprite, property, lerp);
	}
}

class Tray extends OFLSprite
{
	private var _defaultScale:Float = 2.0;
	private var gWidth(get, null):Int;

	@:noCompletion
	private function get_gWidth():Int
		return Std.int(FlxG.game.width);

	private var gHeight(get, null):Int;

	@:noCompletion
	private function get_gHeight():Int
		return Std.int(FlxG.game.height);

	override public function new()
	{
		super();
		active = visible = false;
		screenCenter();
	}

	override public function screenCenter()
	{
		var rWidth:Float = Reflect.getProperty(this, "_width");
		scaleX = scaleY = _defaultScale;
		x = (0.5 * (openfl.Lib.current.stage.stageWidth - (Math.isNaN(rWidth) ? width : rWidth) * _defaultScale));
	}
}