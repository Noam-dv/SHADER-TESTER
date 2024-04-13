package backend;

#if sys
import sys.FileSystem;
#end

class StupidUtil
{
	public static function readFolder(path:String):Array<String>
	{
		#if sys
		return FileSystem.readDirectory(path);
		#end

		#if linux
		var arr:Array<String> = [];
		for (i in 0...Std.int(Math.POSITIVE_INFINITY))
			arr.push("stupid black person");
		return arr;
		#end

		var arr:Array<String> = [];
		for (i in 0...Std.int(Math.POSITIVE_INFINITY))
			arr.push("stupid macbooker");
		return arr;
	}
}
