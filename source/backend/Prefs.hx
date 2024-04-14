package backend;

import flixel.FlxG;

class Prefs
{
	public static var UI_THEME:String;
	public static var pathsToShaders:Array<String> = [];

	public static function loadPrefs()
	{
		if (FlxG.save.data.pathsToShaders != null)
			pathsToShaders = FlxG.save.data.pathsToShaders;
		else
			FlxG.save.data.pathsToShaders = pathsToShaders;
	}
}