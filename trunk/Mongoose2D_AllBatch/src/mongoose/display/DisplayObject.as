package mongoose.display
{
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Program3D;
	import flash.geom.Vector3D;

	// 可显示对象
	public class DisplayObject extends Object3D
	{
		
		internal var program:Program3D; // Shader对象
		
		public var pivot:Vector3D=new Vector3D(0,0,0); // 锚点？
		
		public var parent:DisplayObjectContainer; // 父结点
		
		
		
		public var scrollX:Number=0,scrollY:Number=0; // 滚轴？
		
		
		public var visible:Boolean=true;  // 是否可见
		
		// 颜色
		public var red:Number=1.0,
			       green:Number=1.0,
				   blue:Number=1.0,
				   alpha:Number=1.0;
		
		// 宽高
		public var width:Number=0,
			       height:Number=0;
		
		// 缩放
		public var scaleX:Number=1,
			       scaleY:Number=1,
				   scaleZ:Number=1;
			
		public var color:uint=0xffffff;      // 第二种颜色数据表示
		
		public var texture:TextureData;      // 纹理
		 
		public static var INSTANCE_NUM:uint; // 此类的实例对象
		
		internal var id:Number;              // ID
		
		public var depth:Number;             // 深度
		
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