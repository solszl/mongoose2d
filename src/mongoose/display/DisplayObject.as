package mongoose.display
{
    import com.adobe.utils.AGALMiniAssembler;
    
    import flash.display3D.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.utils.ByteArray;
    
    import mongoose.core.*;
    import mongoose.geom.RemMatrix3D;

    public class DisplayObject extends BaseObject
    {
		static public var INSTANCE_NUM:uint;
		
		public var depth:Number;
		public var visible:Boolean=true;
        public var scaleX:Number = 1;
        public var scaleY:Number = 1;
        public var scaleZ:Number = 1;
        public var parent:DisplayObjectContainer;
        public var color:Number = 0xffffff;
        public var alpha:Number = 1;
        public var width:Number = 0;
        public var height:Number = 0;
		
        public var rotateX:Number = 0;
        public var rotateY:Number = 0;
        public var rotateZ:Number = 0;
		
		internal var r:Number,g:Number,b:Number;
       
		protected var mPivot:Vector3D;
		protected var mMatrix3D:Matrix3D;
		protected var mMyMatrix:Matrix3D;
        protected var mParent:DisplayObject;
        protected var mProgram3d:Program3D;
        protected var mOriginWidth:Number = 0;
        protected var mOriginHeight:Number = 0;
      
		protected var mConstrants:Vector.<Number>;
        protected var mBaseMtx:Matrix3D;
        protected var mOutMatrix:Matrix3D;
		protected var mParentMatrix3D:Matrix3D
		
		
		//旋转注册cache
        private var _rotPivot:Vector3D;
		//临时计算cache
		private var _r1:Number;
        private var _r2:Number;
        protected var mFx:Number;
        protected var mFy:Number;
        private var _fz:Number;
		//位置cache
		private var _mx:Number=0,
			        _my:Number=0,
					_mz:Number=0;
		
		//尺寸缩放cache
		protected var mSx:Number=0,mSy:Number=0;
		//直接缩放cache
		private var _sx:Number=1,_sy:Number=1;
        private var _changed:Boolean = true;
        //旋转cache
        private var _rx:Number=0,
			        _ry:Number=0,
					_rz:Number=0;
		
		private var _color:uint;
		private var _alpha:Number;
		private var _colTem:Number=1/255;
		private var _depth:Number;
		
		
        public function DisplayObject()
        {
			id=INSTANCE_NUM++;
			_depth=.00001/id;
            _rotPivot = new Vector3D(0, 0, 1);
			mPivot=new Vector3D(0,0,0);
            mBaseMtx = new Matrix3D();
            mMatrix3D = new Matrix3D();
			mMyMatrix =new Matrix3D;
            mOutMatrix = new Matrix3D();
			mConstrants=new Vector.<Number>(8);
			mConstrants[4]=1;
			mConstrants[5]=1;
			mConstrants[6]=1;
			mConstrants[7]=1;
        }
		
        override protected function preRender() : void
        {
			depth=z+_depth;
			var col:uint=color-_color;
			_color=color;
			_alpha=alpha;
			if(col!=0)
			{
				r=mConstrants[4]=(color>>16)*_colTem;
				g=mConstrants[5]=(color>>8&0xff)*_colTem;
				b=mConstrants[6]=(color&0xff)*_colTem;
			}
			mConstrants[7]=alpha;
        }
		/**
		 *设置显示对象的注册点 
		 * @param x
		 * @param y
		 * @param z
		 * 
		 */		
		public function setRegisterPoint(x:Number,y:Number,z:Number):void
		{
			mPivot.x=x;
			mPivot.y=y;
			mPivot.z=z;
			init();
		}
        protected function init():void
		{
			mBaseMtx.identity();
			mMatrix3D.identity();
			mBaseMtx.prependTranslation(mPivot.x,mPivot.y,mPivot.z);
			_mx=_my=_mz=0;
			
			mSx=mOriginWidth;
			mSy=mOriginHeight;
			_sx=_sy=1;
			_mx=_my=_mz=0;
			_rx=_ry=_rz=0;
			_rotPivot.x=0;
			_rotPivot.y=0;
			_rotPivot.z=1;
			
			_r1 = 1 / world.width;
			_r2 = 1 / world.height;
			mFx = _r1 * 2;
			mFy = _r2 * 2;
			_fz = 1 / (World.far - World.near);
			//----------------------原始缩放计算----------------------
			
			if(mOriginWidth!=0)
			{
				var tx:Number=mOriginWidth*mFx;
				
				mBaseMtx.appendScale(tx,1,1);
				//trace("原始缩放x")
			}	
			if(mOriginHeight!=0)
			{
				var ty:Number=mOriginHeight*mFy*world.scale;
				mBaseMtx.appendScale(1,ty, 1);
				//trace("原始缩放y")
			}  
			
		}
        protected function composeMatrix() : void
        {
            mOutMatrix.identity();
			
			var tx:Number,ty:Number,tz:Number;
			
			//------------------------尺寸缩放计算------------------------------
			tx=width-mSx;
			ty=height-mSy;
			
			
			if(tx!=0)
			{
				var ttx:Number=width/mSx;
				
				mMatrix3D.prependScale(ttx,1, 1);
				mSx=width;
				
				//trace("尺寸缩放x")
			}	
			if(ty!=0)
			{
				var tty:Number=height/mSy;
				mMatrix3D.prependScale(1,tty, 1);
				//trace("尺寸缩放y")
				mSy=height;
			}  
			//-----------------------直接缩放------------------------------------
			tx=scaleX-_sx;
			ty=scaleY-_sy;
			_sx=scaleX;
			_sy=scaleY;
			if(tx!=0)
			{
				mMatrix3D.prependScale(tx+1,1, 1);
				//trace("直接缩放x")
			}	
			if(ty!=0)
			{
				mMatrix3D.prependScale(1,ty+1, 1);
				//trace("直接缩放y")
			}  
			//--------------------------------------------------------
			tx=rotateX-_rx;
			ty=rotateY-_ry;
			tz=rotateZ-_rz;
			
			_rx=rotateX;
			_ry=rotateY;
			_rz=rotateZ;
			
			if(tx!=0)
			{
				mMatrix3D.appendRotation(tx, Vector3D.X_AXIS, _rotPivot);
				//trace("旋转x")
			}
			if(ty!=0)
			{
				mMatrix3D.appendRotation(ty, Vector3D.Y_AXIS, _rotPivot);
				//trace("旋转y")
			}
			if(tz!=0)
			{
				mMatrix3D.appendRotation(tz, Vector3D.Z_AXIS, _rotPivot);
				//trace("旋转z")
			}
			
			
			//---------------------------------------------------------------
			tx=x-_mx;
			ty=y-_my;
			tz=z-_mz;
			_mx=x;
			_my=y;
			_mz=z;
			if(tx!=0)
			{
				tx=tx*mFx;
				mMatrix3D.appendTranslation(tx,0, 0);
				_rotPivot.x+=tx;
				//trace("位移x")
			}	
			if(ty!=0)
			{
				ty=ty*mFy*world.scale;
				mMatrix3D.appendTranslation(0,-ty, 0);
				_rotPivot.y-=ty;
				//trace("位移y")
			}  
			if(tz!=0)
			{
				tz=tz*_fz;
				mMatrix3D.appendTranslation(0,0, tz);
				_rotPivot.z+=tz;
				//trace("位移z")
			} 
			
            mOutMatrix.append(mBaseMtx);
            mOutMatrix.append(mMatrix3D);
            if (parent != null)
            {
				//this.alpha=_alpha*parent.alpha;
				mConstrants[4]=r*parent.r;
				mConstrants[5]=g*parent.g;
				mConstrants[6]=b*parent.b;
				mConstrants[7]=alpha*parent.alpha;
                mParentMatrix3D=parent.getMatrix3D();
				if(mParentMatrix3D!=null)
				    mOutMatrix.append(mParentMatrix3D);
            }
			else
			{
				this.alpha=_alpha;
				//mConstrants[7]=this.alpha;
			}
        }// end function
        public function getMatrix3D():Matrix3D
		{
			mMyMatrix.identity();
			mMyMatrix.append(mMatrix3D);
			if(mParentMatrix3D!=null)
			     mMyMatrix.append(mParentMatrix3D);
			return mMyMatrix;
		}
        public function render() : void
        {
            preRender();
            composeMatrix();
            draw();
        }// end function

        protected function draw() : void
        {
            
        }// end function

    }
}
