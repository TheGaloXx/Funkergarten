package substates;

import flixel.FlxG;
import flixel.FlxState;
import openfl.utils.Assets;
import lime.app.Application;

class LoadShared extends MusicBeatState
{	
	var target:FlxState;
	
	function new(target:FlxState)
	{
		super();
		this.target = target;
	}
	
	override function create()
	{
		Application.current.window.title = (Main.appTitle + ' - Loading...');
	}

	inline static public function initial(target:FlxState)
		{
			FlxG.switchState(getInitial(target));
		}

	static function getInitial(target:FlxState):FlxState
		{
			Paths.setCurrentLevel("week" + PlayState.storyWeek);
			var loaded = isLibraryLoaded("shared");
			
			if (!loaded)
				return new LoadShared(target);
			
			return target;
		}
	
	static function isLibraryLoaded(library:String):Bool
	{
		return Assets.getLibrary(library) != null;
	}
}