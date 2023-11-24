package world;

import substates.SkinSubstate;
import flixel.FlxSubState;
import data.KadeEngineData;
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
            {
                notPressedYet = false;
                bf.canMove = true;
            }

            #if debug
            if (FlxG.keys.justPressed.R)
                hitbox.visible = !hitbox.visible;
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
                            KadeEngineData.other.data.gotSkin = true;
                            KadeEngineData.flush();

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
        inline function data():Dynamic // shortcut
            return KadeEngineData.other.data;

        var nuggetLines:Array<Int> = [for (i in 0...11) i];

        if (!data().talkedNugget)
        {
            data().talkedNugget = true;
            nuggetLines = [3]; // Nugget can't recognize you.
            KadeEngineData.flush();
        }
        else
            nuggetLines.remove(3); // Nugget can't recognize you.

        if (data().gotSkin || !data().beatedMod)
            nuggetLines.remove(0); // Looks like you beat the mod. Nugget thinks you deserve a reward.
        else if (!data().gotSkin || data().beatedMod)
            nuggetLines = [0];

        if (data().polla)
            nuggetLines.remove(1); // Nugget thinks you should type NUGGET in the main menu.

        if (!cast(data().beatedSongs, Array<Dynamic>).contains('Nugget'))
            nuggetLines.remove(6); // Nugget thinks you are trustworthy. Trust is a rare nugget.

        trace('Locked lines: ${11 - nuggetLines.length} (${[for (i in 0...11) if (!nuggetLines.contains(i)) i]})');

        return FlxG.random.getObject(nuggetLines);
    }
}