package;

class Note extends flixel.FlxSprite
{
	public var strumTime:Float = 0;
	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var doubleNote:Bool = false;
	public var earlyHitMult:Float = 0.5;
	public var lateHitMult:Float = 1;

	public static var swagWidth:Float = 160 * 0.7;

	public var rating:String = "shit";

	// for the new scrolling - sanco
	public var parent:Note = null;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var direction:Float = 0;

	public var endHoldOffset:Float = Math.NEGATIVE_INFINITY;

	//ill be typing bbpanzu in all related to special notes, this is a mod so i wont
	//bbpanzu
	public var noteStyle:String = 'n';
	public var updateTime:Bool = true; // I have to test this again but *APPARENTLY* it fixed all performance issues :v

	//bbpanzu
	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inCharter:Bool = false, noteStyle:String = 'n')
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		if (inCharter)
			this.strumTime = strumTime;
		else 
			this.strumTime = Math.round(strumTime);

		if (this.strumTime < 0)
			this.strumTime = 0;

		this.noteData = noteData;

		//bbpanzu
		if (noteStyle == null)
			noteStyle == 'n';
		else if (noteStyle == 'nuggetN') // Goodbye, good nuggets :( 
			noteStyle = 'apple';

		var goodNotes:Array<String> = ['n', 'nuggetN', 'apple']; //'n', 'nuggetP', 'nuggetN', 'gum', 'b', 'apple'

		//bbpanzu
		if (((!KadeEngineData.settings.data.mechanics && !goodNotes.contains(noteStyle)) || (noteStyle != 'n' && isSustainNote)) || noteStyle == 'sexo')
				this.kill(); //ded
		else if (!KadeEngineData.settings.data.mechanics && goodNotes.contains(noteStyle) && noteStyle != 'n')
			noteStyle = noteStyle = 'n';

		//bbpanzu
		var daPath:String = 'NOTE_assets';
		switch(noteStyle)
		{
			case 'nuggetN':
				daPath = 'NOTE_nugget_normal';
			case 'nuggetP':
				daPath = 'NOTE_nugget_poisoned';
			case 'gum':
				daPath = 'NOTE_gum';
			case 'b':
				daPath = 'NOTE_bullet';
			case 'apple':
				daPath = 'apple';
			default:
				daPath = 'NOTE_assets';
		}

		var dir:Array<String> = ['left', 'down', 'up', 'right'];

		//bbpanzu
		if (daPath != 'NOTE_assets')
		{
			var path = (PlayState.isPixel ? 'gameplay/pixel/$daPath' : 'gameplay/notes/$daPath');
			loadGraphic(Paths.image(path, 'shared'));
			setGraphicSize(Std.int(width * 0.7));
		}
		else
		{
			if (!PlayState.isPixel) //if not pixel
				{
					//normal notes
					frames = Paths.getSparrowAtlas('gameplay/notes/$daPath', 'shared');
	
					animation.addByPrefix('${dir[noteData]}Scroll', '${dir[noteData]}0');
					animation.addByPrefix('${dir[noteData]}hold', '${dir[noteData]} hold piece');
					animation.addByPrefix('${dir[noteData]}holdend', '${dir[noteData]} hold end');
	
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

		updateHitbox();

		x += swagWidth * noteData;

		animation.play('${dir[noteData]}Scroll');

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;

			offsetX += width / 2;

			animation.play('${dir[noteData]}holdend');
			updateHitbox();
			flipY = KadeEngineData.settings.data.downscroll;
			offsetX -= width / 2;

			if (PlayState.isPixel) offsetX += 30;

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play('${dir[noteData]}hold');
				prevNote.scale.y *= ((Conductor.stepCrochet / 100) * (1.055 / (PlayState.isPixel ? 6 : 0.7))) * flixel.math.FlxMath.roundDecimal(PlayState.SONG.speed, 2);
				prevNote.updateHitbox();
			}
		}
		else if(!isSustainNote) {
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

		//bbpanzu
		this.noteStyle = noteStyle;

		#if debug
		ignoreDrawDebug = true;
		#end

		active = false;
	}

	// doesnt work wtf
	public function updateSustainScale(ratio:Float)
	{
		if (isSustainNote)
		{
			if (prevNote != null)
			{
				if (prevNote.isSustainNote)
				{
					prevNote.scale.y *= ratio;
					prevNote.updateHitbox();
					offsetX = prevNote.offsetX;
				}
				else
					offsetX = ((prevNote.width / 2) - (width / 2));
			}
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