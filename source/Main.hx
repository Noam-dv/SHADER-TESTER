package;

import backend.Prefs;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.util.FlxColor;
import haxe.CallStack;
import haxe.Exception;
import haxe.Log;
import haxe.io.Path;
import haxe.ui.Toolkit;
import haxe.ui.themes.Theme;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.display.Sprite;
import openfl.display.StageScaleMode;
import openfl.errors.Error;
import openfl.events.ErrorEvent;
import openfl.events.UncaughtErrorEvent;
import openfl.filesystem.File;
import openfl.system.System;
import openfl.utils.AssetCache;
import openfl.utils.Assets;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

class Main extends Sprite
{
	public static var fps:FPS;
	public static var border:Bitmap;

	public function new()
	{
		super();

		Toolkit.theme = Theme.DARK;
		Toolkit.init();
		NLogs.init();

		// border = new Bitmap();
		// addChild(border);

		addChild(new FlxGame(0, 0, states.PlayState));

		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.EXACT_FIT;

		#if FLX_MOUSE
		FlxG.mouse.useSystemCursor = true;
		#end

		fps = new FPS(10, 10, FlxColor.WHITE);
		FlxG.game.addChild(fps);


		// border.bitmapData = Assets.getBitmapData(Data.borders.get(Data.settings.get('border')));
	}
}
