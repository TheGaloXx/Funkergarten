package;

import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.FlxSprite;
import PlayState;

using StringTools;

class Note extends FlxSprite
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
	public var goodNotes:Array<String> = ['n', 'nuggetN', 'apple']; //'n', 'nuggetP', 'nuggetN', 'gum', 'b', 'apple'

	//bbpanzu
	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inCharter:Bool = false, noteStyle:String = 'n')
	{
		super();

		//bbpanzu
		this.noteStyle = noteStyle;

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

		//bbpanzu
		if ((!KadeEngineData.settings.data.mechanics && !goodNotes.contains(this.noteStyle)) || (this.noteStyle != 'n' && isSustainNote))
				this.kill(); //ded
		else if (!KadeEngineData.settings.data.mechanics && goodNotes.contains(this.noteStyle) && this.noteStyle != 'n')
			this.noteStyle = noteStyle = 'n';

		//bbpanzu
		var folderLol:String = "";
		var daPath:String = 'NOTE_assets';
		switch(noteStyle)
		{
			case 'nuggetN':
				daPath = 'NOTE_nugget_normal';
			case 'nuggetP':
				daPath = 'NOTE_nugget_poisoned';
			case 'gum':
				daPath = 'NOTE_gum';
			/*case 'b':
				daPath = '';*/
			case 'apple':
				daPath = 'NOTE_apple';
			default:
				daPath = 'NOTE_assets';
		}

		if (PlayState.isPixel)
			folderLol = 'pixel/';
		else
			folderLol = '';

		//bbpanzu
		
		if (!PlayState.isPixel) //if not pixel
			{
				//normal notes
				frames = Paths.getSparrowAtlas('gameplay/notes/' + daPath, 'shared');

				animation.addByPrefix('greenScroll', 'green0');
				animation.addByPrefix('redScroll', 'red0');
				animation.addByPrefix('blueScroll', 'blue0');
				animation.addByPrefix('purpleScroll', 'purple0');

				animation.addByPrefix('purpleholdend', 'pruple end hold');
				animation.addByPrefix('greenholdend', 'green hold end');
				animation.addByPrefix('redholdend', 'red hold end');
				animation.addByPrefix('blueholdend', 'blue hold end');

				animation.addByPrefix('purplehold', 'purple hold piece');
				animation.addByPrefix('greenhold', 'green hold piece');
				animation.addByPrefix('redhold', 'red hold piece');
				animation.addByPrefix('bluehold', 'blue hold piece');

				setGraphicSize(Std.int(width * 0.7));
				updateHitbox();
			}
		else //if pixel
			{
				if (daPath == 'NOTE_apple') //if apple pixel note
					{
						frames = Paths.getSparrowAtlas('gameplay/pixel/NOTE_apple', 'shared');

						animation.addByPrefix('greenScroll', 'green0');
						animation.addByPrefix('redScroll', 'red0');
						animation.addByPrefix('blueScroll', 'blue0');
						animation.addByPrefix('purpleScroll', 'purple0');

						setGraphicSize(Std.int(width * 0.7));
						updateHitbox();
					}
				else //if normal pixel notes
					{
						loadGraphic(Paths.image('gameplay/pixel/NOTE_assets', 'shared'), true, 17, 17);

						animation.add('greenScroll', [6]);
						animation.add('redScroll', [7]);
						animation.add('blueScroll', [5]);
						animation.add('purpleScroll', [4]);

						if (isSustainNote)
						{
							loadGraphic(Paths.image('gameplay/pixel/arrowEnds', 'shared'), true, 7, 6);

							animation.add('purpleholdend', [4]);
							animation.add('greenholdend', [6]);
							animation.add('redholdend', [7]);
							animation.add('blueholdend', [5]);

							animation.add('purplehold', [0]);
							animation.add('greenhold', [2]);
							animation.add('redhold', [3]);
							animation.add('bluehold', [1]);
						}

						setGraphicSize(Std.int(width * 6));
						updateHitbox();

						antialiasing = false;
					}
			}

		if (this.noteStyle == 'b')
			color = 0xFF1E00;

		x += swagWidth * noteData;

		switch (noteData)
		{
			case 0:
				animation.play('purpleScroll');
			case 1:
				animation.play('blueScroll');
			case 2:
				animation.play('greenScroll');
			case 3:
				animation.play('redScroll');
		}

		var stepHeight:Float = (0.45 * Conductor.stepCrochet * FlxMath.roundDecimal(PlayState.SONG.speed, 2));

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;

			offsetX += width / 2;

			switch (noteData)
			{
				case 0:
					animation.play('purpleholdend');
				case 1:
					animation.play('blueholdend');
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
			}

			updateHitbox();

			offsetX -= width / 2;

			if (PlayState.isPixel)
				offsetX += 30;

			if (prevNote.isSustainNote)
			{
				switch (prevNote.noteData)
				{
					case 0:
						prevNote.animation.play('purplehold');
					case 1:
						prevNote.animation.play('bluehold');
					case 2:
						prevNote.animation.play('greenhold');
					case 3:
						prevNote.animation.play('redhold');
				}
				prevNote.updateHitbox();

				prevNote.scale.y *= (stepHeight + 1) / prevNote.height;
				prevNote.updateHitbox();
			}
		}
		else if(!isSustainNote) {
			earlyHitMult = 1;
		}
	}

	//bbpanzu
	var curHitBox:Float;
	var curHitBox2:Float;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			//bbpanzu
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

			if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * curHitBox) //bbpanzu
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * curHitBox2)) //bbpanzu
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
				if((isSustainNote && prevNote.wasGoodHit) || strumTime <= Conductor.songPosition)
					wasGoodHit = true;
			}
		}

		if (tooLate || (parent != null && parent.tooLate))
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
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
}