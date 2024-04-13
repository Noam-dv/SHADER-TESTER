package backend;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.Exception;
import haxe.io.Path;
import openfl.utils.Assets;

class AssetPaths
{
	public static inline function script(key:String):String
		return 'assets/data/$key.hx';

	public static inline function shader(key:String):String
		return 'shaders/$key';

	public static inline function data(key:String):String
		return 'assets/data/$key.json';

	public static inline function music(key:String):String
		return 'assets/music/$key.ogg';

	public static inline function sound(key:String):String
		return 'assets/sounds/$key.ogg';

	public static inline function sprite(key:String):String
		return 'assets/images/$key.png';

	public static function font(key:String):String
	{
		final path:String = 'assets/fonts/$key.ttf';

		try
		{
			if (Assets.exists(path, FONT))
				return Assets.getFont(path).fontName;
			else if (Assets.exists(Path.withoutExtension(path), FONT))
				return Assets.getFont(Path.withoutExtension(path)).fontName;
		}
		catch (e:Exception)
			FlxG.log.error(e.message);

		return null;
	}

	public static function spritesheet(key:String):FlxAtlasFrames
	{
		final path:String = Path.withoutExtension(AssetPaths.sprite(key));

		try
		{
			if (Assets.exists(Path.withExtension(path, 'xml'), TEXT))
				return FlxAtlasFrames.fromSparrow(AssetPaths.sprite(key), Path.withExtension(path, 'xml'));
			else if (Assets.exists(Path.withExtension(path, 'json'), TEXT))
				return FlxAtlasFrames.fromTexturePackerJson(AssetPaths.sprite(key), Path.withExtension(path, 'json'));
		}
		catch (e:Exception)
			FlxG.log.error(e.message);

		return null;
	}
}
