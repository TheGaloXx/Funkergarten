package;

import flixel.util.FlxColor;
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
						dialogue = ['dad: test test', 'bf: wait, this shouldnt work because there is no dad icon', 'dad: shut the fuck up'];
					case 'Nugget':
						dialogue = ["bf:¡Beep!", "nugget:Hola, bienvenido a la Cueva Nugget.", 'nugget:A Nugget nadie lo ama ni tampoco tiene amigos.', 'bf:¿Beep?', 'nugget:¿Curioso acerca de las formas de Nugget?', 'bf:Bop.', 'nugget:¿Una batalla de rap?:false:true', 'nugget:Interesante...'];
					case 'Pills':
						dialogue = ["bf:Beep.", 'nugget:Nugget ha hecho lo que le pediste, ahora deja a Nugget en paz.', 'bf:Skdoo bep.', 'nugget:Estás estresando al pobre Nugget, Nugget necesita tomar sus pastillas .', 'nugget:*Gulp* Mucho mejor. ¿De qué estábamos hablando?', 'bf:Beep?', "nugget:¿Rap? Solo una canción y te vas."];

						//dialogue = ["nugget:Now get out, I'm busy."];
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
						dialogue = ["bf:Beep!", "nugget:Hi, welcome to the Nugget Cave.", 'nugget:Nugget knows no love or friendship.', 'bf:Beep?', 'nugget:You are curious about the ways of Nugget?', 'bf:Bop.', 'nugget:A rap battle?:false:true', 'nugget:Interesting...'];
					case 'Pills':
						dialogue = ["bf:Beep.", 'nugget:Nugget has done what you asked, now leave nugget alone.', 'bf:Skdoo bep.', 'nugget:You are stressing poor Nugget, Nugget needs to take his pills.', 'nugget:*Gulp* Much better. What were we talking about?', 'bf:Beep?', "nugget:Rap? Just one song and you leave."];

						//dialogue = ["nugget:Now get out, I'm busy."];
					default:
						trace('uh oh');
				}
			}

			return dialogue;
		}

	public static function getCharacterColor(char:String):FlxColor
		{
			switch (char)
			{
				case 'gf':
					return FlxColor.fromRGB(165, 0, 77);
				case 'dad':
					return FlxColor.fromRGB(175, 102, 206);
				case 'nugget':
					return FlxColor.fromRGB(254, 245, 154);
				case 'monty':
					return FlxColor.fromRGB(253, 105, 34);
				case 'monster':
					return FlxColor.fromRGB(233, 233, 233);
				case 'protagonist' | 'protagonist-pixel':
					return FlxColor.fromRGB(116, 166, 185);
				case 'bf' | 'bf-pixel':
					return FlxColor.fromRGB(49, 176, 209);
				default:
					return 0xffffff;
			}
		}
}


