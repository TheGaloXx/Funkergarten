package;

import flixel.util.FlxColor;
import lime.app.Application;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import Kid;

class BackyardState extends MusicBeatState
{
    var background:FlxSprite;
    var water:FlxSprite;
    var bf:KidBoyfriend;
    var camara:FlxCamera;

    var up:Bool = false;
    var down:Bool = false;
    var right:Bool = false;
    var left:Bool = false;

    var notPressedYet:Bool = true;

    override public function create()
    {
        Application.current.window.title = (Main.appTitle + ' - Backyard');

        #if debug
		flixel.addons.studio.FlxStudio.create();
		#end

        background = new FlxSprite(0,0).loadGraphic(Paths.image('world/backyard'));
        background.antialiasing = false;
        background.flipY = true;
        background.setGraphicSize(Std.int(background.width * 3), Std.int(background.height * 3));
        background.updateHitbox();
        background.screenCenter();
        add(background);

        bf = new KidBoyfriend(-90, 288);
        bf.facing = RIGHT;
        add(bf);

        water = new FlxSprite().makeGraphic(100, 100, FlxColor.YELLOW);
        water.alpha = 0;
        water.width = 519;
        water.height = 124;
        water.setGraphicSize(519, 124);
        water.updateHitbox();
        water.setPosition(-138, 594);
        water.immovable = true;
        add(water);

        camara = new FlxCamera(0, 0, FlxG.width, FlxG.height);
        FlxG.cameras.reset(camara);
        camara.target = bf;
       //camara.setScrollBoundsRect(-128, 0, 1200 * 1.25, (480 * 1.5) + 15); this is already fine but i want to improve it
        camara.setScrollBoundsRect(-128, 0, 1200 * 1.275, (480 * 1.5) + 20);
        add(camara);

        FlxCamera.defaultCameras = [camara];

        super.create();
    }

    var transitioning:Bool = false;

    override public function update(elapsed:Float)
    {
        if (FlxG.keys.justPressed.ANY && notPressedYet)
            notPressedYet = false;

        screenCollision();

        if (bf.x < -100 && bf.y < 335 && !transitioning)
        {
            transitioning = true;
            FlxG.switchState(new RoomState());
        }

        if (FlxG.keys.anyJustPressed([ESCAPE, BACKSPACE]))
        {
            bf.canMove = false;
            FlxG.switchState(new menus.MainMenuState());
        }

        super.update(elapsed);
    }

    function screenCollision():Void
    {
        if (notPressedYet) //because bf appears on the bottom of the screen for some reason lol
            return;

        FlxG.collide(bf, water);

        //95 285
        if (bf.x < -128)
            bf.x = -128;

        if (bf.x > 1331)
            bf.x = 1331;

        if (bf.y < 264)
            bf.y = 264;

        if (bf.y > 642)
            bf.y = 642;
    }
}