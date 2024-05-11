package objects;

import flixel.FlxG;
import flixel.graphics.frames.FlxFrame.FlxFrameType;
import data.GlobalData;
import flixel.math.FlxRect;
import funkin.Conductor;
import states.PlayState;

class Note extends flixel.FlxSprite
{
	public inline static final swagWidth:Float = 160 * 0.7;

	// Constructor variables
	public var strumTime:Float = 0;
	public var noteData:Int = 0;
	public var prevNote:Note;
	public var isSustainNote:Bool = false;
	public var noteStyle:String = 'n';

	public var mustPress:Bool = false;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var sustainLength:Float = 0;
	public var speed:Float = 1;

	public var doubleNote:Bool = false;
	public var earlyHitMult:Float = 0.5;
	public var lateHitMult:Float = 1;

	public var rating:String = "shit";

	// for the new scrolling - sanco
	public var parent:Note = null;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var direction:Float = 0;

	public var endHoldOffset:Float = Math.NEGATIVE_INFINITY;

	private var swagRect:FlxRect;

	public function new(daStrumTime:Float, daNoteData:Int, ?daPrevNote:Note, ?daIsSustainNote:Bool = false, ?inCharter:Bool = false, daNoteStyle:String = 'n')
	{
		super(0, -2000);

		if (!inCharter) daStrumTime = Math.round(daStrumTime);
		if (daStrumTime < 0) daStrumTime = 0;
		daPrevNote ??= this;
		daNoteStyle ??= 'n';

		prevNote = daPrevNote;
		isSustainNote = daIsSustainNote;
		strumTime = daStrumTime;
		noteData = daNoteData;
		noteStyle = daNoteStyle;

		var daPath:String = 'NOTE_assets';
		switch(noteStyle)
		{
			case 'nuggetN': daPath = 'NOTE_nugget_normal';
			case 'nuggetP': daPath = 'NOTE_nugget_poisoned';
			case 'gum': daPath = 'NOTE_gum';
			case 'b': daPath = 'NOTE_bullet';
			case 'apple': daPath = 'apple';
			default: daPath = 'NOTE_assets';
		}

		final dir:Array<String> = ['left', 'down', 'up', 'right'];
		final pixelPath:String = (PlayState.SONG.isPixel ? 'pixel' : 'notes');

		if (daPath != 'NOTE_assets')
		{
			loadGraphic(Paths.image('gameplay/$pixelPath/$daPath', 'shared'));
			setGraphicSize(Std.int(width * 0.7));
		}
		else
		{
			frames = Paths.getSparrowAtlas('gameplay/$pixelPath/$daPath', 'shared');
			animation.addByPrefix('${dir[noteData]}Scroll', 'note ${dir[noteData]}', 0, false);
			animation.addByPrefix('${dir[noteData]}hold', 'hold ${dir[noteData]}', 0, false);
			animation.addByPrefix('${dir[noteData]}holdend', 'end ${dir[noteData]}', 0, false);

			setGraphicSize(Std.int(width * 0.7));
		}
		animation.play('${dir[noteData]}Scroll');
		updateHitbox();

		x += swagWidth * noteData;
		offsetX += 23;

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;

			offsetX += width / 2;

			animation.play('${dir[noteData]}holdend');
			updateHitbox();
			flipY = GlobalData.settings.downscroll;
			offsetX -= width / 2;

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play('${dir[noteData]}hold');
				prevNote.scale.y *= ((Conductor.stepCrochet / 100) * (1.055 / 0.7)) * flixel.math.FlxMath.roundDecimal(PlayState.SONG.speed, 2);
				prevNote.updateHitbox();
			}
		}
		else if (!isSustainNote)
		{
			earlyHitMult = 1;
		}

		switch(noteStyle)
		{
			case 'nuggetP': offsetX += 22;
			case 'nuggetN': offsetX += 22;
			case 'gum':     offsetX += 13;
			case 'b':       offsetX += 0;
			case 'apple':   offsetX += 9;
		}

		#if debug
		ignoreDrawDebug = true;
		#end

		swagRect = FlxRect.get();
	}

	override function update(elapsed:Float)
	{
		//super.update(elapsed); I have to test this again but *APPARENTLY* it fixed all performance issues :v - no it didn't you fucking dumbass what the actual fuck are you talking about

		//just realized i could have left it here
		if (mustPress)
		{
			var curHitBox:Float;
			var curHitBox2:Float;

			switch (noteStyle)
			{
				case 'nuggetP':
					curHitBox = 0.4;
					curHitBox2 = 0.3;
				case 'gum':
					curHitBox = 0.5;
					curHitBox2 = 0.4;
				case  'b': //| 'apple':
					curHitBox = 1.5;
					curHitBox2 = 1.5;
				default:
					curHitBox = lateHitMult;
					curHitBox2 = earlyHitMult;
			}
					
			if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * curHitBox) && strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * curHitBox2))
				canBeHit = true;
			else
				canBeHit = false;
					
			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;
		
			if (strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
			{
				if ((isSustainNote && prevNote.wasGoodHit) || strumTime <= Conductor.songPosition)
					wasGoodHit = true;
			}
		}
					
		if (tooLate || (parent != null && parent.tooLate))
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}

	// simplified this to optimize idk
	override function draw()
	{
		if (alpha == 0 || _frame.type == FlxFrameType.EMPTY || !visible || y > FlxG.height || y < -height || x < -width || x > FlxG.width)
			return;

		#if FLX_DEBUG
		if (flixel.FlxG.debugger.drawDebug) drawDebug();
		#end

		if (!cameras[0].visible || !cameras[0].exists || !isOnScreen(cameras[0]))
			return;

		drawComplex(cameras[0]);

		#if FLX_DEBUG
		flixel.FlxBasic.visibleCount++;
		#end
	}

	// is calling FlxRect's `new` function every frame stupid?
	public inline function updateRect(center:Float):Void
	{
		if (GlobalData.settings.downscroll)
		{
			swagRect.set(0, 0, frameWidth, (center - y) / scale.y);
			swagRect.y = frameHeight - swagRect.height;
		}
		else
		{
			swagRect.set(0, 0, width / scale.x, height / scale.y);
			swagRect.y = (center - y) / scale.y;
			swagRect.height -= swagRect.y;
		}

		clipRect = swagRect;
	}

	override function destroy():Void
	{
		super.destroy();

		if (swagRect != null)
		{
			swagRect.put();
		}

		if (clipRect != null)
		{
			clipRect.put();
		}
	}
}