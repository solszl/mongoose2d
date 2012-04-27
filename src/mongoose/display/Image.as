package mongoose.display
{
	import com.adobe.utils.*;
	
	import flash.display3D.*;
	import flash.display3D.textures.Texture;
	
	public class Image extends DisplayObject
	{
		protected var mOffsetX:Number = 0;
		protected var mOffsetY:Number = 0;
		protected var mTexture:TextureData;
		protected static var program3d:Program3D;
		public static var vertexBuffer:VertexBuffer3D;
		public static var indexBuffer:IndexBuffer3D;
		
		static protected const TOTAL_REG:uint=128;
		//系统占用8个,包括透视和相机
		static protected const SYSTEM_USED_REG:uint=8;
		//预留寄存器数量
		static protected const REG_SAVE:uint=6;
		//每个角色使用的寄存器数量.4个矩阵，一个颜色，一个UV
		static protected const REG_PER_ROLS:uint=6;
		static protected var REG_INDEX:uint;
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
		static public var INSTANCE_NUM:uint;
		static private var LAST_DRAW:uint;
		public function Image(texture:TextureData = null)
		{
			
			REG_INDEX=SYSTEM_USED_REG+REG_SAVE;
			
			
			this.mTexture = texture;
			if (this.mTexture != null)
			{
				this.setTexture(this.mTexture);
			}
			initBuffer();
			initProgram();
		}
		protected function initBuffer():void
		{
			if (vertexBuffer == null)
			{
				var vertexBufferData:Vector.<Number>;
				BATCH_NUM=int((TOTAL_REG-REG_INDEX)/REG_PER_ROLS);
				var step:uint,mid:uint,uid:uint,cid:uint;
				vertexBufferData=new Vector.<Number>;
				while(step<BATCH_NUM)
				{
					mid=step*4+REG_INDEX;
					uid=BATCH_NUM*4+REG_INDEX+step;
					cid=BATCH_NUM*4+REG_INDEX+BATCH_NUM+step;
					//trace(mid,uid,cid);
					vertexBufferData.push(
						0, 0, 1, 0, 0, mid, uid, cid,
						1, 0, 1, 1, 0, mid, uid, cid,
						1,-1, 1, 1, 1, mid, uid, cid,
						0,-1, 1, 0, 1, mid, uid, cid
					);
					step++;
				}
				//trace("顶点的数量:",vertexBufferData.length/4)
				
				vertexBuffer = context3d.createVertexBuffer(BATCH_NUM*4,8);
				vertexBuffer.uploadFromVector(vertexBufferData, 0, BATCH_NUM*4);
			}
			if (indexBuffer == null)
			{
				var indexBufferData:Vector.<uint>;
				indexBufferData=new Vector.<uint>;
				//indexBufferData.push(0,1,2,0,2,3);
				
				for(var i:uint=0;i<BATCH_NUM;i++)
				{
					indexBufferData.push(0+i*4,1+i*4,2+i*4,0+i*4,2+i*4,3+i*4);
				}
				
				indexBuffer = context3d.createIndexBuffer(BATCH_NUM*6);
				indexBuffer.uploadFromVector(indexBufferData, 0, BATCH_NUM*6);
			}
		}
		public function setTexture(texture:TextureData) : void
		{
			mTexture = texture;
			width = mTexture.width;
			height = mTexture.height;
			mOriginWidth = mSx=width;
			mOriginHeight = mSy=height;
			mOffsetX = texture.offsetX;
			mOffsetY = texture.offsetY;
			mOffsetX = mOffsetX / world.width * 2;
			mOffsetY = -mOffsetY / world.height * world.scale * 2;
			
			init();
			//context3d.setVertexBufferAt(1, this.mTexture.uvBuffer, 0, "float2");
		}
		
		protected function initProgram() : void
		{
			if (program3d == null)
			{
                var vg:AGALMiniAssembler;
                var fg:AGALMiniAssembler;
                var vs:String;
                var fs:String;
                
				vg = new AGALMiniAssembler();
				fg = new AGALMiniAssembler();
				vs ="m44 vt0, va0,vc[va2.x]\n"+
					"m44 vt0, vt0,vc0\n"+
					"m44 vt0, vt0,vc4\n"+
					"mov op,vt0\n"+
					
					//根据UV索引获得UV坐标,va1->vertex,vt0->UV
					"mov vt0,vc[va3.x]\n"+
					
					"mul vt1.x,va1.x,vt0.z\n"+
					"mul vt2.x,va1.x,vt0.x\n"+
					"sub vt3.x,vt1.x,vt2.x\n"+
					"add vt3.x,vt3.x,vt0.x\n"+
					
					"mul vt1.y,va1.y,vt0.w\n"+
					"mul vt2.y,va1.y,vt0.y\n"+
					"sub vt3.y,vt1.y,vt2.y\n"+
					"add vt3.y,vt3.y,vt0.y\n"+
					"mov v1,vc[va4.x]\n"+
					"mov v0,vt3.xy";
				
				fs ="tex ft0, v0, fs0 <2d,clamp,linear> \n" + 
					"mul ft0,ft0,v1\n" + 
					//"mul ft0.w,v1.z,ft0.w\n"+
					"mov oc ft0\n";
				vg.assemble(Context3DProgramType.VERTEX, vs);
				fg.assemble(Context3DProgramType.FRAGMENT, fs);
				program3d = context3d.createProgram();
				program3d.upload(vg.agalcode, fg.agalcode);
				context3d.setProgram(program3d);
			}
		}
		
		override protected function draw() : void
		{
			//trace("start",this);
			if(mTexture == null || mTexture.texture == null)
				return;
			
			if(CURRENT_TEXTURE!=mTexture.texture)
			{
				if(CURRENT_TEXTURE!=null)
				{
					//trace("draw cache..");
					//trace(CURRENT_REND,LAST_DRAW,CURRENT_TEMP);
					context3d.drawTriangles(indexBuffer,0,CURRENT_TEMP*2);
					LAST_DRAW=CURRENT_REND;
					CURRENT_TEMP=0;
				}
				context3d.setTextureAt(0, mTexture.texture);
				CURRENT_TEXTURE=mTexture.texture;
			}
			if(CURRENT_VERTEXT_BUFFER!=vertexBuffer)
			{
				context3d.setVertexBufferAt(0, vertexBuffer, 0, "float3");
				context3d.setVertexBufferAt(1, vertexBuffer, 3, "float2");
				context3d.setVertexBufferAt(2, vertexBuffer, 5, "float1");
				context3d.setVertexBufferAt(3, vertexBuffer, 6, "float1");
				context3d.setVertexBufferAt(4, vertexBuffer, 7, "float1");
				CURRENT_VERTEXT_BUFFER=vertexBuffer;
			}
			var mid:uint=REG_INDEX+CURRENT_TEMP*4;
			var uid:uint=BATCH_NUM*4+REG_INDEX+CURRENT_TEMP;
			var cid:uint=BATCH_NUM*4+BATCH_NUM+REG_INDEX+CURRENT_TEMP;
			//trace("数据:",mid,uid,cid);
			context3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX,mid, mOutMatrix, true);
			context3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX,uid,mTexture.uvVector,1);
			context3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX,cid,mColorData,1);
			
			//trace(mid,CURRENT_REND);
			//trace("控制",CURRENT_TEMP,BATCH_NUM)
			if(CURRENT_TEMP==BATCH_NUM-1)
			{
				//trace("绘制一次");
				context3d.drawTriangles(indexBuffer);
				
				LAST_DRAW=CURRENT_REND+1;
				//trace("记忆最后一次完整DrawCall",LAST_DRAW);
				CURRENT_TEMP=0;
			}
			else
			{
				CURRENT_TEMP++;
			}
			if(CURRENT_REND==INSTANCE_NUM-1)
			{
				//trace("绘制二次");
				var p2:uint=(INSTANCE_NUM-LAST_DRAW)*2;
				//trace("剩余DrawCall",INSTANCE_NUM,LAST_DRAW,p2)
				context3d.drawTriangles(indexBuffer,0,p2);
				CURRENT_REND=0;
				CURRENT_TEMP=0;
				//INSTANCE_NUM=0;
			}
			else
			{
				CURRENT_REND++;
			}
			//context3d.drawTriangles(indexBuffer);
		}
		
		override protected function composeMatrix() : void
		{
			super.composeMatrix();
			mOutMatrix.appendTranslation(mOffsetX, mOffsetY, 0);
		}
		
	}
}
