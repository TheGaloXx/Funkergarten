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
		else
			{
				difficultyArray.remove('Facil');
				difficultyArray.insert(0, 'Easy');

				difficultyArray.remove('Normal');
				difficultyArray.insert(1, 'Normal');

				difficultyArray.remove('Dificil');
				difficultyArray.insert(2, 'Hard');

				difficultyArray.remove('Superviviente');
				difficultyArray.insert(3, 'Survivor');
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

	public static function getDialogue():Array<String>
		{
			var dialogue:Array<String> = ['dad:a:false:false', 'bf:a:true:true'];
			var song = PlayState.SONG.song;

			if (FlxG.save.data.esp)
			{
				switch (song)
				{
					// 	character:dialogue:angry:yellow
	// example: nugget:hi im nugget:*scream*:highlighted text
					case 'DadBattle':
						dialogue = ['dad: test test', 'bf: wait, this should work because there is no dad icon', 'dad: shut the fuck up'];
					case 'Monday':
						dialogue = ['dad: test test', 'bf: beep'];
					case 'Nugget':
						dialogue = ['nugget:AIHJSEDFIOAJSIOEDJFfedsfsfs', 'bf:Beep', 'protagonist:jaja xd lmao lol ñ', 'nugget:¡¡¡NO!!!:true'];
					default:
						trace('uh oh');
				}
			}
			else
			{
				switch (song)
				{
					// 	character:dialogue:angry:yellow
	// example: nugget:hi im nugget:*scream*:highlighted text
					case 'DadBattle':
						dialogue = ['protagonist:Normal text', 'protagonist:Angry text:true', 'protagonist:Hint text::true', 'protagonist:Angry hint text:true:true'];
					case 'Monday':
						dialogue = ['protagonist:I banged your mom.', 'bf: beep'];
					case 'Nugget':
						dialogue = ["nugget:Nugget's nuggets are as squishy as they are tasty.", 'bf:Beep bop', 'protagonist:*Throws the knife in the cave*', 'nugget:NUGGET SAID NO!!!:true'];
					default:
						trace('uh oh');
				}
			}

			return dialogue;
		}
}


