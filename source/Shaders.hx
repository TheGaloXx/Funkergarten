package;

import flixel.FlxG;
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

// Original shader from Shadertoy: 20151110_VHS (https://www.shadertoy.com/view/XtBXDt)
class VHSShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform float time;

		#define PI 3.14159265

		vec3 tex2D(sampler2D _tex, vec2 _p)
		{
			vec3 col = texture( _tex, _p ).xyz;
			if (0.5 < abs(_p.x - 0.5))
			{
				col = vec3( 0.1 );
			}
			return col;
		}

		float hash( vec2 _v )
		{
			return fract( sin( dot( _v, vec2( 89.44, 19.36 ) ) ) * 22189.22 );
		}

		float iHash( vec2 _v, vec2 _r )
		{
			float h00 = hash( vec2( floor( _v * _r + vec2( 0.0, 0.0 ) ) / _r ) );
			float h10 = hash( vec2( floor( _v * _r + vec2( 1.0, 0.0 ) ) / _r ) );
			float h01 = hash( vec2( floor( _v * _r + vec2( 0.0, 1.0 ) ) / _r ) );
			float h11 = hash( vec2( floor( _v * _r + vec2( 1.0, 1.0 ) ) / _r ) );
			vec2 ip = vec2( smoothstep( vec2( 0.0, 0.0 ), vec2( 1.0, 1.0 ), mod( _v*_r, 1. ) ) );
			return ( h00 * ( 1. - ip.x ) + h10 * ip.x ) * ( 1. - ip.y ) + ( h01 * ( 1. - ip.x ) + h11 * ip.x ) * ip.y;
		}

		float noise(vec2 _v)
		{
			float sum = 0.;
			for(int i=1; i<9; i++)
			{
				sum += iHash(_v + vec2(i), vec2(2.0 * pow(2.0, float(i)))) / pow(2.0, float(i));
			}
			return sum;
		}

		void main()
		{
			vec2 uv = openfl_TextureCoordv;
			vec2 uvn = uv;
			vec3 col = vec3( 0.0 );

			// tape wave
			uvn.x += ( noise( vec2( uvn.y, time ) ) - 0.5 )* 0.005;
			uvn.x += ( noise( vec2( uvn.y * 100.0, time * 10.0 ) ) - 0.5 ) * 0.01;

			// tape crease
			float tcPhase = clamp( ( sin( uvn.y * 8.0 - time * PI * 1.2 ) - 0.92 ) * noise( vec2( time ) ), 0.0, 0.01 ) * 10.0;
			float tcNoise = max( noise( vec2( uvn.y * 100.0, time * 10.0 ) ) - 0.5, 0.0 );
			uvn.x = uvn.x - tcNoise * tcPhase;

			// switching noise
			float snPhase = smoothstep( 0.03, 0.0, uvn.y );
			uvn.y += snPhase * 0.3;
			uvn.x += snPhase * ( ( noise( vec2( uv.y * 100.0, time * 10.0 ) ) - 0.5 ) * 0.2 );
				
			col = tex2D( bitmap, uvn );
			col *= 1.0 - tcPhase;
			col = mix(
				col,
				col.yzx,
				snPhase
			);

			// bloom
			for( float x = -4.0; x < 2.5; x += 1.0 )
			{
				col.xyz += vec3(
				tex2D( bitmap, uvn + vec2( x - 0.0, 0.0 ) * 7E-3 ).x,
				tex2D( bitmap, uvn + vec2( x - 2.0, 0.0 ) * 7E-3 ).y,
				tex2D( bitmap, uvn + vec2( x - 4.0, 0.0 ) * 7E-3 ).z
				) * 0.1;
			}
			col *= 0.6;

			// ac beat
			col *= 1.0 + clamp( noise( vec2( 0.0, uv.y + time * 0.2 ) ) * 0.6 - 0.25, 0.0, 0.1 );

			gl_FragColor = vec4( col, uvn );
		}
	')
	public function new()
	{
		super();

		this.time.value = [0.0];
	}

	public function update():Void
	{
		this.time.value = [this.time.value[0] + FlxG.elapsed];
	}
}