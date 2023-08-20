package options;

import flixel.FlxBasic;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.FlxCamera;
#if cpp
import sys.thread.Thread;
#end

import flixel.FlxSprite;
import flixel.FlxG;

class GameplayCustomizeState extends funkin.MusicBeatState
{
    private var defaultX:Float = FlxG.width * 0.55 - 135;
    private var defaultY:Float = FlxG.height / 2 - 50;
    private var sick = new FlxSprite();
    private var camHUD:FlxCamera;

    public override function create() 
    {   
        funkin.Conductor.changeBPM(130 / 2);

        if (!data.KadeEngineData.settings.data.changedHit)
        {
         data.KadeEngineData.settings.data.changedHitX = defaultX;
            data.KadeEngineData.settings.data.changedHitY = defaultY;
        }

        camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
        FlxG.cameras.add(camHUD);

        sick.frames = Paths.getSparrowAtlas('gameplay/ratings', 'shared');
        sick.animation.addByPrefix('idle', 'sick', 0, true);
        sick.animation.play('idle', true);
        sick.scrollFactor.set();
        sick.setGraphicSize(Std.int(sick.width * 0.7));
        sick.updateHitbox();
        sick.cameras = [camHUD];
        sick.active = false;
        add(sick);
    
        sick.setPosition(data.KadeEngineData.settings.data.changedHitX, data.KadeEngineData.settings.data.changedHitY);
        
		generateStaticArrows(0);
		generateStaticArrows(1);

        var text = new flixel.text.FlxText(5, FlxG.height + 40, 0, Language.get('GameplayCustomize', 'help_text'), 12);
		text.scrollFactor.set();
        text.size = 16;
        text.alignment = LEFT;
        text.borderStyle = flixel.text.FlxText.FlxTextBorderStyle.OUTLINE;
        text.borderColor = FlxColor.BLACK;
        text.active = false;
		add(text);

		FlxTween.tween(text, {y: FlxG.height - 25}, 2, {ease: FlxEase.elasticInOut});
        FlxG.camera.zoom = 0.9;

        super.create();
    }

    override function update(elapsed:Float) 
    {
		if (FlxG.sound.music != null)
			funkin.Conductor.songPosition = FlxG.sound.music.time;

        FlxG.camera.zoom = FlxMath.lerp(0.9, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125)));
		camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125)));

        input();

        super.update(elapsed);
    }

    override function beatHit() 
    {
        super.beatHit();

        FlxG.camera.zoom += 0.015;
        camHUD.zoom += 0.010;

        trace('beat');
    }

	private function generateStaticArrows(player:Int):Void
    {
        var directions:Array<String> = ['left', 'down', 'up', 'right'];
        var posY = (data.KadeEngineData.settings.data.downscroll ? FlxG.height - 165 : 14);

        for (i in 0...4)
        {
            var babyArrow = new FlxSprite(0, posY - 10);
            babyArrow.frames = Paths.getSparrowAtlas('gameplay/notes/NOTE_assets', 'shared');
            babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
            babyArrow.animation.addByPrefix('static', 'arrow${directions[i].toUpperCase()}');
            babyArrow.animation.play('static');
            babyArrow.updateHitbox();
            babyArrow.scrollFactor.set();
            babyArrow.active = false;
            babyArrow.cameras = [camHUD];
            babyArrow.x += (objects.Note.swagWidth * Math.abs(i) + 100 + ((FlxG.width / 2) * player)) - (data.KadeEngineData.settings.data.middlescroll ? 275 : 0);
            if (player == 0 && data.KadeEngineData.settings.data.middlescroll) babyArrow.visible = false;
            add(babyArrow);
        }
    }

    private function updatePosition():Void
    {
        if (FlxG.keys.justPressed.UP)
            sick.y -= 50;
        if (FlxG.keys.justPressed.DOWN)
            sick.y += 50;
        if (FlxG.keys.justPressed.RIGHT)
            sick.x += 50;
        if (FlxG.keys.justPressed.LEFT)
            sick.x -= 50;

        if (FlxG.keys.justPressed.R)
        {
            sick.setPosition(defaultX, defaultY);
            data.KadeEngineData.settings.data.changedHit = false;
        }

        data.KadeEngineData.settings.data.changedHitX = sick.x;
        data.KadeEngineData.settings.data.changedHitY = sick.y;
        data.KadeEngineData.settings.data.changedHit = true;

        data.KadeEngineData.flush();
    }

    private function input():Void
    {
        if (FlxG.keys.anyJustPressed([UP, DOWN, RIGHT, LEFT, R]))
            updatePosition();

        if (controls.BACK)
        {
            CoolUtil.sound('cancelMenu', 'preload');

            funkin.Conductor.changeBPM(130);
			funkin.MusicBeatState.switchState(new options.GameplayOptions(new GameplayOptions(new KindergartenOptions(null))));
        }
    }
}