package yellmer.engine.ps
{
	public class MathUtils
	{
		public static function random(min:Number = 0, max:Number = 1):Number
		{
			return min + Math.random()*(max - min);
		}
		

		public static function invSqrt(x:Number):Number
		{
			return 1.0/Math.sqrt(x);
		}
		
		public static var PI1_2:Number = Math.PI / 2;
		
	}
}