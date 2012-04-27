package mongoose.display
{
    import flash.display.*;
    import flash.display3D.*;
    import flash.display3D.textures.*;
    import flash.utils.*;
    
    import mongoose.geom.*;
    import mongoose.utils.TextureHelper;

    public class TextureData extends Object
    {
        public var texture:Texture;
        
        public var width:Number;
        public var height:Number;
        public var offsetX:Number;
        public var offsetY:Number;
		public var uvVector:Vector.<Number>;
       
        protected var bitmapData:BitmapData;
        public static var context3d:Context3D;
        private static var cache:Dictionary;
        private static var defaultBmp:BitmapData;
        
        public function TextureData()
        {
            if (defaultBmp == null)
				defaultBmp = new BitmapData(32, 32, true, 4294967295);
           
            bitmapData = defaultBmp;
           
			uvVector=new Vector.<Number>(4);
            if (cache == null)
            {
                cache = new Dictionary();
            }
            setBitmap(defaultBmp);
            
           
        }

        public function setBitmap(bmp:BitmapData) : void
        {
            bitmapData = bmp;
            if (cache[bmp] != null)
            {
                texture = cache[bmp];
				
            }
            else
            {
				//trace("新建...");
                texture = TextureHelper.generateTextureFromBitmap(context3d,bmp,false);
				cache[bmp]=texture;
            }
            
            return;
        }

        public function setUVData(TextureData:Rectangle, Object:Point) : void
        {
            
            width = TextureData.width;
            height = TextureData.height;
			
			width%2==0?width:width++;
			height%2==0?height:height++;
			
            offsetX = Object.x;
            offsetY = Object.y;
            var tx:Number = TextureData.x / bitmapData.width;
            var ty:Number = TextureData.y / bitmapData.height;
            var bx:Number = (TextureData.x + width) / bitmapData.width;
            var by:Number = (TextureData.y + height) / bitmapData.height;
           
			uvVector[0]=tx;
			uvVector[1]=ty;
			uvVector[2]=bx;
			uvVector[3]=by;
         
        }

        public function dispose(bmp:BitmapData) : void
        {
            cache[bmp].dispose();
            texture = null;
            cache[bmp] = null;   
        }
    }
}
