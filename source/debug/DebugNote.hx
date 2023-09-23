package debug;

class DebugNote extends flixel.FlxSprite
{
	public function new(noteStyle:String = 'Normal note')
	{
		super();

		resetNote('n');
		x += flixel.FlxG.width / 2;
		active = false;
	}

	public function resetNote(style:String):Void
	{
		var daPath:String = switch(style)
		{
			case 'Poisoned nugget':	'NOTE_nugget_poisoned';
			case 'Bullet note':	    'NOTE_bullet';
			case 'Apple note':      'apple';
			default:	            'NOTE_assets';
		}

		if (daPath != 'NOTE_assets')
		{
			loadGraphic(Paths.image('gameplay/notes/$daPath', 'shared'));
			setGraphicSize(Std.int(width * 0.7));
		}
		else
		{
			frames = Paths.getSparrowAtlas('gameplay/notes/$daPath', 'shared');
			animation.addByPrefix('idle', 'note left', 0, false);
			setGraphicSize(Std.int(width * 0.7));
			animation.play('idle');
		}

		updateHitbox();

		trace('[ objects.Note style: $style - Path: $daPath ]');
	}
}