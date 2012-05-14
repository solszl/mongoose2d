package mongoose.display
{
    import flash.events.*;
    import flash.geom.Matrix;
    import flash.geom.Matrix3D;
    import flash.geom.Rectangle;
    import flash.geom.Vector3D;
    import flash.utils.Dictionary;
    
    import mongoose.core.Camera;
    [Event(name="mouseClick", type="flash.events.MouseEvent")]
	[Event(name="mouseOver", type="flash.events.MouseEvent")]
	[Event(name="mouseOut", type="flash.events.MouseEvent")]
	[Event(name="mouseDown", type="flash.events.MouseEvent")]
	[Event(name="mouseMove", type="flash.events.MouseEvent")]
    public class InteractiveObject extends Image
    {
		public var mouseEnabled:Boolean=true;
		
		protected var mOrigin:Vector3D=new Vector3D;
		protected var mTarget:Vector3D=new Vector3D;
		protected var mDir:Vector3D;
        protected var enterFrameHandles:Array=[];
		protected var mouseClickEventHandles:Array=[];
		protected var mouseDownEventHandles:Array=[];
		protected var mouseOverEventHandles:Array=[];
		protected var mouseOutEventHandles:Array=[];
		protected var mouseMoveEventHandles:Array=[];
		protected var touchTabEventhandles:Array=[];
		
		
		
		internal var iOver:Boolean=false;
		
		private var _u:Number,_v:Number;
		private var _mouseEnabled:Boolean;
		private var _dx:Number,_dy:Number;
		private var _passA:Boolean;
		private var _passB:Boolean;
		private var _xPos:Number,_yPos:Number,_pixel:uint;
		private var uu1:Number,
					uu2:Number,
					vv1:Number,
					vv2:Number;
					
		private var _pvec:Vector3D,
		            _tvec:Vector3D,
					_qvec:Vector3D,
					_det:Number;
		private var _t:Number,_temp:Number,_tu:Number,_tv:Number;			
					
		internal var iHit:Boolean;
		
		private var _triAnglePass:Boolean;
		private var _step:uint;
		internal var iuseMove:Boolean;
		public var alphaTest:Boolean=true;
		protected var mRectangle:Rectangle=new Rectangle;
        public function InteractiveObject(texture:TextureData)
        {
			
			super(texture);
			
            
        }// end function
		
       
		/**
		 *注册handle之后,会在每次渲染之前执行。参照flash中的Event.ENTER_FRAME 
		 * @param handle
		 * 
		 */        
       
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			switch(type)
			{
				case MouseEvent.CLICK:
					
					addHandle(listener,mouseClickEventHandles);
					break;
				case MouseEvent.MOUSE_DOWN:
					addHandle(listener,mouseDownEventHandles);
					break;
				case MouseEvent.MOUSE_OVER:
					iuseMove=true;
					addHandle(listener,mouseOverEventHandles);
					break;
				case MouseEvent.MOUSE_OUT:
					iuseMove=true;
					addHandle(listener,mouseOutEventHandles);
					break;
				case MouseEvent.MOUSE_MOVE:
					iuseMove=true;
					addHandle(listener,mouseMoveEventHandles);
					break;
				case Event.ENTER_FRAME:
					addHandle(listener,enterFrameHandles);
					break;
				case TouchEvent.TOUCH_TAP:
					addHandle(listener,touchTabEventhandles);
					break;
				default:
					super.addEventListener(type,listener,useCapture,priority,useWeakReference);
					break;
			}
		}
	
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			switch(type)
			{
				case MouseEvent.CLICK:
					removeHandle(listener,mouseClickEventHandles);
					break;
				case MouseEvent.MOUSE_DOWN:
					removeHandle(listener,mouseDownEventHandles);
					break;
				case MouseEvent.MOUSE_OUT:
					removeHandle(listener,mouseOutEventHandles);
					break;
				case MouseEvent.MOUSE_OVER:
					removeHandle(listener,mouseOverEventHandles);
					break;
				case MouseEvent.MOUSE_MOVE:
					removeHandle(listener,mouseMoveEventHandles);
					break;
				case Event.ENTER_FRAME:
					removeHandle(listener,enterFrameHandles);
					break;
				case TouchEvent.TOUCH_TAP:
					removeHandle(listener,touchTabEventhandles);
					break;
				default:
					super.removeEventListener(type,listener,useCapture);
					break;
			}
			if(mouseMoveEventHandles.length==0&&
			   mouseOutEventHandles.length==0&&
			   mouseOverEventHandles.length==0)
				iuseMove=false;
		}
		override protected function preRender():void
		{
			super.preRender();
			_step=0;
			
			while(_step<enterFrameHandles.length)
			{
				enterFrameHandles[_step](this);
				_step++;
			}
		}
		internal function hitTest(type:String,x:Number,y:Number):InteractiveObject
		{
			if(!mouseEnabled)return null;
			if(type==MouseEvent.MOUSE_MOVE&&!iuseMove)return null;
			
			_dx=(x*mWidthRecipDbl-1);
			_dy=(1-y*mHeightRecipDbl)*world.scale;
			
			
			
			mOutMatrix.append(Camera.current.matrix);
			mOutMatrix.invert();
			
			mOrigin.x=_dx*World.near;
			mOrigin.y=_dy*World.near;
			mOrigin.z=World.near;

			mTarget.x=_dx*World.far;
			mTarget.y=_dy*World.far;
			mTarget.z=World.far;
			
			
			
			mOrigin=mOutMatrix.transformVector(mOrigin);
			//trace(p2)
			mTarget=mOutMatrix.transformVector(mTarget);
			//trace(orig)
			mDir=mTarget.subtract(mOrigin);
			
			
			_passA=instric(v0,edge1,edge2);
			uu1=_u,
			vv1=_v;
			_passB=instric(v0,edge2,edge3);
			uu2=_u,
			vv2=_v;
			if(_passA||_passB)
			{
				if(alphaTest)
				{
					_u=Math.max(uu1,uu2);
					_v=Math.max(vv1,vv2);
					_u=mTexture.uValue*_u+mTexture.uvVector[0];
					_v=mTexture.vValue*_v+mTexture.uvVector[1];
					_xPos=this.mTexture.bitmapData.width;
					_yPos=this.mTexture.bitmapData.height;
					_pixel=this.mTexture.bitmapData.getPixel32(_xPos*_u,_yPos*_v);
					_pixel>0?iHit=true:iHit=false;
				}
				else
				{
					iHit=true;
				}
				
			}
			else
			{
				iHit=false;
			}
			if(iHit)
			{
				
				return this;
			}
			else
			{
				if(iOver==true)
				{
					triggerEvent(MouseEvent.MOUSE_OUT);
					iOver=false;
				}
				return null;
			}
		}
		
		private function addHandle(handle:Function,handles:Array):void
		{
			var step:uint=0;
			while(step<handles.length)
			{
				if(handles[step]==handle)
					return;
				step++;
			}
			handles.push(handle);
		}
		private function removeHandle(handle:Function,handles:Array):void
		{
			var step:uint=0;
			while(step<handles.length)
			{
				if(handles[step]==handle)
				{
					handles.splice(step,1);
					return;
				}
				step++;
			}
		}
		
		protected function instric(p0:Vector3D,edge1:Vector3D,edge2:Vector3D):Boolean
		{
			_triAnglePass=true;
			//var edge1:Vector3D,edge2:Vector3D;
			
			//----------------------------------------------------			
			
			_pvec=mDir.crossProduct(edge2);
			_det=edge1.dotProduct(_pvec);
			if(_det>0)
			{
				_tvec=mOrigin.subtract(p0);
			}
			if(_det<0)
			{
				_tvec=p0.subtract(mOrigin);
				_det=-_det;
			}
			if(_det<0.0001)
				_triAnglePass= false;
			_tu=_tvec.dotProduct(_pvec);
			if(_tu<0||_tu>_det)
				_triAnglePass= false;
			_qvec=_tvec.crossProduct(edge1);
			_tv=mDir.dotProduct(_qvec);
			if(_tv<0||_tu+_tv>_det)
				_triAnglePass= false;
			_t=edge2.dotProduct(_qvec);
			_temp=1/_det;
			_t*=_temp;
			_tu*=_temp;
			_tv*=_temp;
			_u=_tu;
			_v=_tv;
			
		    return _triAnglePass;
		}
		internal function triggerEvent(type:String,last:InteractiveObject=null):void
		{
			var step:int;
			switch(type)
			{
				case MouseEvent.MOUSE_DOWN:
					step=0;
					while(step<mouseDownEventHandles.length)
					{
						mouseDownEventHandles[step](this);
						step++;
					}
					break;
				case MouseEvent.CLICK:
					step=0;
					while(step<mouseClickEventHandles.length)
					{
						mouseClickEventHandles[step](this);
						step++;
					}
					break;
				case MouseEvent.MOUSE_OVER:
					step=0;
					if(iOver==false)
					{
						while(step<mouseOverEventHandles.length)
						{
							mouseOverEventHandles[step](this);
							step++;
						}
						iOver=true;
					}
					
					break;
				case MouseEvent.MOUSE_OUT:
					step=0;
					if(iOver==true)
					{
						while(step<mouseOutEventHandles.length)
						{
							mouseOutEventHandles[step](this);
							step++;
						}
						iOver=false;
					}
					break;
				case TouchEvent.TOUCH_TAP:
					step=0;
					while(step<touchTabEventhandles.length)
					{
						touchTabEventhandles[step](this);
						step++;
					}
					
					break;
				case MouseEvent.MOUSE_MOVE:
					step=0;
					
					if(iOver==false&&iHit)
					{
						triggerEvent(MouseEvent.MOUSE_OVER);
						iOver=true;
					};
					while(step<mouseMoveEventHandles.length)
					{
						mouseMoveEventHandles[step](this);
						step++;
					}
					break;
			}
		}
    }
}
