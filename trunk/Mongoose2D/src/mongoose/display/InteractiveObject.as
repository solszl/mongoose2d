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
		public var mouseEnabled:Boolean=true;
		protected var mOrigin:Vector3D=new Vector3D;
		protected var mTarget:Vector3D=new Vector3D;
		protected var mDir:Vector3D;
        protected var enterHandle:Array=[];
		protected var clickEventHandle:Array=[];
		protected var mouseOverEventHandle:Array=[];
		protected var mouseMoveEventHandle:Array=[];
		
		private var _u:Number,_v:Number;
        public function InteractiveObject(texture:TextureData)
        {
			super(texture)
            
        }// end function
        
       
        public function enterFrameEvent(handle:Function):void
		{
			enterHandle.push(handle);
		}
		public function removeFrameEvent(name:String,handle:Function):void
		{
			
		}
		override protected function preRender():void
		{
			super.preRender();
			var step:uint,item:Object;
			var len:uint=enterHandle.length;
			while(step<len)
			{
				enterHandle[step](this);
				step++;
			}
		}
		internal function onMouseEvent(type:String,x:Number,y:Number,view:Number):Boolean
		{
			//var pass:Boolean=true;
			//trace(this,"event:"+type,x,y,view)
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
					return true
				}
				else
					return false;
				//trace(_u,_v,pixel.toString(16));
			}
			return false
		}
		public function addClickEvent(handle:Function):void
		{
			clickEventHandle.push(handle);
		}
		public function addMouseOverEvent(handle:Function):void
		{
			mouseOverEventHandle.push(handle);
		}
		public function addMouseMoveEvent(handle:Function):void
		{
			mouseMoveEventHandle.push(handle);
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
				case "click":
					step=0;
					while(step<clickEventHandle.length)
					{
						clickEventHandle[step](this);
						step++;
					}
					break;
				case "mouseOver":
					step=0;
					while(step<mouseOverEventHandle.length)
					{
						mouseOverEventHandle[step](this);
						step++;
					}
					break;
				case "mouseMove":
					step=0;
					while(step<mouseMoveEventHandle.length)
					{
						mouseMoveEventHandle[step](this);
						step++;
					}
					break;
				
			}
		}
    }
}
