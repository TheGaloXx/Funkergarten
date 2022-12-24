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

            case 'room':
                camZoom = 0.9;
                PlayState.curStage = 'room';

                bg1 = new BGSprite('room', 0, 0, false);
                bg1.setGraphicSize(Std.int(bg1.width * 2));
                bg1.screenCenter();
                add(bg1);

                bg2 = new BGSprite('light', 0, 0, false, 0.95, 0.95);
                bg2.setGraphicSize(Std.int(bg2.width * 2));
                bg2.screenCenter();
                bg2.blend = ADD;
                bg2.alpha = 0.9;
                add(bg2);

                bfX = 680;
                bfY = 212;
                dadX = 100;
                dadY = 250;
                thirdCharacterX = -100;
                thirdCharacterY = 100;
                gfX = 340;
                gfY = -10;

            case 'newRoom':
                camZoom = 0.9;
                PlayState.curStage = 'newRoom';

                bg1 = new BGSprite('newRoom', 0, 0, false);
                bg1.setGraphicSize(Std.int(bg1.width * 1.2));
                bg1.screenCenter();
                add(bg1);

                bg2 = new BGSprite('newLight', 0, 0, false, 0.95, 0.95);
                bg2.setGraphicSize(Std.int(bg2.width * 1.2));
                bg2.blend = ADD;
                bg2.alpha = 0.5;
                bg2.screenCenter();
                add(bg2);

                bg3 = new BGSprite('bed', 0, 0, false, 1.5, 1.5);
                bg3.setGraphicSize(Std.int(bg3.width * 1.2));
                bg3.screenCenter();
                bg3.y -= 200;
                add(bg3);

                bfX = 800;
                bfY = 250;
                dadX = -50;
                dadY = 170;
                thirdCharacterX = -100;
                thirdCharacterY = 100;
                gfX = 280;
                gfY = -100;

            case 'room-pixel':
                camZoom = 0.9;
                PlayState.curStage = 'room-pixel';

                bg1 = new BGSprite('room-pixel', 0, 0, false);
                bg1.setGraphicSize(Std.int((bg1.width * 2) * 0.775));
                bg1.screenCenter();
                add(bg1);

                bg2 = new BGSprite('light-pixel', 0, 0, false, 0.95, 0.95);
                bg2.setGraphicSize(Std.int((bg2.width * 2) * 0.775));
                bg2.setPosition(-340, -80);
                bg2.blend = ADD;
                bg2.alpha = 0.6;
                add(bg2);

                bfX = 922;
                bfY = 276;
                dadX = 200;
                dadY = 312;
                thirdCharacterX = -100;
                thirdCharacterY = 100;
                gfX = 376;
                gfY = -14;

            case 'cave':
                camZoom = 0.6;
                PlayState.curStage = 'cave';

                bg1 = new BGSprite('nuggetCave', 0, 0, false);
                add(bg1);

                bg2 = new BGSprite('nuggets', -55, 2100, false, 1.5, 1.5);
                add(bg2);

                bg3 = new BGSprite('', 0,0,false, 0, 0);
                bg3.makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
                bg3.alpha = 0;
                add(bg3);

                bfX = 2065;
                bfY = 1200;
                dadX = 1180;
                dadY = 1225;
                thirdCharacterX = -100;
                thirdCharacterY = 100;
                gfX = 2280;
                gfY = 970;
                
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

        PlayState.defaultCamZoom = camZoom;
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