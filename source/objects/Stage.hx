package objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;

using StringTools;

class Stage extends funkin.MusicBeatState
{
	public var stage:String = 'stage'; // the stage name

	public var camZoom:Float = 1; // the stage zoom

	public var backgroundSprites:FlxTypedGroup<objects.BGSprite>; // a group for the animated sprites

	public var positions:Map<String, Array<Float>> = [
		"bf" => [770, 450],
		"dad" => [100, 100],
		"gf" => [400, 130],
		"third" => [-100, 100]
	];

	public function new(daStage:String)
	{
		super();

		this.stage = daStage;

		backgroundSprites = new FlxTypedGroup<objects.BGSprite>();
		add(backgroundSprites);

		states.PlayState.curStage = daStage;

		switch (daStage)
		{
			case 'stage':
				camZoom = 0.9;

				var bg1 = new FlxSprite(0, 0).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.WHITE);
				bg1.screenCenter();
				bg1.alpha = 0.5;
				add(bg1);

			/*
				bg2 = new objects.BGSprite('example', 1090, 510, true, 0.95, 0.95);
				bg2.animation.addByPrefix('idle', 'idle', 12, false);
				bg2.animation.addByPrefix('hey', 'hey', 12, false);
				bg2.addOffset('idle');
				bg2.addOffset('hey', -8, 14);

				backgroundSprites.add(bg2);
				add(bg2);
			 */

			case 'room':
				camZoom = 0.9;

				var bg1:objects.BGSprite = new objects.BGSprite('room', 0, 0, false);
				bg1.setGraphicSize(Std.int(bg1.width * 2));
				bg1.screenCenter();
				backgroundSprites.add(bg1);

				var bg2:objects.BGSprite = new objects.BGSprite('light', 0, 0, false, 0.95, 0.95, true);
				bg2.setGraphicSize(Std.int(bg2.width * 2));
				bg2.screenCenter();
				bg2.blend = ADD;
				bg2.alpha = 0.9;
				backgroundSprites.add(bg2);

				if (data.KadeEngineData.settings.data.distractions)
				{
					var bg3:objects.BGSprite = new objects.BGSprite('room-pixel', 0, 0, false);
					bg3.setGraphicSize(Std.int((bg3.width * 2) * 0.775));
					bg3.screenCenter();
					bg3.alpha = 0.0001;
					backgroundSprites.add(bg3);

					var bg4:objects.BGSprite = new objects.BGSprite('light-pixel', 0, 0, false, 0.95, 0.95, true);
					bg4.setGraphicSize(Std.int((bg4.width * 2) * 0.775));
					bg4.setPosition(-340, -80);
					bg4.blend = ADD;
					bg4.alpha = 0.6; //shit crashes with alpha 0.0001 for some reason. I believe it is because of the blend effect
					//bg4.alpha = 0.0001; //bg4.alpha = 0.6;
					backgroundSprites.add(bg4);
				}

				setPositions(100, 250, 680, 212, 340, -10);

			case 'newRoom':
				camZoom = 0.9;

				var bg1:objects.BGSprite = new objects.BGSprite('newRoom', 0, 0, false);
				bg1.setGraphicSize(Std.int(bg1.width * 1.2));
				bg1.screenCenter();
				backgroundSprites.add(bg1);

				var bg2:objects.BGSprite = new objects.BGSprite('newLight', 0, 0, false, 0.95, 0.95, true);
				bg2.setGraphicSize(Std.int(bg2.width * 1.2));
				bg2.blend = ADD;
				bg2.alpha = 0.5;
				bg2.screenCenter();
				backgroundSprites.add(bg2);

				var bg3:objects.BGSprite = new objects.BGSprite('bed', 0, 0, false, 1.5, 1.5, true);
				bg3.setGraphicSize(Std.int(bg3.width * 1.2));
				bg3.screenCenter();
				bg3.y -= 200;
				backgroundSprites.add(bg3);

				setPositions(-50, 170, 800, 250, 280, -100);

			case 'room-pixel':
				camZoom = 0.9;

				var bg1:objects.BGSprite = new objects.BGSprite('room-pixel', 0, 0, false);
				bg1.setGraphicSize(Std.int((bg1.width * 2) * 0.775));
				bg1.screenCenter();
				backgroundSprites.add(bg1);

				var bg2:objects.BGSprite = new objects.BGSprite('light-pixel', 0, 0, false, 0.95, 0.95, true);
				bg2.setGraphicSize(Std.int((bg2.width * 2) * 0.775));
				bg2.setPosition(-340, -80);
				bg2.blend = ADD;
				bg2.alpha = 0.6;
				backgroundSprites.add(bg2);

				setPositions(200, 312, 922, 276, 376, -14);

			case 'cave':
				camZoom = 0.5;

				var bg1:objects.BGSprite = new objects.BGSprite('caveBG', 0, 0, false, 1, 1);
				backgroundSprites.add(bg1);

				var bg2:objects.BGSprite = new objects.BGSprite('caveFront', 0, 0, false, 1, 1);
				backgroundSprites.add(bg2);

				var bg3:objects.BGSprite = new objects.BGSprite('caveShadows', 0, 0, false, 1, 1);
				backgroundSprites.add(bg3);

				setPositions(1040, 1200, 1890, 1170, 2280, 970);

			case 'closet':
				camZoom = 0.7;

				var bg1:objects.BGSprite = new objects.BGSprite('closet', 0, 0, false);
				backgroundSprites.add(bg1);

				var bg2:objects.BGSprite = new objects.BGSprite('closetFront', 0, 0, false, 1.1, 1.2, true);
				backgroundSprites.add(bg2);

				setPositions(390, 185, 1300, 550, 2280, 970);

			case 'principal':
				camZoom = 0.55;

				var bg1:objects.BGSprite = new objects.BGSprite('principal', 0, 0, false);
				bg1.screenCenter();
				backgroundSprites.add(bg1);

				setPositions(-450, -120, 1050, 340, 1300, 110);

			case 'void':
				camZoom = 0.7;

				var bg1:objects.BGSprite = new objects.BGSprite('mcdonalds', 0, 0, false, 1, 1, false, 'shit');
				bg1.screenCenter();
				backgroundSprites.add(bg1);

				setPositions(170, 750, 900, 530);

			case 'cafeteria':
				camZoom = 0.7;

				var bg1:objects.BGSprite = new objects.BGSprite('cafeteria', 0, 0, false);
				bg1.screenCenter();
				backgroundSprites.add(bg1);

				setPositions(100, 310, 850, 240, 0, 0);

			default:
				camZoom = 0.9;
				states.PlayState.curStage = 'stage';

				var bg1 = new FlxSprite(0, 0).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.WHITE);
				bg1.screenCenter();
				bg1.alpha = 0.5;
				add(bg1);

