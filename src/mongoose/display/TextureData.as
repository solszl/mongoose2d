package mongoose.display
{
    import flash.display.*;
    import flash.display3D.*;
    import flash.display3D.textures.*;
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
		public var uvVector:Vector.<Number>;
       
        protected var mBitmapData:BitmapData;
        public static var context3d:Context3D;
        private static var cache:Dictionary;
        private static var defaultBmp:BitmapData;
		
		/**
		 * @param useDefault 是否开启缺省材质
		 */        
        public function TextureData(useDefault:Boolean=false)
        {
			uvVector = Vector.<Number>([0.0, 0.0, 1.0, 1.0]);
			if (cache == null)
			{
				cache = new Dictionary();
			}
			
			if(useDefault)
			{
				if (defaultBmp == null)
					defaultBmp = new BitmapData(32, 32, true, 4294967295);
				
				mBitmapData = defaultBmp;
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
                texture = TextureHelper.generateTextureFromBitmap(context3d,bmp,false);
				cache[bmp]=texture;
            }
            
            return;
        }
		
		public function get bitmapData():BitmapData
		{
			return mBitmapData;
		}

        public function setUVData(TextureData:MRectangle, offsetPt:MPoint=null):void
        {
            width = TextureData.width;
            height = TextureData.height;
			
			width%2==0?width:width++;
			height%2==0?height:height++;
			
			if(offsetPt)
			{
				offsetX = offsetPt.x;
				offsetY = offsetPt.y;
			}
            
            var tx:Number = TextureData.x / mBitmapData.width;
            var ty:Number = TextureData.y / mBitmapData.height;
            var bx:Number = (TextureData.x + width) / mBitmapData.width;
            var by:Number = (TextureData.y + height) / mBitmapData.height;
           
			uvVector[0]=tx;
			uvVector[1]=ty;
			uvVector[2]=bx;
			uvVector[3]=by;
        }

        public function dispose(bmp:BitmapData):void
        {
            cache[bmp].dispose();
            texture = null;
            cache[bmp] = null;   
        }
    }
}
