package mongoose.core
{
    import com.adobe.utils.*;
    
    import flash.display.Stage;
    import flash.display.Stage3D;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DBlendFactor;
    import flash.display3D.Context3DClearMask;
    import flash.display3D.Context3DCompareMode;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DStencilAction;
    import flash.display3D.Context3DTriangleFace;
    import flash.events.*;
    import flash.geom.Matrix3D;
    
    import mongoose.display.*;
    import mongoose.geom.*;
    
    import tools.*;

    public class World extends EventDispatcher
    {
        protected var mFullScreen:Boolean;
        protected var mPerspective:PerspectiveMatrix3D;
        protected var mStage3D:Stage3D;
        protected var mRect:MRectangle;
      
        public var scale:Number;
        protected var mCamera:Camera;
        protected var mFps:FrameRater;
        private static var STAGE_USED:uint = 0;
        public static var near:Number = 0.1;
        public static var far:Number = 10000;
        public var stage:Stage;
		
		public var width:Number,height:Number;
		public var context3d:Context3D;
		public var x:Number=0,y:Number=0;
		protected var mChilds:Vector.<DisplayObject>;
        
        public function World(stage2D:Stage, viewPort:MRectangle)
        {
            stage = stage2D;
           
            mRect=viewPort;
            mPerspective = new PerspectiveMatrix3D();
			Camera.stage=stage;
            mCamera = new Camera();
            mCamera.active = true;
            mFps = new FrameRater(65280, true,false);
			mChilds=new Vector.<DisplayObject>;
            this.initialize(stage, mRect);
          
        }
       
        public function set fullScreen(mRect:Boolean) : void
        {
            this.mFullScreen = mRect;
            this.onResize();
            return;
        }

        private function onResize(VERTEX:Event = null) : void
        {
            var ra:Number;
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
                ra = Math.atan(height / width) * 2;
                mPerspective.perspectiveFieldOfViewLH(ra, width / height, near, far);
                context3d.configureBackBuffer(width, height, 0, false);
				//context3d.setDepthTest(true,Context3DCompareMode.LESS_EQUAL);
				context3d.setStencilActions(Context3DTriangleFace.FRONT,Context3DCompareMode.LESS_EQUAL);
				//context3d.setStencilReferenceValue(Context3DStencilAction.
                context3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, mPerspective, true);
            }
            scale = height / width;
			
            dispatchEvent(new Event(Event.CHANGE));
        }

        public function addCamera(camera:Camera) : void
        {
            return;
        }

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
            var ra:Number = Math.atan(stage.stageHeight / stage.stageWidth) * 2;
            mPerspective.perspectiveFieldOfViewLH(ra, width / height, near, far);
            
            stage.addEventListener(Event.RESIZE, onResize);
        }

        public function start() : void
        {
            mStage3D = stage.stage3Ds[STAGE_USED];
            mStage3D.addEventListener(Event.CONTEXT3D_CREATE, this.onCreate);
            mStage3D.requestContext3D();
            STAGE_USED++;

        }

        protected function onCreate(VERTEX:Event) : void
        {
            context3d = mStage3D.context3D;
            context3d.enableErrorChecking = true;
            context3d.configureBackBuffer(width, height, 0, false);
            context3d.setCulling(Context3DTriangleFace.NONE);
			//context3d.setDepthTest(false,Context3DCompareMode.LESS_EQUAL);
			//context3d.setStencilReferenceValue(Context3DClearMask.DEPTH,100,200);
            context3d.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
            TextureData.context3d = context3d;
			BaseObject.stage=stage;
			BaseObject.world=this;
			BaseObject.context3d=context3d;
            stage.addEventListener(Event.ENTER_FRAME, this.onRender);
			
			_initMouseListener(stage);
			
            onResize();
            dispatchEvent(new Event(Event.COMPLETE));
			onRender();

        }

        protected function onRender(VERTEX:Event=null) : void
        {
            context3d.clear();
            Camera.current.capture();
			context3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX,0,Camera.current.matrix,true);
            render();
            
            context3d.present();
        }

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
        }

        public function addChild(object:DisplayObject) : void
        {
			Image.INSTANCE_NUM++;
            mChilds.push(object);
        }
        
		
        public function render() : void
        {
            var step:uint;
            var total:uint = mChilds.length;
            while (step< total)
            {
                mChilds[step].render();
				step++;
            }
			mFps.uints=Image.INSTANCE_NUM;
        }
		
        public function getMatrix3D():Matrix3D
		{
			return null;
		}
		
		protected function _initMouseListener( root:Stage ):void
		{
			if (root)
			{
				root.addEventListener(MouseEvent.CLICK, _mouseEventHandler);
				root.addEventListener(MouseEvent.MOUSE_DOWN, _mouseEventHandler);
				//				root.addEventListener(MouseEvent.MOUSE_MOVE, _mouseEventHandler);
				root.addEventListener(MouseEvent.MOUSE_UP, _mouseEventHandler);
			}
		}
		
		protected function _removeMouseListener( root:Stage ):void
		{
			if (root)
			{
				root.removeEventListener(MouseEvent.CLICK, _mouseEventHandler);
				root.removeEventListener(MouseEvent.MOUSE_DOWN, _mouseEventHandler);
				root.addEventListener(MouseEvent.MOUSE_MOVE, _mouseEventHandler);
				root.removeEventListener(MouseEvent.MOUSE_UP, _mouseEventHandler);
			}
		}
		
		protected function _mouseEventHandler(evt:MouseEvent):void
		{
			var i:int;
			var len:uint= mChilds.length;
            var child:DisplayObject;
			while (i < len)
			{
                child = mChilds[i];
                if(child is InteractiveObject)
				    InteractiveObject(child).triggerMouseEvent(evt);
				i++;
			}
		}
    }
}
