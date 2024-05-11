package objects;

import flixel.tweens.FlxEase;
import objects.Character.CharData;
import states.PlayState;
import funkin.Conductor;
import data.GlobalData;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.FlxG;
import flixel.FlxSprite;

//i really like creating a new .hx for every fucking thing that i make
//omg there is a way to make every one in a single .hx
//only simple stuff here, not anything too complex

class LanguageSpr extends FlxTypedGroup<FlxSprite>
{
    public var book:FlxSprite;
    public var selected:Bool = false;

    public function new(x:Float, y:Float, idiom:String)
    {
        super();

        book = new FlxSprite(x, y).loadGraphic(Paths.image('menu/book', 'preload'));
        book.active = false;
        book.setGraphicSize(0, 410);
	    book.updateHitbox();
        add(book);

        var txt = new FlxText(0, y + 100, book.width + 10, idiom, 86);
        txt.autoSize = false;
        txt.alignment = CENTER;
        txt.font = Paths.font('Crayawn-v58y.ttf');
        txt.active = false;
        CoolUtil.middleSprite(book, txt, X);
        add(txt);
    }

    override function update(elapsed:Float)
	{
        if (selected)
            book.alpha = 1;
        else
            book.alpha = 0.5;
        
		super.update(elapsed);
    }
}

class Apple extends FlxSpriteGroup
{
    public var sprite:FlxSprite;
    public var counter:FlxText;

    override public function new()
    {
        super(0, 0, 2);

        sprite = new FlxSprite();
        if (!PlayState.SONG.isPixel)
        {
            sprite.loadGraphic(Paths.image('gameplay/notes/apple', 'shared'));
        }
        else
        {
            sprite.frames = Paths.pixel();
            sprite.animation.addByPrefix('idle', 'apple', 0, false);
            sprite.animation.play('idle');
            sprite.antialiasing = false;
            sprite.setGraphicSize(sprite.width * 4);
            sprite.updateHitbox();
        }

        sprite.setGraphicSize(sprite.width * 0.7);
        sprite.updateHitbox();
        add(sprite);

        counter = new FlxText(10, 0, sprite.width, '', 62);
        counter.autoSize = false;
		counter.setFormat(Paths.font('Crayawn-v58y.ttf'), 62, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		counter.borderSize = 2;
        counter.y += sprite.height - counter.height / 1.5;
        add(counter);

        scrollFactor.set();
        active = false;
    }

    public function updateCounter(amount:Int):Void
    {
        counter.text = 'x' + Std.string(amount);

        counter.color = switch (amount)
        {
            case 0: FlxColor.RED;
            case 3: FlxColor.YELLOW;
            default: FlxColor.WHITE;
        }

        FlxTween.cancelTweensOf(counter, ['scale', 'scale.x', 'scale.y']);
        counter.scale.set(1.05, 1.05);
        FlxTween.tween(counter.scale, {x: 1, y: 1}, 0.25, {ease: FlxEase.circOut});
    }
}

class PageSprite extends FlxSpriteGroup
{
    public function new(text:String, upper:Bool, duration:Float = 0.5)
    {
        super();

        var initY = upper ? -420 : FlxG.height;
        var finalY = upper ? -250 : FlxG.height - 150;
        var textOffset = upper ? 270 : 40;

        var page = new FlxSprite(0, initY).loadGraphic(Paths.image('songCredit', 'preload'));
        page.scrollFactor.set();
        page.screenCenter(X);
        page.flipY = !upper;
        add(page);

        var daText = new FlxText(0, initY + textOffset, text, 50);
        daText.setFormat(Paths.font('Crayawn-v58y.ttf'), 50, FlxColor.BLACK, CENTER);
        daText.scrollFactor.set();
        daText.screenCenter(X);
        add(daText);

        active = false;

        FlxTween.tween(page, {y: finalY}, 1, {ease: flixel.tweens.FlxEase.expoOut});
        FlxTween.tween(daText, {y: finalY + textOffset}, 1, {ease: flixel.tweens.FlxEase.expoOut, onComplete: function(_)
        {
            FlxTween.tween(page, {y: initY}, 1, {startDelay: duration, ease: flixel.tweens.FlxEase.expoIn});
            FlxTween.tween(daText, {y: initY + textOffset}, 1, {startDelay: duration, ease: flixel.tweens.FlxEase.expoIn, onComplete: function(_)
            {
                page.destroy();
                daText.destroy();
                destroy();
            }});
        }});
    }
}

class DialogueIcon extends FlxSprite
{
    public var daColor:FlxColor;
    public var char:String;

