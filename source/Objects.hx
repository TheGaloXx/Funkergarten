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
    public var botton:FlxSprite;
    public var finishThing:Void->Void;
    public var actualColor:FlxColor;

    var colors = [0xA64D7B, 0x6DCCAF, 0xA17B55, 0x76DA9B, 0x7F8CDB, 0xC48CD9, 0xC4D88D, 0x685DD3];

    public function new(X:Float, Y:Float, texto:String = "", description:String, finishThing:Void->Void, halfAlpha:Bool = true)
        {
            super(X, Y);

            this.texto = texto;
            this.description = description;
            this.finishThing = finishThing;

            botton = new FlxSprite(X, Y);
            botton.loadGraphic(Paths.image('menu/' + (halfAlpha ? 'button' : 'solidButton'), 'preload'));
            botton.color = colors[FlxG.random.int(0, colors.length - 1)];
            actualColor = botton.color;
            botton.scrollFactor.set();
            add(botton);

            daText = new FlxText(X, Y, 0, "", 50);
            daText.setFormat(Paths.font('Crayawn-v58y.ttf'), 50, FlxColor.BLACK, CENTER);
            daText.text = texto;
            daText.scrollFactor.set();
            daText.fieldWidth = botton.width - 5;
            add(daText);  
        }

    override function update(elapsed:Float)
	{
        //daText.setPosition(botton.x + (botton.width / 5), botton.y + (botton.height / 3) - 5); //actual position

        daText.setPosition(botton.x + 5, botton.y + (botton.height / 3) - 5); //fieldwidth test, edit: EPICO
        if ((daText.height >= (botton.height / 1.5))){
           daText.size = 40;
           daText.y -= 2.5;
        }

        //daText.autoSize = true; //proba esto


        //daText.setPosition(botton.x + (botton.width / 5), botton.y + (botton.height / 3) - 5);
        daText.text = texto;
        daText.alignment = CENTER;
        //if (daText.width > (botton.width / 1.5))
        //   daText.size -= 2;

        if (FlxG.mouse.overlaps(botton))
        {
            selected = true;
            if (FlxG.mouse.justPressed)
                finishThing();
        }
        else
            selected = false;

        if (selected)
            botton.color = FlxColor.YELLOW; //botton.alpha = 0.75; //botton.shader = new Outline();
        else
            botton.color = actualColor;     //botton.alpha = 1; //botton.shader = null;
        
		super.update(elapsed);
    }
}

class SongCreditsSprite extends FlxSpriteGroup
{
    public var selected:Bool = false;
    public var daText:FlxText;
    public var author:String = "";
    public var description:String;
    public var botton:FlxSprite;

    public function new(Y:Float, song:String = "", author:String = "")
        {
            super(Y);

            this.author = author;

            botton = new FlxSprite();
            botton.loadGraphic(Paths.image('songCredit', 'preload'));
            botton.scrollFactor.set();
            botton.screenCenter(X);
            botton.y = Y;
            add(botton);

            daText = new FlxText(0, Y, 0, "", 50);
            daText.setFormat(Paths.font('Crayawn-v58y.ttf'), 50, FlxColor.BLACK, CENTER);
            daText.text = song + "\n by " + author;
            daText.scrollFactor.set();
            daText.screenCenter(X);
            daText.y = Y;
            daText.y += 270;
            add(daText);   

            scrollFactor.set();
            screenCenter(X);

            y = Y;
        }
}

class MenuItem extends FlxSpriteGroup
{
	public var targetY:Float = 0;
	public var week:FlxSprite;
	public var flashingInt:Int = 0;

	//a

	public function new(x:Float, y:Float, weekNum:Int = 0)
	{
		super(x, y);
		week = new FlxSprite().loadGraphic(Paths.image('menu/storymenu/week' + weekNum, 'preload'));
		add(week);
	}

	private var isFlashing:Bool = false;

	public function startFlashing():Void
	{
		isFlashing = true;
	}

	// if it runs at 60fps, fake framerate will be 6
	// if it runs at 144 fps, fake framerate will be like 14, and will update the graphic every 0.016666 * 3 seconds still???
	// so it runs basically every so many seconds, not dependant on framerate??
	// I'm still learning how math works thanks whoever is reading this lol
	var fakeFramerate:Int = Math.round((1 / FlxG.elapsed) / 10);

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		y = FlxMath.lerp(y, (targetY * 120) + 480, 0.17 * (60 / KadeEngineData.settings.data.fpsCap));

		if (isFlashing)
			flashingInt += 1;
	
		if (flashingInt % fakeFramerate >= Math.floor(fakeFramerate / 2))
			week.color = 0xFF33ffff;
		else if (KadeEngineData.settings.data.flashing)
			week.color = FlxColor.WHITE;
	}
}

class NoteCombo extends FlxText
{
    public var selected:Bool = false;

    public function new()
        {
            super();

            alignment = CENTER;
            color = FlxColor.BLACK;
            borderSize = 2;
            size = 125;
            font = Paths.font("againts.otf");
            antialiasing = true;
            scrollFactor.set();
            screenCenter();
            x = x - 450;
            borderColor = FlxColor.WHITE;
            borderStyle = OUTLINE;
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