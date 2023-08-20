package world;

import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import objects.Kid;

class BackyardState extends funkin.MusicBeatState
{
    var background:FlxSprite;
    var water:FlxSprite;
    var bf:KidBoyfriend;
    var nugget:objects.Kid;
    var hitbox:FlxSprite;
    var indicator:Indicator;
    var camara:FlxCamera;

    var notPressedYet:Bool = true;

    override public function create()
    {
        CoolUtil.title('Backyard');
		CoolUtil.presence(null, 'In the backyard', false, 0, null);

        background = new FlxSprite(0,0).loadGraphic(Paths.image('world/backyard', 'preload'));
        background.antialiasing = false;
        background.flipY = true;
        background.setGraphicSize(Std.int(background.width * 3));
        background.updateHitbox();
        background.screenCenter();
        add(background);

        nugget = new objects.Kid(375, 295, 'nugget');
        nugget.flipX = true;
        add(nugget);

        bf = new KidBoyfriend(-90, 288);
        bf.facing = RIGHT;
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

        FlxG.cameras.setDefaultDrawTarget(camara, true);

        super.create();
    }

    var transitioning:Bool = false;

    override public function update(elapsed:Float)
    {
        if (!transitioning)
        {
            if (FlxG.keys.justPressed.ANY && notPressedYet)
                notPressedYet = false;

            #if debug
        if (FlxG.keys.justPressed.R)
            hitbox.visible = !hitbox.visible;
        #end

        if (bf.overlaps(nugget) && !transitioning)
        {
            indicator.visible = true;

            if (FlxG.keys.anyJustPressed([ENTER, SPACE]) && bf.canMove)
            {
                nugget.flipX = !bf.flipX;
                bf.canMove = false;
                
                var dialogueCam = new FlxCamera();
				dialogueCam.bgColor.alpha = 0;
				FlxG.cameras.add(dialogueCam, false);

				var dialogueSpr = new objects.DialogueBox.NuggetDialogue(CoolUtil.getDialogue('BackYState_Dialogue'));
				dialogueSpr.scrollFactor.set();
				dialogueSpr.finishThing = function()
				{
					FlxG.cameras.remove(dialogueCam);
					bf.canMove = true;
				};
				dialogueSpr.cameras = [dialogueCam];
				add(dialogueSpr);
            }
        }
        else
        {
            indicator.visible = false;
        }

            if (bf.x < -100 && bf.y < 335 && !transitioning)
            {
                transitioning = true;
                funkin.MusicBeatState.switchState(new RoomState());
            }

            if (FlxG.keys.anyJustPressed([ESCAPE, BACKSPACE]))
            {
                bf.canMove = false;
                funkin.MusicBeatState.switchState(new states.MainMenuState());
            }
        } 

        super.update(elapsed);

        screenCollision();
        FlxG.collide(bf, hitbox);
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
}