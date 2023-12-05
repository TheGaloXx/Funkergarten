package objects;

import flixel.util.FlxStringUtil;
import funkin.Conductor;
import flixel.math.FlxMath;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxSprite;

class ChartNote extends FlxSprite
{
    private static final dir:Array<String> = ['left', 'down', 'up', 'right'];
    public static var daFrames:FlxAtlasFrames;

	public var strumTime:Float = 0;
	public var noteData:Int = 0;
	public var noteStyle:String = 'n';
	public var sustainLength:Float = 0;

	public function new()
	{
		super();

		#if debug
		ignoreDrawDebug = true;
		#end

        active = false;
	}

	override function draw()
	{
		if (alpha == 0 || _frame.type == flixel.graphics.frames.FlxFrame.FlxFrameType.EMPTY || !visible) return;

		#if FLX_DEBUG
		if (flixel.FlxG.debugger.drawDebug) drawDebug();
		#end

		if (!cameras[0].visible || !cameras[0].exists || !isOnScreen(cameras[0])) return;
		drawComplex(cameras[0]);

		#if FLX_DEBUG
		flixel.FlxBasic.visibleCount++;
		#end
	}

    private function loadSprite():Void
    {
        if (noteStyle == 'n' || noteStyle == null)
        {
            frames = daFrames;
            for (i in dir) animation.addByPrefix(i + 'Scroll', 'note $i', 0, false);
        }
        else
        {
            var daPath:String = '';
            switch(noteStyle)
            {
                case 'nuggetN': daPath = 'NOTE_nugget_normal';
                case 'nuggetP': daPath = 'NOTE_nugget_poisoned';
                case 'gum': daPath = 'NOTE_gum';
                case 'b': daPath = 'NOTE_bullet';
                case 'apple': daPath = 'apple';
            }

            loadGraphic(Paths.image('gameplay/notes/$daPath', 'shared'));
        }

        animation.play('${dir[noteData]}Scroll');
    }

    public function play(daStrumTime:Float, daNoteData:Int, daSustainLength:Float, daNoteStyle:String, X:Float, Y:Float, size:Int):Void
    {
        if (daStrumTime < 0) daStrumTime = 0;
		if (daNoteStyle == null || daNoteStyle == 'gum') daNoteStyle = 'n';

		strumTime = daStrumTime;
		noteData = daNoteData;
        sustainLength = daSustainLength;
		noteStyle = daNoteStyle;

        loadSprite();
        setGraphicSize(size, size);
        updateHitbox();
        setPosition(X, Y);
    }

    override public function toString():String
    {
        return FlxStringUtil.getDebugString(
        [
            LabelValuePair.weak("Time", strumTime),
            LabelValuePair.weak("Direction", noteData),
            LabelValuePair.weak("Sus length", sustainLength),
            LabelValuePair.weak("Type", noteStyle),
            LabelValuePair.weak("Width", width),
            LabelValuePair.weak("Height", height)
        ]);
    }
}

class ChartSustain extends FlxSprite
{
	public function new()
	{
		super();

		makeGraphic(1, 1);
		scale.x = 8; // get the bitmap to be as small as possible and stretch it out instead

        active = false;
	}

	// simplified this to optimize idk
	override function draw()
	{
		if (alpha == 0 || _frame.type == flixel.graphics.frames.FlxFrame.FlxFrameType.EMPTY || !visible) return;

		#if FLX_DEBUG
		if (flixel.FlxG.debugger.drawDebug) drawDebug();
		#end

		if (!cameras[0].visible || !cameras[0].exists || !isOnScreen(cameras[0])) return;
		drawComplex(cameras[0]);

		#if FLX_DEBUG
		flixel.FlxBasic.visibleCount++;
		#end
	}

    public function play(daNoteData:Int, daSustainLength, X:Float, Y:Float, daHeight:Float):Void
    {
		scale.y = Math.floor(FlxMath.remapToRange(daSustainLength, 0, Conductor.stepCrochet * 16, 0, daHeight));

        updateHitbox();
        setPosition(X, Y);

		color = [0xc24b99, 0x01ffff, 0x13fa05, 0xf9393f][daNoteData];
    }
}
