package objects;

import funkin.Conductor;

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

	public function new(daStrumTime:Float, daNoteData:Int, ?daPrevNote:Note, ?daIsSustainNote:Bool = false, ?inCharter:Bool = false, daNoteStyle:String = 'n')
	{
		super(0, -2000);

		if (!inCharter) daStrumTime = Math.round(daStrumTime);
		if (daStrumTime < 0) daStrumTime = 0;
		if (daPrevNote == null) daPrevNote = this;
		if (daNoteStyle == null || daNoteStyle == 'gum') daNoteStyle = 'n';

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

		if (daPath != 'NOTE_assets')
		{
			var path = (states.PlayState.isPixel ? 'gameplay/pixel/$daPath' : 'gameplay/notes/$daPath');
			loadGraphic(Paths.image(path, 'shared'));
			setGraphicSize(Std.int(width * 0.7));
		}
		else
		{
			if (!states.PlayState.isPixel) //if not pixel
				{
					//normal notes
					frames = Paths.getSparrowAtlas('gameplay/notes/$daPath', 'shared');
	
					animation.addByPrefix('${dir[noteData]}Scroll', 'note ${dir[noteData]}', 0, false);
					animation.addByPrefix('${dir[noteData]}hold', 'hold ${dir[noteData]}', 0, false);
					animation.addByPrefix('${dir[noteData]}holdend', 'end ${dir[noteData]}', 0, false);
	
					setGraphicSize(Std.int(width * 0.7));
				}
			else //if pixel
				{
					loadGraphic(Paths.image('gameplay/pixel/NOTE_assets', 'shared'), true, 17, 17);
	
					animation.add('upScroll', [6]);
					animation.add('rightScroll', [7]);
					animation.add('downScroll', [5]);
					animation.add('leftScroll', [4]);
	
					if (isSustainNote)
					{
						loadGraphic(Paths.image('gameplay/pixel/arrowEnds', 'shared'), true, 7, 6);
	
						animation.add('leftholdend', [4]);
						animation.add('upholdend', [6]);
						animation.add('rightholdend', [7]);
						animation.add('downholdend', [5]);
	
						animation.add('lefthold', [0]);
						animation.add('uphold', [2]);
						animation.add('righthold', [3]);
						animation.add('downhold', [1]);
					}
	
					setGraphicSize(Std.int(width * 6));
	
					antialiasing = false;
				}
		}
		animation.play('${dir[noteData]}Scroll');
		updateHitbox();

		x += swagWidth * noteData;
		if (!states.PlayState.isPixel) offsetX += 23;

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;

			offsetX += width / 2;

			animation.play('${dir[noteData]}holdend');
			updateHitbox();
			flipY = data.KadeEngineData.settings.data.downscroll;
			offsetX -= width / 2;

			if (states.PlayState.isPixel) offsetX += 30;

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play('${dir[noteData]}hold');
				prevNote.scale.y *= ((Conductor.stepCrochet / 100) * (1.055 / (states.PlayState.isPixel ? 6 : 0.7))) * flixel.math.FlxMath.roundDecimal(states.PlayState.SONG.speed, 2);
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
			case 'b':       offsetX += 24;
			case 'apple':   offsetX += 9;
		}

		#if debug
		ignoreDrawDebug = true;
		#end
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
}