package world;

import substates.SkinSubstate;
import flixel.FlxSubState;
import data.GlobalData;
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
		CoolUtil.presence(null, Language.get('Discord_Presence', 'backyard_menu'), false, 0, null);

        background = new FlxSprite();
        background.frames = Paths.getSparrowAtlas('world_assets', 'preload');
        background.animation.addByPrefix('idle', 'backyard', 0, false);
        background.animation.play('idle');
        background.active = background.antialiasing = false;
        background.setGraphicSize(Std.int(background.width * 3));
        background.updateHitbox();
        background.screenCenter();
        add(background);

        nugget = new objects.Kid(375, 295, 'nugget');
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

        indicator = new Indicator(387, nugget.getGraphicMidpoint().y - 135);
        add(indicator);

        water = new FlxSprite().makeGraphic(100, 100, FlxColor.YELLOW);
        #if debug
        water.alpha = 0.25;
        water.blend = ADD;
        #end
        water.visible = false;
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
            {
                notPressedYet = false;
                bf.canMove = true;
            }

            #if debug
            if (FlxG.keys.justPressed.R)
            {
                hitbox.visible = !hitbox.visible;
                water.visible = !water.visible;
            }
            #end

            if (bf.overlaps(nugget) && !transitioning)
            {
                if (bf.canMove)
                    indicator.visible = true;
                else
                    indicator.visible = false;

                if (FlxG.keys.anyJustPressed([ENTER, SPACE]) && bf.canMove)
                {
                    nugget.flipX = !bf.flipX;
                    bf.canMove = false;
                    bf.velocity.set();
                    bf.animation.play('idle');
                    
                    var dialogueCam = new FlxCamera();
                    dialogueCam.bgColor.alpha = 0;
                    FlxG.cameras.add(dialogueCam, false);

                    final line = getNuggetLine();
                    var substate:FlxSubState = (line == 0 ? new SkinSubstate() : null);

                    var dialogueSpr = new objects.DialogueBox.NuggetDialogue(CoolUtil.getDialogue('BYNugget' + line));
                    dialogueSpr.scrollFactor.set();
                    dialogueSpr.finishThing = function()
                    {
                        FlxG.cameras.remove(dialogueCam);
                        bf.canMove = true;

                        if (line == 0)
                        {
                            bf.canMove = false;
                            GlobalData.other.gotSkin = true;
                            GlobalData.flush();

                            substate.closeCallback = function()
                            {
                                bf.canMove = true;
                            }

                            openSubState(substate);
                        }
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
                    CoolUtil.sound('cancelMenu', 'preload', 0.5);
                    bf.canMove = false;
                    bf.animation.play('idle');
                    FlxG.sound.music.stop();
                    FlxG.sound.playMusic(Paths.music('freakyMenu', 'preload'), 0.7);
					funkin.Conductor.changeBPM(91 * 2);
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

        /* sanco here, explaining how this works and how i fixed the water collision :sob:
        we want to keep using the flxg collide function since it already works partially but now gotta work with math to fully fix the collisions
        basically, the y pos is the top of the hitbox, the bottom is the y and the height of the hitbox, the left is the x of the hitbox

        the x position where this starts to happen is -85.5 (tested through adding 0.5 to the player on debug)
        if the player x is less than the limit (-85.5) then we check the next case (y pos explained below)

        the maximum y pos of bf that prevents the player from moving (collisions on the other half) is 490
        the water y position is 594

        if we get the bf bottom and calculate the difference between the top of the water (594) and the bottom (490 + 102 (height)) -> (490 + 102) - 594
        it returns a float depending if we are inside the hitbox, in this case we are checking if the diff is greater than 0
        if it is then it means that we are colliding with the hitbox and we should not go further than that

        so if both conditions return true then we just set the y position to the water top - the player height
        dumb ass explanation lmfao
        */

        if (bf.x < -85.5 && ((bf.y + bf.height) - water.y) >= 0)
            bf.y = (water.y - bf.height);

        //95 285
        if (bf.x < -128)
            bf.x = -128;

        if (bf.x > 1331)
            bf.x = 1331;

        if (bf.y < 280)
            bf.y = 280;

        if (bf.y > 642)
            bf.y = 642;
    }

    private inline function getNuggetLine():Int
    {
        // why not just var data:Dynamic = GlobalData.other; - sanco
        inline function data():Dynamic // shortcut
            return GlobalData.other;

        var nuggetLines:Array<Int> = [for (i in 0...11) i];

        if (!data().talkedNugget)
        {
            data().talkedNugget = true;
            nuggetLines = [3]; // Nugget can't recognize you.
            GlobalData.flush();
        }
        else
            nuggetLines.remove(3); // Nugget can't recognize you.

        if (data().gotSkin || !data().beatedMod)
            nuggetLines.remove(0); // Looks like you beat the mod. Nugget thinks you deserve a reward.
        else if (!data().gotSkin && data().beatedMod)
            nuggetLines = [0];

        if (data().polla)
            nuggetLines.remove(1); // Nugget thinks you should type NUGGET in the main menu.

        if (!data().beatedSongs.contains('Nugget'))
            nuggetLines.remove(6); // Nugget thinks you are trustworthy. Trust is a rare nugget.

        trace('Locked lines: ${11 - nuggetLines.length} (${[for (i in 0...11) if (!nuggetLines.contains(i)) i]})');

        if (nuggetLines.contains(1) && data().beatedMod)
        {
            trace('Increasing odds of Nugget giving you the hint!');

            if (FlxG.random.bool(75))
            {
                trace('You got it!');

                nuggetLines = [1];
            }
        }

        return FlxG.random.getObject(nuggetLines);
    }
}