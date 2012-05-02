package mongoose
{
	import mongoose.display.BaseObject;
	import mongoose.display.DisplayObject;
	
	public class PointLight extends DisplayObject
	{
		public var vector:Vector.<Number>;
		public var distance:Number;
		public var strenth:Number;
		
		public function PointLight()
		{
			super();
			vector=new Vector.<Number>(8);
			
		}
		override protected function draw():void
		{
			
		} 
	}
}