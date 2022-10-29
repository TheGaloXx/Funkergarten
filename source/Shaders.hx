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