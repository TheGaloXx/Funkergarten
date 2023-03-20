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

class PixelShader extends FlxShader
{
	@:glFragmentSource('

			#pragma header

            uniform float PIXEL_FACTOR;
			uniform vec2 screen;

            void main()
            {
                vec2 size = vec2(PIXEL_FACTOR * screen.xy / screen.x);
                vec2 uv = floor(openfl_TextureCoordv * size) / size;
                vec3 col = flixel_texture2D(bitmap, uv).xyz;
                gl_FragColor = vec4(col, 1.);
            }
        ')
	@:glVertexSource('
            attribute vec4 openfl_Position;
            attribute vec2 openfl_TextureCoord;
            uniform mat4 openfl_Matrix;
            varying vec2 openfl_TextureCoordv;

            void main(void)
            {
                openfl_TextureCoordv = openfl_TextureCoord;

		    	gl_Position = openfl_Matrix * openfl_Position;
            }
        ')
	public function new()
	{
		super();
	}
}

class PixelEffect
{
	public var shader(default, null):PixelShader = new PixelShader();
	public var PIXEL_FACTOR(default, set):Float;
	// in case you want to change the x and y (width / height)
	public var screenWidth(default, set):Float;
	public var screenHeight(default, set):Float;

	private function set_PIXEL_FACTOR(value:Float):Float
	{
		PIXEL_FACTOR = value;
		shader.PIXEL_FACTOR.value = [PIXEL_FACTOR];
		trace("Pixel Factor changed to " + value);
		return value;
	}

	private function set_screenWidth(value:Float):Float
	{
		screenWidth = value;
		shader.screen.value = [screenWidth, screenHeight];
		trace("Screen width changed to " + value);
		return value;
	}

	private function set_screenHeight(value:Float):Float
	{
		screenHeight = value;
		shader.screen.value = [screenWidth, screenHeight];
		trace("Screen height changed to " + value);
		return value;
	}

	public function new()
	{
		shader.PIXEL_FACTOR.value = [4096.];
		shader.screen.value = [FlxG.width, FlxG.height];
	}
}
