package mongoose.display
{
    import flash.display.*;
    import flash.display3D.*;
    import flash.display3D.textures.*;
    import flash.utils.*;
    import mongoose.geom.*;

    public class TextureData extends Object
    {
        public var texture:Texture;
        public var uvBuffer:VertexBuffer3D;
        public var width:Number;
        public var height:Number;
        public var offsetX:Number;
        public var offsetY:Number;
        protected var uvData:Vector.<Number>;
        protected var bitmapData:BitmapData;
        public static var context3d:Context3D;
        private static var cache:Dictionary;
        private static var defaultBmp:BitmapData;
        private static var defaultUV:VertexBuffer3D;

        public function TextureData()
        {
            if (defaultBmp == null)
				defaultBmp = new BitmapData(32, 32, true, 4294967295);
           
            bitmapData = defaultBmp;
            uvData = new Vector.<Number>;
            if (cache == null)
            {
                cache = new Dictionary();
            }
            setBitmap(defaultBmp);
            if (defaultUV == null)
            {
                setUVData(new Rectangle(0, 0, 1, 1), new Point(0, 0));
                defaultUV = uvBuffer;
            }
            return;
        }// end function

        public function setBitmap(offsetY:BitmapData) : void
        {
            bitmapData = offsetY;
            if (cache[offsetY] != null)
            {
                texture = cache[offsetY];
            }
            else
            {
                texture = context3d.createTexture(offsetY.width, offsetY.height, "bgra", false);
                texture.uploadFromBitmapData(offsetY);
            }
            cache[offsetY] = texture;
            return;
        }// end function

        public function setUVData(TextureData:Rectangle, Object:Point) : void
        {
            uvBuffer = context3d.createVertexBuffer(4, 2);
            width = TextureData.width;
            height = TextureData.height;
            offsetX = Object.x;
            offsetY = Object.y;
            var tx:Number = TextureData.x / bitmapData.width;
            var ty:Number = TextureData.y / bitmapData.height;
            var bx:Number = (TextureData.x + width) / bitmapData.width;
            var by:Number = (TextureData.y + height) / bitmapData.height;
            uvData[0] = tx;
            uvData[1] = ty;
            uvData[2] = bx;
            uvData[3] = ty;
            uvData[4] = bx;
            uvData[5] = by;
            uvData[6] = tx;
            uvData[7] = by;
            uvBuffer.uploadFromVector(uvData, 0, 4);
            return;
        }// end function

        public function dispose(offsetY:BitmapData) : void
        {
            cache[offsetY].dispose();
            texture = null;
            cache[offsetY] = null;
            uvBuffer.dispose();
            uvBuffer = null;
            return;
        }// end function

    }
}
