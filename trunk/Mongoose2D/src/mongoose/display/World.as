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
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.ui.Multitouch;
    import flash.ui.MultitouchInputMode;
    
    import mongoose.core.Camera;
    import mongoose.geom.*;
    import mongoose.tools.*;

    [Event(name="complete", type="flash.events.Event")]
	[Event(name="change", type="flash.events.Event")]
    public class World extends EventDispatcher
    {
		
        
        public var perspective:PerspectiveMatrix3D;
        protected var mStage3D:Stage3D;
        protected var mRect:MRectangle;
		protected var mCamera:Camera;
		protected var mFps:FrameRater;
		protected var mChilds:Array;
		protected var mViewAngle:Number;
		protected var hitObj:InteractiveObject;
		protected var mFullScreen:Boolean;
		public var lights:Vector.<Number>=new Vector.<Number>(8);
        private static var STAGE_USED:uint = 0;
		
        public static var near:Number = 0.1;
        public static var far:Number = 10000;
        public var stage:Stage;
		static public var SCALE:Number;
		public var width:Number,height:Number;
		public var context3d:Context3D;
		public var x:Number=0,y:Number=0;
		static public var WIDTH_RECIP:Number;
		static public var HEIGHT_RECIP:Number;
		static public var Z_SCALE:Number;
		
		private var _sortBy:String="depth";
		private var _sortParam:int=Array.NUMERIC | Array.DESCENDING;
		public var enableSort:Boolean;
		private var _x:Number=0,_y:Number=0,_isMove:Boolean;
		private var _prevObj:InteractiveObject;
		private var _click:Boolean;
		private var _lock:Boolean;
		
		private var _obj:InteractiveObject;
		private var _last:InteractiveObject;
		private var _step:uint;
		public var worldScaleMatrix:Matrix3D;
        public function World(stage2D:Stage, viewPort:MRectangle)
        {
            stage = stage2D;
			/*_debugText=new flash.text.TextField;
			_debugText.textColor=0x99cc00;
			_debugText.text="wagaa";
			_debugText.autoSize=TextFieldAutoSize.LEFT;
			_debugText.y=22;
			stage.addChild(_debugText);*/
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
			worldScaleMatrix=new Matrix3D;
			
			
			
			
			Camera.stage=stage;
            mCamera = new Camera();
            mCamera.active = true;
            mFps = new FrameRater(65280, true,false);
			mChilds=[];
			Z_SCALE=1 / (far - near)
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
				SCALE = height / width;
				WIDTH_RECIP=2/width;
				HEIGHT_RECIP=2/height*SCALE;
				
				mViewAngle = Math.atan(height / width) * 2;
                perspective.perspectiveFieldOfViewLH(mViewAngle, width/height, near, far);
                context3d.configureBackBuffer(width, height, 8, false);
				
				worldScaleMatrix.identity();
				worldScaleMatrix.appendScale(2/width,2/height*SCALE,World.Z_SCALE);
				worldScaleMatrix.appendTranslation(-1, height/width, 1);
				
				context3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, worldScaleMatrix, true);
				
                context3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, perspective, true);
            }
           
			
			
            dispatchEvent(new Event(Event.CHANGE));
        }
        public function removeChild(obj:DisplayObject):void
		{
			
			var step:uint=0;
			while(step<mChilds.length)
			{
				var r:Boolean=mChilds[step]==obj;
				if(r)
				{
					mChilds.splice(step,1);
					
					return;
				}
				step++;
			}
			
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
			mViewAngle = Math.atan(stage.stageHeight / stage.stageWidth) * 2;
            perspective.perspectiveFieldOfViewLH(mViewAngle, width / height, near, far);
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
			
            context3d.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			context3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT,0,lights);
            TextureData.context3d = context3d;
			BaseObject.stage=stage;
			BaseObject.world=this;
			BaseObject.context3d=context3d;
            stage.addEventListener(Event.ENTER_FRAME, this.onRender);
			stage.addEventListener(MouseEvent.MOUSE_DOWN,onStageClick);
            stage.addEventListener(MouseEvent.MOUSE_UP,onStageClick);
			stage.addEventListener(MouseEvent.MOUSE_MOVE,onStageMove);
			stage.addEventListener(TouchEvent.TOUCH_TAP,onTabTouch);
			stage.addEventListener(TouchEvent.TOUCH_BEGIN,onTabTouch);
			Multitouch.inputMode=MultitouchInputMode.TOUCH_POINT;
			
            onResize();
            dispatchEvent(new Event(Event.COMPLETE));
			onRender();

        }
		private function onTabTouch(e:TouchEvent):void
		{
			
			hitTest(TouchEvent.TOUCH_TAP,e.stageX,e.stageY);
		}
		private function onStageClick(e:MouseEvent):void
		{
            if(e.type == 'mouseDown')
            {
			    _click=true;
            }
			hitTest(e.type,e.stageX,e.stageY);
			
		}
		private function onStageMove(e:MouseEvent):void
		{
			
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
		
		}
		internal function hitTest(type:String,x:Number,y:Number):void
		{
			_step=0;
			_last=null;
			while(_step<mChilds.length)
			{
				
				_obj=mChilds[_step] as InteractiveObject;
				
				if(_obj!=null)
				{
					
					_obj=_obj.hitTest(type,x,y);
					if(_obj!=null)
					{
						
						_last=_obj;
						
					}
				}
				_step++;
			}
			if(_prevObj!=null&&_prevObj!=_last)
			{
				_prevObj.triggerEvent(MouseEvent.MOUSE_OUT);
				_prevObj=null;
			}
			if(_last!=null)
			{
				_last.triggerEvent(type);
				_prevObj=_last;
			}
			
		}
        protected function onRender(VERTEX:Event=null) : void
        {
            context3d.clear();
            Camera.current.capture();
			//context3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX,0,Camera.current.matrix,true);
			
			if(!_click)
			{
				//hitTest(MouseEvent.MOUSE_MOVE,_x,_y);
				
			}
			_click=false;
			
			render();
			
			if(Image.BATCH_INDEX>0)
			{
				
				context3d.drawTriangles(Image.CURRENT_INDEX_BUFFER,0,Image.BATCH_INDEX*2);
				Image.BATCH_INDEX=0;
			}
            context3d.present();
        }
        public function set showFps(value:Boolean):void
		{
			if (value)
			{
				stage.addChild(mFps);
			}
			else if (stage.contains(mFps))
			{
				stage.removeChild(mFps);
			}
		}
       
		/**
		 *添加一个显示对象 
		 * @param object 显示对象
		 * 
		 */        
        public function addChild(object:DisplayObject) : void
        {
            mChilds.push(object);
        }
		/**
		 *制定排序索引，参考Array.sortOn ,默认Z排序
		 * @param name 索引名称
		 * @param param 排序参数
		 * 
		 */        
		public function sortOn(name:String,param:int):void
		{
			_sortBy=name;
			_sortParam=param;
		}
        public function render() : void
        {
           _step=0;
           
			if(enableSort)mChilds.sortOn(_sortBy,_sortParam);
            while (_step< mChilds.length)
            {
				
                mChilds[_step].render();
				_step++;
            }
			
			mFps.uints=DisplayObject.INSTANCE_NUM;
        }
        public function getMatrix3D():Matrix3D
		{
			return null;
		}
    }
}
