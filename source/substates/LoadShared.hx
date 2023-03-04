package substates;

import flixel.FlxState;
import openfl.utils.Assets;

class LoadShared extends MusicBeatState
{	
	var target:FlxState;
	
	function new(target:FlxState)
	{
		super();
		this.target = target;
	}

	inline static public function initial(target:FlxState)
		{
			MusicBeatState.switchState(getInitial(target));
		}

	static function getInitial(target:FlxState):FlxState
		{
			Paths.setCurrentLevel("week" + PlayState.storyWeek);
			var loaded = Assets.getLibrary("shared") != null;
			
			if (!loaded)
				return new LoadShared(target);
			
			return target;
		}
}