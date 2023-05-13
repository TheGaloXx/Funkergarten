package;

import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
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
        CoolUtil.title('Room');
		CoolUtil.presence(null, 'In the room', false, 0, null);

        background = new FlxSprite(0,0).loadGraphic(Paths.image('world/room', 'preload'));
        background.antialiasing = false;
        background.flipY = true;
        background.setGraphicSize(Std.int(background.width * 3));
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

        FlxG.cameras.setDefaultDrawTarget(camara, true);

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
                screenFade.active = false;
                add(screenFade);

                PlayState.storyPlaylist = ['Monday', 'Nugget'];
                var songFormat = StringTools.replace(PlayState.storyPlaylist[0], " ", "-");
			    var poop:String = Highscore.formatSong(songFormat, menus.MainMenuState.difficulty);
                trace(poop);
		        PlayState.isStoryMode = true;
                PlayState.storyDifficulty = menus.MainMenuState.difficulty;
                PlayState.SONG = Song.loadFromJson(poop, PlayState.storyPlaylist[0].toLowerCase());
                PlayState.storyWeek = 1;
                PlayState.campaignScore = 0;
                PlayState.tries = 0;

                FlxTween.tween(screenFade, {alpha: 1}, 0.5);
                new FlxTimer().start(0.5, function(_) {

                    substates.LoadingState.loadAndSwitchState(new PlayState(), true);
                });
            }
        }
        else
            indicator.visible = false;

        if (bf.y < 270 && bf.x > 935 && bf.x < 1100 && !transitioning)
        {
            transitioning = true;
            bf.canMove = false;
            BackyardState.tellMonday = false;
            MusicBeatState.switchState(new BackyardState());
        }

        if (FlxG.keys.anyJustPressed([ESCAPE, BACKSPACE]))
            {
                bf.canMove = false;
                MusicBeatState.switchState(new menus.MainMenuState());
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