package mongoose.display
{
    import flash.events.*;
    import flash.geom.Matrix;
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    import flash.utils.Dictionary;
    
    import mongoose.core.Camera;

    public class InteractiveObject extends Image
    {
		public var mouseEnabled:Boolean=false;
		
		protected var mOrigin:Vector3D=new Vector3D;
		protected var mTarget:Vector3D=new Vector3D;
		protected var mDir:Vector3D;
        protected var enterFrameHandles:Array=[];
		protected var mouseClickEventHandles:Array=[];
		protected var mouseDownEventHandles:Array=[];
		protected var mouseOverEventHandles:Array=[];
		protected var mouseOutEventHandles:Array=[];
		protected var mouseMoveEventHandles:Array=[];
		
		private var _u:Number,_v:Number;
		
		internal var iOver:Boolean=false;
		private var _listen:Boolean;
		
		
		private var _mouseEnabled:Boolean;
		private var dx:Number,dy:Number;
		private var _passA:Boolean;
		private var _passB:Boolean;
		private var uu1:Number,
					uu2:Number,
					vv1:Number,
					vv2:Number;
		internal var iHit:Boolean;
		
		private var _triAnglePass:Boolean;
		private var _step:uint;
        public function InteractiveObject(texture:TextureData)
        {
			
			super(texture);
			
            
        }// end function
		
       
		/**
		 *注册handle之后,会在每次渲染之前执行。参照flash中的Event.ENTER_FRAME 
		 * @param handle
		 * 
		 */        
        /*public function addEventHandle(type:String,handle:Function):void
		{
			switch(type)
			{
				case MouseEvent.CLICK:
					
					addHandle(handle,mouseClickEventHandles);
					break;
				case MouseEvent.MOUSE_DOWN:
					addHandle(handle,mouseDownEventHandles);
					break;
				case MouseEvent.MOUSE_OVER:
					
					addHandle(handle,mouseOverEventHandles);
					break;
				case MouseEvent.MOUSE_OUT:
					
					addHandle(handle,mouseOutEventHandles);
					break;
				case MouseEvent.MOUSE_MOVE:
					
					addHandle(handle,mouseMoveEventHandles);
					break;
				case Event.ENTER_FRAME:
					addHandle(handle,enterFrameHandles);
					break;
				
			}
		}*/
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
					
					addHandle(listener,mouseOverEventHandles);
					break;
				case MouseEvent.MOUSE_OUT:
					
					addHandle(listener,mouseOutEventHandles);
					break;
				case MouseEvent.MOUSE_MOVE:
					
					addHandle(listener,mouseMoveEventHandles);
					break;
				case Event.ENTER_FRAME:
					addHandle(listener,enterFrameHandles);
					break;
				default:
					super.addEventListener(type,listener,useCapture,priority,useWeakReference);
					break;
			}
		}
		/*public function removeEventHandle(type:String,handle:Function):void
		{
			switch(type)
			{
				case MouseEvent.CLICK:
					removeHandle(handle,mouseClickEventHandles);
					break;
				case MouseEvent.MOUSE_DOWN:
					break;
				case Event.ENTER_FRAME:
					removeHandle(handle,enterFrameHandles);
					break;
			}
		}*/
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
				case Event.ENTER_FRAME:
					removeHandle(listener,enterFrameHandles);
					break;
				default:
					super.removeEventListener(type,listener,useCapture);
					break;
			}
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
			if(mouseOverEventHandles.length==0||
			   mouseOutEventHandles.length==0)
			return null;
			dx=(x*mWidthRecipDbl-1);
			dy=(1-y*mHeightRecipDbl)*world.scale;
			
			mOutMatrix.appendTranslation(-1, world.scale, 0);
			mOutMatrix.invert();
			
			mOrigin.x=dx*World.near;
			mOrigin.y=dy*World.near;
			mOrigin.z=World.near;

			mTarget.x=dx*World.far;
			mTarget.y=dy*World.far;
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
				_u=Math.max(uu1,uu2);
				_v=Math.max(vv1,vv2);
				_u=mTexture.uValue*_u+mTexture.uvVector[0];
				_v=mTexture.vValue*_v+mTexture.uvVector[1];
				var w:Number=this.mTexture.bitmapData.width;
				var h:Number=this.mTexture.bitmapData.height;
				var pixel:uint=this.mTexture.bitmapData.getPixel32(w*_u,h*_v);
				pixel>0?iHit=true:iHit=false;
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
			var pvec:Vector3D,tvec:Vector3D,qvec:Vector3D,det:Number;
			var t:Number,temp:Number,u:Number,v:Number;
			//----------------------------------------------------			
			
			pvec=mDir.crossProduct(edge2);
			det=edge1.dotProduct(pvec);
			if(det>0)
			{
				tvec=mOrigin.subtract(p0);
			}
			if(det<0)
			{
				tvec=p0.subtract(mOrigin);
				det=-det;
			}
			if(det<0.0001)
				_triAnglePass= false;
			u=tvec.dotProduct(pvec);
			if(u<0||u>det)
				_triAnglePass= false;
			qvec=tvec.crossProduct(edge1);
			v=mDir.dotProduct(qvec);
			if(v<0||u+v>det)
				_triAnglePass= false;
			t=edge2.dotProduct(qvec);
			temp=1/det;
			t*=temp;
			u*=temp;
			v*=temp;
			_u=u;
			_v=v;
			
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
