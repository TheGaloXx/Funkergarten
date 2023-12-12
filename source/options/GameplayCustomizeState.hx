package options;

import input.Controls.ActionType;
import objects.Objects.Clock;
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
    private var defaultX:Float = (FlxG.width * 0.55) - 225;
    private var defaultY:Float;
    private var sick = new FlxSprite();
    private var camHUD:FlxCamera;

    public override function create() 
    {
        camHUD = new FlxCamera();
		// camHUD.bgColor.alpha = 0;
        FlxG.cameras.add(camHUD);

        add(new Clock(camHUD));

        if (!states.PlayState.isPixel)
            sick.frames = Paths.ui();
        else
        {
            sick.frames = Paths.pixel();
            sick.antialiasing = false;
            sick.setGraphicSize(Std.int(sick.width * 6 * 0.7));
        }
        sick.animation.addByIndices('idle', 'ratings', [3], '', 0, false);
        sick.animation.play('idle', true);
        sick.cameras = [camHUD];
        sick.updateHitbox();
        sick.scrollFactor.set();

        sick.screenCenter(Y);
        sick.y += 50;

        defaultY = sick.y;

        if (!data.KadeEngineData.settings.data.changedHit)
        {
            data.KadeEngineData.settings.data.changedHitX = defaultX;
            data.KadeEngineData.settings.data.changedHitY = defaultY;
            data.KadeEngineData.flush();
        }

        sick.setPosition(data.KadeEngineData.settings.data.changedHitX, data.KadeEngineData.settings.data.changedHitY);
		generateStaticArrows();
        add(sick);

        var text = new flixel.text.FlxText(10, FlxG.height, 0, Language.get('GameplayCustomize', 'help_text'), 26);
		text.scrollFactor.set();
        text.autoSize = false;
        text.alignment = LEFT;
        text.borderStyle = flixel.text.FlxText.FlxTextBorderStyle.OUTLINE;
        text.borderColor = FlxColor.BLACK;
        text.active = false;
		add(text);

		FlxTween.tween(text, {y: FlxG.height - text.height - 10}, 2, {ease: FlxEase.elasticInOut});
        FlxG.camera.zoom = 0.9;

        super.create();
    }

    override function update(elapsed:Float) 
    {
		if (FlxG.sound.music != null)
			funkin.Conductor.songPosition = FlxG.sound.music.time;

        FlxG.camera.zoom = FlxMath.lerp(0.9, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125)));
		camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125)));

        super.update(elapsed);

        updatePosition();
    }

    override function beatHit() 
    {
        super.beatHit();

        if ((curBeat % 2 == 0 && ((curBeat >= 64 && curBeat <= 124) || (curBeat >= 192 && curBeat <= 252))) || (curBeat % 4 == 0))
        {
            FlxG.camera.zoom += 0.015;
            camHUD.zoom += 0.010;
        }
    }

	private function generateStaticArrows():Void
    {
        for (player in 0...2)
        {
            for (i in 0...4)
            {
                var babyArrow = new objects.Strum(i, player);
                babyArrow.cameras = [camHUD];
                babyArrow.active = false;
                add(babyArrow);
            }
        }
    }

    private function updatePosition():Void
    {
        var up:Bool = controls.UI_UP.state == PRESSED;
        var down:Bool = controls.UI_DOWN.state == PRESSED;
        var left:Bool = controls.UI_LEFT.state == PRESSED;
        var right:Bool = controls.UI_RIGHT.state == PRESSED;

        if (up && down) up = down = false;
        if (left && right) left = right = false;

        if (right)
            sick.velocity.x = 300;
        else if (left)
            sick.velocity.x = -300;
        else
            sick.velocity.x = 0;

        if (down)
            sick.velocity.y = 300;
        else if (up)
            sick.velocity.y = -300;
        else
            sick.velocity.y = 0;

        if (sick.x > FlxG.width + sick.width)
            sick.x = FlxG.width + sick.width;
        else if (sick.x < -sick.width)
            sick.x = -sick.width;

        if (sick.y > FlxG.height + sick.height)
            sick.y = FlxG.height + sick.height;
        else if (sick.y < -sick.height)
            sick.y = -sick.height;

        data.KadeEngineData.settings.data.changedHitX = sick.x;
        data.KadeEngineData.settings.data.changedHitY = sick.y;
        data.KadeEngineData.settings.data.changedHit = true;
    }

    override function onActionPressed(action:ActionType)
    {
        if (action == BACK)
        {
            data.KadeEngineData.flush();

            CoolUtil.sound('cancelMenu', 'preload', 0.5);

			funkin.MusicBeatState.switchState(new options.GameplayOptions(new KindergartenOptions(null)));
        }

        if (action == RESET)
        {
            sick.setPosition(defaultX, defaultY);
            data.KadeEngineData.settings.data.changedHit = false;
        }
    }
}