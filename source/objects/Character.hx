package objects;

import flixel.FlxG;
import funkin.Conductor;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import data.GlobalData;

using StringTools;

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Float>>;
	public var debugMode:Bool = false;

	//Gameplay shit
	public var isPlayer:Bool = false;
	public var holdTimer:Float = 0;
	public var altAnimSuffix(default, set):String = "";
	private var specialAnim:Bool = false;
	private var canIdle:Bool = true;
	private static inline final camOffset:Int = 30;

	//JSON shit
	public var curCharacter:String = 'none';
	public var curColor:String = "#000000";
	public var camPos:Array<Float> = [100, 100];
	public var camSingPos = new FlxPoint();

	public function new(x:Float, y:Float, ?character:String = "none", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Float>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		frames = Paths.getSparrowAtlas('characters/' + curCharacter, (curCharacter == 'polla' ? 'shit' : 'shared'));
		parseDataFile();

		dance();

		if (isPlayer && !curCharacter.startsWith('bf'))
		{
			flipX = !flipX;
			flipAnims();
		}
	}

	override function update(elapsed:Float)
	{
		if (!isMonsterAttack())
		{
			if ((isPlayer && !debugMode) || !isPlayer)
			{
				if (animation.curAnim != null && animation.curAnim.name.startsWith('sing'))
					holdTimer += elapsed;
				else
					holdTimer = 0;
			}

			if (!isPlayer)
			{
				if (holdTimer >= getHoldTime())
				{
					dance();
					holdTimer = 0;
				}
			}
		}

		updateAnimation(elapsed);

		return;

		super.update(elapsed);
	}

	public function dance()
	{
		if (!canIdle || specialAnim || debugMode || isMonsterAttack())
			return;

		playAnim(/* altAnimSuffix + */ 'idle');
	}

	private function flipAnims(hasMiss:Bool = false)
	{
		var suffix:String = (hasMiss ? "miss" : "");

		var oldRight = animation.getByName('singRIGHT' + suffix).frames;
		animation.getByName('singRIGHT' + suffix).frames = animation.getByName('singLEFT').frames;
		animation.getByName('singLEFT' + suffix).frames = oldRight;

		if (animation.getByName('singRIGHTmiss') != null && animation.getByName('singLEFTmiss') != null)
			flipAnims(true);
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (!animExists(AnimName) || isMonsterAttack() || (animation.curAnim != null && animation.curAnim.looped && !Force)) return;
	
		canIdle = false;

		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName)) offset.set(daOffset[0], daOffset[1]);
		else offset.set(0, 0);

		if (AnimName == 'idle')
			canIdle = true;
		else
		{
			if (!animation.getByName(AnimName).looped)
			{
				animation.finishCallback = (daAnim:String) ->
				{
					if (daAnim == AnimName)
					{
						if (!debugMode)
						{
							if (isPlayer && AnimName.endsWith('miss'))
								playAnim('idle', false, false, 10);
							else if (daAnim != 'idle')
								canIdle = true;
						}
						
					}
				}
			}
		}
	}

	var singDirections:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public function sing(direction:Int, miss:Bool = false)
	{
		if (specialAnim || isMonsterAttack())
			return;

		playAnim(altAnimSuffix + singDirections[direction] + (miss ? 'miss' : ''), true);
		var anim:String = singDirections[direction] + altAnimSuffix;

		if (GlobalData.settings.singCamMoveEnabled && !GlobalData.settings.lowQuality)
		{
			switch (direction)
			{
				case 2: camSingPos.set(0, -camOffset);
				case 3: camSingPos.set(camOffset, 0);
				case 1: camSingPos.set(0, camOffset);
				case 0: camSingPos.set(-camOffset, 0);
			}
		}
	}

	public function playSpecialAnim(AnimName:String):Void
	{
		if (!animExists(AnimName) || isMonsterAttack()) return;

		canIdle = false;
		specialAnim = true;

		playAnim(AnimName, true, false, 0);

		if (!animation.getByName(AnimName).looped)
		{
			animation.finishCallback = function(cock:String)
			{
				if (cock == AnimName)
				{
					specialAnim = false;
					canIdle = true;
				}
			}
		}
	}

	private inline function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets.set(name, [x, y]);
	}

	//kade 1.8
	function parseDataFile()
	{
		trace('Generating character (${CoolUtil.firstLetterUpperCase(curCharacter)}) from JSON data.');

		var jsonData = Paths.loadJSON('characters/${curCharacter}', (curCharacter == 'polla' ? 'shit' : 'preload'));
		if (jsonData == null)
		{
			trace('Failed to parse JSON data for character ${curCharacter}');
			return;
		}

		var charData:CharacterData = cast jsonData;

		for (anim in charData.animations)
		{
			anim.looped ??= false;
			anim.offsets ??= [0, 0];

			addAnim(anim.frameIndices != null, anim.name, anim.prefix, anim.frameIndices, anim.looped, anim.offsets);
		}

		charData.antialiasing ??= GlobalData.settings.antialiasingEnabled;
		charData.sizeMult ??= [1, 1];
		curColor = charData.color;
		antialiasing = charData.antialiasing;
		setGraphicSize(Std.int(width * charData.sizeMult[0]), Std.int(height * charData.sizeMult[1]));
		updateHitbox();
		camPos = [getGraphicMidpoint().x + charData.camPositions[0], getGraphicMidpoint().y + charData.camPositions[1]];
	}

	var animationsLol:Array<String> = [];

	function addAnim(byIndices:Bool, name:String, prefix:String, indices:Array<Int>, looped:Bool, offsets:Array<Int>)
	{
		if (byIndices)
			animation.addByIndices(name, prefix, indices, "", 24, looped);
		else
			animation.addByPrefix(name, prefix, 24, looped);

		animationsLol.push('\n' + name + " (" + prefix + ")       |   " + "(" + offsets[0] + " - " + offsets[1] + ")");
		addOffset(name, offsets[0], offsets[1]);
	}

	private function animExists(animName:String):Bool
	{
		if (!animOffsets.exists(animName)) //animation doesnt have offsets but no problem i guess
			FlxG.log.warn('Anim "' + animName + '" offsets are null');

		if (animation.getByName(animName) == null) //animation doesnt exist so problem i guess
		{
			FlxG.log.warn('Anim "' + animName + '" is null');
			return false;
		}

		return true;
	}

	// WHAT THE FUCK IS A SET FUNCTION
	function set_altAnimSuffix(suffix:String):String
	{
		altAnimSuffix = suffix;

		trace('Alt animation suffix: $suffix.');

		dance();

		return suffix;
	}

	private /* inline */ function isMonsterAttack():Bool
	{
		final animIsNull:Bool = this.animation.curAnim == null;

		if (animIsNull)
			return false;

		final isDebugMode:Bool = this.debugMode;
		final isPlayerMode:Bool = this.isPlayer;
		final isMonster:Bool = this.curCharacter == 'monster';

		final isKillAnim:Bool = this.animation.curAnim.name == 'kill';
		final isAttackAnim:Bool = this.animation.curAnim.name == 'attack-loop';
		final isMonsterAnim:Bool = isKillAnim || isAttackAnim;

		return !isDebugMode && !isPlayerMode && isMonster && isMonsterAnim;
	}

	public inline function getHoldTime(singSteps:Int = 4):Float
	{
		return Conductor.stepCrochet * singSteps * 0.001;
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

class CharData
{
	public var char:String;
	public var color:String;
	public var antialiasing:Null<Bool>;

	public function new(char:String)
	{
		var jsonData:Dynamic = Paths.loadJSON('characters/${char}', (char == 'polla' ? 'shit' : 'preload'));
		if (jsonData == null)
		{
			trace('Failed to parse JSON data for character ${char}');
			return;
		}

		var charData:CharacterData = cast jsonData;

		this.char = char;
		this.color = charData.color;
		this.antialiasing = charData.antialiasing;

		if (antialiasing != false)
		{
			antialiasing = FlxSprite.defaultAntialiasing;
		}
	}
}