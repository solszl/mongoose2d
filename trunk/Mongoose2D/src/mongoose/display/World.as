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
    
    import mongoose.core.Camera;
    import mongoose.geom.*;
    import mongoose.tools.*;

    public class World extends EventDispatcher
    {
        protected var mFullScreen:Boolean;
        public var perspective:PerspectiveMatrix3D;
        protected var mStage3D:Stage3D;
        protected var mRect:MRectangle;
		protected var mCamera:Camera;
		protected var mFps:FrameRater;
		protected var mChilds:Array;
        
		public var lights:Vector.<Number>=new Vector.<Number>(8);
        private static var STAGE_USED:uint = 0;
		
        public static var near:Number = 0.1;
        public static var far:Number = 10000;
        public var stage:Stage;
		public var scale:Number;
		public var width:Number,height:Number;
		public var context3d:Context3D;
		public var x:Number=0,y:Number=0;
	
		protected var mViewAngle:Number;
		protected var hitObj:InteractiveObject;
		
		private var _sortBy:String="z";
		private var _sortParam:int=Array.DESCENDING|Array.NUMERIC;
		public var enableSort:Boolean;
		private var _x:Number=0,_y:Number=0,_isMove:Boolean;
		private var _prevObj:InteractiveObject;
        public function World(stage2D:Stage, viewPort:MRectangle)
        {
            stage = stage2D;
           
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
          
        }// end function
       
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
			context3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT,0,lights);
            TextureData.context3d = context3d;
			BaseObject.stage=stage;
			BaseObject.world=this;
			BaseObject.context3d=context3d;
            stage.addEventListener(Event.ENTER_FRAME, this.onRender);
			stage.addEventListener(MouseEvent.CLICK,onStageClick);
			stage.addEventListener(MouseEvent.MOUSE_MOVE,onStageMove);
            onResize();
            dispatchEvent(new Event(Event.COMPLETE));
			onRender();

        }// end function
		private function onStageClick(e:MouseEvent):void
		{
			hitTest(e.type,e.stageX,e.stageY);
		}
		private function onStageMove(e:MouseEvent):void
		{
			//trace(_x,e.stageX,_y,e.stageY)
			if(_x!=e.stageX||_y!=e.stageY)
			{
				_isMove=true;
				
				_x=e.stageX;
				_y=e.stageY;
			}
			else
			{
				_isMove=false;
			}
			//trace("_--------------------",_isMove)
			
		}
        private function hitTest(type:String,x:Number,y:Number):void
		{
			var step:uint=0;
			var obj:InteractiveObject,oop:InteractiveObject;
			var hit:InteractiveObject;
			
			while(step<mChilds.length)
			{
				obj=mChilds[step] as InteractiveObject;
				if(obj!=null)
				{
					
					var re:Boolean=obj.hitTest(type,x,y);
					//if(obj!=null&&prevObj!=null&&type==MouseEvent.MOUSE_MOVE)prevObj.triggerEvent(MouseEvent.MOUSE_OUT);
					if(re)hit=obj.iHitObj;
					
					
				}
				step++;
			}
			//trace(_prevObj,_prevObj!=hit)
			if(_prevObj!=hit&&_prevObj!=null)
			{
				//trace(_prevObj.iHit)
				//if(_prevObj.iHit==false)
					_prevObj.triggerEvent(MouseEvent.MOUSE_OUT);
				
			}
			if(hit!=null)
			{
				_prevObj=hit;
				if(type==MouseEvent.CLICK||type==MouseEvent.MOUSE_DOWN)hit.triggerEvent(type);
				else
					hit.triggerEvent(MouseEvent.MOUSE_OVER);
			};	
		}
        protected function onRender(VERTEX:Event=null) : void
        {
            context3d.clear();
            Camera.current.capture();
			context3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX,0,Camera.current.matrix,true);
			if(_isMove)
			{
				hitTest(MouseEvent.MOUSE_MOVE,_x,_y);
				//trace("test",_isMove);
				_isMove=false;
				
			}
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

        public function addChild(object:DisplayObject) : void
        {
			
            mChilds.push(object);
        }// end function
        
		public function sortOn(name:String,param:int):void
		{
			_sortBy=name;
			_sortParam=param;
		}
        public function render() : void
        {
            var step:uint;
            var total:uint = mChilds.length;
			if(enableSort)mChilds.sortOn(["depth"],Array.NUMERIC | Array.DESCENDING);
            while (step< total)
            {
				//trace(mChilds[step].z);
                mChilds[step].render();
				step++;
            }
			//trace("over")
			mFps.uints=DisplayObject.INSTANCE_NUM;
        }// end function
        public function getMatrix3D():Matrix3D
		{
			return null;
		}
    }
}
