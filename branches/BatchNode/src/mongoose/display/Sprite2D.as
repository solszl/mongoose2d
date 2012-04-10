package mongoose.display
{
    import com.adobe.utils.*;
    
    import flash.display3D.*;
    import flash.display3D.textures.Texture;

    public class Sprite2D extends DisplayObjectContainer
    {
        protected var mOffsetX:Number = 0;
        protected var mOffsetY:Number = 0;
        protected var mTexture:TextureData;
        private static var program3d:Program3D;
        public static var vertexBuffer:VertexBuffer3D;
        public static var indexBuffer:IndexBuffer3D;

		//cache...
		static private var CURRENT_TEXTURE:Texture;
		static private var CURRENT_PROGRAM:Program3D;
		static private var CURRENT_VERTEXT_BUFFER:VertexBuffer3D;
		//记录总进度
		static private var CURRENT_REND:uint=0;
		//记录局部进度
		static private var CURRENT_TEMP:uint=0;
		//可用Batch数量
		static private var BATCH_NUM:uint;
		//总渲染任务
		static private var INSTANCE_NUM:uint;
        public function Sprite2D(texture:TextureData = null)
        {
			INSTANCE_NUM++;
            var vertexBufferData:Vector.<Number>;
            var indexBufferData:Vector.<uint>;
            this.mTexture = texture;
            if (this.mTexture != null)
            {
                this.setTexture(this.mTexture);
            }
            if (vertexBuffer == null)
            {
				BATCH_NUM=int((TOTAL_REG-REG_INDEX)/REG_PER_ROLS);
				var step:uint,mid:uint,uid:uint,cid:uint;
                vertexBufferData=new Vector.<Number>;
				while(step<BATCH_NUM)
				{
					mid=step*4+REG_INDEX;
					uid=BATCH_NUM*4+REG_INDEX+step;
					cid=BATCH_NUM*4+REG_INDEX+BATCH_NUM+step;
					
					vertexBufferData.push(
					                       0, 0,1,mid,uid,cid,
										   1, 0,1,mid,uid,cid,
										   1,-1,1,mid,uid,cid,
										   0,-1,1,mid,uid,cid
				                         );
					step++;
				}
				
				
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
                vs =     "m44 vt0,va0,vc0\n" + 
					     "m44 vt0,vt0,vc4\n" + 
						 "m44 vt0,vt0,vc8\n" + 
						 "mov op vt0\n" + 
						 "mov v0,va1\n"+
				         "mov v1,vt0";
				
                fs =     "tex ft0, v0, fs0 <2d,clamp,linear> \n" + 
					     "mul ft0,ft0,fc0\n" + 
						 "mul ft0.w,v1.z,ft0.w\n"+
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
			
			if(CURRENT_TEXTURE!=mTexture.texture)
			{
				context3d.setTextureAt(0, mTexture.texture);
				CURRENT_TEXTURE=mTexture.texture;
			}
            if(CURRENT_VERTEXT_BUFFER!=vertexBuffer)
			{
				context3d.setVertexBufferAt(0, vertexBuffer, 0, "float3");
				CURRENT_VERTEXT_BUFFER=vertexBuffer;
			}
			var mid:uint=REG_INDEX+CURRENT_TEMP*4;
			var uid:uint=BATCH_NUM*4+REG_INDEX+CURRENT_TEMP;
			var cid:uint=BATCH_NUM*4+BATCH_NUM+REG_INDEX+CURRENT_TEMP;
			trace(mid,uid,cid);
			context3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX,mid, mOutMatrix, true);
			context3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX,uid,mUVData);
			context3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX,cid,mColorData);
			context3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, mColorData);
			//trace(mid,CURRENT_REND);
			if(CURRENT_TEMP==BATCH_NUM-1)
			{
				trace("绘制一次");
				
				CURRENT_TEMP=0;
				
			}
			else
			{
				CURRENT_TEMP++;
			}
			if(CURRENT_REND==INSTANCE_NUM-1)
			{
				trace("绘制二次");
				CURRENT_REND=0;
			}
			else
			{
				CURRENT_REND++;
			}
			
            //context3d.drawTriangles(indexBuffer);
        }// end function

        override protected function composeMatrix() : void
        {
            super.composeMatrix();
            mOutMatrix.appendTranslation(mOffsetX, mOffsetY, 0);
        }// end function

    }
}
