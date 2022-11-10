package;

import lime.utils.Assets;
import flixel.FlxG;

using StringTools;

class CoolUtil
{
	public static var difficultyArray:Array<String> = ['Easy', "Normal", "Hard", "Survivor"];

	public static function difficultyFromInt(difficulty:Int):String
	{
		if (FlxG.save.data.esp)
			{
				difficultyArray.remove('Easy');
				difficultyArray.insert(0, 'Facil');

				difficultyArray.remove('Normal');
				difficultyArray.insert(1, 'Normal');

				difficultyArray.remove('Hard');
				difficultyArray.insert(2, 'Dificil');

				difficultyArray.remove('Survivor');
				difficultyArray.insert(3, 'Superviviente');
			}
		return difficultyArray[difficulty];
	}

	//Psych Engine
	inline public static function boundTo(value:Float, min:Float, max:Float):Float 
	{
		return Math.max(min, Math.min(max, value));
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}
	
	public static function coolStringFile(path:String):Array<String>
		{
			var daList:Array<String> = path.trim().split('\n');
	
			for (i in 0...daList.length)
			{
				daList[i] = daList[i].trim();
			}
	
			return daList;
		}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}
}


