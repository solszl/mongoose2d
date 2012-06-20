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
		
		private var _x:Number,_y:Number,_z:Number,
		            _u:Number,_v:Number,
					_r:Number,_g:Number,_b:Number,_a:Number;
		private var _step:uint,
		            _verticIndex:uint,
					_drawIndex:uint,
					_globalIndex:uint,
					_uvIndex:uint,
					_rotX:Number,
					_rotY:Number,
					_rotZ:Number,
					_xSin:Number,_xCos:Number,
					_ySin:Number,_yCos:Number,
					_zSin:Number,_zCos:Number,
					_xAngle:Number,
					_yAngle:Number,
					_zAngle:Number;
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
				//"mul ft0,ft0,v1\n"+
				//"mul ft0,ft0,v1\n" +
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
					
				var clour:Vector.<Number>=obj.color;
				var txture:TextureData=obj.texture;
				
				if(mCurrentTexture!=txture.texture)
				{
					mCurrentTexture=txture.texture;
					context3d.setTextureAt(0,mCurrentTexture);
				}
				//var len:uint=obj.childs.length;
				/*var x:Number,y:Number,z:Number,
				    u:Number,v:Number,
				    r:Number,g:Number,b:Number,a:Number;*/
				
				
				
				//var rx:Number,ry:Number,rz:Number;
			
				obj.render();
				
				//trace(obj.name)
				_drawIndex=_drawCall*4*mNumPerVertic;
				
				_xAngle=obj.rotationX*pi;
				_yAngle=obj.rotationY*pi;
				_zAngle=obj.rotationZ*pi;
				
				_xSin=Math.sin(_xAngle);
				_xCos=Math.cos(_xAngle);
				
				_yCos=Math.sin(_yAngle);
				_yCos=Math.cos(_yAngle);
				
				_zSin=Math.sin(_zAngle);
				_zCos=Math.cos(_zAngle);
				
				//trace("\n处理对象:",obj.name,obj.x,obj.y,obj.z);
				
				
				
				_step=0;
				while(_step<4)
				{
					_verticIndex=_step*mNumPerVertic;
					_globalIndex=_drawIndex+_verticIndex;
					
					_x=mCubeData[_verticIndex];
					_y=mCubeData[_verticIndex+1];
					_z=mCubeData[_verticIndex+2];
					
				
					_x+=obj.pivot.x;
					_y+=obj.pivot.y;
					//缩放
					_x*=txture.width;
					_y*=txture.height;
					
					_x*=obj.width/txture.width;
					_y*=obj.height/txture.height;
					
					_x*=obj.scaleX;
					_y*=obj.scaleY;
					
					_rotX=_rotY=_rotZ;
					//x旋转
					_rotY=_y*_xCos-_z*_xSin;
					_rotZ=_y*_xSin+_z*_xCos;
					//y旋转
					_rotX=_x*_yCos+_rotZ*_yCos;
					_z=_x*-_yCos+_rotZ*_yCos;
					//z旋转
					_x=_rotX*_zCos-_rotY*_zSin;
					_y=_rotX*_zSin+_rotY*_zCos;
					
					//位移
					_x+=obj.x;_y-=obj.y;_z+=obj.z;
					
					mVerticBufferData[_globalIndex]=_x;
					mVerticBufferData[_globalIndex+1]=_y;
					mVerticBufferData[_globalIndex+2]=_z;

					_uvIndex=_step*2;
					
					
					mVerticBufferData[_globalIndex+3]=obj.uv[_uvIndex];
					mVerticBufferData[_globalIndex+4]=obj.uv[_uvIndex+1];
					
					
					mVerticBufferData[_globalIndex+5]=clour[0];
					mVerticBufferData[_globalIndex+6]=clour[1];
					mVerticBufferData[_globalIndex+7]=clour[2];
					mVerticBufferData[_globalIndex+8]=clour[3];
					//trace("处理对象:",obj.name,"顶点",st,"的基本变化,旋转+位移")
					_step++;
				}
				var target:DisplayObject=obj;
				
				//var currtarget:Sprite2D=obj;
				
				while(!(target.parent is World)&&target.parent!=null)
				{
					
					_xAngle=target.parent.rotationX*pi;
					_yAngle=target.parent.rotationY*pi;
					_zAngle=target.parent.rotationZ*pi;
					
					_xSin=Math.sin(_xAngle);
					_xCos=Math.cos(_xAngle);
					
					_yCos=Math.sin(_yAngle);
					_yCos=Math.cos(_yAngle);
					
					_zSin=Math.sin(_zAngle);
					_zCos=Math.cos(_zAngle);
					
					
					
					_drawIndex=_drawCall*4*mNumPerVertic;
					
					_step=0;
					while(_step<4)
					{
						_verticIndex=_step*mNumPerVertic;
						_globalIndex=_drawIndex+_verticIndex;

						_x=mVerticBufferData[_globalIndex];
						_y=mVerticBufferData[_globalIndex+1];
						_z=mVerticBufferData[_globalIndex+2];

					
						_x-=obj.x;_y+=obj.y;_z-=obj.z;

						_rotY=(_y-target.y)*_xCos-(_z+target.z)*_xSin;
						_rotZ=(_y+target.y)*_xSin+(_z+target.z)*_xCos;
						
						_rotX=(_x+target.x)*_yCos+_rotZ*_yCos;
						_z=(_x+target.x)*-_yCos+_rotZ*_yCos;
						
						_x=_rotX*_zCos-_rotY*_zSin;
						_y=_rotX*_zSin+_rotY*_zCos;
				
						_x+=target.parent.x;_y-=target.parent.y;_z+=target.parent.z;
						mVerticBufferData[_globalIndex]=_x;
						mVerticBufferData[_globalIndex+1]=_y;
						mVerticBufferData[_globalIndex+2]=_z;
						_step++;
					}
				
					target=target.parent;
				}

				_drawCall++;
			}
			var container:DisplayObjectContainer=obj as DisplayObjectContainer;
			if(container)
			{
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