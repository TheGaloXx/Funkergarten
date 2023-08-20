package world;

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
    var water:FlxSprite;
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
        CoolUtil.title('Room');
		CoolUtil.presence(null, 'In the room', false, 0, null);

        add(group);

        background = new FlxSprite(0,0).loadGraphic(Paths.image('world/room', 'preload'));
        background.antialiasing = false;
        background.flipY = true;
        background.setGraphicSize(Std.int(background.width * 3));
        background.updateHitbox();
        background.screenCenter();
        group.add(background);

        protagonist = new objects.Kid(600, 435, 'protagonist');
        group.add(protagonist);

        bf = new KidBoyfriend(1020, 315);
        group.add(bf);

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

        FlxG.cameras.setDefaultDrawTarget(camara, true);

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

        FlxG.sound.playMusic(Paths.music('world theme', 'preload'), data.KadeEngineData.settings.data.musicVolume);

        super.create();
    }

    var transitioning:Bool = false;

    override public function update(elapsed:Float)
    {
        #if debug
        if (FlxG.keys.justPressed.R)
            hitbox.visible = !hitbox.visible;
        #end

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
                screenFade.active = false;
                add(screenFade);

                states.PlayState.storyPlaylist = ['Monday', 'Nugget', 'Cash Grab', 'Staff Only', 'Expelled'];
                var songFormat = StringTools.replace(states.PlayState.storyPlaylist[0], " ", "-");
			    var poop:String = data.Highscore.formatSong(songFormat, states.MainMenuState.difficulty);
                trace(poop);
		        states.PlayState.isStoryMode = true;
                states.PlayState.storyDifficulty = states.MainMenuState.difficulty;
                states.PlayState.SONG = funkin.Song.loadFromJson(poop, states.PlayState.storyPlaylist[0].toLowerCase());
                states.PlayState.campaignScore = 0;
                states.PlayState.tries = 0;

                FlxTween.tween(screenFade, {alpha: 1}, 0.5);
                new FlxTimer().start(0.5, function(_) {

                    substates.LoadingState.loadAndSwitchState(new states.PlayState(), true);
                });
            }
        }
        else
            indicator.visible = false;

        if (bf.y < 270 && bf.x > 935 && bf.x < 1100 && !transitioning)
        {
            transitioning = true;
            bf.canMove = false;
            funkin.MusicBeatState.switchState(new BackyardState());
        }

        if (FlxG.keys.anyJustPressed([ESCAPE, BACKSPACE]))
            {
                bf.canMove = false;
                funkin.MusicBeatState.switchState(new states.MainMenuState());
            }


        super.update(elapsed);

        screenCollision();
        group.sort(flixel.util.FlxSort.byY);
        //FlxG.collide(bf, hitbox);
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

    function MondayShit():Void
        {
            #if debug
            var isTuesday:Bool = FlxG.random.bool(35);
            #else
            var isTuesday:Bool = FlxG.random.bool(1);
            #end
    
            var monday = new FlxText(0,0,0, "", 160);
            monday.text = (isTuesday ? (data.KadeEngineData.settings.data.esp ? "Martes" : "Tuesday") : (data.KadeEngineData.settings.data.esp ? "Lunes" : "Monday"));
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
    
            if (!isTuesday)
            {
                var text:String = (data.KadeEngineData.settings.data.esp ? "de nuevo" : "again");
    
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
                    times.text = "(" + (data.KadeEngineData.settings.data.esp ? "literalmente" : "literally") + " x " + data.KadeEngineData.other.data.mondays + ")";
            }
            else
            {
                var text:String = (data.KadeEngineData.settings.data.esp ? "literalmente" : "literally");
                if (Date.now().getDay() == 2)  //psych engine lol
                    {
                        times.text = "(" + (data.KadeEngineData.settings.data.esp ? "literalmente" : "literally") + ")";
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
                            }});
                        });
                }});
            }});
        }
}