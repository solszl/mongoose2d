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
		
		public var parent:DisplayObject;
		public var rotationX:Number=0,
			       rotationY:Number=0,
				   rotationZ:Number=0;
		public var scrollX:Number=0,scrollY:Number=0;
		public var red:Number=1.0,
			       green:Number=1.0,
				   blue:Number=1.0,
				   alpha:Number=1.0;
		
		public var uv:Vector.<Number>;
		public var width:Number=0,
			       height:Number=0;
		public var scaleX:Number=1,
			       scaleY:Number=1,
				   scaleZ:Number=1;
		
		private var _texture:TextureData;
		public function DisplayObject()
		{
			super();
			
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
		
		public function set texture(txt:TextureData):void
		{
			_texture=txt;
			
			if(_texture!=null)
			{
				
				width=_texture.width;
				height=_texture.height;
				uv=_texture.uvVector;
			}
		}
		public function get texture():TextureData
		{
			return _texture;
		}
		public function render():void
		{
			
		}
	}
}