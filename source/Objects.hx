package;

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

        var txt = new FlxText(0, y + 100, 0, idiom, 86);
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

class Apple extends FlxSprite
{
    override public function new(x:Float, y:Float)
    {
        super(x, y);

        if (!PlayState.isPixel)
            loadGraphic(Paths.image('gameplay/notes/apple', 'shared'));
        else
            loadGraphic(Paths.image('gameplay/pixel/apple', 'shared'));

        setGraphicSize(Std.int(width * 0.6));
        updateHitbox();
        scrollFactor.set();
    }
}

class KinderButton extends FlxSpriteGroup
{
    public var selected:Bool = false;
    public var daText:FlxText;
    public var texto:String = "";
    public var description:String;
    public var finishThing:Void->Void;
    public var actualColor:FlxColor;
    private var botton:FlxSprite;

    public function new(X:Float, Y:Float, texto:String = "", description:String, finishThing:Void->Void)
        {
            super(X, Y);

            this.texto = texto;
            this.description = description;
            this.finishThing = finishThing;

            var colors = [0xA64D7B, 0x6DCCAF, 0xA17B55, 0x76DA9B, 0x7F8CDB, 0xC48CD9, 0xC4D88D, 0x685DD3];

            botton = new FlxSprite(X, Y);
            botton.loadGraphic(Paths.image('menu/' + 'button', 'preload'));
            botton.color = colors[FlxG.random.int(0, colors.length - 1)];
            actualColor = botton.color;
            botton.scrollFactor.set();
            botton.active = false;
            add(botton);

            daText = new FlxText(X, 0, botton.width - 10, texto, 50);
            daText.autoSize = false;
            daText.setFormat(Paths.font('Crayawn-v58y.ttf'), 50, FlxColor.BLACK, CENTER);
            daText.scrollFactor.set();
            daText.y = Y + ((botton.height / 2) - (daText.height / 2));
            daText.active = false;
            add(daText);  
        }

    override function update(elapsed:Float)
	{
        daText.text = texto;
        selected = FlxG.mouse.overlaps(botton);

        if (selected)
        {
            botton.color = FlxColor.YELLOW;
            if (FlxG.mouse.justPressed)
                finishThing();
        }
        else
            botton.color = actualColor;
        
		super.update(elapsed);
    }
}

class SongCreditsSprite extends FlxSpriteGroup
{
    public function new(Y:Float, song:String = "", author:String = "")
    {
        super();

        var botton = new FlxSprite(0, Y).loadGraphic(Paths.image('songCredit', 'preload'));
        botton.scrollFactor.set();
        botton.screenCenter(X);
        botton.active = false;
        add(botton);

        var daText = new FlxText(0, Y + 270, 0, song + "\n by " + author, 50);
        daText.setFormat(Paths.font('Crayawn-v58y.ttf'), 50, FlxColor.BLACK, CENTER);
        daText.scrollFactor.set();
        daText.screenCenter(X);
        daText.active = false;
        add(daText);

        active = false;
    }
}

class DialogueIcon extends FlxSprite
{
    public var daColor:FlxColor;
    private var character:Character;
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

            character = new Character(0,0,char);

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
                case 'bf':
                    daColor = FlxColor.fromString(character.curColor);
                    offset.set(10, 10);
                default:
                    daColor = FlxColor.fromString(character.curColor);
                    offset.set(0, 0);
            }
        }
    
    override function update(elapsed:Float)
    {
        if (this != null && animation.curAnim != null)
        {
            if (animation.curAnim.name == 'talking' && animation.curAnim.curFrame == 1)
                angle = FlxG.random.int(-10, -2);
            else
                angle = 0;
        }
        super.update(elapsed);
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

            frames = Paths.getSparrowAtlas('menu/mainButtons', 'preload');
            animation.addByPrefix('idle', animationName, 24);
            scrollFactor.set();
            animation.play('idle');

            setGraphicSize(Std.int(width * 0.6));
            updateHitbox();
            x = 900;
        }

    override function update(elapsed:Float)
	{
        lerpX = (selected ? 700 : 900);
        if (x != lerpX) // idk
            x = FlxMath.lerp(x, lerpX, elapsed * 5); //make this with elapsed later for fps bullshit

        if (FlxG.mouse.overlaps(this))
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
    private var epicTween:flixel.tweens.FlxTween;

	override public function new()
	{
		super();

        var ratings = ['miss', 'shit', 'bad', 'good', 'sick'];
		if (!PlayState.isPixel)
        {
            frames = Paths.getSparrowAtlas('gameplay/ratings', 'shared');
            for (i in 0...ratings.length)
                animation.addByPrefix(ratings[i], ratings[i], 0, true);
            setGraphicSize(Std.int(width * 0.7));
        }
        else
        {
            loadGraphic(Paths.image('gameplay/pixel/good', 'shared'));
            antialiasing = false;
            setGraphicSize(Std.int(width * 6 * 0.7));
        }
        updateHitbox();

        acceleration.y = FlxG.random.int(200, 300);
        alpha = 0;
    
        if (KadeEngineData.settings.data.changedHit)
            setPosition(KadeEngineData.settings.data.changedHitX, KadeEngineData.settings.data.changedHitY);
        else
        {
            screenCenter(Y);
            y += 50;
            x = (FlxG.width * 0.55) - 225;
        }

        scrollFactor.set();
	}

	public function play(daRating:String)
    {
        if (!PlayState.isPixel)
            animation.play(daRating, true);
        else
            loadGraphic(Paths.image('gameplay/pixel/' + daRating, 'shared'));

        if (epicTween != null)
            epicTween.cancel();
        alpha = 1;
        
        if (KadeEngineData.settings.data.changedHit)
            setPosition(KadeEngineData.settings.data.changedHitX, KadeEngineData.settings.data.changedHitY);
        else
        {
            screenCenter(Y);
            y += 50;
            x = (FlxG.width * 0.55) - 225;
        }

        velocity.set();
        velocity.y -= FlxG.random.int(150, 160);

        epicTween = flixel.tweens.FlxTween.tween(this, {alpha: 0}, 0.1, {startDelay: Conductor.crochet * 0.001, onComplete: function(_)
        {
            velocity.set();
        }});
    }
}

class Number extends FlxSprite
{
    override public function new()
    {
        super();

		if (!PlayState.isPixel)
		{
			frames = Paths.getSparrowAtlas('gameplay/numbers', 'shared');
			animation.addByPrefix('idle', 'numbers', 0, true);
            setGraphicSize(Std.int(width * 0.5));
		}
		else
        {
            loadGraphic(Paths.image('gameplay/pixel/num0'));
            antialiasing = false;
			setGraphicSize(Std.int(width * 6));
        }
		updateHitbox();
		acceleration.y = FlxG.random.int(200, 300);
        kill();
    }

    public function play(i:Int):Void
    {
        if (!PlayState.isPixel)
        {
            frames = Paths.getSparrowAtlas('gameplay/numbers', 'shared');
			animation.addByPrefix('idle', 'numbers', 0, true);
			animation.play('idle', true, false, i);
            setGraphicSize(Std.int(width * 0.5));
        }
        else
        {
            loadGraphic(Paths.image('gameplay/pixel/num$i'));
            antialiasing = false;
			setGraphicSize(Std.int(width * 6));
        }
        updateHitbox();

        alpha = 1;
        velocity.set();
        velocity.y -= FlxG.random.int(150, 160);
        flixel.tweens.FlxTween.tween(this, {alpha: 0}, 0.1, {
            onComplete: function(_)
            {
                kill();
            },
            startDelay: Conductor.crochet * 0.001
        });
    }
}