package backend.system;

import haxe.macro.Expr;
import flash.utils.Function as F;
import haxe.PosInfos;
using StringTools;

class Logs {
    public static var _trace:F; 

    public static function init() {
        _trace = haxe.Log.trace;
        // haxe.Log.trace = coloredTrace;
    }

    /* public static function coloredTrace(level:String, params:Array<Dynamic>, pos:PosInfos) {
        _trace()
    } */ 

    public static function trace(text:String, color:String = "DEFAULT_COLOR") {
        var colorCode:String = getColorCode(color);
        var resetColor:String = getColorCode("DEFAULT_COLOR");
        _trace(colorCode + text + resetColor);
    }

    public static function getColorCode(color:String):String {
        switch (color.toLowerCase()) {
            case "black": return "\033[30m"; 
            case "red": return "\033[31m";
            case "green": return "\033[32m";
            case "yellow": return "\033[33m"; 
            case "blue": return "\033[34m";
            case "magenta": return "\033[35m"; 
            case "cyan": return "\033[36m";
            case "white": return "\033[37m"; 
            default: return "\033[0m";
        }
    }
}