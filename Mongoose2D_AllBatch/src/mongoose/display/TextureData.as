package mongoose.display
{
    import flash.display.*;
    import flash.display3D.*;
    import flash.display3D.textures.*;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.*;
    
    import mongoose.geom.getUpPower2;
    
 
    public class TextureData extends Object
    {
        public var texture:Texture;
        
        public var width:Number = 0.0;
        public var height:Number = 0.0;
        public var offsetX:Number = 0.0;
        public var offsetY:Number = 0.0;
		//UV值空间
		public var uValue:Number = 0.0;
		public var vValue:Number = 0.0;
		
		public var uvVector:Vector.<Number>;
       
        protected var mBitmapData:BitmapData;
        public static var context3d:Context3D;
        private static var cache:Dictionary;
        private static var defaultBmp:BitmapData;
		private static var id:uint;
		public var sid:uint;
		/**
		 * @param useDefault 是否开启缺省材质
		 */        
        public function TextureData(bd:BitmapData=null,useDefault:Boolean=false)
        {
			sid=id++;
			uvVector = Vector.<Number>([0, 0, 1,0, 1,1,0,1]);
			if (cache == null)
			{
				cache = new Dictionary();
			}
			
			
			if(bd!=null)
            {
				bitmapData = bd;
               //setUVData(new Rectangle(0,0,bd.width,bd.height));
            }
			else if(useDefault)
			{
				if(defaultBmp==null)
				defaultBmp = new BitmapData(16, 16, true, 4294967295);
				bitmapData = defaultBmp;
			}
        }

        public function set bitmapData(bmp:BitmapData):void
        {
            mBitmapData = bmp;
            if (cache[bmp] != null)
            {
                texture = cache[bmp];
            }
            else
            {
			    var tw:Number=getUpPower2(mBitmapData.width);
				var th:Number=getUpPower2(mBitmapData.height);
	                texture =context3d.createTexture(tw,th,"bgra",false);
					texture.uploadFromBitmapData(bmp);
	                
				    cache[bmp]=texture;
                
            }
			setUVData(new Rectangle(0,0,bmp.width,bmp.height));
            return;
        }
		
		public function get bitmapData():BitmapData
		{
			return mBitmapData;
		}

        public function setUVData(rect:Rectangle, offsetPt:Point=null):void
        {
            width = rect.width;
            height = rect.height;
			
          
            var tw:Number=getUpPower2(mBitmapData.width);
			var th:Number=getUpPower2(mBitmapData.height);
			if(offsetPt)
			{
				offsetX = offsetPt.x;
				offsetY = offsetPt.y;
			}
            
            var tx:Number = rect.x / tw;
            var ty:Number = rect.y / th;
            var bx:Number = (rect.x + width) / tw;
            var by:Number = (rect.y + height) /th;
           
			uvVector[0]=tx;
			uvVector[1]=ty;
			uvVector[2]=bx;
			uvVector[3]=ty;
			uvVector[4]=bx;
			uvVector[5]=by;
			uvVector[6]=tx;
			uvVector[7]=by;
			
			uValue=bx-tx;
			vValue=by-ty;
        }

        public function dispose(bmp:BitmapData):void
        {
            cache[bmp].dispose();
            texture = null;
            cache[bmp] = null;   
        }
    }
}
