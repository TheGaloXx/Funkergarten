package menus;

import flixel.FlxBasic;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import lime.app.Application;
import flixel.FlxCamera;
#if cpp
import sys.thread.Thread;
#end

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.FlxG;

class GameplayCustomizeState extends MusicBeatState
{
    //a
    var defaultX:Float = FlxG.width * 0.55 - 135;
    var defaultY:Float = FlxG.height / 2 - 50;

    var sick:FlxSprite;

    var text:FlxText;
    var blackBorder:FlxSprite;

    var strumLine:FlxSprite;
    var strumLineNotes:FlxTypedGroup<FlxSprite>;
    var playerStrums:FlxTypedGroup<FlxSprite>;
    private var camHUD:FlxCamera;
    
    public override function create() {

        Application.current.window.title = (Main.appTitle + (FlxG.save.data.esp ? ' - Customizar Gameplay' : ' - Gameplay Customize'));

        
        
        blackBorder = new FlxSprite(0, 0).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
        blackBorder.screenCenter();
		add(blackBorder);

        sick = new FlxSprite().loadGraphic(Paths.image('gameplay/sick','shared'));
        sick.antialiasing = FlxG.save.data.antialiasing;
        sick.scrollFactor.set();

		persistentUpdate = true;

        super.create();

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
        FlxG.cameras.add(camHUD);

        add(sick);

		FlxG.camera.zoom = 0.9;

		strumLine = new FlxSprite(0, 0).makeGraphic(FlxG.width, 14);
		strumLine.scrollFactor.set();
        strumLine.alpha = 0.4;

        add(strumLine);
		
		if (FlxG.save.data.downscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();

        sick.cameras = [camHUD];
        strumLine.cameras = [camHUD];
        playerStrums.cameras = [camHUD];
        
		generateStaticArrows(0);
		generateStaticArrows(1);

        text = new FlxText(5, FlxG.height + 40, 0, (FlxG.save.data.esp ? "Presiona las flechas de tu teclado para mover el 'Sick', R para reiniciar, tecla Escape para regresar." : "Press the arrows keys to move the 'Sick', R to reset, Escape to go back."), 12);
		text.scrollFactor.set();
        text.size = 16;
        text.color = FlxColor.WHITE;
        text.alignment = LEFT;
        text.borderStyle = FlxTextBorderStyle.OUTLINE;
        text.borderColor = FlxColor.BLACK;
		add(text);

		FlxTween.tween(text,{y: FlxG.height - 18},2,{ease: FlxEase.elasticInOut});

        if (!FlxG.save.data.changedHit)
        {
            FlxG.save.data.changedHitX = defaultX;
            FlxG.save.data.changedHitY = defaultY;
        }

        sick.x = FlxG.save.data.changedHitX;
        sick.y = FlxG.save.data.changedHitY;


        FlxG.mouse.visible = true;

    }

    override function update(elapsed:Float) {
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

        super.update(elapsed);

        FlxG.camera.zoom = FlxMath.lerp(0.9, FlxG.camera.zoom, 0.95);
        camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);

        if (FlxG.keys.justPressed.UP)
        {
            sick.y -= 50;
        }
        
        if (FlxG.keys.justPressed.DOWN)
            {
                sick.y += 50;
            }

        if (FlxG.keys.justPressed.RIGHT)
            {
                sick.x += 50;
            }

        if (FlxG.keys.justPressed.LEFT)
            {
                sick.x -= 50;
            }

        FlxG.save.data.changedHitX = sick.x;
        FlxG.save.data.changedHitY = sick.y;
        FlxG.save.data.changedHit = true;

        for (i in playerStrums)
            i.y = strumLine.y;
        for (i in strumLineNotes)
            i.y = strumLine.y;

        if (FlxG.keys.justPressed.R)
        {
            sick.x = defaultX;
            sick.y = defaultY;
            FlxG.save.data.changedHitX = sick.x;
            FlxG.save.data.changedHitY = sick.y;
            FlxG.save.data.changedHit = false;
        }

        if (controls.BACK)
        {
            FlxG.mouse.visible = false;
            FlxG.sound.play(Paths.sound('cancelMenu'));

            
			FlxG.switchState(new menus.OptionsMenu());
        }

    }

    override function beatHit() 
    {
        super.beatHit();

        FlxG.camera.zoom += 0.015;
        camHUD.zoom += 0.010;

        trace('beat');

    }


    // ripped from play state cuz im lazy
    
	private function generateStaticArrows(player:Int):Void
        {
            for (i in 0...4)
            {
                // FlxG.log.add(i);
                var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);
                babyArrow.frames = Paths.getSparrowAtlas('gameplay/NOTE_assets', 'shared');
                babyArrow.antialiasing = FlxG.save.data.antialiasing;
                babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
                switch (Math.abs(i))
                {
                    case 0:
                        babyArrow.x += Note.swagWidth * 0;
                        babyArrow.animation.addByPrefix('static', 'arrowLEFT');
                    case 1:
                        babyArrow.x += Note.swagWidth * 1;
                        babyArrow.animation.addByPrefix('static', 'arrowDOWN');
                    case 2:
                        babyArrow.x += Note.swagWidth * 2;
                        babyArrow.animation.addByPrefix('static', 'arrowUP');
                    case 3:
                        babyArrow.x += Note.swagWidth * 3;
                        babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
                }
                babyArrow.updateHitbox();
                babyArrow.scrollFactor.set();
    
                babyArrow.ID = i;
    
                if (player == 1)
                    playerStrums.add(babyArrow);
    
                babyArrow.animation.play('static');
                babyArrow.x += 50;
                babyArrow.x += ((FlxG.width / 2) * player);
    
                strumLineNotes.add(babyArrow);
            }
        }
}