package backend;

import flixel.FlxSprite;
import haxe.ds.Vector;
import math.Vectors.Vector2;
import math.Vectors.Vector2;

class SpriteTarget
{
	public var position:Vector2 = new Vector2();
	public var scale:Vector2 = new Vector2(1, 1);
	public var sprite:FlxSprite;

	public function new(position:Vector2, ?sprite:FlxSprite)
	{
		this.position = position;
		this.sprite = sprite;
	}
}
