package objects;

import openfl.text.TextField;
import openfl.text.TextFormat;
import haxe.Timer;
import openfl.display.FPS;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
import flixel.FlxG;
import flixel.util.FlxColor;
import openfl.Lib;
import flixel.math.FlxMath;
import haxe.Int64;
import openfl.system.System;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
#if gl_stats
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
#end

// TheRealJake_12 (from Haxe's official Discord server) gave me this code, THANK YOU.

class Counter extends TextField
{
	public var currentFPS(default, null):Int;
	private var times:Array<Float> = [];
	public var memoryMegas:Dynamic = 0;
	public var taskMemoryMegas:Dynamic = 0;
	public var memoryUsage:String = '';
	public var displayFPS:String;
	var skippedFrames = 0;
	private var cacheCount:Int;

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

		addEventListener(Event.ENTER_FRAME, onEnter);
	}

	private function onEnter(_)
	{
		if (!visible) return;

		var now = Timer.stamp();

		times.push(now);

		while (times[0] < now - 1) times.shift();

		var currentCount = times.length;
		displayFPS = "FPS: " + currentFPS;
		currentFPS = Math.round((currentCount + cacheCount) / 2);
		if (currentFPS > FlxG.updateFramerate) currentFPS = FlxG.updateFramerate;

		memoryUsage = "Memory Usage: ";
		#if !html5
		memoryMegas = Int64.make(0, System.totalMemory);

		taskMemoryMegas = Int64.make(0, MemoryUtil.getMemoryfromProcess());

		#if windows
		if (taskMemoryMegas >= 0x40000000)
			memoryUsage += FlxMath.roundDecimal((Math.round(cast(taskMemoryMegas, Float) / 0x400 / 0x400 / 0x400 * 1000) / 1000), 1) + " GB";
		else if (taskMemoryMegas >= 0x100000)
			memoryUsage += FlxMath.roundDecimal((Math.round(cast(taskMemoryMegas, Float) / 0x400 / 0x400 * 1000) / 1000), 1) + " MB";
		else if (taskMemoryMegas >= 0x400)
			memoryUsage += FlxMath.roundDecimal((Math.round(cast(taskMemoryMegas, Float) / 0x400 * 1000) / 1000), 1) + " KB";
		else
			memoryUsage += FlxMath.roundDecimal(taskMemoryMegas, 1) + " B)";
		#end

		#else
		memoryMegas = HelperFunctions.truncateFloat((MemoryUtil.getMemoryfromProcess() / (1024 * 1024)) * 10, 3);
		memoryUsage += FlxMath.roundDecimal(memoryMegas, 1) + " MB";
		#end

		text = ('${displayFPS}\n' + '$memoryUsage\n' + Main.currentClass);

		#if (gl_stats && !disable_cffi && (!html5 || !canvas))
		text += "\nTotal Draw Cells: " + Context3DStats.totalDrawCalls();
		text += "\nStage Draw Cells: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE);
		// text += "\nStage3D Draw Cells: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D);
		#end

		cacheCount = currentCount;
	}
}
