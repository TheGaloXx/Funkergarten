package menus;

import lime.app.Application;
import flixel.FlxG;
import openfl.Lib;

class OptionCategory
{
	private var _options:Array<Option> = new Array<Option>();
	public final function getOptions():Array<Option>
	{
		return _options;
	}

	public final function addOption(opt:Option)
	{
		_options.push(opt);
	}

	
	public final function removeOption(opt:Option)
	{
		_options.remove(opt);
	}

	private var _name:String = "New Category";
	public final function getName() {
		return _name;
	}

	public function new (catName:String, options:Array<Option>)
	{
		_name = catName;
		_options = options;
	}
}

class Option
{
	public function new()
	{
		display = updateDisplay();
	}
	private var description:String = "";
	private var display:String;
	private var acceptValues:Bool = false;

	public var allowFastChange:Bool = true;
	public var isAntialiasingOption:Bool = false;

	public final function getDisplay():String
	{
		return display;
	}

	public final function getAccept():Bool
	{
		return acceptValues;
	}

	public final function getDescription():String
	{
		return description;
	}

	public function getValue():String { return throw "stub!"; };
	
	// Returns whether the label is to be updated.
	public function press():Bool { return throw "stub!"; }
	private function updateDisplay():String { return throw "stub!"; }
	public function left():Bool { return throw "stub!"; }
	public function right():Bool { return throw "stub!"; }
}



class DFJKOption extends Option
{
	private var controls:Controls;

	public function new(controls:Controls, desc:String)
	{
		super();
		this.controls = controls;

		description = desc;
	}

	public override function press():Bool
	{
		OptionsMenu.instance.openSubState(new KeyBindMenu());
		return false;
	}

	private override function updateDisplay():String
	{
		return (FlxG.save.data.esp ? "Controles" : "Key Bindings");
	}
}

//INDIE CROSS CODE ****************************

//END OF INDIE CROSS CODE ****************************

class DownscrollOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.downscroll = !FlxG.save.data.downscroll;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return FlxG.save.data.downscroll ? "Downscroll" : "Upscroll";
	}
}

class GhostTapOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.ghost = !FlxG.save.data.ghost;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return FlxG.save.data.ghost ? "Ghost Tapping" : "No Ghost Tapping";
	}
}

class AccuracyOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.accuracyDisplay = !FlxG.save.data.accuracyDisplay;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return (FlxG.save.data.esp ? "Precision " : "Accuracy ") + (!FlxG.save.data.accuracyDisplay ? (FlxG.save.data.esp ? "no" : "off") : (FlxG.save.data.esp ? "si" : "on"));
	}
}

class SongPositionOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.songPosition = !FlxG.save.data.songPosition;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return (FlxG.save.data.esp ? "Posicion de la Cancion " : "Song Position ") + (!FlxG.save.data.songPosition ? (FlxG.save.data.esp ? "no" : "off") : (FlxG.save.data.esp ? "si" : "on"));
	}
}

class DistractionsAndEffectsOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.distractions = !FlxG.save.data.distractions;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return (FlxG.save.data.esp ? "Distracciones " : "Distractions ") + (!FlxG.save.data.distractions ? (FlxG.save.data.esp ? "no" : "off") : (FlxG.save.data.esp ? "si" : "on"));
	}
}

class FlashingLightsOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.flashing = !FlxG.save.data.flashing;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return (FlxG.save.data.esp ? "Luces Parpadeantes " : "Flashing Lights ") + (!FlxG.save.data.flashing ? (FlxG.save.data.esp ? "no" : "off") : (FlxG.save.data.esp ? "si" : "on"));
	}
}

class ShadersOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.canAddShaders = !FlxG.save.data.canAddShaders;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Shaders " + (!FlxG.save.data.canAddShaders ? (FlxG.save.data.esp ? "no" : "off") : (FlxG.save.data.esp ? "si" : "on"));
	}
}

class Judgement extends Option
{
	

	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}
	
	public override function press():Bool
	{
		return true;
	}

	private override function updateDisplay():String
	{
		return "Safe Frames";
	}

	override function left():Bool {

		if (Conductor.safeFrames == 1)
			return false;

		Conductor.safeFrames -= 1;
		FlxG.save.data.frames = Conductor.safeFrames;

		Conductor.recalculateTimings();
		return false;
	}

	override function getValue():String {
		return "Safe Frames: " + Conductor.safeFrames + (FlxG.save.data.esp ? " - Menos = menos hitbox de la nota | Mas = mas hitbox de la nota." : " - Less = less note hitbox | More = more note hitbox.");
	}

	override function right():Bool {

		if (Conductor.safeFrames == 20)
			return false;

		Conductor.safeFrames += 1;
		FlxG.save.data.frames = Conductor.safeFrames;

		Conductor.recalculateTimings();
		return true;
	}
}

class FPSOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.fps = !FlxG.save.data.fps;
		(cast (Lib.current.getChildAt(0), Main)).toggleFPS(FlxG.save.data.fps);
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return (FlxG.save.data.esp ? "Contador de FPS " : "FPS Counter ") + (!FlxG.save.data.fps ? (FlxG.save.data.esp ? "no" : "off") : (FlxG.save.data.esp ? "si" : "on"));
	}
}

class ScoreScreen extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.scoreScreen = !FlxG.save.data.scoreScreen;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return (FlxG.save.data.esp ? "Pantalla de Resultados " : "Score Screen ") + (!FlxG.save.data.scoreScreen ? (FlxG.save.data.esp ? "no" : "off") : (FlxG.save.data.esp ? "si" : "on"));
	}
}




class FPSCapOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		return false;
	}

	private override function updateDisplay():String
	{
		return (FlxG.save.data.esp ? "Limite de FPS" : "FPS Cap");
	}
	
	override function right():Bool {
		if (FlxG.save.data.fpsCap >= 290)
		{
			FlxG.save.data.fpsCap = 290;
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(290);
		}
		else
			FlxG.save.data.fpsCap = FlxG.save.data.fpsCap + 10;
		(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);

		return true;
	}

	override function left():Bool {
		if (FlxG.save.data.fpsCap > 290)
			FlxG.save.data.fpsCap = 290;
		else if (FlxG.save.data.fpsCap < 60)
			FlxG.save.data.fpsCap = Application.current.window.displayMode.refreshRate;
		else
			FlxG.save.data.fpsCap = FlxG.save.data.fpsCap - 10;
		(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
		return true;
	}

	override function getValue():String
	{
		return (FlxG.save.data.esp ? "Limite de FPS: ": "Current FPS Cap: ") + FlxG.save.data.fpsCap + 
		(FlxG.save.data.fpsCap == Application.current.window.displayMode.refreshRate ? "Hz (Refresh Rate)" : "");
	}
}


class ScrollSpeedOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		return false;
	}

	private override function updateDisplay():String
	{
		return (FlxG.save.data.esp ? "Velocidad de Notas" : "Scroll Speed");
	}

	override function right():Bool {
		FlxG.save.data.scrollSpeed += 0.1;

		if (FlxG.save.data.scrollSpeed < 1)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.scrollSpeed > 4)
			FlxG.save.data.scrollSpeed = 4;
		return true;
	}

	override function getValue():String {
		return (FlxG.save.data.esp ? "Velocidad de las notas actual: " : "Current Scroll Speed: ") + HelperFunctions.truncateFloat(FlxG.save.data.scrollSpeed, 1);
	}

	override function left():Bool {
		FlxG.save.data.scrollSpeed -= 0.1;

		if (FlxG.save.data.scrollSpeed < 1)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.scrollSpeed > 4)
			FlxG.save.data.scrollSpeed = 4;

		return true;
	}
}

class CustomizeGameplay extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		trace("switch");
		FlxG.switchState(new GameplayCustomizeState());
		return false;
	}

	private override function updateDisplay():String
	{
		return (FlxG.save.data.esp ? "Customizar Gameplay" : "Customize Gameplay");
	}
}

class BotPlay extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	
	public override function press():Bool
	{
		FlxG.save.data.botplay = !FlxG.save.data.botplay;
		trace('BotPlay : ' + FlxG.save.data.botplay);
		display = updateDisplay();
		return true;
	}
	
	private override function updateDisplay():String
		return "BotPlay " + (FlxG.save.data.botplay ? (FlxG.save.data.esp ? "si" : "on") : (FlxG.save.data.esp ? "no" : "off"));
}

class MiddleScroll extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	
	public override function press():Bool
	{
		FlxG.save.data.middlescroll = !FlxG.save.data.middlescroll;
		trace('Middle Scroll: ' + FlxG.save.data.middlescroll);
		display = updateDisplay();
		return true;
	}
	
	private override function updateDisplay():String
		return "Middle Scroll " + (FlxG.save.data.middlescroll ? (FlxG.save.data.esp ? "si" : "on") : (FlxG.save.data.esp ? "no" : "off"));
}

class AntialiasingOption extends Option
{
	public function new(desc:String)
	{
		super();
		isAntialiasingOption = true;
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.antialiasing = !FlxG.save.data.antialiasing;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Antialiasing " + (!FlxG.save.data.antialiasing ? (FlxG.save.data.esp ? "no" : "off") : (FlxG.save.data.esp ? "si" : "on"));
	}
}

class CamMovement extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.camMove = !FlxG.save.data.camMove;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return (FlxG.save.data.esp ? "Movimiento de Camara " : "Camera Movement ") + (!FlxG.save.data.camMove ? (FlxG.save.data.esp ? "no" : "off") : (FlxG.save.data.esp ? "si" : "on"));
	}
}

class SnapOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.snap = !FlxG.save.data.snap;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return (FlxG.save.data.esp ? "Chasquido de Nota " : "Snap Note Hit ") + (!FlxG.save.data.snap ? (FlxG.save.data.esp ? "no" : "off") : (FlxG.save.data.esp ? "si" : "on"));
	}
}

class PracticeMode extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.practice = !FlxG.save.data.practice;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return (FlxG.save.data.esp ? "Modo Practica " : "Practice Mode ") + (!FlxG.save.data.practice ? (FlxG.save.data.esp ? "no" : "off") : (FlxG.save.data.esp ? "si" : "on"));
	}
}

class Language extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.esp = !FlxG.save.data.esp;
		display = updateDisplay();
		OptionsMenu.instance.openSubState(new ResetOptionsMenu());
		return true;
	}
	private override function updateDisplay():String
	{
		return (FlxG.save.data.esp ? "Idioma: " : "Language: ") + (FlxG.save.data.esp ? "espanol" : "english");
	}
}

class Mechanics extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.mechanics = !FlxG.save.data.mechanics;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return (FlxG.save.data.esp ? "Mecanicas " : "Mechanics ") + (!FlxG.save.data.mechanics ? (FlxG.save.data.esp ? "no" : "off") : (FlxG.save.data.esp ? "si" : "on"));
	}
}