package mongoose.display
{
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Program3D;
	import flash.geom.Vector3D;

	public class DisplayObject extends Object3D
	{
		
		internal var program:Program3D;
		public var pivot:Vector3D=new Vector3D(0,0,0);
		
		public var parent:DisplayObjectContainer;
		public var rotationX:Number=0,
			       rotationY:Number=0,
				   rotationZ:Number=0;
		public var scrollX:Number=0,scrollY:Number=0;
		public var visible:Boolean=true;
		public var red:Number=1.0,
			       green:Number=1.0,
				   blue:Number=1.0,
				   alpha:Number=1.0;
		
	
		public var width:Number=0,
			       height:Number=0;
		public var scaleX:Number=1,
			       scaleY:Number=1,
				   scaleZ:Number=1;
		public var color:uint=0xffffff;
		public var texture:TextureData;
		public static var INSTANCE_NUM:uint;
		internal var id:Number;
		public var depth:Number;
		public function DisplayObject()
		{
			super();
			INSTANCE_NUM++;
			id=.001/INSTANCE_NUM;
		}
		public function set blendMode(mode:String):void
		{
			
		}
		public function setColor(r:Number=1.0,g:Number=1.0,b:Number=1.0):void
		{
			this.red=r;
			this.green=g;
			this.blue=b;
		}
		
		
		public function render():void
		{
			
		}
	}
}