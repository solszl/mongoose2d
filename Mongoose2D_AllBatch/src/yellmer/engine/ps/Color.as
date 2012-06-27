package yellmer.engine.ps
{
	import flash.geom.ColorTransform;
	

	public class Color
	{
		public var r:Number = 0;
		public var g:Number = 0;
		public var b:Number = 0;
		public var a:Number = 0;
		
		public function Color(a:Number = 0, r:Number = 0, g:Number = 0, b:Number = 0):void
		{
			this.a = a;
			this.r = r;
			this.g = g;
			this.b = b;
		}
		
		public function clone():Color
		{
			var col:Color = new Color(a, r,g,b);
			return col;
		}
		
		public function SetHWColor(col:uint):void
		{
			a = (col>>24 & 0xFF)/255.0; 
			r = ((col>>16) & 0xFF)/255.0;
			g = ((col>>8) & 0xFF)/255.0; 
			b = (col & 0xFF)/255.0;	
		}
		
		public function GetHWColor():uint
		{
			return (uint(a*255.0)<<24) + 
					(uint(r*255.0)<<16) + 
					(uint(g*255.0)<<8) + 
					uint(b*255.0);	
		}
		
		
		public function minu(v:Color):Color
		{
			return new Color(a-v.a,r-v.r,g-v.g,b-v.b);
		}
		
		public function minuEqual(v:Color):Color
		{
			a -= v.a;
			r -= v.r;
			g -= v.g;
			b -= v.b;
			return this;
		}
		
		
		public function plus(v:Color):Color
		{
			return new Color(a+v.a,r+v.r,g+v.g,b+v.b);
		}
		
		public function plusEqual(v:Color):Color
		{
			a += v.a;
			r += v.r;
			g += v.g;
			b += v.b;
			return this;
		}
		
		
		public function mult(v:Number):Color
		{
			return new Color(a*v,r*v,g*v,b*v);
		}
		
		public function multEqual(scalar:Number):Color
		{
			a *= scalar;
			r *= scalar;
			g *= scalar;
			b *= scalar;
			return this;
		}
		
		
		
		
		public static function SetA(col:uint, a:uint):uint
		{
			return (((col) & 0x00FFFFFF) + (uint(a)<<24));
		}
		
		public static function SetR(col:uint, r:uint):uint
		{
			return (((col) & 0xFF00FFFF) + (uint(r)<<16));
		}
		
		public static function SetG(col:uint, g:uint):uint
		{
			return (((col) & 0xFFFF00FF) + (uint(g)<<08));
		}
		
		public static function SetB(col:uint, b:uint):uint
		{
			return (((col) & 0xFFFFFF00) + (uint(b)<<00));
		}
		
		public static function GetA(col:uint):uint{return  ((col)>>24) & 0xFF;}
		public static function GetR(col:uint):uint{return  ((col)>>16) & 0xFF;}
		public static function GetG(col:uint):uint{return  ((col)>>08) & 0xFF;}
		public static function GetB(col:uint):uint{return  ((col)>>00) & 0xFF;}
		
		public static function ARGB(a:uint, r:uint, g:uint, b:uint):uint
		{
			return ((uint(a)<<24) + (uint(r)<<16) + (uint(g)<<8) + uint(b));
		}
			
		


	}
}