    public function new(x:Float, y:Float, char:String)
    {
        super(x, y);

        this.char = char;

        frames = Paths.getSparrowAtlas('gameplay/icons', 'shared');
        animation.addByIndices('idle', char, [0], "", 0, false);
        animation.addByIndices('talking', char, [1, 0], "", 24, true);
        animation.play('idle');
        scrollFactor.set();

        switch (char)
        {
            case 'nugget':
                daColor = 0xe58966;
            case 'protagonist':
                daColor = 0xc8c8c8;
            case 'janitor':
                daColor = 0x74b371;
                offset.set(20, 15);
                setGraphicSize(Std.int(width * 0.8));
            case 'principal':
                daColor = 0x6288a8;
                offset.set(35, 25);
                setGraphicSize(Std.int(width * 0.9));
            case 'monty':
                daColor = 0x85d3a2;
            case 'lady': //lol
                daColor = 0xc8b794;
            case 'buggs':
                daColor = 0x9d927b;
            case 'lily':
                daColor = 0x97d8e0;
            case 'cindy':
                daColor = 0xddaddf;
            case 'applegate':
                daColor = 0xcd8ae2;
            case 'jerome':
                daColor = 0xe3bb39;
            default:
                daColor = FlxColor.fromString(new CharData(char).color);

                if (char == 'bf' || char == 'bf-alt')
                    offset.set(10, 10);
                else
                    offset.set(0, 0);
        }
    }
    
    override function update(elapsed:Float)
    {
        if (animation.curAnim != null)
        {
            if (animation.curAnim.name == 'talking' && animation.curAnim.curFrame == 1)
                angle = FlxG.random.int(-10, -2);
            else
                angle = 0;
        }

        updateAnimation(elapsed);

        // super.update(elapsed);
    }
}

//not an object but you can suck my balls
class Outline extends flixel.system.FlxAssets.FlxShader {
	@:glFragmentSource('
    #pragma header

    void main() {
      vec4 color = texture2D(bitmap, openfl_TextureCoordv);
      const float BORDER_WIDTH = 1.5;
      float w = BORDER_WIDTH / openfl_TextureSize.x;
      float h = BORDER_WIDTH / openfl_TextureSize.y;

      if (color.a == 0.) {
        if (texture2D(bitmap, vec2(openfl_TextureCoordv.x + w, openfl_TextureCoordv.y)).a != 0.
        || texture2D(bitmap, vec2(openfl_TextureCoordv.x - w, openfl_TextureCoordv.y)).a != 0.
        || texture2D(bitmap, vec2(openfl_TextureCoordv.x, openfl_TextureCoordv.y + h)).a != 0.
        || texture2D(bitmap, vec2(openfl_TextureCoordv.x, openfl_TextureCoordv.y - h)).a != 0.) {
          gl_FragColor = vec4(0.262, 0.156, 0.4, 0.6);
        } else {
          gl_FragColor = color;
        }
      } else {
        gl_FragColor = color;
      }
    }')
	public function new() {
		super();
	}
}

//class SoundSetting extends FlxSpriteGroup     nope, this is too complex to be here

class MainMenuButton extends FlxSprite
{
    private var lerpX:Int = 900;
    public var selected:Bool = false;
    public var clickFunction:Void->Void;

    public function new(Y:Float, animationName:String = "")
        {
            super(900, Y);

            frames = Paths.getSparrowAtlas('menu/mainmenu_assets', 'preload');
            animation.addByPrefix('idle', animationName, 24);
            scrollFactor.set();
            animation.play('idle');

            // setGraphicSize(Std.int(width * 0.6));
            updateHitbox();
            x = 900;
        }

    override function update(elapsed:Float)
	{
        lerpX = (selected ? 700 : 900);
        if (x != lerpX) // idk
            x = FlxMath.lerp(x, lerpX, CoolUtil.boundTo(elapsed * 5)); //make this with elapsed later for fps bullshit

        if (CoolUtil.overlaps(this))
        {
            selected = true;

            if (FlxG.mouse.justPressed)
                clickFunction();
        }
        else
            selected = false;

        
		super.update(elapsed);
    }
}

class Rating extends FlxSprite
{
    final ratings = ['shit', 'bad', 'good', 'sick'];

	override public function new()
	{
		super();

		if (!states.PlayState.SONG.isPixel)
            frames = Paths.ui();
        else
        {
            frames = Paths.pixel();
            antialiasing = false;
            setGraphicSize(Std.int(width * 6 * 0.7));
        }
        for (i in 0...ratings.length)
            animation.addByIndices(ratings[i], 'ratings', [i], '', 0, true);

        updateHitbox();
        scrollFactor.set();

        kill();
	}

    override function update(elapsed:Float)
    {
        // super.update(elapsed); instead of putting "active = false" everywhere, i can just cancel this from calling and it wont update all previous code but the function will still call

        updateMotion(elapsed); //just update the velocity and shit
    }

	public function play(daRating:String)
    {
        animation.play(daRating, true);

        flixel.tweens.FlxTween.cancelTweensOf(this);
        alpha = 1;

        if (GlobalData.settings.changedHit)
            setPosition(GlobalData.settings.changedHitX, GlobalData.settings.changedHitY);
        else
        {
            screenCenter(Y);
            y += 50;
            x = (FlxG.width * 0.55) - 225;
        }

        acceleration.y = 550;
		velocity.y = FlxG.random.int(-140, -175);
		velocity.x = FlxG.random.int(0, -10);

        flixel.tweens.FlxTween.tween(this, {alpha: 0}, 0.2, {startDelay: funkin.Conductor.crochet * 0.001, onComplete: function(_)
        {
            kill();
        }});
    }
}

class Number extends FlxSprite
{
    override public function new()
    {
        super();

		if (!states.PlayState.SONG.isPixel)
		    frames = Paths.ui();
		else
        {
            frames = Paths.pixel();
            antialiasing = false;
			setGraphicSize(Std.int(width * 6));
        }
        animation.addByPrefix('idle', 'numbers', 0, true);

		updateHitbox();
        kill();
    }

