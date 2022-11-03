package;

import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.FlxG;
using StringTools;

class Stage extends MusicBeatState
{
    public var stage:String = 'stage'; //the stage name

    public var camZoom:Float = 1; //the stage zoom

    public var bg1:BGSprite; //sprites
    public var bg2:BGSprite;
    public var bg3:BGSprite;
    public var bg4:BGSprite;
    public var bg5:BGSprite;

    public var backgroundSprites:FlxTypedGroup<BGSprite>; //a group for the animated sprites

    public var bfX:Float = 770;
    public var bfY:Float = 450;
    public var dadX:Float = 100;
    public var dadY:Float = 100;
    public var thirdCharacterX:Float = -100;
    public var thirdCharacterY:Float = 100;
    public var gfX:Float = 400;
    public var gfY:Float = 130;

	public function new(daStage:String)
	{
		super();

        this.stage = daStage;

        backgroundSprites = new FlxTypedGroup<BGSprite>();
		add(backgroundSprites);

        switch(daStage)
        {
            case 'stage':
                camZoom = 0.9;
                PlayState.curStage = 'stage';

                var bg1 = new FlxSprite(0, 0).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.WHITE);
                bg1.screenCenter();
                bg1.alpha = 0.5;
                add(bg1);

                /*
                bg2 = new BGSprite('example', 1090, 510, true, 0.95, 0.95);
                bg2.animation.addByPrefix('idle', 'idle', 12, false);
                bg2.animation.addByPrefix('hey', 'hey', 12, false);
                bg2.addOffset('idle');
                bg2.addOffset('hey', -8, 14);

                backgroundSprites.add(bg2);
                add(bg2);
                */

                bfX = 770;
                bfY = 450;
                dadX = 100;
                dadY = 100;
                thirdCharacterX = -100;
                thirdCharacterY = 100;
                gfX = 400;
                gfY = 130;
                
            default:
                camZoom = 0.9;
                PlayState.curStage = 'stage';

                var bg1 = new FlxSprite(0, 0).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.WHITE);
                bg1.screenCenter();
                bg1.alpha = 0.5;
                add(bg1);

                /*
                bg2 = new BGSprite('example', 1090, 510, true, 0.95, 0.95);
                bg2.animation.addByPrefix('idle', 'idle', 12, false);
                bg2.animation.addByPrefix('hey', 'hey', 12, false);
                bg2.addOffset('idle');
                bg2.addOffset('hey', -8, 14);

                backgroundSprites.add(bg2);
                add(bg2);
                */

                bfX = 770;
                bfY = 450;
                dadX = 100;
                dadY = 100;
                thirdCharacterX = -100;
                thirdCharacterY = 100;
                gfX = 400;
                gfY = 130;
        }

        for (i in backgroundSprites)
            {
                backgroundSprites.forEach(function(_)
                    {
                        if (i != null && !i.destroyed)
                            i.dance();
                    });
            }

        camZoom = PlayState.defaultCamZoom;
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
                    for (i in backgroundSprites)
                        {
                            backgroundSprites.forEach(function(_)
                                {
                                    if (i != null && !i.destroyed)
                                        i.dance();
                                });
                        }
                }
        }
}