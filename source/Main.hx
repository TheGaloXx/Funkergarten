package;

import substates.Start;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import Counters;

#if sys
import Discord.DiscordClient;
import haxe.CallStack;
import haxe.io.Path;
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
#end

#if cpp
import cpp.NativeGc;
#end

using StringTools;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	private var fpsCounter:FPSCounter;
	public static var memoryCounter:MemoryCounter;

	public static var characters = ['bf', 'bf-pixel', 'dad', 'gf', 'nugget', 'monty', 'monster', 'protagonist', 'bf-dead', 'bf-pixel-dead', 'protagonist-pixel', 'janitor', 'principal', 'polla', //characters

	'example'	//stage sprites
	];

	public static var embedSongs:Array<String> = ['Nugget de Polla'];

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static var appTitle:String = "Funkergarten";

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
			init();
		else
			addEventListener(Event.ADDED_TO_STAGE, init);
	}
	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE, init);

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		var ratioX:Float = stageWidth / gameWidth;
		var ratioY:Float = stageHeight / gameHeight;

		gameWidth = Math.ceil(stageWidth / Math.min(ratioX, ratioY));
		gameHeight = Math.ceil(stageHeight / Math.min(ratioX, ratioY));

		#if cpp
		NativeGc.enable(true);
		#end

		FlxG.save.bind('other', 'funkergarten');
		KadeEngineData.bind();

		addChild(new FlxGame(gameWidth, gameHeight, Start, 120, 120, true, false));
		
		#if debug
		flixel.addons.studio.FlxStudio.create();
		#end
		
		fpsCounter = new FPSCounter();
		fpsCounter.width = gameWidth;
		addChild(fpsCounter);
		toggleFPS(KadeEngineData.settings.data.fps);

		memoryCounter = new MemoryCounter(10, (fpsCounter.textHeight + fpsCounter.y) - 1);
		memoryCounter.width = gameWidth;
		addChild(memoryCounter);
		memoryCounter.visible = KadeEngineData.settings.data.fps;

		#if sys
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end
	}

	public function toggleFPS(fpsEnabled:Bool):Void {
		fpsCounter.visible = fpsEnabled;
	}

	// Code was entirely made by sqirra-rng for their fnf engine named "Izzy Engine", big props to them!!!
	#if sys
	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = "./crash/" + "Funkergarten_" + dateNow + ".txt";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: "
			+ e.error
			+ "\nPlease report this error to the dev team\n\n> Crash Handler written by: sqirra-rng";

		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		Application.current.window.alert(errMsg, "Error!");
		#if cpp
		DiscordClient.shutdown();
		#end
		Sys.exit(1);
	}
	#end
}
