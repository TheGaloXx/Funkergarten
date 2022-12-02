package;

import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import lime.app.Application;
import flixel.FlxCamera;
import flixel.FlxG;
import Kid;
import flixel.FlxSprite;

class RoomState extends MusicBeatState
{
    var background:FlxSprite;
    var water:FlxSprite;
    var bf:KidBoyfriend;
    var protagonist:Kid;
    var hitbox:FlxSprite;
    var indicator:Indicator;
    var camara:FlxCamera;

    var up:Bool = false;
    var down:Bool = false;
    var right:Bool = false;
    var left:Bool = false;

    override public function create()
    {
        Application.current.window.title = (Main.appTitle + ' - Room');

        #if debug
		flixel.addons.studio.FlxStudio.create();
		#end

        background = new FlxSprite(0,0).loadGraphic(Paths.image('world/room'));
        background.antialiasing = false;
        background.flipY = true;
        background.setGraphicSize(Std.int(background.width * 3), Std.int(background.height * 3));
        background.updateHitbox();
        background.screenCenter();
        add(background);

        protagonist = new Kid(600, 435, 'protagonist');
        add(protagonist);

        bf = new KidBoyfriend(1020, 315);
        add(bf);

        hitbox = new FlxSprite().makeGraphic(100, 100, FlxColor.YELLOW);
        #if debug
        hitbox.alpha = 0.25;
        hitbox.blend = ADD;
        #end
        hitbox.visible = false;
        hitbox.width = 42;
        hitbox.height = 51;
        hitbox.setGraphicSize(42, 51);
        hitbox.updateHitbox();
        hitbox.setPosition(606, 437);
        hitbox.immovable = true;
        add(hitbox);

        indicator = new Indicator(610, protagonist.getGraphicMidpoint().y - 150);
        add(indicator);

        camara = new FlxCamera(0, 0, FlxG.width, FlxG.height);
        FlxG.cameras.reset(camara);
        camara.target = bf;
        camara.setScrollBoundsRect(-130, -50, background.width - 10, background.height);
        add(camara);

        FlxCamera.defaultCameras = [camara];

        super.create();
    }

    var transitioning:Bool = false;

    override public function update(elapsed:Float)
    {
        screenCollision();

        #if debug
        if (FlxG.keys.justPressed.R)
            hitbox.visible = !hitbox.visible;
        #end

        FlxG.collide(bf, hitbox);

        if (bf.overlaps(protagonist) && !transitioning)
        {
            indicator.visible = true;

            if (FlxG.keys.anyJustPressed([ENTER, SPACE]))
            {
                protagonist.flipX = !bf.flipX;
                transitioning = true;
                bf.canMove = false;
                var screenFade:FlxSprite = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
                screenFade.scrollFactor.set();
                screenFade.alpha = 0;
                add(screenFade);
                FlxTween.tween(screenFade, {alpha: 1}, 0.5);
                new FlxTimer().start(0.5, function(_)   secretSong('Monday', 3) );
            }
        }
        else
        {
            indicator.visible = false;
        }

        if (bf.y < 270 && bf.x > 935 && bf.x < 1100 && !transitioning)
        {
            transitioning = true;
            bf.canMove = false;
            FlxG.switchState(new BackyardState());
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
        if (bf.x < 10)
            bf.x = 10;

        if (bf.x > 1200)
            bf.x = 1200;

        if (bf.y < 263)
            bf.y = 263;

        if (bf.y > 640)
            bf.y = 640;
    }
}