package yellmer.engine.ps
{
	import flash.geom.Vector3D;

	public class Vector2D
	{
		public var x:Number = 0;
		public var y:Number = 0;
		
		public function Vector2D(x:Number = 0, y:Number = 0)
		{
			this.x = x;
			this.y = y;
		}
		
		
		public function clone():Vector2D
		{
			return new Vector2D(x,y);
		}
		
		public function minu(v:Vector2D):Vector2D
		{
			return new Vector2D(x-v.x, y-v.y);
		}
		
		public function minuEqual(v:Vector2D):Vector2D
		{
			x -= v.x;
			y -= v.y;
			return this;
		}
		
		
		public function plus(v:Vector2D):Vector2D
		{
			return new Vector2D(x+v.x, y+v.y);
		}
		
		public function plusEqual(v:Vector2D):Vector2D
		{
			x += v.x;
			y += v.y;
			return this;
		}
		
		
		public function mult(v:Number):Vector2D
		{
			return new Vector2D(x*v, y*v);
		}
		
		public function multEqual(scalar:Number):Vector2D
		{
			x *= scalar;
			y *= scalar;
			return this;
		}
		
		
		
		public function angel(v:Vector2D = null):Number
		{
			if(v)
			{
				var s:Vector2D = this.clone();
				var t:Vector2D = v.clone();
				
				s.normalize();
				t.normalize();
				return Math.acos(s.dot(t));
			}
			else
			{
				return Math.atan2(x, y);
			}
		}
		
		public function length():Number
		{
			return Math.sqrt(dot(this));
		}
		
		public function dot(v:Vector2D):Number
		{
			return x*v.x + y*v.y;
		}
		
		public function normalize():Vector2D
		{
			var rc:Number = 1.0/Math.sqrt(dot(this));
			x *= rc;
			y *= rc;
			return this;
		}
		
	}
}