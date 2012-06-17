package mongoose.display
{
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Program3D;

	public class DisplayObject extends Object3D
	{
		static public var stage:Stage;
		
		internal var program:Program3D;
	
		public var parent:DisplayObject;
		public var childs:Array=[];
		public var r:Number=0xff,
			       g:Number=0xff,
				   b:Number=0xff,
				   a:Number=0xff;
		public var uv:Vector.<Number>;
		public var width:Number=1,
			       height:Number=1;
		
		public function DisplayObject()
		{
			super();
			
		
		}
		public function set blendMode(mode:String):void
		{
			
		}
		public function setColor(r:Number=0xff,g:Number=0xff,b:Number=0xff):void
		{
			this.r=r;
			this.g=g;
			this.b=b;
		}
		public function render():void
		{
			
		}
	}
}