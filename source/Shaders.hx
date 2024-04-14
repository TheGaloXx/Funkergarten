package;

import flixel.system.FlxAssets.FlxShader;
import openfl.filters.ShaderFilter;

//indie cross aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
class ChromaHandler
{
	public static var chromaticAberration:ShaderFilter = new ShaderFilter(new ChromaticAberration());
	
	public static function setChrome(chromeOffset:Float):Void
	{
		chromaticAberration.shader.data.rOffset.value = [chromeOffset];
		chromaticAberration.shader.data.gOffset.value = [0.0];
		chromaticAberration.shader.data.bOffset.value = [chromeOffset * -1];
	}
}

class ChromaticAberration extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform float rOffset;
		uniform float gOffset;
		uniform float bOffset;

		void main()
		{
			vec4 col = vec4(1.0);
			
			col.r = texture2D(bitmap, openfl_TextureCoordv - vec2(rOffset, 0.0)).r;
			col.ga = texture2D(bitmap, openfl_TextureCoordv - vec2(gOffset, 0.0)).ga;
			col.b = texture2D(bitmap, openfl_TextureCoordv - vec2(bOffset, 0.0)).b;

			gl_FragColor = col;
		}')
	public function new()
	{
		super();

		rOffset.value = [0.0];
		gOffset.value = [0.0];
		bOffset.value = [0.0];
	}
}

// Took this from the HaxeFlixel MosaicEffect demo: https://haxeflixel.com/demos/MosaicEffect/
class MosaicShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		uniform vec2 uBlocksize;

		void main()
		{
			vec2 blocks = openfl_TextureSize / uBlocksize;
			gl_FragColor = flixel_texture2D(bitmap, floor(openfl_TextureCoordv * blocks) / blocks);
		}')
	public function new()
	{
		super();
	}
}

class MosaicEffect
{
	public static inline var DEFAULT_STRENGTH:Float = 1;

	public var shader(default, null):MosaicShader;
	public var strengthX(default, null):Float = DEFAULT_STRENGTH;
	public var strengthY(default, null):Float = DEFAULT_STRENGTH;

	public function new()
	{
		shader = new MosaicShader();
		shader.data.uBlocksize.value = [strengthX, strengthY];
	}

	public function setStrength(strengthX:Float, strengthY:Float):Void
	{
		this.strengthX = strengthX;
		this.strengthY = strengthY;

		shader.uBlocksize.value[0] = strengthX;
		shader.uBlocksize.value[1] = strengthY;
	}
}

// Code from FNF': Vs Impostor V4 - https://github.com/Clowfoe/IMPOSTOR-UPDATE/blob/main/source/ChromaticAbberation.hx
class Aberration2 extends flixel.FlxBasic
{
    public var shader(default, null):CAGLSL = new CAGLSL();
	public var amount(default, set):Float = 0;

    private var iTime:Float = 0;

    public function new(_amount:Float):Void
	{
        super();

        amount = _amount;
    }

    override function update(elapsed:Float):Void {}
	override function draw():Void {}
    
    function set_amount(v:Float):Float
	{
		amount = v;
		shader.amount.value = [amount];

		return v;
	}
}

class CAGLSL extends FlxShader
{
    @:glFragmentSource('
        #pragma header

        uniform float amount;

		vec2 PincushionDistortion(in vec2 uv, float strength) 
		{
			vec2 st = uv - 0.5;
			float uvA = atan(st.x, st.y);
			float uvD = dot(st, st);
			return 0.5 + vec2(sin(uvA), cos(uvA)) * sqrt(uvD) * (1.0 - strength * uvD);
		}

		vec3 ChromaticAbberation(sampler2D tex, in vec2 uv) 
		{
			float rChannel = texture(tex, PincushionDistortion(uv, 0.3 * amount)).r;
			float gChannel = texture(tex, PincushionDistortion(uv, 0.15 * amount)).g;
			float bChannel = texture(tex, PincushionDistortion(uv, 0.075 * amount)).b;
			vec3 retColor = vec3(rChannel, gChannel, bChannel);
			return retColor;
		}

		void main()
		{
			vec2 uv = openfl_TextureCoordv;
			vec3 col = ChromaticAbberation(bitmap, uv);
		
			gl_FragColor = vec4(col, 1.0);
		}')

    public function new()
    {
        super();
    }
}