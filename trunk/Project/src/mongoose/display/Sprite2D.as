package mongoose.display
{
    import com.adobe.utils.*;
    
    import flash.display3D.*;

    public class Sprite2D extends DisplayObjectContainer
    {
        protected var mOffsetX:Number = 0;
        protected var mOffsetY:Number = 0;
        protected var mTexture:TextureData;
        private static var program3d:Program3D;
        public static var vertexBuffer:VertexBuffer3D;
        public static var indexBuffer:IndexBuffer3D;

        public function Sprite2D(texture:TextureData = null)
        {
            var vertexBufferData:Vector.<Number>;
            var indexBufferData:Vector.<uint>;
            this.mTexture = texture;
            if (this.mTexture != null)
            {
                this.setTexture(this.mTexture);
            }
            if (vertexBuffer == null)
            {
                vertexBufferData=new Vector.<Number>;
				vertexBufferData.push(
					                    0,0,1,
										1,0,1,
										1,-1,1,
										0,-1,1
				                     );
				
                vertexBuffer = context3d.createVertexBuffer(4, 3);
                vertexBuffer.uploadFromVector(vertexBufferData, 0, 4);
            }
            if (indexBuffer == null)
            {
                indexBufferData=new Vector.<uint>;
				indexBufferData.push(0,1,2,0,2,3);
                indexBuffer = context3d.createIndexBuffer(6);
                indexBuffer.uploadFromVector(indexBufferData, 0, 6);
            }
            initProgram();
        }// end function

        public function setTexture(texture:TextureData) : void
        {
            mTexture = texture;
            width = mTexture.width;
            height = mTexture.height;
            mOriginWidth = width;
            mOriginHeight = height;
            mOffsetX = texture.offsetX;
            mOffsetY = texture.offsetY;
            mOffsetX = mOffsetX / world.width * 2;
            mOffsetY = -mOffsetY / world.height * world.scale * 2;
            context3d.setVertexBufferAt(1, this.mTexture.uvBuffer, 0, "float2");
        }// end function

        protected function initProgram() : void
        {
            var vg:AGALMiniAssembler;
            var fg:AGALMiniAssembler;
            var vs:String;
            var fs:String;
            if (program3d == null)
            {
                vg = new AGALMiniAssembler();
                fg = new AGALMiniAssembler();
                vs =     "m44 vt0,va0,vc8\n" + 
					     "m44 vt0,vt0,vc0\n" + 
						 "m44 vt0,vt0,vc4\n" + 
						 "mov op vt0\n" + 
						 "mov v0,va1";
				
                fs = "tex ft0, v0, fs0 <2d,clamp,linear> \n" + 
					     "mul ft0,ft0,fc0\n" + 
						 "mov oc ft0\n";
                vg.assemble(Context3DProgramType.VERTEX, vs);
                fg.assemble(Context3DProgramType.FRAGMENT, fs);
                program3d = context3d.createProgram();
                program3d.upload(vg.agalcode, fg.agalcode);
                context3d.setProgram(program3d);
            }
        }// end function

        override protected function draw() : void
        {
            super.draw();
            context3d.setTextureAt(0, mTexture.texture);
            context3d.setVertexBufferAt(0, vertexBuffer, 0, "float3");
            context3d.drawTriangles(indexBuffer);
        }// end function

        override protected function composeMatrix() : void
        {
            super.composeMatrix();
            mOutMatrix.appendTranslation(mOffsetX, mOffsetY, 0);
        }// end function

    }
}
