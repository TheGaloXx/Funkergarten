package;

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
	public var modifiedByLua:Bool = false;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var doubleNote:Bool = false;

	public var earlyHitMult:Float = 0.5;
	public var lateHitMult:Float = 1;

	public static var swagWidth:Float = 160 * 0.7;

	public var rating:String = "shit";


	//ill be typing bbpanzu in all related to special notes, this is a mod so i wont
	//bbpanzu
	public var noteStyle:String = 'n';

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

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		if (inCharter)
			this.strumTime = strumTime;
		else 
			this.strumTime = Math.round(strumTime);

		if (this.strumTime < 0 )
			this.strumTime = 0;

		this.noteData = noteData;

		//bbpanzu
		if (noteStyle == null)
			noteStyle == 'n';

		//bbpanzu
		if (!FlxG.save.data.mechanics && this.noteStyle != 'n') // si no hay mecanicas y la nota no es normal (racismo)
			{
				this.kill(); //ded
			}

		if (FlxG.save.data.mechanics && this.noteStyle != 'n' && isSustainNote)
			this.kill();

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
				frames = Paths.getSparrowAtlas('gameplay/' + daPath);

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
				antialiasing = FlxG.save.data.antialiasing;
			}
		else //if pixel
			{
				if (daPath == 'NOTE_apple') //if apple pixel note
					{
						frames = Paths.getSparrowAtlas('gameplay/pixel/NOTE_apple');

						animation.addByPrefix('greenScroll', 'green0');
						animation.addByPrefix('redScroll', 'red0');
						animation.addByPrefix('blueScroll', 'blue0');
						animation.addByPrefix('purpleScroll', 'purple0');

						setGraphicSize(Std.int(width * 0.7));
						updateHitbox();
						antialiasing = FlxG.save.data.antialiasing;
					}
				else //if normal pixel notes
					{
						loadGraphic(Paths.image('gameplay/pixel/NOTE_assets'), true, 17, 17);

						animation.add('greenScroll', [6]);
						animation.add('redScroll', [7]);
						animation.add('blueScroll', [5]);
						animation.add('purpleScroll', [4]);

						if (isSustainNote)
						{
							loadGraphic(Paths.image('gameplay/pixel/arrowEnds'), true, 7, 6);

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

		switch (noteData)
		{
			case 0:
				x += swagWidth * 0;
				animation.play('purpleScroll');
			case 1:
				x += swagWidth * 1;
				animation.play('blueScroll');
			case 2:
				x += swagWidth * 2;
				animation.play('greenScroll');
			case 3:
				x += swagWidth * 3;
				animation.play('redScroll');
		}

		// trace(prevNote);

		// we make sure its downscroll and its a SUSTAIN NOTE (aka a trail, not a note)
		// and flip it so it doesn't look weird.
		// THIS DOESN'T FUCKING FLIP THE NOTE, CONTRIBUTERS DON'T JUST COMMENT THIS OUT JESUS
		if (FlxG.save.data.downscroll && sustainNote) 
			flipY = true;

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;

			x += width / 2;

			switch (noteData)
			{
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
				case 1:
					animation.play('blueholdend');
				case 0:
					animation.play('purpleholdend');
			}

			updateHitbox();

			x -= width / 2;

			if (PlayState.isPixel)
				x += 30;

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


				if(FlxG.save.data.scrollSpeed != 1)
					prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * FlxG.save.data.scrollSpeed;
				else
					prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
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
					curHitBox = 0.3;
					curHitBox2 = 0.2;
				case 'gum':
					curHitBox = 0.5;
					curHitBox2 = 0.4;
				case  'b' | 'apple' | 'nuggetN':
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

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}