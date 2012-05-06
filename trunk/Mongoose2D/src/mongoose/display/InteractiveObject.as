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
		public var mouseEnabled:Boolean = true;
		
		protected var mOrigin:Vector3D=new Vector3D;
		protected var mTarget:Vector3D=new Vector3D;
		protected var mDir:Vector3D;
        protected var enterFrameHandles:Array=[];
		protected var clickEventHandles:Array=[];
		protected var mouseOverEventHandles:Array=[];
		protected var mouseOutEventHandles:Array=[];
		protected var mouseMoveEventHandles:Array=[];
        protected var mouseDownEventHandles:Array=[];
        protected var mouseUpEventHandles:Array=[];
        
		private var _u:Number,_v:Number;
		
		internal var iOver:Boolean=false;
		private var _listen:Boolean;
		private var _useMove:Boolean;
		private var _useOver:Boolean,_useOut:Boolean;
		private var _mouseEnabled:Boolean;
		internal var iHit:Boolean;
		internal var iHitObj:InteractiveObject;
        public function InteractiveObject(texture:TextureData)
        {
			
			super(texture);
			
            
        }// end function
		
       
		/**
		 *注册handle之后,会在每次渲染之前执行。参照flash中的Event.ENTER_FRAME 
		 * @param handle
		 * 
		 */        
        public function addEventHandle(type:String,handle:Function):void
		{
			switch(type)
			{
				case MouseEvent.CLICK:
					
					addHandle(handle,clickEventHandles);
					break;
				case MouseEvent.MOUSE_DOWN:
					break;
				case MouseEvent.MOUSE_OVER:
					_useOver=true;
					addHandle(handle,mouseOverEventHandles);
					break;
				case MouseEvent.MOUSE_OUT:
					_useOut=true;
					addHandle(handle,mouseOutEventHandles);
					break;
				case MouseEvent.MOUSE_MOVE:
					addHandle(handle,mouseMoveEventHandles);
					break;
                case MouseEvent.MOUSE_DOWN:
                    addHandle(handle,mouseDownEventHandles);
                    break;
                case MouseEvent.MOUSE_UP:
                    addHandle(handle,mouseUpEventHandles);
                    break;
				case Event.ENTER_FRAME:
					addHandle(handle,enterFrameHandles);
					break;
				
			}
		}
		public function removeEventHandle(type:String,handle:Function):void
		{
			switch(type)
			{
				case MouseEvent.CLICK:
					removeHandle(handle,clickEventHandles);
					break;
				case MouseEvent.MOUSE_DOWN:
                    removeHandle(handle,mouseDownEventHandles);
					break;
                case MouseEvent.MOUSE_UP:
                    removeHandle(handle,mouseUpEventHandles);
                    break;
				case Event.ENTER_FRAME:
					removeHandle(handle,enterFrameHandles);
					break;
			}
		}
		
		override protected function preRender():void
		{
			super.preRender();
			var step:uint,item:Object;
			var len:uint=enterFrameHandles.length;
			while(step<len)
			{
				enterFrameHandles[step](this);
				step++;
			}
		}
		internal function hitTest(type:String,x:Number,y:Number):Boolean
		{
			//trace(type,x,y)
			_useMove=_useOut||_useOut;
			if(type==MouseEvent.MOUSE_MOVE&&!_useMove)
			{
				//trace("over")
				return false;
			}
			iHit=false;	
			var dx:Number=(x*mFx-1);
			var dy:Number=(1-y*mFy)*world.scale;
			
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
			
			
			var a:Boolean=instric(v0,v1,v2);
			var u1:Number=_u,
				v1:Number=_v;
			var b:Boolean=instric(v0,v2,v3);
			var u2:Number=_u,
				v2:Number=_v;
			if(a||b)
			{
				_u=Math.max(u1,u2);
				_v=Math.max(v1,v2);
				_u=mTexture.uValue*_u+mTexture.uvVector[0];
				_v=mTexture.vValue*_v+mTexture.uvVector[1];
				var w:Number=this.mTexture.bitmapData.width;
				var h:Number=this.mTexture.bitmapData.height;
				var pixel:uint=this.mTexture.bitmapData.getPixel32(w*_u,h*_v);
				if(pixel>0)
				{
					iHit=true;
					return true;
				}
			}
			return false;
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
		
		protected function instric(p0:Vector3D,p1:Vector3D,p2:Vector3D):Boolean
		{
		    var pass:Boolean=true;
			var edge1:Vector3D,edge2:Vector3D;
			var pvec:Vector3D,tvec:Vector3D,qvec:Vector3D,det:Number;
			var t:Number,temp:Number,u:Number,v:Number;
			//----------------------------------------------------			
			edge1=p1.subtract(p0);
			edge2=p2.subtract(p0);
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
				pass= false;
			u=tvec.dotProduct(pvec);
			if(u<0||u>det)
				pass= false;
			qvec=tvec.crossProduct(edge1);
			v=mDir.dotProduct(qvec);
			if(v<0||u+v>det)
				pass= false;
			t=edge2.dotProduct(qvec);
			temp=1/det;
			t*=temp;
			u*=temp;
			v*=temp;
			_u=u;
			_v=v;
			
		    return pass;
		}
		internal function triggerEvent(type:String):void
		{
			var step:int;
			switch(type)
			{
				case MouseEvent.CLICK:
					step=0;
					while(step<clickEventHandles.length)
					{
						clickEventHandles[step](this);
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
					
					while(step<mouseMoveEventHandles.length)
					{
						mouseMoveEventHandles[step](this);
						step++;
					}
					
					break;
                case MouseEvent.MOUSE_DOWN:
                    step=0;
                    
                    while(step<mouseDownEventHandles.length)
                    {
                        mouseDownEventHandles[step](this);
                        step++;
                    }
                    
                    break;
                case MouseEvent.MOUSE_UP:
                    step=0;
                    
                    while(step<mouseUpEventHandles.length)
                    {
                        mouseUpEventHandles[step](this);
                        step++;
                    }
                    
                    break;
			}
		}
    }
}
