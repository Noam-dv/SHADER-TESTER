package backend;

import flixel.FlxBasic;
import hscript.Interp;
import openfl.Lib;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.FlxCamera;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.FlxSprite;
import flixel.FlxG;
import hscript.Interp;
import hscript.Parser;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import haxe.ds.StringMap;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;
#if sys 
import sys.FileSystem;
import sys.io.File;
#end

class Script extends FlxBasic
{
    public var hscript:Interp;

    public override function new()
    {
        super();
        hscript = new Interp();
    }

    public function runScript(script:String)
    {
        var parser = new hscript.Parser();

        try
        {
            var ast = parser.parseString(script);

            hscript.execute(ast);
        }
        catch (e:Dynamic)
        {
            NLogs.print("Error occurred while executing script:" + e, "red");
            logError(e);
        }
    }

    public function setVariable(name:String, val:Dynamic)
    {
        hscript.variables.set(name, val);
    }

    public function getVariable(name:String):Dynamic
    {
        return hscript.variables.get(name);
    }

    public function run(funcName:String, ?args:Array<Any>):Dynamic
    {
        if (hscript == null)
            return null;

        if (hscript.variables.exists(funcName))
        {
            var func = hscript.variables.get(funcName);
            if (args == null)
            {
                var result = null;
                try
                {
                    result = func();
                }
                catch (e:Dynamic)
                {
                    NLogs.print("Error occurred while executing function:" + e, 'red');
                    logError(e);
                }
                return result;
            }
            else
            {
                var result = null;
                try
                {
                    result = Reflect.callMethod(null, func, args);
                }
                catch (e:Dynamic)
                {
                    NLogs.print("Error occurred while executing function:" + e, 'red');
                    logError(e);
                }
                return result;
            }
        }
        return null;
    }

    private function logError(error:Dynamic):Void
    {
        NLogs.print("Error:" + error, 'red');
    }

    public override function destroy()
    {
        super.destroy();
        hscript = null;
    }
}