				/*
					bg2 = new objects.BGSprite('example', 1090, 510, true, 0.95, 0.95);
					bg2.animation.addByPrefix('idle', 'idle', 12, false);
					bg2.animation.addByPrefix('hey', 'hey', 12, false);
					bg2.addOffset('idle');
					bg2.addOffset('hey', -8, 14);

					backgroundSprites.add(bg2);
					add(bg2);
				 */
		}

		// for (i in 1...5)
		//    Reflect.field(this, 'bg${i + 1}');

		backgroundSprites.forEach(function(i:objects.BGSprite)
		{
			if (i != null && !i.destroyed && i.animated)
				i.dance();
		});

		states.PlayState.defaultCamZoom = camZoom;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	override function beatHit()
	{
		super.beatHit();

		if (curBeat % 2 == 0)
		{
			backgroundSprites.forEach(function(i:objects.BGSprite)
			{
				if (i != null && !i.destroyed && i.animated)
					i.dance();
			});
		}
	}

	private function setPositions(dadX:Float, dadY:Float, bfX:Float, bfY:Float, gfX:Float = null, gfY:Float = null, thirdX:Float = null,
			thirdY:Float = null):Void
	{
		positions = [
			"bf" => [bfX, bfY],
			"dad" => [dadX, dadY],
			"gf" => [gfX, gfY],
			"third" => [thirdX, thirdY]
		];
	}
}
