package;

import openfl.text.TextField;
import openfl.text.TextFormat;

// THIS IS A MODIFICATION OF THE OPENFL FPS CLASS

class FPSCounter extends openfl.text.TextField
{
	public var currentFPS(default, null):Int;

	private var cacheCount:Int;
	private var currentTime:Float;
	private var times:Array<Float> = [];

	public function new()
	{
		super();

		x = 10;
		y = 8;

		selectable = mouseEnabled = false;
		defaultTextFormat = new openfl.text.TextFormat("_sans", 12, 0xFFFFFFFF);
		text = "FPS: ";
		defaultTextFormat.align = "left";
		defaultTextFormat.bold = true;

		cacheCount = currentFPS = 0;
		currentTime = 0;
	}

	private override function __enterFrame(deltaTime:Float):Void
	{
		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000) times.shift();

		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) / 2);

		if (currentCount != cacheCount) text = "FPS: " + currentFPS;

		cacheCount = currentCount;

		textColor = (currentFPS < (flixel.FlxG.updateFramerate / 1.2) ? 0xFFFF0000 : 0xFFFFFFFF);
	}
}

class MemoryCounter extends TextField
{
	private static final intervalArray:Array<String> = ['B', 'KB', 'MB', 'GB'];
	private var memoryPeak(default, null):Float;

	public function new(x:Float = 10, y:Float = 10)
	{
		super();

		this.x = x;
		this.y = y;

		memoryPeak = 0;
		selectable = mouseEnabled = false;
		defaultTextFormat = new TextFormat("_sans", 12, 0xFFFFFF);
		text = "Memory: ";
	}

	private override function __enterFrame(_):Void
	{
		if (!visible) return;

		var mem:Float = #if cpp cpp.vm.Gc.memInfo64(3) #else openfl.system.System.totalMemory #end;

		if (mem > memoryPeak) memoryPeak = mem;
		text = "Memory: " + getInterval(mem) + "\nMemory peak: " + getInterval(memoryPeak);
	}

	private static function getInterval(size:Float)
	{
		var data:Int = 0;
		while (size > 1024 && data < intervalArray.length - 1)
		{
			data++;
			size = size / 1024;
		}
		size = Math.round(size * 100) / 100;
		return '$size ${intervalArray[data]}';
	}
}

class ClassIndicator extends openfl.text.TextField
{
	public function new(x:Float, y:Float)
	{
		super();

		this.x = x;
		this.y = y;

		selectable = mouseEnabled = false;
		defaultTextFormat = new openfl.text.TextFormat("_sans", 12, 0xFFFFFFFF);
		text = "Class: ";
		defaultTextFormat.align = "left";
		defaultTextFormat.bold = true;
	}
}