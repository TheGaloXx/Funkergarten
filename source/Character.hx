package;

import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'none';
	public var turn:Bool = true;

	public var canSing:Bool = true;
	public var canIdle:Bool = true;

	public var holdTimer:Float = 0;

	public var curColor:String = "#000000";

	public var altAnimSuffix:String = "";

	public var camPos:Array<Float> = [100, 100];

	public function new(x:Float, y:Float, ?character:String = "none", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		var tex:FlxAtlasFrames;

		switch (curCharacter)
		{
			case 'example':
				frames = Paths.getSparrowAtlas('bg/example', 'shared');
				animation.addByPrefix('idle', "idle", 24, true);
				animation.addByPrefix('hey', "hey", 24, true);

				addOffset('idle');
				addOffset('hey', -8, 14);
				playAnim('idle');

			default:
				tex = Paths.getSparrowAtlas('characters/' + curCharacter, (curCharacter == 'polla' ? 'shit' : 'shared'));
				frames = tex;
				parseDataFile();
		}

		dance();

		if (isPlayer)
		{
			if (!curCharacter.startsWith('bf'))
			{
				flipX = !flipX;
				flipAnims();
			}
		}
	}

	override function update(elapsed:Float)
	{
		if (!curCharacter.startsWith('bf'))
		{
			if (animation.curAnim != null && animation.curAnim.name.startsWith('sing'))
				holdTimer += elapsed;

			var dadVar:Float = 4;

			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				canSing = true;
				canIdle = true;
				holdTimer = 0;
			}
		}

		if ((curCharacter == 'monty' || curCharacter == 'monster') && animation.curAnim.name.startsWith('sing') && animation.curAnim.finished)
				dance();

		super.update(elapsed);
	}

	private var danced:Bool = false;

	public function dance()
	{
		if (debugMode)
			return;

		if (curCharacter == 'gf')
			{
				//if (animation.curAnim != null)
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}
			}
		else
			{
				if (canIdle)
					playAnim('idle' + altAnimSuffix);
			}
	}

	private function flipAnims(hasMiss:Bool = false)
	{
		if (curCharacter.startsWith('bf'))
			return;

		var suffix:String = (hasMiss ? "miss" : "");

		var oldRight = animation.getByName('singRIGHT' + suffix).frames;
		animation.getByName('singRIGHT' + suffix).frames = animation.getByName('singLEFT').frames;
		animation.getByName('singLEFT' + suffix).frames = oldRight;

		if (animation.getByName('singRIGHTmiss') != null && animation.getByName('singLEFTmiss') != null)
		{
			flipAnims(true);
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0, playafterfin:Bool = false, whatanimtoplay:String = ''):Void
		{
			if (!animOffsets.exists(AnimName))
				return;
		
			//THIS CODE IS TAKEN FROM INDIE CROSS
			
			animation.play(AnimName, Force, Reversed, Frame);
	
			var daOffset = animOffsets.get(AnimName);
			if (animOffsets.exists(AnimName))
				offset.set(daOffset[0], daOffset[1]);
			else
				offset.set(0, 0);
	
			if (playafterfin)
				{
					var idletimer:FlxTimer;
					
					var num = animation.animNAMES.indexOf(AnimName);
					idletimer = new FlxTimer().start(animation.animFRAMES[num]/animation.animFPS[num]+0.05, function(tmr:FlxTimer)
					{
						if (whatanimtoplay == '')
							dance();
						else
							playAnim(whatanimtoplay,true);
					});
				}
		}

	var singDirections:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public function sing(direction:Int, miss:Bool = false)
		{
			if (!canSing || !turn)
				return;

			var suffix:String = (miss ? 'miss' : altAnimSuffix);

			canIdle = false;

			playAnim(singDirections[direction] + suffix, true);
			var anim:String = singDirections[direction] + suffix;

			animation.finishCallback = function(anim)
				{
					if (curCharacter.startsWith('bf'))
						canIdle = true;
				}
		}

	/* explicacion 'rapida':
	si existe la animacion 1 y no es null (vacio)
	{
		no puede cantar ni hacer idle, y se hace la animacion1, al terminar la animacion se hace el idle y se puede cantar y hacer idle
		PERO
		si se quiere hacer otra animacion (animAfter) y existe la animacion2 y no es null (vacio)
		se hace la animacion 2 y al finalizar se hace idle y se puede cantar y hacer idle
	}
	*/

	public function animacion(animacion1:String, animAfter:Bool = false, animacion2:String = null):Void
		{
			if (!animOffsets.exists(animacion1)) //animation doesnt have offsets but no problem i guess
				{
					trace('Anim "' + animacion1 + '" offsets are null');
				}

			if (animation.getByName(animacion1) == null) //animation doesnt exist so problem i guess
			{
				trace('Anim "' + animacion1 + '" is null');
				return;
			}

					canSing = false;
					canIdle = false;

					playAnim(animacion1, true, false, 0, false);

					animation.finishCallback = function(animacion1)
					{
						if (animAfter)
						{
							if (!animOffsets.exists(animacion2)) //animation doesnt have offsets but no problem i guess
								{
									trace('Anim "' + animacion2 + '" offsets are null');
								}
				
							if (animation.getByName(animacion2) == null) //animation doesnt exist so problem i guess
							{
								trace('Anim "' + animacion2 + '" is null');
								return;
							}

							playAnim(animacion2, true, false, 0, false);

							animation.finishCallback = function(animacion2)
								{
									//playAnim('idle', true, false, 0, false);

									canSing = true;
									canIdle = true;
								}
						}
						else
						{
							//playAnim('idle', true, false, 0, false);

							canSing = true;
							canIdle = true;
						}
					}
		}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	//kade 1.8
	function parseDataFile()
		{
			trace('Generating character (${curCharacter}) from JSON data...');
	
			var jsonData = Paths.loadJSON('characters/${curCharacter}', (curCharacter == 'polla' ? 'shit' : 'preload'));
			if (jsonData == null)
			{
				trace('Failed to parse JSON data for character ${curCharacter}');
				return;
			}

			var charData:CharacterData = cast jsonData;
	
			for (anim in charData.animations)
			{	
				if (anim.looped == null)
					anim.looped = false;
				if (anim.offsets == null)
					anim.offsets = [0, 0];

				addAnim(anim.frameIndices != null, anim.name, anim.prefix, anim.frameIndices, anim.looped, anim.offsets);
			}

			//if (charData.camPositions == null || charData.camPositions[0] == null || charData.camPositions[1] == null)
			//	charData.camPositions == [100, 100];
			if (charData.antialiasing == null)
				charData.antialiasing = KadeEngineData.settings.data.antialiasing;
			if (charData.sizeMult == null)
				charData.sizeMult = [1, 1];


			curColor = charData.color;
			antialiasing = charData.antialiasing;
			setGraphicSize(Std.int(width * charData.sizeMult[0]), Std.int(height * charData.sizeMult[1]));
			trace(width + " - " + height + " - " + this.getGraphicMidpoint() + " - " + this.getGraphicMidpoint().x + " - " + this.getGraphicMidpoint().y);
			//camPos = [getGraphicMidpoint().x + charData.camPositions[0], getGraphicMidpoint().y + charData.camPositions[1]];
			//lets see where this shit crashes
			//camPos = [2, 2];
			//camPos = charData.camPositions;
			//camPos = [getGraphicMidpoint().x + 1, getGraphicMidpoint().y + 1];
			trace(charData.camPositions); //GOD FUCKING DAMN IT WAS BECAUSE GF CAM POSITIONS WERE NULL AIUGHGUHGUHGHGHGDHHD		BUT WHY THE FUCK DID IT HAPPEN, I LITERALLY TYPED "if shit's null, be 100".   ughhh fuck it, now you HAVE to put the cam pos or else youre fucked
			camPos = [getGraphicMidpoint().x + charData.camPositions[0], getGraphicMidpoint().y + charData.camPositions[1]];

			trace(animationsLol);
		}

		var animationsLol:Array<String> = [];

		function addAnim(byIndices:Bool, name:String, prefix:String, indices:Array<Int>, looped:Bool, offsets:Array<Int>)
		{
			if (byIndices)
				{
					animation.addByIndices(name, prefix, indices, "", 24, looped);
				}
				else
				{
					animation.addByPrefix(name, prefix, 24, looped);
				}

			animationsLol.push(name + " (" + prefix + ") | " + "[" + offsets[0] + " - " + offsets[1] + ")\n");
			addOffset(name, offsets[0], offsets[1]);
		}
}

//kade 1.8
typedef CharacterData =
{
	var color:String;
	var antialiasing:Null<Bool>;
	var camPositions:Null<Array<Float>>; //if i keep having to put Null in every fucking variable im gonna lose my mind
	var sizeMult:Array<Float>;

	var animations:Array<AnimationData>;
}

typedef AnimationData =
{
	var name:String;
	var prefix:String;
	var looped:Null<Bool>;
	var ?offsets:Array<Int>;
	var ?frameIndices:Array<Int>;
}
