package;

import flixel.FlxG;

using StringTools;

class Main extends openfl.display.Sprite
{
	var gameWidth:Int = 1280;
	var gameHeight:Int = 720;

	private var counter:objects.Counter;

	public static var currentClass:String = '';
	public static var characters = ['bf', 'bf-pixel', 'dad', 'gf', 'nugget', 'monty', 'monster', 'protagonist', 'bf-dead', 'bf-pixel-dead', 'protagonist-pixel', 'janitor', 'principal', 'polla' //characters
		//stage sprites
	];

	public static var embedSongs:Array<String> = ['Nugget de Polla'];
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
		var stageWidth:Int = openfl.Lib.current.stage.stageWidth;
		var stageHeight:Int = openfl.Lib.current.stage.stageHeight;

		var ratioX:Float = stageWidth / gameWidth;
		var ratioY:Float = stageHeight / gameHeight;

		gameWidth = Math.ceil(stageWidth / Math.min(ratioX, ratioY));
		gameHeight = Math.ceil(stageHeight / Math.min(ratioX, ratioY));

		#if cpp
		cpp.NativeGc.enable(true);
		#end

		FlxG.save.bind('other', 'funkergarten');
		data.KadeEngineData.bind();

		addChild(new flixel.FlxGame(gameWidth, gameHeight, substates.Start, 120, 120, true, false));
		var tray = new objects.SoundTray.VolumeTray();
		addChild(tray);
		FlxG.sound.volumeHandler = function(_){ tray.show(); } 

		#if (debug && FLX_STUDIO)
		flixel.addons.studio.FlxStudio.create();
		#end

		counter = new objects.Counter();
		counter.width = gameWidth;
		addChild(counter);

		toggleFPS(data.KadeEngineData.settings.data.fps);

		#if sys
		openfl.Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(openfl.events.UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end
	}

	public function toggleFPS(fpsEnabled:Bool):Void
	{
		counter.visible = fpsEnabled;
	}

	public function updateClassIndicator():Void{
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

	public static function changeFPS(cap:Int)
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

		errMsg += "\nUncaught Error: "
			+ e.error
			+ "\nPlease report this error to the dev team\nRELGAOH WHAT DO I PUT HERE???\n\n> Crash Handler written by: sqirra-rng";

		if (!sys.FileSystem.exists("./crash/"))
			sys.FileSystem.createDirectory("./crash/");

		sys.io.File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + haxe.io.Path.normalize(path));

		lime.app.Application.current.window.alert(errMsg, "Error!");
		#if cpp
		Discord.DiscordClient.shutdown();
		#end
		Sys.exit(1);
	}
	#end
}
