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

	var hasSingAnims:Bool = true;

	public var camPos:Array<Float> = [];

	public function new(x:Float, y:Float, ?character:String = "none", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		var tex:FlxAtlasFrames;
		antialiasing = FlxG.save.data.antialiasing;

		//default anims
		tex = Paths.getSparrowAtlas('characters/' + curCharacter, 'shared');
		frames = tex;
		animation.addByPrefix('idle', 'idle', 24, false);
		animation.addByPrefix('singUP', 'up', 24, false);
		animation.addByPrefix('singRIGHT', 'right', 24, false);
		animation.addByPrefix('singDOWN', 'down', 24, false);
		animation.addByPrefix('singLEFT', 'left', 24, false);

		switch (curCharacter)
		{
			//CHARACTERS SECTION

			case 'gf':
				// GIRLFRIEND CODE
				hasSingAnims = false;
				animation.remove('idle');
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				addOffset('cheer');
				addOffset('sad', -2, -21);
				addOffset('danceLeft', 0, -9);
				addOffset('danceRight', 0, -9);

				playAnim('danceRight');

				camPos = [getGraphicMidpoint().x, getGraphicMidpoint().y];

			case 'dad':
				addOffset('idle');
				addOffset("singUP", -6, 50);
				addOffset("singRIGHT", 0, 27);
				addOffset("singLEFT", -10, 10);
				addOffset("singDOWN", 0, -30);	

				camPos = [getGraphicMidpoint().x += 200, getGraphicMidpoint().y -= 35];

		case 'nugget':
				addOffset('idle');
				addOffset("singUP", 18, 14);
				addOffset("singRIGHT", -8, 2);
				addOffset("singLEFT", 24, 0);
				addOffset("singDOWN", -11, -10);
				
				camPos = [getGraphicMidpoint().x += 160, getGraphicMidpoint().y -= 25];

		case 'monty':
				addOffset('idle');
				addOffset("singUP", 67, 33);
				addOffset("singRIGHT", -16, -8);
				addOffset("singLEFT", 291, -17);
				addOffset("singDOWN", 92, -72);	

				camPos = [getGraphicMidpoint().x + 120, getGraphicMidpoint().y -= 30];

		case 'monster':
				animation.addByPrefix('kill', 'KILL', 24, false);

				addOffset('idle');
				addOffset("singUP", 116, 34);
				addOffset("singRIGHT", 64, -3);
				addOffset("singLEFT", 67, -1);
				addOffset("singDOWN", 94, -1);
				addOffset("kill", 109, 86);	

				camPos = [getGraphicMidpoint().x += 180, getGraphicMidpoint().y -= 25];

		case 'protagonist':
				addOffset('idle');
				addOffset("singUP", 22, 21);
				addOffset("singRIGHT", 16, 1);
				addOffset("singLEFT", 180, 3);
				addOffset("singDOWN", 37, -19);

				camPos = [getGraphicMidpoint().x += 160, getGraphicMidpoint().y -= 25];

		case 'noCard':
				hasSingAnims = false;

				addOffset('idle');

				camPos = [0, 0];

		case 'protagonist-pixel':
				addOffset('idle');
				addOffset("singUP", 80, 43);
				addOffset("singRIGHT", -4, -1);
				addOffset("singLEFT", 51, -9);
				addOffset("singDOWN", 34, -28);

				animation.addByPrefix('noCard', 'no card', 24, false);
				addOffset("noCard", 47, 45);

				if (FlxG.save.data.gotCardDEMO)
				{
					addOffset("singUP", 47, 45);
					animation.getByName('singUP').frames = animation.getByName('noCard').frames;
					//animation.remove('singUP');
					//animation.addByPrefix('singUP', 'no card', 24, false);
				}

				setGraphicSize(Std.int(width * 0.95), Std.int(height * 0.95));

				camPos = [getGraphicMidpoint().x += 180, getGraphicMidpoint().y -= 75];

			case 'bf':
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
				//animation.addByPrefix('attack', 'boyfriend attack', 24, false);
				animation.addByPrefix('dodge', 'boyfriend dodge', 24, false);
				//animation.addByPrefix('scared', 'BF idle shaking', 24);

				addOffset('idle', -5);

				addOffset("singUP", -54, 16);
				addOffset("singRIGHT", -111, 6);
				addOffset("singLEFT", 7, 6);
				addOffset("singDOWN", -36, -13);
	
				addOffset("singUPmiss", -36);
				addOffset("singRIGHTmiss", -67, 4);
				addOffset("singLEFTmiss", -26, 6);
				addOffset("singDOWNmiss", -25, -1);
	
				addOffset("hey", -29, 4);
				addOffset("hurt", -48, 8);
				//addOffset("attack", 291, 273);
				addOffset("dodge", -20, 4);
				//addOffset('scared', -4);

				flipX = true;

				setGraphicSize(Std.int(width * 0.9), Std.int(height * 0.9)); //head is big af

				camPos = [getGraphicMidpoint().x -= 150, getGraphicMidpoint().y -= 15];

			case 'bf-pixel':
				animation.addByPrefix('idle', 'BF idle dance', 24, false);

				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);

				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);

				addOffset('idle', 0);

				addOffset("singUP", -24, 21);
				addOffset("singRIGHT", -43, -2);
				addOffset("singLEFT", 12, -5);
				addOffset("singDOWN", 13, -20);
	
				addOffset("singUPmiss", -12, 23);
				addOffset("singRIGHTmiss", -50, -2);
				addOffset("singLEFTmiss", 22, -5);
				addOffset("singDOWNmiss", 20, -23);

				flipX = true;

				//setGraphicSize(Std.int(width * 2.5), Std.int(height * 2.5)); this made the sprite look like ass so I made it bigger in the .fla instead of this
				setGraphicSize(Std.int(width * 0.9), Std.int(height * 0.9)); //now I had to make it smaller lmaooo

				camPos = [getGraphicMidpoint().x -= 250, getGraphicMidpoint().y -= 75];

			case 'bf-dead':
				hasSingAnims = false;
				animation.remove('idle');
				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				addOffset('firstDeath', 37, 11);
				addOffset('deathLoop', 36, 8);
				addOffset('deathConfirm', 36, 8);
				playAnim('firstDeath');

				flipX = true;

				setGraphicSize(Std.int(width * 0.9), Std.int(height * 0.9)); //head is big af

				camPos = [getGraphicMidpoint().x, getGraphicMidpoint().y];

			case 'bf-pixel-dead':
				hasSingAnims = false;
				animation.remove('idle');
				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				addOffset('firstDeath', 0, 0);
				addOffset('deathLoop', 0, 0);
				addOffset('deathConfirm', 0, 0);
				playAnim('firstDeath');

				flipX = true;

				//setGraphicSize(Std.int(width * 5), Std.int(height * 2.5)); this made the sprite look like ass so I made it bigger in the .fla instead of this
				setGraphicSize(Std.int(width * 1.8), Std.int(height * 0.9)); //now I had to make it smaller lmaooo

				camPos = [getGraphicMidpoint().x -= 75, getGraphicMidpoint().y -= 10];

			//yeah i know its not the most efficient way
			//but im doing it to adjust background sprites offsets
			//BACKGROUND SPRITES SECTION

			case 'example':
				hasSingAnims = false;
				frames = Paths.getSparrowAtlas('bg/example', 'shared');
				animation.addByPrefix('hey', "hey", 24, true);

				addOffset('idle');
				addOffset('hey', -8, 14);
				playAnim('idle');
		}

		if (!hasSingAnims)
		{
			animation.remove('singUP');
			animation.remove('singDOWN');
			animation.remove('singRIGHT');
			animation.remove('singLEFT');
		}

		curColor = CoolUtil.getCharacterColor(curCharacter);

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
