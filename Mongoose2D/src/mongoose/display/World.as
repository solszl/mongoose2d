package mongoose.display
{
    import com.adobe.utils.*;
    
    import flash.display.Stage;
    import flash.display.Stage3D;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DBlendFactor;
    import flash.display3D.Context3DCompareMode;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DTriangleFace;
    import flash.display3D.IndexBuffer3D;
    import flash.events.*;
    import flash.geom.Matrix3D;
    import flash.utils.getTimer;
    
    import mongoose.core.Camera;
    import mongoose.geom.*;
    import mongoose.tools.*;

    public class World extends DisplayObjectContainer
    {
        protected var mFullScreen:Boolean;
        public var perspective:PerspectiveMatrix3D;
        protected var mStage3D:Stage3D;
        protected var mRect:MRectangle;
		protected var mCamera:Camera;
		protected var mFps:FrameRater;
		//protected var mChilds:Array;
        //protected var mConstrants:Vector.<Number>=new Vector.<Number>(4);
		public var lights:Vector.<Number>=new Vector.<Number>(8);
        private static var STAGE_USED:uint = 0;
		
        public static var near:Number = 0.1;
        public static var far:Number = 10000;
        public var stage:Stage;
		public var scale:Number;
		//public var width:Number,height:Number;
		public var context3d:Context3D;
		//public var x:Number=0,y:Number=0;
	
		protected var mViewAngle:Number;
		protected var hitObj:InteractiveObject;
		
		private var _sortBy:String="z";
		private var _sortParam:int=Array.DESCENDING|Array.NUMERIC;
		//public var enableSort:Boolean;
		private var _mouseX:Number,_mouseY:Number,_move:Boolean=false;
		private var _mouseMoveDelay:Number=16;
		private var _time:Number=0;
		private var _eventObject:Array=[];
        public function World(stage2D:Stage, viewPort:MRectangle)
        {
			
            stage = stage2D;
            world=this;
			
			
			lights[0]=0
			lights[1]=.5
			lights[2]=0
			lights[3]=2
			lights[4]=0
			lights[5]=0
			lights[6]=1
			lights[7]=5
			
            mRect=viewPort;
            perspective = new PerspectiveMatrix3D();
			Camera.stage=stage;
            mCamera = new Camera();
            mCamera.active = true;
            mFps = new FrameRater(65280, true,false);
			mChilds=[];
            this.initialize(stage, mRect);
			
			super();
        }// end function
        override protected function init():void
		{
			
		}
		override protected function composeMatrix():void{}
		override protected function preRender():void{}
		override protected function draw():void{}
        public function set fullScreen(mRect:Boolean) : void
        {
            this.mFullScreen = mRect;
            this.onResize();
            return;
        }// end function

        private function onResize(VERTEX:Event = null) : void
        {
            
            if (context3d)
            {
                if (mFullScreen)
                {
                    width = stage.stageWidth;
                    height = stage.stageHeight;
                    mStage3D.x = 0;
                    mStage3D.y = 0;
                }
                else
                {
                    width = mRect.width;
                    height = mRect.height;
                    mStage3D.x = mRect.x;
                    mStage3D.y = mRect.y;
                }
				mViewAngle = Math.atan(height / width) * 2;
                perspective.perspectiveFieldOfViewLH(mViewAngle, width / height, near, far);
                context3d.configureBackBuffer(width, height, 8, false);
				//context3d.setDepthTest(true,Context3DCompareMode.LESS);
                context3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, perspective, true);
            }
            scale = height / width;
			
            dispatchEvent(new Event(Event.CHANGE));
        }// end function

        public function addCamera(camera:Camera) : void
        {
            return;
        }// end function

        public function initialize(mRoot:Stage, viewPort:MRectangle) : void
        {
            stage = mRoot;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            mRect = viewPort;
            width = mRect.width;
            height = mRect.height;
            x = mRect.x;
            y = mRect.y;
			mViewAngle = Math.atan(stage.stageHeight / stage.stageWidth) * 2;
            perspective.perspectiveFieldOfViewLH(mViewAngle, width / height, near, far);
            stage.addEventListener(Event.RESIZE, onResize);
   
        }// end function

        public function start() : void
        {
            mStage3D = stage.stage3Ds[STAGE_USED];
            mStage3D.addEventListener(Event.CONTEXT3D_CREATE, this.onCreate);
            mStage3D.requestContext3D();
            STAGE_USED++;

        }// end function
   
        protected function onCreate(VERTEX:Event) : void
        {
            context3d = mStage3D.context3D;
            context3d.enableErrorChecking = true;
            context3d.configureBackBuffer(width, height, 0, false);
            context3d.setCulling(Context3DTriangleFace.NONE);
			
            context3d.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			
            TextureData.context3d = context3d;
			BaseObject.stage=stage;
			BaseObject.world=this;
			BaseObject.context3d=context3d;
            stage.addEventListener(Event.ENTER_FRAME, this.onRender);
			
            onResize();
            dispatchEvent(new Event(Event.COMPLETE));
			onRender();

        }// end function
		
        
        protected function onRender(VERTEX:Event=null) : void
        {
			
            context3d.clear();
            Camera.current.capture();
			context3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX,0,Camera.current.matrix,true);
            render();
			//trace("清空末尾缓冲区",Image.BATCH_INDEX);
			if(Image.BATCH_INDEX>0)
			{
				//trace("结束输出缓冲区",Image.BATCH_INDEX)
				context3d.drawTriangles(Image.CURRENT_INDEX_BUFFER,0,Image.BATCH_INDEX*2);
				Image.BATCH_INDEX=0;
			}
			  
			
            context3d.present();
        }// end function

        public function showFps(mRect:Boolean) : void
        {
            if (mRect)
            {
                stage.addChild(mFps);
            }
            else if (stage.contains(mFps))
            {
                stage.removeChild(mFps);
            }
            return;
        }// end function

       /* public function addChild(object:DisplayObject) : void
        {
			if(!checkObject(object))
                mChilds.push(object);
			stage.addEventListener(MouseEvent.CLICK,onListenClick);
        }*/
		
		/*internal function changeEventObject(obj:InteractiveObject,todo:uint):void
		{
			
			if(todo==0)
				_eventObject.push(obj);
			else
			{
				
				var step:uint=0;
				while(step<_eventObject.length)
				{
					if(_eventObject[step]==obj)
					{
						_eventObject.splice(step,1);
						break;
					}
					step++;
				}
			}
			
		}*/
        private function checkObject(obj:DisplayObject):Boolean
		{
			var step:uint=0;
			while(step<mChilds.length)
			{
				if(mChilds[step]==obj)
					return true;
				step++;
			}
			return false;
		}
		/*public function sortOn(name:String,param:int):void
		{
			_sortBy=name;
			_sortParam=param;
		}*/
       /* public function render() : void
        {
            var step:uint;
            var total:uint = mChilds.length;
			if(enableSort)mChilds.sortOn(_sortBy,_sortParam);
            while (step< total)
            {
                mChilds[step].render();
				step++;
            }
			mFps.uints=Image.INSTANCE_NUM;
        }*/
        override public function getMatrix3D():Matrix3D
		{
			return null;
		}
    }
}
