package mongoose.display
{
    import flash.display.*;
    import flash.display3D.*;
    import flash.display3D.textures.*;
    import flash.geom.Point;
    import flash.utils.*;
    
    import mongoose.geom.MPoint;
    import mongoose.geom.MRectangle;
    import mongoose.utils.TextureHelper;

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
		
		/**
		 * @param useDefault 是否开启缺省材质
		 */        
        public function TextureData(bd:BitmapData=null)
        {
			defaultBmp=new BitmapData(16, 16, true, 4294967295);
			uvVector = Vector.<Number>([0.0, 0.0, 1.0, 1.0]);
			if (cache == null)
			{
				cache = new Dictionary();
			}
			
			
			if (bd == null)
				bitmapData = defaultBmp;
			else
				bitmapData = bd;
			
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
                if(bmp != null)
                {
                    texture = TextureHelper.generateTextureFromBitmap(context3d,bmp,false);
                    setUVData(new MRectangle(0,0,bmp.width,bmp.height));
				    cache[bmp]=texture;
                }
                else
                {
                    texture = null;
                }
            }
            
            return;
        }
		
		public function get bitmapData():BitmapData
		{
			return mBitmapData;
		}

        public function setUVData(rect:MRectangle, offsetPt:MPoint=null):void
        {
            width = rect.width;
            height = rect.height;
			
            var _quadRect:Point=TextureHelper.getTextureDimensionsFromSize(mBitmapData.width, mBitmapData.height);
            
			if(offsetPt)
			{
				offsetX = offsetPt.x;
				offsetY = offsetPt.y;
			}
            
            var tx:Number = rect.x / _quadRect.x;
            var ty:Number = rect.y / _quadRect.y;
            var bx:Number = (rect.x + width) / _quadRect.x;
            var by:Number = (rect.y + height) / _quadRect.y;
           
			uvVector[0]=tx;
			uvVector[1]=ty;
			uvVector[2]=bx;
			uvVector[3]=by;
			
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
