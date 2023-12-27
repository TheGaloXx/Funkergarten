package objects;

using StringTools;

class Character extends flixel.FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;
	private var camOffset:Int = 30;

	//Gameplay shit
	public var isPlayer:Bool = false;
	public var turn:Bool = true;
	public var canSing:Bool = true;
	public var canIdle:Bool = true;
	public var holdTimer:Float = 0;
	public var altAnimSuffix(default, set):String = "";

	//JSON shit
	public var curCharacter:String = 'none';
	public var curColor:String = "#000000";
	public var camPos:Array<Float> = [100, 100];
	public var camSingPos = new flixel.math.FlxPoint();

	public function new(x:Float, y:Float, ?character:String = "none", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		var tex:flixel.graphics.frames.FlxAtlasFrames;

		switch (curCharacter)
		{
			default:
				tex = Paths.getSparrowAtlas('characters/' + curCharacter, (curCharacter == 'polla' ? 'shit' : 'shared'));
				frames = tex;
				parseDataFile();
		}

		dance();

		if (isPlayer && !curCharacter.startsWith('bf'))
		{
			flipX = !flipX;
			flipAnims();
		}
	}

	override function update(elapsed:Float)
	{
		if (!isPlayer)
		{
			if (animation.curAnim != null && animation.curAnim.name.startsWith('sing'))
				holdTimer += elapsed;

			var dadVar:Float = 4;

			if (holdTimer >= funkin.Conductor.stepCrochet * dadVar * 0.001)
			{
				canSing = true;
				canIdle = true;
				holdTimer = 0;
			}
		}

		updateAnimation(elapsed);

		return;

		super.update(elapsed);
	}

	private var danced:Bool = false;

	public function dance()
	{
		if (debugMode) return;

		if (canIdle) playAnim(/* altAnimSuffix + */ 'idle');
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
			if (!animExists(AnimName)) return;
		
			animation.play(AnimName, Force, Reversed, Frame);
	
			var daOffset = animOffsets.get(AnimName);
			if (animOffsets.exists(AnimName)) offset.set(daOffset[0], daOffset[1]);
			else offset.set(0, 0);
		}

	var singDirections:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public function sing(direction:Int, miss:Bool = false)
		{
			if (!canSing || !turn) return;

			canIdle = false;

			playAnim(altAnimSuffix + singDirections[direction] + (miss ? 'miss' : ''), true);
			var anim:String = singDirections[direction] + altAnimSuffix;

			animation.finishCallback = function(cockkk:String) if (isPlayer && cockkk == anim) canIdle = true;

			if (data.KadeEngineData.settings.data.camMove && !data.KadeEngineData.settings.data.lowQuality)
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

	public function animacion(AnimName:String):Void
		{
			if (!animExists(AnimName)) return;

			canSing = false;
			canIdle = false;

			playAnim(AnimName, true, false, 0);

			animation.finishCallback = function(cock:String)
			{
				if (cock == AnimName)
				{
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

			charData.antialiasing ??= data.KadeEngineData.settings.data.antialiasing;
			charData.sizeMult ??= [1, 1];
			curColor = charData.color;
			antialiasing = charData.antialiasing;
			setGraphicSize(Std.int(width * charData.sizeMult[0]), Std.int(height * charData.sizeMult[1]));
			updateHitbox();
			camPos = [getGraphicMidpoint().x + charData.camPositions[0], getGraphicMidpoint().y + charData.camPositions[1]];

			trace(animationsLol);
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
			trace('Anim "' + animName + '" offsets are null');

		if (animation.getByName(animName) == null) //animation doesnt exist so problem i guess
		{
			trace('Anim "' + animName + '" is null');
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
		canIdle = true; // idk man
		canSing = true;

		return suffix;
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
