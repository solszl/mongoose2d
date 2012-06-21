package mongoose.display
{
	import com.adobe.utils.AGALMiniAssembler;
	import com.adobe.utils.PerspectiveMatrix3D;
	
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	
	import mongoose.tools.FrameRater;

	[Event(name="addedToStage", type="flash.events.Event")]
	public class World extends DisplayObjectContainer
	{
		protected var mStage3d:Stage3D;
		public var antiAlias:uint;
		public var autoSize:Boolean;
		private var context3d:Context3D;
		private var _stage:Stage;
		private var _drawCall:uint=0;
		protected var mMaxVertics:uint=65535;
		protected var mFps:FrameRater;
		//position,uv,color
		protected var mNumPerVertic:uint=9;
		protected var mNumVerticPerPerson:uint=4;
		protected var mMaxPerson:uint=uint(mMaxVertics/mNumVerticPerPerson);
		protected var mVerticBuffer:VertexBuffer3D;
		
		protected var mIndexBufferData:Vector.<uint>;
		protected var mIndexBuffer:IndexBuffer3D;
		protected var mVerticBufferData:Vector.<Number>;
		protected var mCurrentTexture:Texture;
		protected var mCurrentProgram:Program3D;
		protected var mNormalProgram:Program3D;
		protected var mCubeData:Vector.<Number>;
		
		
		protected var mPerspective:PerspectiveMatrix3D;
		protected var mWorldScaleMatrix:Matrix3D=new Matrix3D;
		private var pi:Number=Math.PI/180;
		private var _scale:Number;
		public function World(stage2d:Stage,viewPort:Rectangle,antiAlias:uint=0):void
		{
			_stage=stage2d;
			_stage.scaleMode="noScale";
			_stage.align=StageAlign.TOP_LEFT;
			width=viewPort.width;
			height=viewPort.height;
			
			this.antiAlias=antiAlias;
			mFps = new FrameRater(65280, true,false);
			mStage3d=_stage.stage3Ds[0];
			mStage3d.x=viewPort.x;
			mStage3d.y=viewPort.y;
			mCubeData=new Vector.<Number>;
			mPerspective=new PerspectiveMatrix3D;
			mCubeData.push
			(
				0, 0, 0, 0, 0, 1,1,1,1,
				1, 0, 0, 1, 0, 1,1,1,1,
				1,-1, 0, 1, 1, 1,1,1,1,
				0,-1, 0, 0, 1, 1,1,1,1
			)
			
			_stage.addEventListener(Event.RESIZE,onResize);
			mStage3d.addEventListener(Event.CONTEXT3D_CREATE,onContext);
		}
		private function onResize(e:Event):void
		{
			if(context3d!=null&&autoSize)
			{
				width=_stage.stageWidth;
				height=_stage.stageHeight;
				
				configure();
			}
		}
		
		private function onContext(e:Event):void
		{
			width=_stage.stageWidth;
			height=_stage.stageHeight;
			context3d=mStage3d.context3D;
			DisplayObject.stage=_stage;
			
			createBuffers();
			createProgram();
			configure();
			
			TextureData.context3d=context3d;
			
			context3d.enableErrorChecking=true;
			context3d.setCulling(Context3DTriangleFace.NONE);
			context3d.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, 
				                      Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			dispatchEvent(new Event(Event.ADDED_TO_STAGE));
			_stage.addEventListener(Event.ENTER_FRAME,onRender);
			
		}
		private function configure():void
		{
			
			var mViewAngle:Number = Math.atan(height/width) * 2;
			//mPerspective.identity();
			mPerspective.perspectiveFieldOfViewLH(mViewAngle,width/height, .1,10000);

			_scale=height/width;
			mWorldScaleMatrix.identity();
			mWorldScaleMatrix.appendScale(2/width,2/height*_scale,.1/10000);
			mWorldScaleMatrix.appendTranslation(-1,_scale,1);
			context3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX,4,mPerspective,true);
			context3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX,0,mWorldScaleMatrix,true);
			context3d.configureBackBuffer(width,height,antiAlias,false);
		}
		public function set showFps(value:Boolean):void
		{
			if (value)
			{
				_stage.addChild(mFps);
			}
			else if (_stage.contains(mFps))
			{
				_stage.removeChild(mFps);
			}
		}
		private function createBuffers():void
		{
			mVerticBuffer=context3d.createVertexBuffer(mMaxPerson*mNumVerticPerPerson,mNumPerVertic);
			mVerticBufferData=new Vector.<Number>;
			mIndexBuffer=context3d.createIndexBuffer(mMaxPerson*6);
			mIndexBufferData=new Vector.<uint>;
			var step:uint=0;
			while(step<mMaxPerson)
			{
				mVerticBufferData.push(
					//position,uv,color
					0, 0, 0,  0,0, 1,1,1,1,
					1, 0, 0,  1,0, 1,1,1,1,
					1,-1, 0,  1,1, 1,1,1,1,
					0,-1, 0,  0,1, 1,1,1,1
				);
				
				
				var add:uint=step*4;
				mIndexBufferData.push(0+add,1+add,2+add,0+add,2+add,3+add);
				
				step++;
			}
			mVerticBuffer.uploadFromVector(mVerticBufferData,0,mMaxPerson*mNumVerticPerPerson);
			mIndexBuffer.uploadFromVector(mIndexBufferData,0,mIndexBufferData.length);
			context3d.setVertexBufferAt(0,mVerticBuffer,0,"float3");
			context3d.setVertexBufferAt(1,mVerticBuffer,3,"float2");
			context3d.setVertexBufferAt(2,mVerticBuffer,5,"float4");
		}
		private function createProgram():void
		{
			var vsa:AGALMiniAssembler=new AGALMiniAssembler;
			var fsa:AGALMiniAssembler=new AGALMiniAssembler;
			var vs:String="m44 vt0,va0,vc0\n"+
				"m44 vt0,vt0,vc4\n"+
				
				"mov op,vt0\n"+
				"mov v0,va1\n"+
				"mov v1,va2";
			var fs:String="tex ft0, v0, fs0 <2d,clamp,linear> \n" + 
				"mul ft0,ft0,v1\n"+
				// "mul ft0,ft0,v1\n" +
				"mov oc,ft0"; 
			vsa.assemble(Context3DProgramType.VERTEX,vs);
			fsa.assemble(Context3DProgramType.FRAGMENT,fs);
			mNormalProgram=context3d.createProgram();
			mNormalProgram.upload(vsa.agalcode,fsa.agalcode);
			
			mCurrentProgram=mNormalProgram;
			context3d.setProgram(mCurrentProgram);
		}
		private function onRender(e:Event):void
		{
			context3d.clear();
			_drawCall=0;
			renderObj(this);
			if(_drawCall>0)
			{
				mVerticBuffer.uploadFromVector(mVerticBufferData,0,_drawCall*4);
			    context3d.drawTriangles(mIndexBuffer,0,_drawCall*2);
				mFps.uints=_drawCall;
			}
			
			context3d.present();
		}
		private function renderObj(obj:DisplayObject):void
		{
			if(!(obj is World))
			{
					
				
				if(mCurrentTexture!=obj.texture.texture)
				{
					mCurrentTexture=obj.texture.texture;
					context3d.setTextureAt(0,mCurrentTexture);
				}
				//var len:uint=obj.childs.length;
				var x:Number,y:Number,z:Number,
				    u:Number,v:Number,
				    r:Number,g:Number,b:Number,a:Number;
				
				var st:uint;
				var sid:int,id:uint,uid:uint;
				var rx:Number,ry:Number,rz:Number;
				var xsint:Number,
					xcost:Number,
					ysint:Number,
					ycost:Number,
					zsint:Number,
					zcost:Number;
				
				var xAngle:Number,
				    yAngle:Number,
				    zAngle:Number;
				
				obj.render();
				
				//trace(obj.name)
				var index:uint=_drawCall*4*mNumPerVertic;
				
				xAngle=obj.rotationX*pi;
				yAngle=obj.rotationY*pi;
				zAngle=obj.rotationZ*pi;
				
				xsint=Math.sin(xAngle);
				xcost=Math.cos(xAngle);
				
				ysint=Math.sin(yAngle);
				ycost=Math.cos(yAngle);
				
				zsint=Math.sin(zAngle);
				zcost=Math.cos(zAngle);
				
				//trace("\n处理对象:",obj.name,obj.x,obj.y,obj.z);
				
				st=0;
				while(st<4)
				{
					sid=st*mNumPerVertic;
					id=index+sid;
					
					x=mCubeData[sid];
					y=mCubeData[sid+1];
					z=mCubeData[sid+2];
					
				
					x+=obj.pivot.x;
					y+=obj.pivot.y;
					//缩放
					x*=obj.texture.width;
					y*=obj.texture.height;
					
					x*=obj.width/obj.texture.width;
					y*=obj.height/obj.texture.height;
					
					x*=obj.scaleX;
					y*=obj.scaleY;
					
					rx=ry=rz=0;
					//x旋转
					ry=y*xcost-z*xsint;
					rz=y*xsint+z*xcost;
					//y旋转
					rx=x*ycost+rz*ysint;
					z=x*-ysint+rz*ycost;
					//z旋转
					x=rx*zcost-ry*zsint;
					y=rx*zsint+ry*zcost;
					
					//位移
					x+=obj.x;y-=obj.y;z+=obj.z;
					
					mVerticBufferData[id]=x;
					mVerticBufferData[id+1]=y;
					mVerticBufferData[id+2]=z;

					uid=st*2;
						
					mVerticBufferData[id+3]=obj.uv[uid];
					mVerticBufferData[id+4]=obj.uv[uid+1];
					
					mVerticBufferData[id+5]=obj.color[0];
					mVerticBufferData[id+6]=obj.color[1];
					mVerticBufferData[id+7]=obj.color[2];
					mVerticBufferData[id+8]=obj.color[3];
					//trace("处理对象:",obj.name,"顶点",st,"的基本变化,旋转+位移")
					st++;
				}
				var target:DisplayObject=obj;
				var tx:Number=0,ty:Number=0,tz:Number=0;
				
				
				//var currtarget:Sprite2D=obj;
				
				while(target.parent!=null)
				{
					//trace(target.name);
					//trace("---------------------处理",obj.name,"的叠加变化-------------------")
					
					
					//trace(target.name,tx,ty,tz);
					//取出父级参数环境
					xAngle=target.parent.rotationX*pi;
					yAngle=target.parent.rotationY*pi;
					zAngle=target.parent.rotationZ*pi;
					
					xsint=Math.sin(xAngle);
					xcost=Math.cos(xAngle);
					
					ysint=Math.sin(yAngle);
					ycost=Math.cos(yAngle);
					
					zsint=Math.sin(zAngle);
					zcost=Math.cos(zAngle);
					//trace("计算",target.name,"的父级",target.parent.name,"的三角关系")
					
					st=0;
					index=_drawCall*4*mNumPerVertic;
					
					
					//trace("获取源数据:",obj.name,index);
					while(st<4)
					{
						sid=st*mNumPerVertic;
						id=index+sid;

						x=mVerticBufferData[id];
						y=mVerticBufferData[id+1];
						z=mVerticBufferData[id+2];

						//trace(obj.name,"的顶点计算开始","顶点:"+st,x,y,z);
					
						x-=target.x;y+=target.y;z-=target.z;

						ry=(y-target.y)*xcost-(z+target.z)*xsint;
						rz=(y+target.y)*xsint+(z+target.z)*xcost;
						
						rx=(x+target.x)*ycost+rz*ysint;
						z=(x+target.x)*-ysint+rz*ycost;
						
						x=rx*zcost-ry*zsint;
						y=rx*zsint+ry*zcost;
						//trace(currtarget.name,x,y,z)
						x+=target.parent.x;y-=target.parent.y;z+=target.parent.z;
						mVerticBufferData[id]=x;
						mVerticBufferData[id+1]=y;
						mVerticBufferData[id+2]=z;
						st++;
					}
					
					tx+=target.parent.x;
					ty+=target.parent.y;
					tz+=target.parent.z;
					
					target=target.parent;
				}
                
				_drawCall++;
			}
			if(obj is DisplayObjectContainer)
			{
				var container:DisplayObjectContainer=obj as DisplayObjectContainer;
				var childs:Array=container.childs;
				var step:uint=0;
				var total:uint=childs.length;
				while(step<total)
				{
					renderObj(childs[step]);
					step++;
				}
			}
		}
		public function start():void
		{
			
			mStage3d.requestContext3D();
		}
	}
}