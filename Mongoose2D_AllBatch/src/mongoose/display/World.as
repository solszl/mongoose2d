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
	import flash.events.MouseEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
	
	import mongoose.tools.FrameRater;

	[Event(name="addedToStage", type="flash.events.Event")]
	public class World extends DisplayObjectContainer
	{
		protected var mStage3d:Stage3D;
		public var antiAlias:uint;
		public var autoSize:Boolean;
		public var near:Number=.1;
		public var far:Number=10000;
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
		protected var mObjects:Array;
		
		protected var mPerspective:PerspectiveMatrix3D;
		protected var mWorldScaleMatrix:Matrix3D=new Matrix3D;
		private var _pi:Number=Math.PI/180;
		private var _scale:Number;
		
		private var _xsint:Number,
					_xcost:Number,
					_ysint:Number,
					_ycost:Number,
					_zsint:Number,
					_zcost:Number;
		
		private var _xAngle:Number,_yAngle:Number,_zAngle:Number;
		private var _sid:int,_id:uint,_uid:uint;
		private var _rx:Number,_ry:Number,_rz:Number;
		private var _x:Number,_y:Number,_z:Number;
		
		private var _vt:uint,_vtIndex:uint;
		private var _widthRcp:Number,_heightRcp:Number;

		protected var mNearPoint:Vector3D=new Vector3D;
		protected var mFarPoint:Vector3D=new Vector3D;
		protected var mDir:Vector3D=new Vector3D;
		
		private var _startDraw:uint,_stopDraw:uint;
		private var _points:Vector.<Vector3D>=new Vector.<Vector3D>;
		private var _cpu:Number=0;
		private var _gpu:Number=0;
		
		protected var mScaleMatrix:Matrix3D=new Matrix3D;
		
		private var sin:Function=Math.sin,
			        cos:Function=Math.cos;
		
		private var _angle1:Array=[];
		private var _angle2:Array=[];
		
		private var _type:String="";
		private var _xPos:Number,_yPos:Number;
		
		private var _testObject:InteractiveObject;
		private var _prevObject:InteractiveObject;
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
			mObjects=new Array(mMaxPerson);
			mPerspective=new PerspectiveMatrix3D;
			mCubeData.push
			(
				0, 0, 0, 0, 0,1,1,1,1,
				1, 0, 0, 1, 0,1,1,1,1,
				1,-1, 0, 1, 1,1,1,1,1,
				0,-1, 0, 0, 1,1,1,1,1
			)
			_points.push(new Vector3D);
			_points.push(new Vector3D);
			_points.push(new Vector3D);
			_points.push(new Vector3D);
			_stage.addEventListener(Event.RESIZE,onResize);
			
			mStage3d.addEventListener(Event.CONTEXT3D_CREATE,onContext);
		}
		private function onResize(e:Event):void
		{
			if(context3d!=null&&autoSize)
			{
				configure();
			}
		}
		
		private function onContext(e:Event):void
		{
			context3d=mStage3d.context3D;
			InteractiveObject.stage=_stage;
            TextureData.context3d=context3d;
			
			configure();
			createBuffers();
			createProgram();
			
			context3d.enableErrorChecking=true;
			context3d.setCulling(Context3DTriangleFace.NONE);
			context3d.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, 
				                      Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			
			//_stage.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			_stage.addEventListener(MouseEvent.CLICK,onClick);
			_stage.addEventListener(MouseEvent.MOUSE_DOWN,onClick);
			_stage.addEventListener(MouseEvent.MOUSE_UP,onClick);
			
			_stage.addEventListener(Event.ENTER_FRAME,onRender);
			dispatchEvent(new Event(Event.ADDED_TO_STAGE));
		}
		private function onClick(e:MouseEvent):void
		{
			_type=e.type;
			
		}
		private function onMouseMove(e:MouseEvent):void
		{
			var tx:Number=e.stageX;
			var ty:Number=e.stageY;
			var dx:Number=(tx*_widthRcp-1);
			var dy:Number=1-ty*_heightRcp;
			
			mNearPoint.x=dx*near;
			mNearPoint.y=dy*near;
			mNearPoint.z=near;
			
			mFarPoint.x=dx*far;
			mFarPoint.y=dy*far;
			mFarPoint.z=far;
			
			
			mNearPoint=mScaleMatrix.transformVector(mNearPoint);
			mFarPoint=mScaleMatrix.transformVector(mFarPoint);
			
			mDir=mFarPoint.subtract(mNearPoint);
			//trace(mNearPoint,mFarPoint);
		}
		private function configure():void
		{
			width=_stage.stageWidth;
			height=_stage.stageHeight;
			_widthRcp=2/width;
			_heightRcp=2/height;
			var mViewAngle:Number = Math.atan(height/width) * 2;
			mPerspective.perspectiveFieldOfViewLH(mViewAngle,width/height, near,far);

			_scale=height/width;
			mWorldScaleMatrix.identity();
			mWorldScaleMatrix.appendScale(2/width,2/height*_scale,1 / (far - near));
			mWorldScaleMatrix.appendTranslation(-1,_scale,1);
			
			mScaleMatrix.rawData=mWorldScaleMatrix.rawData;
			//mScaleMatrix.appendTranslation(1,-_scale,1);
			//mScaleMatrix.appendScale(1,_scale,1);
			mScaleMatrix.appendTranslation(0,1-_scale,0);
			mScaleMatrix.invert();
			
			mScaleMatrix.appendScale(1,_scale,1);
			
			
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
		public function showLogo(value:Boolean):void
		{
			if(value)
			{
				
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
					0, 0, 0,  0,0,1,1,1,1,
					1, 0, 0,  1,0,1,1,1,1,
					1,-1, 0,  1,1,1,1,1,1,
					0,-1, 0,  0,1,1,1,1,1
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
			var vs:String=
				"m44 vt0,va0,vc0\n"+
				"m44 op,vt0,vc4\n"+
				
//				"mov op,vt0\n"+
				"mov v0,va1\n"+
				"mov v1,va2";
			var fs:String="tex ft0, v0, fs0 <2d,repeat,linear> \n" + 
				   "mul oc,ft0,v1\n"//+
				// "mul ft0,ft0,v1\n" +
//				"mov oc,ft0"; 
			vsa.assemble(Context3DProgramType.VERTEX,vs);
			fsa.assemble(Context3DProgramType.FRAGMENT,fs);
			mNormalProgram=context3d.createProgram();
			mNormalProgram.upload(vsa.agalcode,fsa.agalcode);
			
			mCurrentProgram=mNormalProgram;
			context3d.setProgram(mCurrentProgram);
		}
		private function onRender(e:Event=null):void
		{
			var tx:Number=stage.mouseX;
			var ty:Number=stage.mouseY;
			var dx:Number=(tx*_widthRcp-1);
			var dy:Number=1-ty*_heightRcp;
			
			mNearPoint.x=dx*near;
			mNearPoint.y=dy*near;
			mNearPoint.z=near;
			
			mFarPoint.x=dx*far;
			mFarPoint.y=dy*far;
			mFarPoint.z=far;
			
			
			mNearPoint=mScaleMatrix.transformVector(mNearPoint);
			mFarPoint=mScaleMatrix.transformVector(mFarPoint);
			
			mDir=mFarPoint.subtract(mNearPoint);
			
			
			context3d.clear();
			
			_drawCall=0;
			
			renderObj(this);
		
			
			if(_testObject!=null)
			{
				if(_type!="")
				{
					_testObject.triggerEvent(_type,stage.mouseX,stage.mouseY);
					
				}
				if(_prevObject!=_testObject)
				{
					if(_prevObject!=null)
					{
						_prevObject.triggerEvent(MouseEvent.MOUSE_OUT,stage.mouseX,stage.mouseY);
					}
					_prevObject=_testObject;
				}
				_testObject.triggerEvent(MouseEvent.MOUSE_OVER,stage.mouseX,stage.mouseY);
				_testObject.triggerEvent(MouseEvent.MOUSE_MOVE,stage.mouseX,stage.mouseY);
				_testObject=null;
			}
			else if(_prevObject!=null)
			{
				_prevObject.triggerEvent(MouseEvent.MOUSE_OUT,stage.mouseX,stage.mouseY);
				_prevObject=null;
			}
			_type="";
			
			mVerticBuffer.uploadFromVector(mVerticBufferData,0,_drawCall*4);
			mFps.uints=_drawCall;
			
			_startDraw=0;

			var step:uint=0;
			var obj:DisplayObject;
			var texture:TextureData;
			var end:uint;
			while(step<_drawCall)
			{
				obj=mObjects[step];
				texture=obj.texture;
				if(mCurrentTexture!=texture.texture)
				{
					if(mCurrentTexture!=null)
					{
						context3d.setTextureAt(0,mCurrentTexture);
						end=step-_startDraw;
						context3d.drawTriangles(mIndexBuffer,_startDraw*6,end*2);
						_startDraw=step;
					}
					mCurrentTexture=texture.texture;
				}
				step++;
			}
			
			
			if(_drawCall>0)
			{
				context3d.setTextureAt(0,mCurrentTexture);
				end=_drawCall-_startDraw;
				context3d.drawTriangles(mIndexBuffer,_startDraw*6,end*2);
			}
			
			context3d.present();
		}
		
		private function renderObj(obj:DisplayObject):void
		{
			var texture:TextureData=obj.texture;
			if(!(obj is World))
			{
				obj.render();
				
				if(texture!=null&&obj.visible)
				{
					obj.width=texture.width;
					obj.height=texture.height;
					mCurrentTexture=texture.texture;
					mObjects[_drawCall]=obj;
					//var len:uint=obj.childs.length;
					//trace(obj.name)
					_vtIndex=_drawCall*4*mNumPerVertic;
					//trace("顶点计算",_drawCall);
					_xAngle=obj.rotationX*_pi;
					_yAngle=obj.rotationY*_pi;
					_zAngle=obj.rotationZ*_pi;
					
					_xsint=sin(_xAngle);
					_xcost=cos(_xAngle);
					
					_ysint=sin(_yAngle);
					_ycost=cos(_yAngle);
					
					_zsint=sin(_zAngle);
					_zcost=cos(_zAngle);
					
					//trace("\n处理对象:",obj.name,obj.x,obj.y,obj.z);
					
					_vt=0;
					
					
					while(_vt<4)
					{
						_sid=_vt*mNumPerVertic;
						_id=_vtIndex+_sid;
						
						_x=mCubeData[_sid];
						_y=mCubeData[_sid+1];
						_z=mCubeData[_sid+2];
						
					
						_x+=obj.pivot.x;
						_y+=obj.pivot.y;
						//缩放
						_x*=obj.width*obj.scaleX;
						_y*=obj.height*obj.scaleY;
						
						_rx=_ry=_rz=0;
						//x旋转
						_ry=_y*_xcost-_z*_xsint;
						_rz=_y*_xsint+_z*_xcost;
						//y旋转
						_rx=_x*_ycost+_rz*_ysint;
						_z=_x*-_ysint+_rz*_ycost;
						//z旋转
						_x=_rx*_zcost-_ry*_zsint;
						_y=_rx*_zsint+_ry*_zcost;
						
						//位移
						_x+=obj.x;_y-=obj.y;_z+=obj.z;
						
						mVerticBufferData[_id]  =_x;
						mVerticBufferData[_id+1]=_y;
						mVerticBufferData[_id+2]=_z;
	
						var point:Vector3D=_points[_vt];
						
						point.x=_x;
						point.y=_y;
						point.z=_z;
						
						_uid=_vt*2;
							
						mVerticBufferData[_id+3]=texture.uvVector[_uid]  +obj.scrollX;
						mVerticBufferData[_id+4]=texture.uvVector[_uid+1]+obj.scrollY;
						
						mVerticBufferData[_id+5]=obj.red;
						mVerticBufferData[_id+6]=obj.green;
						mVerticBufferData[_id+7]=obj.blue;
						mVerticBufferData[_id+8]=obj.alpha;
						//trace("处理对象:",obj.name,"顶点",st,"的基本变化,旋转+位移")
						_vt++;
					}
					var target:DisplayObject=obj;
					var notWorld:Boolean=!(target.parent is World);
					var tParent:DisplayObject;
					while(target.parent!=null&&notWorld)
					{
						tParent=target.parent;
						//取出父级参数环境
						_xAngle=tParent.rotationX*_pi;
						_yAngle=tParent.rotationY*_pi;
						_zAngle=tParent.rotationZ*_pi;
						
						_xsint=sin(_xAngle);
						_xcost=cos(_xAngle);
						
						_ysint=sin(_yAngle);
						_ycost=cos(_yAngle);
						
						_zsint=sin(_zAngle);
						_zcost=cos(_zAngle);

						_vt=0;
						_vtIndex=_drawCall*4*mNumPerVertic;

						//trace("获取源数据:",obj.name,index);
						while(_vt<4)
						{
							_sid=_vt*mNumPerVertic;
							_id=_vtIndex+_sid;
	
							_x=mVerticBufferData[_id];
							_y=mVerticBufferData[_id+1];
							_z=mVerticBufferData[_id+2];
	
							//trace(obj.name,"的顶点计算开始","顶点:"+st,x,y,z);
						
							_x-=target.x;_y+=target.y;_z-=target.z;
	
							_ry=(_y-target.y)*_xcost-(_z+target.z)*_xsint;
							_rz=(_y+target.y)*_xsint+(_z+target.z)*_xcost;
							
							_rx=(_x+target.x)*_ycost+_rz*_ysint;
							_z=(_x+target.x)*-_ysint+_rz*_ycost;
							
							_x=_rx*_zcost-_ry*_zsint;
							_y=_rx*_zsint+_ry*_zcost;
							//trace(currtarget.name,x,y,z)
							_x+=tParent.x;_y-=tParent.y;_z+=tParent.z;
							mVerticBufferData[_id]=  _points[_vt].x=_x;
							mVerticBufferData[_id+1]=_points[_vt].y=_y;
							mVerticBufferData[_id+2]=_points[_vt].z=_z;
							
							mVerticBufferData[_id+5]*=tParent.red;
							mVerticBufferData[_id+6]*=tParent.green;
							mVerticBufferData[_id+7]*=tParent.blue;
							mVerticBufferData[_id+8]*=tParent.alpha;
							
							_vt++;
						}
						target=target.parent;
					}
					var intObj:InteractiveObject= obj as InteractiveObject;
					if(intObj!=null&&intObj.mouseEnabled)
					{
						if(intObj.iuseMove||_type!="")
						{
							var edge1:Vector3D=_points[1].subtract(_points[0]);
							var edge2:Vector3D=_points[2].subtract(_points[0]);
							var edge3:Vector3D=_points[3].subtract(_points[0]);
		
							
							instric(_points[0],edge1,edge2,_angle1);
							
							instric(_points[0],edge2,edge3,_angle2);
							
	                        if(_angle1[0]||_angle2[0])
							{
								if(alphaTest)
								{
									var u:Number=_angle1[1] > _angle2[1] ? _angle1[1] : _angle2[1];
									var v:Number=_angle1[2] > _angle2[2] ? _angle1[2] : _angle2[2];
									u=texture.uValue*u+texture.uvVector[0];
									v=texture.vValue*v+texture.uvVector[1];
									_xPos=texture.bitmapData.width;
									_yPos=texture.bitmapData.height;
									var _pixel:uint=texture.bitmapData.getPixel32(_xPos*u,_yPos*v);
									//_pixel>0?iHit=true:iHit=false;
									//	trace(_pixel);
									if(((_pixel >> 24) & 0xFF)>0)_testObject=intObj;
								}
								else
								{
									_testObject=intObj;
								}
							}
						}
					}
					_drawCall++;
				}
			}	
			var container:DisplayObjectContainer=obj  as  DisplayObjectContainer;
			if(container!=null)
			{
				
				var childs:Array=container.childs;
				var step:uint=0;
				var total:uint=childs.length;
				container.depth=container[container.sortName]+container.id;
				if(container.enableSort&&total>1)
				{
					childs.sortOn("depth",container.sortParam);
				}
				
				while(step<total)
				{
					renderObj(childs[step]);
					step++;
				}
			}
		}
		protected function instric(p0:Vector3D,edge1:Vector3D,edge2:Vector3D,result:Array):void
		{
			var pass:Boolean=true;
			var cvec:Vector3D=mDir.crossProduct(edge2);
			var det:Number=edge1.dotProduct(cvec);
			var tvec:Vector3D=new Vector3D,
				qvec:Vector3D=new Vector3D,
				u:Number,
				v:Number,
				t:Number,
				_temp:Number;
			if(det>0)
			{
				tvec=mNearPoint.subtract(p0);
			}
			if(det<0)
			{
				tvec=p0.subtract(mNearPoint);
				det=-det;
			}
			if(det<0.0001)pass= false;
				
			u=tvec.dotProduct(cvec);
			if(u<0||u>det)pass= false;
				
			qvec=tvec.crossProduct(edge1);
			v=mDir.dotProduct(qvec);
			if(v<0||u+v>det)pass= false;
				
			t=edge2.dotProduct(qvec);
			_temp=1/det;
			t*=_temp;
			u*=_temp;
			v*=_temp;
			result[0]=pass;
			result[1]=u;
			result[2]=v;
		}
		public function start():void
		{
			
			mStage3d.requestContext3D();
		}
	}
}