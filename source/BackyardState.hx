package;

import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
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
    var nugget:Kid;
    var hitbox:FlxSprite;
    var indicator:Indicator;
    var camara:FlxCamera;
    var blackScreen:FlxSprite;

    var up:Bool = false;
    var down:Bool = false;
    var right:Bool = false;
    var left:Bool = false;

    var notPressedYet:Bool = true;
    public static var tellMonday:Bool;

    override public function create()
    {
        Application.current.window.title = (Main.appTitle + ' - Backyard');

        background = new FlxSprite(0,0).loadGraphic(Paths.image('world/backyard'));
        background.antialiasing = false;
        background.flipY = true;
        background.setGraphicSize(Std.int(background.width * 3), Std.int(background.height * 3));
        background.updateHitbox();
        background.screenCenter();
        add(background);

        nugget = new Kid(375, 295, 'nugget');
        nugget.flipX = true;
        add(nugget);

        bf = new KidBoyfriend(-90, 288);
        bf.facing = RIGHT;
        bf.canMove = false;
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
        hitbox.setPosition(384, 260);
        hitbox.immovable = true;
        add(hitbox);

        indicator = new Indicator(387, nugget.getGraphicMidpoint().y - 150);
        add(indicator);

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

        blackScreen = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
        blackScreen.scrollFactor.set();
        add(blackScreen);

        if (tellMonday)
        {
            tellMonday = false;
            new FlxTimer().start(0.5, function(_)
            {
                MondayShit();
            });
        }
        else
        {
            FlxTween.tween(blackScreen, {alpha: 0}, 1, {onComplete: function(_)
                {
                    transitioning = false;
                    bf.canMove = true;
                }});
        }

        super.create();
    }

    var transitioning:Bool = true;

    override public function update(elapsed:Float)
    {
        if (!transitioning)
        {
            if (FlxG.keys.justPressed.ANY && notPressedYet)
                notPressedYet = false;

            screenCollision();

            #if debug
        if (FlxG.keys.justPressed.R)
            hitbox.visible = !hitbox.visible;
        #end

        FlxG.collide(bf, hitbox);

        if (bf.overlaps(nugget) && !transitioning)
        {
            indicator.visible = true;

            if (FlxG.keys.anyJustPressed([ENTER, SPACE]))
            {
                nugget.flipX = !bf.flipX;
                transitioning = true;
                bf.canMove = false;
                var screenFade:FlxSprite = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
                screenFade.scrollFactor.set();
                screenFade.alpha = 0;
                add(screenFade);
                FlxTween.tween(screenFade, {alpha: 1}, 0.5);
                new FlxTimer().start(0.5, function(_)   secretSong('Nugget', 2) );
            }
        }
        else
        {
            indicator.visible = false;
        }

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
        } 

        super.update(elapsed);
    }

    function screenCollision():Void
    {
        if (notPressedYet) //because bf spawns at the bottom of the screen for some reason lol
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

    function MondayShit():Void
    {
        #if debug
        var isTuesday:Bool = FlxG.random.bool(35);
        #else
        var isTuesday:Bool = FlxG.random.bool(1);
        #end

        var monday:FlxText = new FlxText(0,0,0, "", 160);
        monday.text = (isTuesday ? (FlxG.save.data.esp ? "Martes" : "Tuesday") : (FlxG.save.data.esp ? "Lunes" : "Monday"));
        monday.scrollFactor.set();
        monday.font = Paths.font('Crayawn-v58y.ttf');
        monday.alpha = 0;
        monday.screenCenter();
        monday.color = FlxColor.YELLOW;
        add(monday);

        var times:FlxText = new FlxText(0,0,0, "", 60);
        times.scrollFactor.set();
        times.font = Paths.font('Crayawn-v58y.ttf');
        times.y = monday.y + 125;
        times.alpha = 0;
        times.color = FlxColor.YELLOW;
        add(times);

        if (!isTuesday)
        {
            var text:String = (FlxG.save.data.esp ? "de nuevo" : "again");

            switch(FlxG.save.data.mondays)
            {
                case -1:
                    times.text = "El pepe";
                case 0:
                    times.text = "";
                case 1:
                    times.text = "(" + text + ")";
                default:
                    times.text = "(" + text + " x " + FlxG.save.data.mondays + ")";

            }

            if (Date.now().getDay() == 1)  //psych engine lol
            {
                times.text = "(" + (FlxG.save.data.esp ? "literalmente" : "literally") + " x " + FlxG.save.data.mondays + ")";
            }
        }
        else
        {
            var text:String = (FlxG.save.data.esp ? "literalmente" : "literally");
            if (Date.now().getDay() == 2)  //psych engine lol
                {
                    times.text = "(" + (FlxG.save.data.esp ? "literalmente" : "literally") + ")";
                }
        }

        FlxG.save.data.mondays++;

        times.screenCenter(X);

        FlxTween.tween(monday, {alpha: 1}, 0.75, {onComplete: function(_)
        {
            FlxTween.tween(times, {alpha: 1}, 0.75, {onComplete: function(_)
            {
                new FlxTimer().start(1, function(_)
                    {
                        FlxTween.tween(blackScreen, {alpha: 0}, 1);
                        FlxTween.tween(monday, {alpha: 0}, 1);
                        FlxTween.tween(times, {alpha: 0}, 1, {onComplete: function(_)
                        {
                            transitioning = false;
                            bf.canMove = true;
                        }});
                    });
            }});
        }});
    }
}