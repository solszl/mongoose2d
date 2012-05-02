package mongoose.display
{
	import com.adobe.utils.*;
	
	import flash.display3D.*;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	
	public class Image extends DisplayObject
	{
		protected var mOffsetX:Number = 0;
		protected var mOffsetY:Number = 0;
		protected var mTexture:TextureData;
		
		//记录BATCH进度
		static public var BATCH_INDEX:uint=0;
		static public var CURRENT_VERTEX_BUFFER:VertexBuffer3D;
		static public var CURRENT_INDEX_BUFFER:IndexBuffer3D;
		static public var INSTANCE_NUM:uint;
		static protected const TOTAL_REGISTER:uint=128;
		//系统占用8个,包括透视和相机
		static protected const SYSTEM_USED_REG:uint=8;
		//预留寄存器数量
		static protected const REG_SAVE:uint=0;
		//每个角色使用的寄存器数量.4个矩阵，一个颜色，一个UV
		static protected const REG_PER_ROLS:uint=6;
		//当前使用的Program3D
		static protected var VERTEX_SHADER:ByteArray;
		//static protected var CURRENT_PROGRAME:Program3D;
		static protected var REG_INDEX:uint;
		static protected var POSITION:Array=[];
		//cache...
		static protected var CURRENT_TEXTURE:Texture;
		static protected var CURRENT_PROGRAM:Program3D;
		static private var CURRENT_VERTEXT_BUFFER:VertexBuffer3D;
		//可用Batch数量
		static protected var BATCH_NUM:uint;
		
		static protected var v0:Vector3D;
		static protected var v1:Vector3D;
		static protected var v2:Vector3D;
		static protected var v3:Vector3D;
		public function Image(texture:TextureData = null)
		{
			INSTANCE_NUM++;
			REG_INDEX=SYSTEM_USED_REG+REG_SAVE;
			
			
			this.mTexture = texture;
			if (this.mTexture != null)
			{
				this.setTexture(this.mTexture);
			}
			else
			{
				init();
			}
			if(VERTEX_SHADER==null)
			{
			  var vs:String =
				    "m44 vt0, va0,vc[va2.x]\n"+
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
					//输出颜色
					"mov v1,vc[va4.x]\n"+
					//输出UV坐标
					"mov v0,vt3.xy\n"+
					//输出顶点坐标
					"mov v3,vt0\n"+
					
					"m44 vt4, va5,vc[va2.x]\n"+
					"m44 vt4, vt4,vc0\n"+
					//"m44 vt4, vt4,vc4\n"+
					//输出法线坐标
					"mov v2,vt4";
			   var vsa:AGALMiniAssembler=new AGALMiniAssembler;
			       vsa.assemble("vertex",vs);
				   VERTEX_SHADER=vsa.agalcode;
			}
			world.addEventListener(Event.CHANGE,onChange);
			initBuffer();
			initProgram();
		}// end function
		private function onChange(e:Event):void
		{
			init();
		}
		protected function initBuffer():void
		{
			if (CURRENT_VERTEX_BUFFER == null)
			{
				var vertexBufferData:Vector.<Number>;
				BATCH_NUM=int((TOTAL_REGISTER-REG_INDEX)/REG_PER_ROLS);
				var step:uint,mid:uint,uid:uint,cid:uint;
				vertexBufferData=new Vector.<Number>;
				while(step<BATCH_NUM)
				{
					mid=step*4+REG_INDEX;
					uid=BATCH_NUM*4+REG_INDEX+step*2;
					cid=BATCH_NUM*4+REG_INDEX+step*2+1;
					//trace(mid,uid,cid);
					v0=new Vector3D(0,0,1);
					v1=new Vector3D(1,0,1);
					v2=new Vector3D(1,-1,1);
					v3=new Vector3D(0,-1,1);
					vertexBufferData.push(
						0, 0, 1, 0, 0, mid, uid, cid,0,0,1,
						1, 0, 1, 1, 0, mid, uid, cid,0,0,1,
						1,-1, 1, 1, 1, mid, uid, cid,0,0,1,
						0,-1, 1, 0, 1, mid, uid, cid,0,0,1
					);
					step++;
				}
				//trace("顶点的数量:",vertexBufferData.length/4)
				
				CURRENT_VERTEX_BUFFER = context3d.createVertexBuffer(BATCH_NUM*4,11);
				CURRENT_VERTEX_BUFFER.uploadFromVector(vertexBufferData, 0, BATCH_NUM*4);
				context3d.setVertexBufferAt(0, CURRENT_VERTEX_BUFFER, 0, "float3");
				context3d.setVertexBufferAt(1, CURRENT_VERTEX_BUFFER, 3, "float2");
				context3d.setVertexBufferAt(2, CURRENT_VERTEX_BUFFER, 5, "float1");
				context3d.setVertexBufferAt(3, CURRENT_VERTEX_BUFFER, 6, "float1");
				context3d.setVertexBufferAt(4, CURRENT_VERTEX_BUFFER, 7, "float1");
				context3d.setVertexBufferAt(5, CURRENT_VERTEX_BUFFER, 8, "float3");
			}
			if (CURRENT_INDEX_BUFFER == null)
			{
				var indexBufferData:Vector.<uint>;
				indexBufferData=new Vector.<uint>;
				//indexBufferData.push(0,1,2,0,2,3);
				
				for(var i:uint=0;i<BATCH_NUM;i++)
				{
					indexBufferData.push(0+i*4,1+i*4,2+i*4,0+i*4,2+i*4,3+i*4);
				}
				
				CURRENT_INDEX_BUFFER = context3d.createIndexBuffer(BATCH_NUM*6);
				CURRENT_INDEX_BUFFER.uploadFromVector(indexBufferData, 0, BATCH_NUM*6);
			}
		}
		public function setTexture(texture:TextureData) : void
		{
			mTexture = texture;
			width = mTexture.width;
			height = mTexture.height;
			if(mOriginWidth!=width||mOriginHeight!=height)
			{
				mOriginWidth = mSx=width;
			    mOriginHeight = mSy=height;
				init();
			}
			
			mOffsetX = texture.offsetX;
			mOffsetY = texture.offsetY;
			mOffsetX = mOffsetX / world.width * 2;
			mOffsetY = -mOffsetY / world.height * world.scale * 2;
			mConstrants[0]=texture.uvVector[0];
			mConstrants[1]=texture.uvVector[1];
			mConstrants[2]=texture.uvVector[2];
			mConstrants[3]=texture.uvVector[3];
			
			//context3d.setVertexBufferAt(1, this.mTexture.uvBuffer, 0, "float2");
		}// end function
		
		protected function initProgram() : void
		{
			//var vg:AGALMiniAssembler;
			var fg:AGALMiniAssembler;
			var vs:String;
			var fs:String;
			if (CURRENT_PROGRAM == null)
			{
				//vg = new AGALMiniAssembler();
				fg = new AGALMiniAssembler();
				
				
				fs ="tex ft0, v0, fs0 <2d,clamp,linear> \n" + 
					"mul ft0,ft0,v1\n" + 
					//"dp3 ft2,v2.xyz,fc1.xyz\n"+
					//"mul ft3,ft2,fc0\n"+
					//"sub ft1.x,ft0.x,fc0.x\n"+
					//"kil ft1.x\n"+
					//求方向向量
					"sub ft1.xyz,fc1.xyz,v2.xyz\n"+
					//求向量长度
					"dp3 ft1.xyz,ft1.xyz,ft1.xyz\n"+
					//缩放长度,光晕大小
					"mul ft1.xyz,ft1.xyz,fc1.w\n"+
					//计算颜色与长度关系
					"div ft3,fc0.xyz,ft1.xyz\n"+
					//颜色强度
					"pow ft3.xyz,ft3.xyz,fc0.w\n"+
					//"nrm ft3.xyz,ft3,xyz\n"+
					"sat ft3,ft3\n"+
					
					//"mul ft0.xyz,ft3.xyz,ft0.xyz\n"+
					"mov oc ft0\n";
				//vg.assemble(Context3DProgramType.VERTEX, vs);
				fg.assemble(Context3DProgramType.FRAGMENT, fs);
				CURRENT_PROGRAM = context3d.createProgram();
				CURRENT_PROGRAM.upload(VERTEX_SHADER, fg.agalcode);
				
			}
			mProgram3d=CURRENT_PROGRAM;
			context3d.setProgram(mProgram3d);
			
		}// end function
		
		override protected function draw() : void
		{
			//贴图不一样
			if(!visible)
				return;
			
			if(mTexture == null)
				return;
			
			if(CURRENT_TEXTURE!=mTexture.texture)
			{
				//贴图不为空
				if(CURRENT_TEXTURE!=null)
				{
					//输出缓冲区渲染数据
//					trace("提前缓冲区输出",BATCH_INDEX,this);
					if(BATCH_INDEX>0)
					{
						context3d.drawTriangles(CURRENT_INDEX_BUFFER,0,BATCH_INDEX*2);
						BATCH_INDEX=0;
					}
				
				}
				context3d.setTextureAt(0, mTexture.texture);
				CURRENT_TEXTURE=mTexture.texture;
			}
			if(CURRENT_PROGRAM!=mProgram3d)
			{
				context3d.setProgram(mProgram3d);
				CURRENT_PROGRAM=mProgram3d;
			}
			
			var mid:uint=REG_INDEX+BATCH_INDEX*4;
			var uid:uint=BATCH_NUM*4+REG_INDEX+BATCH_INDEX*2;
			//var cid:uint=BATCH_NUM*4+BATCH_NUM+REG_INDEX+BATCH_INDEX;
			//trace("数据:",mid,uid);
			context3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX,mid, mOutMatrix, true);
			context3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX,uid,mConstrants,2);
			
			if(BATCH_INDEX==BATCH_NUM-1)
			{
				//trace("输出全部缓冲区",BATCH_INDEX,mid,uid);
				context3d.drawTriangles(CURRENT_INDEX_BUFFER);
				BATCH_INDEX=0;
			}
			else
			{
				BATCH_INDEX++;
			}
		}// end function
		
		override protected function composeMatrix() : void
		{
			super.composeMatrix();
			mOutMatrix.appendTranslation(mOffsetX, mOffsetY, 0);
		}// end function
		
	}
}
