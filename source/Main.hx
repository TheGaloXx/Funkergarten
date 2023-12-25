package;

import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import flixel.FlxG;

using StringTools;

class Main extends openfl.display.Sprite
{
	private var counter:objects.Counter;
	private var gamepadText:objects.Counter.GamepadText;

	public static var currentClass:String = '';
	public static var characters = ['bf', 'bf-pixel', 'bf-alt', 'nugget', 'monty', 'monster', 'protagonist', 'bf-dead', 'bf-pixel-dead', 'protagonist-pixel', 'janitor', 'principal', 'polla' //characters
		//stage sprites
	];

	public static var appTitle:String = "Funkergarten";

	public static function main():Void
	{
		openfl.Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
			init();
		else
			addEventListener(openfl.events.Event.ADDED_TO_STAGE, init);
	}
	private function init(?E:openfl.events.Event):Void
	{
		if (hasEventListener(openfl.events.Event.ADDED_TO_STAGE))
			removeEventListener(openfl.events.Event.ADDED_TO_STAGE, init);

		setupGame();
	}

	private function setupGame():Void
	{
		var gameWidth:Int = 1280;
		var gameHeight:Int = 720;

		var stageWidth:Int = openfl.Lib.current.stage.stageWidth;
		var stageHeight:Int = openfl.Lib.current.stage.stageHeight;

		var ratioX:Float = stageWidth / gameWidth;
		var ratioY:Float = stageHeight / gameHeight;

		gameWidth = Math.ceil(stageWidth / Math.min(ratioX, ratioY));
		gameHeight = Math.ceil(stageHeight / Math.min(ratioX, ratioY));

		#if cpp
		// cpp.NativeGc.enable(true);
		#end

		FlxG.save.bind('other', 'funkergarten');
		data.KadeEngineData.bind();

		addChild(new funkin.FunkinGame(gameWidth, gameHeight, substates.Start, 120, 120, true, false));
		var tray = new objects.SoundTray.VolumeTray();
		addChild(tray);
		FlxG.sound.volumeHandler = function(_){ tray.show(); } 

		#if debug
		flixel.addons.studio.FlxStudio.create();
		#end

		counter = new objects.Counter();
		counter.width = gameWidth;
		addChild(counter);

		toggleFPS(data.KadeEngineData.settings.data.fps);

		addChild(gamepadText = new objects.Counter.GamepadText(gameWidth, gameHeight));
		openfl.Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, gamepadEvent);

		#if sys
		openfl.Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(openfl.events.UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end
	}

	public inline function toggleFPS(fpsEnabled:Bool):Void
	{
		counter.visible = fpsEnabled;
	}

	public inline function updateClassIndicator():Void{
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
	function onCrash(e:openfl.events.UncaughtErrorEvent):Void
	{
		funkin.FunkinGame.crashed = true;

		var errMsg:String = "";
		var path:String;
		var callStack:Array<haxe.CallStack.StackItem> = haxe.CallStack.exceptionStack(true);
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

		if (!sys.FileSystem.exists("./crash/"))
			sys.FileSystem.createDirectory("./crash/");

		sys.io.File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + haxe.io.Path.normalize(path));

		if (!FlxG.fullscreen) lime.app.Application.current.window.alert(errMsg, "Error!");
		#if cpp
		Discord.DiscordClient.shutdown();
		#end
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

		removeEventListener(KeyboardEvent.KEY_DOWN, gamepadEvent);
	}
}
