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

	public var curColor:FlxColor = FlxColor.RED;

	public var altAnimSuffix:String = "";

	public function new(x:Float, y:Float, ?character:String = "none", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		var tex:FlxAtlasFrames;
		antialiasing = FlxG.save.data.antialiasing;

		switch (curCharacter)
		{
			//CHARACTERS SECTION

			case 'gf':
				// GIRLFRIEND CODE
				tex = Paths.getSparrowAtlas('characters/gf');
				frames = tex;
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				addOffset('cheer');
				addOffset('sad', -2, -21);
				addOffset('danceLeft', 0, -9);
				addOffset('danceRight', 0, -9);

				addOffset("singUP", 0, 4);
				addOffset("singRIGHT", 0, -20);
				addOffset("singLEFT", 0, -19);
				addOffset("singDOWN", 0, -20);
				addOffset('hairBlow', 45, -8);
				addOffset('hairFall', 0, -9);

				addOffset('scared', -2, -17);

				playAnim('danceRight');

				curColor = FlxColor.fromRGB(165, 0, 77);

			case 'dad':
				// DAD ANIMATION LOADING CODE
				tex = Paths.getSparrowAtlas('characters/dad', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'Dad idle dance', 24, false);
				animation.addByPrefix('singUP', 'Dad Sing Note UP', 24, false);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24, false);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24, false);
				animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24, false);

				addOffset('idle');
				addOffset("singUP", -6, 50);
				addOffset("singRIGHT", 0, 27);
				addOffset("singLEFT", -10, 10);
				addOffset("singDOWN", 0, -30);	

				curColor = FlxColor.fromRGB(175, 102, 206);

		case 'nugget':
				// DAD ANIMATION LOADING CODE
				tex = Paths.getSparrowAtlas('characters/nugget', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'nugget idle', 24, false);
				animation.addByPrefix('singUP', 'nugget up', 24, false);
				animation.addByPrefix('singRIGHT', 'nugget right', 24, false);
				animation.addByPrefix('singDOWN', 'nugget down', 24, false);
				animation.addByPrefix('singLEFT', 'nugget left', 24, false);

				addOffset('idle');
				addOffset("singUP", 18, 14);
				addOffset("singRIGHT", -8, 2);
				addOffset("singLEFT", 24, 0);
				addOffset("singDOWN", -11, -10);	

				curColor = FlxColor.fromRGB(254, 245, 154);

		case 'monty':
				// DAD ANIMATION LOADING CODE
				tex = Paths.getSparrowAtlas('characters/monty', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'IDLE', 24, false);
				animation.addByPrefix('singUP', 'UP', 24, false);
				animation.addByPrefix('singRIGHT', 'RIGHT', 24, false);
				animation.addByPrefix('singDOWN', 'DOWN', 24, false);
				animation.addByPrefix('singLEFT', 'LEFT', 24, false);

				addOffset('idle');
				addOffset("singUP", 67, 33);
				addOffset("singRIGHT", -16, -8);
				addOffset("singLEFT", 291, -17);
				addOffset("singDOWN", 92, -72);	

				curColor = FlxColor.fromRGB(253, 105, 34);

		case 'monster':
				// DAD ANIMATION LOADING CODE
				tex = Paths.getSparrowAtlas('characters/monster', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'IDLE', 24, false);
				animation.addByPrefix('singUP', 'UP', 24, false);
				animation.addByPrefix('singRIGHT', 'RIGHT', 24, false);
				animation.addByPrefix('singDOWN', 'DOWN', 24, false);
				animation.addByPrefix('singLEFT', 'LEFT', 24, false);
				animation.addByPrefix('kill', 'KILL', 24, false);

				addOffset('idle');
				addOffset("singUP", 116, 34);
				addOffset("singRIGHT", 64, -3);
				addOffset("singLEFT", 67, -1);
				addOffset("singDOWN", 94, -1);
				addOffset("kill", 109, 86);	

				curColor = FlxColor.fromRGB(233, 233, 233);

		case 'protagonist':
				// DAD ANIMATION LOADING CODE
				tex = Paths.getSparrowAtlas('characters/protagonist', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'idle', 24, false);
				animation.addByPrefix('singUP', 'up', 24, false);
				animation.addByPrefix('singRIGHT', 'right', 24, false);
				animation.addByPrefix('singDOWN', 'down', 24, false);
				animation.addByPrefix('singLEFT', 'left', 24, false);

				addOffset('idle');
				addOffset("singUP", 22, 21);
				addOffset("singRIGHT", 16, 1);
				addOffset("singLEFT", 180, 3);
				addOffset("singDOWN", 37, -19);

				curColor = FlxColor.fromRGB(128, 60, 68);

			case 'bf':
				var tex = Paths.getSparrowAtlas('characters/bf', 'shared');
				frames = tex;

				animation.addByPrefix('idle', 'BF idle dance', 24, false);

				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);

				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);

				animation.addByPrefix('hey', 'BF HEY', 24, false);
				animation.addByPrefix('hurt', 'BF hit', 24, false);
				animation.addByPrefix('attack', 'boyfriend attack', 24, false);
				animation.addByPrefix('dodge', 'boyfriend dodge', 24, false);
				animation.addByPrefix('scared', 'BF idle shaking', 24);

				addOffset('idle', -5);

				addOffset("singUP", -47, 33);
				addOffset("singRIGHT", -48, -7);
				addOffset("singLEFT", 7, -6);
				addOffset("singDOWN", -16, -50);
	
				addOffset("singUPmiss", -39, 19);
				addOffset("singRIGHTmiss", -47, 21);
				addOffset("singLEFTmiss", -9, 20);
				addOffset("singDOWNmiss", -12, -22);
	
				addOffset("hey", -2, 4);
				addOffset("hurt", 8, 20);
				addOffset("attack", 291, 273);
				addOffset("dodge", -7, -15);
				addOffset('scared', -4);

				flipX = true;

				curColor = FlxColor.fromRGB(49, 176, 209);

			case 'bf-dead':
				frames = Paths.getSparrowAtlas('characters/bf-dead', 'shared');
				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				addOffset('firstDeath', 37, 11);
				addOffset('deathLoop', 37, 5);
				addOffset('deathConfirm', 37, 69);
				playAnim('firstDeath');

				flipX = true;

				curColor = FlxColor.fromRGB(49, 176, 209);



			//yeah i know its not the most efficient way
			//but im doing it to adjust background sprites offsets
			//BACKGROUND SPRITES SECTION

			case 'example':
				frames = Paths.getSparrowAtlas('bg/example', 'shared');
				animation.addByPrefix('idle', "idle", 24, false);
				animation.addByPrefix('hey', "hey", 24, true);

				addOffset('idle');
				addOffset('hey', -8, 14);
				playAnim('idle');
		}

		dance();

		if (isPlayer)
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf'))
			{
				// var animArray
				var oldRight = animation.getByName('singRIGHT').frames;
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animation.getByName('singLEFT').frames = oldRight;

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}
	}

	override function update(elapsed:Float)
	{
		if (!curCharacter.startsWith('bf'))
		{
			if (animation.curAnim != null && animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;

			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				canSing = true;
				canIdle = true;
				holdTimer = 0;
			}
		}

		if ((curCharacter == 'monty' || curCharacter == 'monster') && animation.curAnim.name.startsWith('sing') && animation.curAnim.finished)
			{
				dance();
			}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	public function dance()
	{
		if (debugMode)
			return;

		if (curCharacter == 'gf')
			{
				if (animation.curAnim != null && !animation.curAnim.name.startsWith('hair'))
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

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0, playafterfin:Bool = false, whatanimtoplay:String = ''):Void
		{
			if (!animOffsets.exists(AnimName))
				{
					return;
				}
		
			//THIS CODE IS TAKEN FROM INDIE CROSS
			
			animation.play(AnimName, Force, Reversed, Frame);
	
			var daOffset = animOffsets.get(AnimName);
			if (animOffsets.exists(AnimName))
			{
				offset.set(daOffset[0], daOffset[1]);
			}
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

	public function sing(direction:Int, miss:Bool = false)
		{
			if (!canSing || !turn)
				return;

			var anim:String;

			// 0 = left - 1 = down - 2 = up - 3 = right

			var suffix:String = '';

			if (miss)
				suffix = 'miss';
			else
				suffix = altAnimSuffix;


			canIdle = false;

			switch(direction)
			{
				case 0:
					playAnim('singLEFT' + suffix, true);
					anim = 'singLEFT' + suffix;
				case 1:
					playAnim('singDOWN' + suffix, true);
					anim = 'singDOWN' + suffix;
				case 2:
					playAnim('singUP' + suffix, true);
					anim = 'singUP' + suffix;
				case 3:
					playAnim('singRIGHT' + suffix, true);
					anim = 'singRIGHT' + suffix;
			}

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
			if (animOffsets.exists(animacion1) && animacion1 != null)
				{
					canSing = false;
					canIdle = false;

					playAnim(animacion1, true, false, 0, false);

					animation.finishCallback = function(animacion1)
					{
						if (animAfter && (animOffsets.exists(animacion2)) && animacion2 != null)
						{
							playAnim(animacion2, true, false, 0, false);

							animation.finishCallback = function(animacion2)
								{
									playAnim('idle', true, false, 0, false);

									canSing = true;
									canIdle = true;
								}
						}
						else
						{
							playAnim('idle', true, false, 0, false);

							canSing = true;
							canIdle = true;
						}
					}
				}
		}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
}
