package mongoose.display
{
	import flash.events.EventDispatcher;

	// mongoose引擎所有显示对象的基类
	public class Object3D extends EventDispatcher
	{
		public var name:String;      // 名字
		
		public var data:Object={};   // 数据，可以是任何类型
		
		public var x:Number=0,y:Number=0,z:Number=0; // 坐标？
		
		// 旋转
		public var rotationX:Number=0,
			       rotationY:Number=0,
			       rotationZ:Number=0;
		public function Object3D()
		{
		}
	}
}