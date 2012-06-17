package mongoose.display
{
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display3D.Context3D;
	import flash.events.Event;
	import flash.geom.Rectangle;

	public class World extends DisplayObjectContainer
	{
		private var context3d:Context3D;
		protected var mStage3d:Stage3D;
		public var antiAlias:uint;
		public var autoSize:Boolean;
		public function World(stage:Stage,viewPort:Rectangle,antiAlias:uint=0):void
		{
			DisplayObject.stage=stage;
			width=viewPort.width;
			height=viewPort.height;
			mStage3d=stage.stage3Ds[0];
			mStage3d.x=viewPort.x;
			mStage3d.y=viewPort.y;
			stage.scaleMode="noScale";
			stage.align=StageAlign.TOP_LEFT;
			this.antiAlias=antiAlias;
			stage.addEventListener(Event.RESIZE,onResize);
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
			context3d.configureBackBuffer(width,height,antiAlias,false);
			stage.addEventListener(Event.ENTER_FRAME,onRender);
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