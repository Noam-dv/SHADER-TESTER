package math;

class Vector2
{
	public var x:Float;
	public var y:Float;

	public function new(x:Float = 0, y:Float = 0)
	{
		this.x = x;
		this.y = y;
	}

	public function add(o:Vector2):Vector2
	{
		return new Vector2(this.x + o.x, this.y + o.y);
	}

	public function subtract(o:Vector2):Vector2
	{
		return new Vector2(this.x - o.x, this.y - o.y);
	}

	public function scale(s:Float):Vector2
	{
		return new Vector2(this.x * s, this.y * s);
	}
}

class Vector3
{
	public var x:Float;
	public var y:Float;
	public var z:Float;

	public function new(x:Float = 0, y:Float = 0, z:Float = 0)
	{
		this.x = x;
		this.y = y;
		this.z = z;
	}

	public function add(o:Vector3):Vector3
	{
		return new Vector3(this.x + o.x, this.y + o.y, this.z + o.z);
	}

	public function subtract(o:Vector3):Vector3
	{
		return new Vector3(this.x - o.x, this.y - o.y, this.z - o.z);
	}

	public function scale(s:Float):Vector3
	{
		return new Vector3(this.x * s, this.y * s, this.z * s);
	}
}

class Vector4
{
	public var x:Float;
	public var y:Float;
	public var z:Float;
	public var w:Float;

	public function new(x:Float = 0, y:Float = 0, z:Float = 0, w:Float = 0)
	{
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}

	public function add(o:Vector4):Vector4
	{
		return new Vector4(this.x + o.x, this.y + o.y, this.z + o.z, this.w + o.w);
	}

	public function subtract(o:Vector4):Vector4
	{
		return new Vector4(this.x - o.x, this.y - o.y, this.z - o.z, this.w - o.w);
	}

	public function scale(s:Float):Vector4
	{
		return new Vector4(this.x * s, this.y * s, this.z * s, this.w * s);
	}
}
