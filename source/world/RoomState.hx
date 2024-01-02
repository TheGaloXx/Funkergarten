package world;

import funkin.MusicBeatState;
import flixel.util.FlxCollision;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.FlxG;
import objects.Kid;
import flixel.FlxSprite;

class RoomState extends funkin.MusicBeatState
{
    var background:FlxSprite;
    var bf:KidBoyfriend;
    var protagonist:objects.Kid;
    var hitbox:FlxSprite;
    var indicator:Indicator;
    var camara:FlxCamera;

    public static var tellMonday:Bool;
    var blackScreen:FlxSprite;
    private var group = new flixel.group.FlxGroup.FlxTypedGroup<FlxSprite>();

    override public function create()
    {
        // FlxG.fixedTimestep = true;

        CoolUtil.title('Room');
		CoolUtil.presence(null, Language.get('Discord_Presence', 'room_menu'), false, 0, null);

        hitbox = new FlxSprite().loadGraphic(Paths.image('hitbox', 'preload'));
        hitbox.antialiasing = false;
        hitbox.setGraphicSize(Std.int(hitbox.width * 3));
        hitbox.updateHitbox();
        hitbox.screenCenter();
        add(hitbox);

        background = new FlxSprite();
        background.frames = Paths.getSparrowAtlas('world_assets', 'preload');
        background.animation.addByPrefix('idle', 'room', 0, false);
        background.animation.play('idle');
        background.active = background.antialiasing = false;
        background.setGraphicSize(Std.int(background.width * 3));
        background.updateHitbox();
        background.screenCenter();
        add(background);

        add(group);

        protagonist = new objects.Kid(600, 435, 'protagonist');
        group.add(protagonist);

        bf = new KidBoyfriend(1020, 315);
        bf.canMove = false;
        group.add(bf);

        indicator = new Indicator(610, protagonist.getGraphicMidpoint().y - 135);
        add(indicator);

        camara = new FlxCamera(0, 0, FlxG.width, FlxG.height);
        FlxG.cameras.reset(camara);
        camara.target = bf;
        camara.setScrollBoundsRect(-130, -20, background.width - 10, background.height - 20);
        add(camara);

        FlxG.cameras.setDefaultDrawTarget(camara, true);

        blackScreen = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
        blackScreen.scale.set(FlxG.width * 2, FlxG.height * 2);
        blackScreen.updateHitbox();
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

        if (!FlxG.sound.music.playing) FlxG.sound.playMusic(Paths.music('world theme', 'preload'));

        super.create();
    }

    var transitioning:Bool = false;

    override public function update(elapsed:Float)
    {
        if (bf.overlaps(protagonist) && !transitioning)
        {
            indicator.visible = true;

            if (FlxG.keys.anyJustPressed([ENTER, SPACE]))
            {
                protagonist.flipX = !bf.flipX;
                transitioning = true;
                bf.canMove = false;
                bf.velocity.set();
                bf.animation.play('idle');

                var screenFade:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
                screenFade.scale.set(FlxG.width * 2, FlxG.height * 2);
                screenFade.updateHitbox();
                screenFade.scrollFactor.set();
                screenFade.alpha = 0;
                screenFade.active = false;
                add(screenFade);

                states.PlayState.storyPlaylist = ['Monday', 'Nugget', 'Staff Only', 'Cash Grab', 'Expelled'];
                var songFormat = StringTools.replace(states.PlayState.storyPlaylist[0], " ", "-");
			    var poop:String = data.Highscore.formatSong(songFormat, states.PlayState.storyDifficulty);
                trace(poop);
		        states.PlayState.isStoryMode = true;
                states.PlayState.SONG = funkin.Song.loadFromJson(poop, states.PlayState.storyPlaylist[0].toLowerCase());
                states.PlayState.tries = 0;

                FlxTween.tween(screenFade, {alpha: 1}, 0.5);
                new FlxTimer().start(0.5, function(_) {

                    MusicBeatState.switchState(new states.PlayState(), true);
                });
            }
        }
        else
            indicator.visible = false;

        if (bf.y < 280 && bf.x > 935 && bf.x < 1100 && !transitioning)
        {
            transitioning = true;
            bf.canMove = false;
            funkin.MusicBeatState.switchState(new BackyardState());
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

        super.update(elapsed);

        screenCollision();
        group.sort(flixel.util.FlxSort.byY);
        // FlxG.collide(bf, hitbox);
    }

    function screenCollision():Void
    {
        if (FlxCollision.pixelPerfectCheck(bf, hitbox, 1))
        {
            // this is so lazy LMFAOO

            if (bf.x < background.x + background.width / 2)
            {
                if (bf.velocity.x < 0)
                    bf.velocity.x = 0;
            }
            else
            {
                if (bf.velocity.x > 0)
                    bf.velocity.x = 0;
            }

            if (bf.velocity.y < 0)
                bf.velocity.y = 0;
        }

        /*
        if (bf.x < 10)
            bf.x = 10;

        if (bf.x > 1200)
            bf.x = 1200;
        */

        if (bf.y < 273)
            bf.y = 273;

        if (bf.y > 640)
            bf.y = 640;
    }

    function MondayShit():Void
        {
            #if debug
            var isTuesday:Bool = FlxG.random.bool(35);
            #else
            var isTuesday:Bool = FlxG.random.bool(1);
            #end
    
            var monday = new FlxText(0,0,0, "", 160);
            monday.text = (isTuesday ? Language.get('Room', 'tuesday_text') : Language.get('Room', 'monday_text'));
            monday.scrollFactor.set();
            monday.font = Paths.font('Crayawn-v58y.ttf');
            monday.alpha = 0;
            monday.screenCenter();
            monday.color = FlxColor.YELLOW;
            add(monday);
    
            var times = new FlxText(0,0,0, "", 60);
            times.scrollFactor.set();
            times.font = Paths.font('Crayawn-v58y.ttf');
            times.y = monday.y + 125;
            times.alpha = 0;
            times.color = FlxColor.YELLOW;
            add(times);

            final literally = Language.get('Room', 'literally_text');
    
            if (!isTuesday)
            {
                var text:String = Language.get('Room', 'again_text');
    
                switch(data.KadeEngineData.other.data.mondays)
                {
                    case -1:
                        times.text = "El pepe";
                    case 0:
                        times.text = "";
                    case 1:
                        times.text = "(" + text + ")";
                    default:
                        times.text = "(" + text + " x " + data.KadeEngineData.other.data.mondays + ")";
    
                }
    
                if (Date.now().getDay() == 1)  //psych engine lol
                {
                    if (data.KadeEngineData.other.data.mondays >= 2)
                        times.text = '($literally x ' + data.KadeEngineData.other.data.mondays + ")";
                    else
                        times.text = '($literally)';
                }
            }
            else
            {
                if (Date.now().getDay() == 2)  //psych engine lol
                {
                    times.text = '($literally)';
                }
                else
                {
                    times.text = Language.get('Room', 'lol_text');
                }
            }
    
            data.KadeEngineData.other.data.mondays++;
    
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

                                remove(blackScreen); blackScreen.destroy();
                                remove(monday); monday.destroy();
                                remove(times); times.destroy();
                            }});
                        });
                }});
            }});
        }
}