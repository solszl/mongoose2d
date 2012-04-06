package mongoose.core
{
    import com.adobe.utils.*;
    
    import flash.display.Stage;
    import flash.display.Stage3D;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.display3D.Context3DBlendFactor;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DTriangleFace;
    import flash.events.*;
    
    import mongoose.display.*;
    import mongoose.geom.*;
    
    import tools.*;

    public class World extends DisplayObjectContainer
    {
        protected var mFullScreen:Boolean;
        protected var mPerspective:PerspectiveMatrix3D;
        protected var mStage3D:Stage3D;
        protected var mRect:Rectangle;
      
        public var scale:Number;
        protected var mCamera:Camera;
        protected var mFps:FrameRater;
        private static var STAGE_USED:uint = 0;
        public static var near:Number = 0.1;
        public static var far:Number = 10000;

        public function World(stage2D:Stage, viewPort:Rectangle)
        {
            stage = stage2D;
            world = this;
            mRect=viewPort;
            mPerspective = new PerspectiveMatrix3D();
            mCamera = new Camera();
            mCamera.active = true;
            mFps = new FrameRater(65280, true,false);
			
			super();
            this.initialize(stage, mRect);
          
        }// end function

        public function set fullScreen(mRect:Boolean) : void
        {
            this.mFullScreen = mRect;
            this.onResize();
            return;
        }// end function

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
                context3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, mPerspective, true);
            }
            scale = height / width;
            dispatchEvent(new Event(Event.CHANGE));
        }// end function

        public function addCamera(camera:Camera) : void
        {
            return;
        }// end function

        public function initialize(mRoot:Stage, viewPort:Rectangle) : void
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
            stage.addEventListener(Event.ENTER_FRAME, this.onRender);
			
            onResize();
            dispatchEvent(new Event(Event.COMPLETE));
			onRender();

        }// end function

        protected function onRender(VERTEX:Event=null) : void
        {
            context3d.clear();
            Camera.current.capture();
			context3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX,4,Camera.current.matrix,true);
            render();
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

        override public function addChild(object:DisplayObject) : void
        {
            super.addChild(object);
            mFps.uints = mChilds.length;
            
        }// end function

        override public function render() : void
        {
            var step:uint;
            var total:* = mChilds.length;
            while (step< total)
            {
                
                mChilds[step].render();
				step++;
            }
            return;
        }// end function

    }
}
