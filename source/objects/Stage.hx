package objects;

import flixel.math.FlxPoint;
import states.PlayState;
import data.GlobalData;
import flixel.group.FlxGroup.FlxTypedGroup;
import objects.BGSprite;

using StringTools;

class Stage extends FlxTypedGroup<BGSprite>
{
	public var camZoom:Float = 1; // the stage zoom
	public var bfCamOffset:FlxPoint;
	public var hasGF:Bool;

	public var positions:Map<String, Array<Float>> = [
		"bf" => [770, 450],
		"dad" => [100, 100],
		"gf" => [400, 130],
		"third" => [-100, 100]
	];

	public function new()
	{
		super();

		bfCamOffset = FlxPoint.get(0, 0);

		makeStage(PlayState.SONG.stage);

		active = false;

		PlayState.instance.defaultCamZoom = camZoom;
	}

	override function destroy():Void
	{
		bfCamOffset.put();
		super.destroy();
	}

	private function setPositions(dadX:Float, dadY:Float, bfX:Float, bfY:Float, gfX:Float = null, gfY:Float = null):Void
	{
		if (PlayState.SONG.player1 != 'bf-pixel')
		{
			bfY += 35;

			if (GlobalData.other.usingSkin)
			{
				bfX += 19 / 2; 
				bfY += 72;
			}
		}

		positions =
		[
			"bf" => [bfX, bfY],
			"dad" => [dadX, dadY],
			"gf" => [gfX, gfY]
		];
	}

	private function makeStage(daStage:String)
	{
		function addSprite(path:String, aboveChar:Bool = false, scrollX:Float = 1, scrollY:Float = 1, library:String = 'shared'):BGSprite
		{
			var sprite:BGSprite = new BGSprite(path, aboveChar, scrollX, scrollY, library);
			add(sprite);

			return sprite;
		}

		hasGF = true;
		
		switch (daStage)
		{
			case 'room':
				camZoom = 0.9;

				var bg1 = addSprite('room');
				bg1.setGraphicSize(bg1.width * 2);

				var bg2 = addSprite('light', true, 0.95, 0.95);
				bg2.setGraphicSize(bg2.width * 2);
				bg2.blend = ADD;
				bg2.alpha = 0.9;

				setPositions(100, 250, 680, 214, 360, 170);

			case 'room-pixel':
				camZoom = 0.9;

				var bg1 = addSprite('room-pixel');
				bg1.setGraphicSize((bg1.width * 2) * 0.775);

				var bg2 = addSprite('light-pixel', true, 0.95, 0.95);
				bg2.setGraphicSize((bg2.width * 2) * 0.775);
				bg2.setPosition(-340, -80);
				bg2.blend = ADD;
				bg2.alpha = 0.6;

				setPositions(200, 312, 922, 288, 371, -14);

				hasGF = false;

			case 'cave':
				camZoom = 0.55;

				addSprite('caveBG').setPosition();
				addSprite('caveFront').setPosition();
				addSprite('caveShadows').setPosition();

				setPositions(1040, 1130, 1890, 1190, 2280, 970);

				hasGF = false;

			case 'closet':
				camZoom = 0.65;

				var bg1 = addSprite('closet');
				bg1.setGraphicSize(bg1.width * 1.2);
				bg1.updateHitbox();
				bg1.screenCenter();

				var bg2 = addSprite('closetFront', true, 1.2, 1.2);
				bg2.setGraphicSize(bg2.width * 1.2);
				bg2.updateHitbox();
				bg2.screenCenter();
				bg2.y += 75;

				setPositions(-82, 208, 1025, 420, 495, 340);

			case 'principal':
				camZoom = 0.6;

				addSprite('principal');

				setPositions(-450, 0, 1050, 370, 675, 360);

			case 'void':
				camZoom = 0.8;

				addSprite('mcdonalds', false, 1, 1, 'shit');

				setPositions(170, 795, 780, 560, 380, 540);

			case 'cafeteria':
				camZoom = 0.7;

				addSprite('cafeteria');

				setPositions(100, 310, 850, 270, 475, 220);

			case 'laboratory':
				makeStage('room');

				setPositions(80, 50, 680, 214, 360, 170);

			case 'playground':
				camZoom = 0.8;

				var bg1 = addSprite('playground');
				bg1.setGraphicSize(bg1.width * 4.5);
				bg1.antialiasing = false;

				setPositions(-20, 264, 680, 214, 360, 170);
		}
	}
}
