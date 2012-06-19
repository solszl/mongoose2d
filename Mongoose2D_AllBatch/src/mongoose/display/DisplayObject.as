package mongoose.display
{
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Program3D;
	import flash.geom.Vector3D;

	public class DisplayObject extends Object3D
	{
		static public var stage:Stage;
		
		
	
		
		
		internal var program:Program3D;
		public var pivot:Vector3D=new Vector3D(0,0,0);
		public var texture:TextureData;
		public var parent:DisplayObject;
		public var rotationX:Number=0,
			       rotationY:Number=0,
				   rotationZ:Number=0;
		public var red:Number=1.0,
			       green:Number=1.0,
				   blue:Number=1.0,
				   alpha:Number=1.0;
		internal var color:Vector.<Number>;
		public var uv:Vector.<Number>;
		public var width:Number=0,
			       height:Number=0;
		
		public function DisplayObject()
		{
			super();
			color=new Vector.<Number>;
		
		}
		public function set blendMode(mode:String):void
		{
			
		}
		public function setColor(r:Number=0xff,g:Number=0xff,b:Number=0xff):void
		{
			this.red=r;
			this.green=g;
			this.blue=b;
		}
		public function render():void
		{
			color[0]=red;
			color[1]=green;
			color[2]=blue;
			color[3]=alpha;
			if(this.texture!=null)
			{
				
				width=this.texture.width;
				height=this.texture.height;
		        uv=this.texture.uvVector;
			}
		}
	}
}