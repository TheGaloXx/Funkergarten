package;

import openfl.events.UncaughtErrorEvent;
import Discord.DiscordClient;
import sys.FileSystem;
import sys.io.File;
import haxe.CallStack;
import states.Start;
import funkin.FunkinGame;
import openfl.Lib;
import data.GlobalData;
import objects.SoundTray.VolumeTray;
import openfl.events.Event;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import openfl.display.Sprite;
import flixel.FlxG;
import objects.Counter;

using StringTools;

class Main extends Sprite
{
	private var counter:Counter;
	private var gamepadText:GamepadText;

	public static var currentClass:String = '';
	public static var tray:VolumeTray;

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?_):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE, init);

		setupGame();
	}

	private function setupGame():Void
	{
		var gameWidth:Int = 1280;
		var gameHeight:Int = 720;

		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		var ratioX:Float = stageWidth / gameWidth;
		var ratioY:Float = stageHeight / gameHeight;

		gameWidth = Math.ceil(stageWidth / Math.min(ratioX, ratioY));
		gameHeight = Math.ceil(stageHeight / Math.min(ratioX, ratioY));

		FlxG.save.bind('other', 'funkergarten');

		addChild(new FunkinGame(gameWidth, gameHeight, Start, 60, 60, true, false));

		tray = new VolumeTray();
		addChild(tray);

		#if debug
		flixel.addons.studio.FlxStudio.create();
		#end

		counter = new Counter();
		counter.width = gameWidth;
		addChild(counter);

		toggleFPS(GlobalData.settings.showFPS);

		addChild(gamepadText = new GamepadText(gameWidth, gameHeight));

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, gamepadEvent);
		
		#if FLX_KEYBOARD
		FlxG.stage.addEventListener(Event.ENTER_FRAME, handleVolume);
		#end

		#if sys
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end
	}

	public inline function toggleFPS(fpsEnabled:Bool):Void
	{
		counter.visible = fpsEnabled;
	}

	public inline function updateClassIndicator():Void
	{
		#if debug
		try
		{
			// classTxt.text = 'Class: ' + Type.getClassName(Type.getClass(FlxG.state));
			currentClass = 'Class: ' + Type.getClassName(Type.getClass(FlxG.state));
		}
		catch (e)
		{
			trace('AN ERROR OCCURRED: ${e.message}.');
		}
		#end
	}

	public inline static function changeFPS(cap:Int)
	{
		if (cap > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = cap;
			FlxG.drawFramerate = cap;
		}
		else
		{
			FlxG.drawFramerate = cap;
			FlxG.updateFramerate = cap;
		}
	}

	// Code was entirely made by sqirra-rng for their fnf engine named "Izzy Engine", big props to them!!!
	#if sys
	function onCrash(e:UncaughtErrorEvent):Void
	{
		FunkinGame.crashed = true;

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

		errMsg += '\nUncaught Error: '
			+ e.error
			+ "\nPlease report this error in Funkergarten's Gamebanana page\n\n\n> Crash Handler written by: sqirra-rng";

		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + haxe.io.Path.normalize(path));

		if (!FlxG.fullscreen)
		{
			FlxG.stage.window.alert(errMsg, "Error!");
		}

		DiscordClient.shutdown();

		Sys.exit(1);
	}
	#end

	private function gamepadEvent(key:KeyboardEvent)
	{
		if (gamepadText == null || !gamepadText.visible)
			return;

		if (key.keyCode == Keyboard.E)
		{
			trace('Epic');
			removeChild(gamepadText);
			gamepadText = null;
		}

		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, gamepadEvent);
	}

	private function handleVolume(_):Void
	{
		var up = FlxG.keys.anyJustReleased([PLUS, NUMPADPLUS]);
		var down = FlxG.keys.anyJustReleased([MINUS, NUMPADMINUS]);

		if ((up && down) || (!up && !down))
			return;

		var oldVolume:Float = CoolUtil.volume;

		if (up)
			CoolUtil.changeVolume(10);
		else if (down)
			CoolUtil.changeVolume(-10);

		if (oldVolume != CoolUtil.volume)
			CoolUtil.sound('scrollMenu', 'preload', 0.3);
	}
}