    public function play(i:Int):Void
    {
		animation.addByPrefix('idle', 'numbers', 0, true);
		animation.play('idle', true, false, i);

        flixel.tweens.FlxTween.cancelTweensOf(this);
        alpha = 1;
        acceleration.y = FlxG.random.int(200, 300);
		velocity.y = FlxG.random.int(-140, -160);
		velocity.x = FlxG.random.float(-5, -5);

        flixel.tweens.FlxTween.tween(this, {alpha: 0}, 0.2, {
            onComplete: function(_)
            {
                kill();
            },
            startDelay: funkin.Conductor.crochet * 0.002
        });
    }

    override function update(elapsed:Float)
    {
        // super.update(elapsed); instead of putting "active = false" everywhere, i can just cancel this from calling and it wont update all previous code but the function will still call

        updateMotion(elapsed); //just update the velocity and shit
    }
}

class Clock extends FlxTypedGroup<FlxSprite>
{
    private var clock:FlxSprite;
    private var secondHand:FlxSprite;
    private var minuteHand:FlxSprite;
    private var ringing:Bool = false;

    public var songLength:Float;
    public var alpha(default, set):Float = 1;

    public function new(camera:flixel.FlxCamera)
    {
        super();

        final stuff =
        {
            width: 6,
            height: 33,
            offsetX: 37,
            offsetY: 35
        }

        add(clock = new FlxSprite());
        clock.frames = Paths.getSparrowAtlas('gameplay/clock', 'shared');
        clock.animation.addByIndices('idle', 'alarm', [0, 1], '', 8, true);
        clock.animation.addByIndices('ring', 'alarm', [2, 3, 4, 5, 6, 7, 8], '', 24, false);
        clock.animation.addByIndices('ringing', 'alarm', [9, 10, 11, 12], '', 24, true);
        clock.animation.play('idle');
        if (GlobalData.settings.middlescroll)
            clock.x = FlxG.width - clock.width - 10;
        else
            clock.screenCenter(X);
        clock.x += 34;
        clock.y = (GlobalData.settings.downscroll ? FlxG.height - clock.height - 5 : 5);

        minuteHand = new FlxSprite(clock.x + (clock.width + stuff.width) / 2 - stuff.offsetX, clock.y + clock.height / 2 + stuff.offsetY).makeGraphic(stuff.width, stuff.height, FlxColor.BLACK);
        minuteHand.active = false;
        minuteHand.origin.y = 0;
        minuteHand.angle = 180;
        add(minuteHand);

        secondHand = new FlxSprite(clock.x + (clock.width + stuff.width) / 2 - stuff.offsetX, clock.y + clock.height / 2 + stuff.offsetY).makeGraphic(stuff.width, stuff.height * 2, FlxColor.BLACK);
        secondHand.active = false;
        secondHand.origin.y = 0;
        secondHand.angle = 180;
        add(secondHand);

        cameras = [camera];
    }

    private static inline final runs = 10;

    public function updateTime()
    {
        if (ringing)
            return;

        var songPositionSeconds:Float = funkin.Conductor.songPosition / 1000; //convert to seconds duh
        var minuteRotation = (songPositionSeconds / (songLength / 1000)) * 360;
        var secondRotation = (songPositionSeconds / (songLength / 1000)) * (runs * 360);

        minuteHand.angle = minuteRotation - 180;
        secondHand.angle = secondRotation - 180;
    }

    public function ring():Void
    {
        if (ringing)
            return;

        ringing = true;

        minuteHand.destroy();
        minuteHand = null;
        secondHand.destroy();
        secondHand = null;

        clock.animation.play('ring', true);

        clock.animation.finishCallback = function(xd:String)
        {
            if (xd == 'ring')
            {
                clock.animation.play('ringing');
                CoolUtil.sound('bell', 'shared');
            }
        }
    }

    function set_alpha(value:Float):Float
    {
        value = FlxMath.bound(value, 0, 1);

        for (basic in members)
        {
            basic.alpha = value;
        }

        return value;
    }
}

class Ghost extends FlxSprite
{
    public function new()
    {
        super();
        active = false;
    }

    public function setup(target:objects.Character):Void
    {
        FlxTween.cancelTweensOf(this);
        var anim = target.animation.curAnim.name;

		loadGraphicFromSprite(target);
        animation.play(anim, true);
		setPosition(target.x, target.y);
		offset.copyFrom(target.offset);
        color = FlxColor.fromString(target.curColor);
        scale.copyFrom(target.scale);
        alpha = 0.9;

		FlxTween.tween(this, {alpha: 0}, Conductor.crochet * 0.0025, {
			onComplete: function(_)
			{
				kill();
			}
		});
    }
}