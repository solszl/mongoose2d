package mongoose.display
{
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display3D.Context3D;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.geom.Rectangle;

	[Event(name="addedToStage", type="flash.events.Event")]
	public class World extends DisplayObjectContainer
	{
		protected var mStage3d:Stage3D;
		public var antiAlias:uint;
		public var autoSize:Boolean;
		private var context3d:Context3D;
		private var _stage:Stage;
		
		protected var mMaxVertics:uint=65535;
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
		protected var mCubeData:Vector.<Number>;
		public function World(stage2d:Stage,viewPort:Rectangle,antiAlias:uint=0):void
		{
			_stage=stage2d;
			_stage.scaleMode="noScale";
			_stage.align=StageAlign.TOP_LEFT;
			width=viewPort.width;
			height=viewPort.height;
			
			this.antiAlias=antiAlias;
			
			mStage3d=_stage.stage3Ds[0];
			mStage3d.x=viewPort.x;
			mStage3d.y=viewPort.y;
			mCubeData=new Vector.<Number>;
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
				width=stage.stageWidth;
				height=stage.stageHeight;
				context3d.configureBackBuffer(width,height,antiAlias,false);
			}
		}
		
		private function onContext(e:Event):void
		{
			context3d=mStage3d.context3D;
			createBuffers();
			DisplayObject.stage=_stage;
			context3d.configureBackBuffer(width,height,antiAlias,false);
			
			_stage.addEventListener(Event.ENTER_FRAME,onRender);
			
			dispatchEvent(new Event(Event.ADDED_TO_STAGE));
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
		
		private function createIndexBuffer():void
		{
			
		}
		private function onRender(e:Event):void
		{
			context3d.clear();
			renderObj(this);
			context3d.present();
		}
		private function renderObj(obj:DisplayObject):void
		{
			obj.render();
			//
			//renderObject
			//
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