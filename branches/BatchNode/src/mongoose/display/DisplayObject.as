package mongoose.display
{
    import flash.display3D.*;
    import flash.events.*;
    import flash.geom.*;
    
    import mongoose.core.*;

    public class DisplayObject extends BaseObject
    {
		
        public var scaleX:Number = 1;
        public var scaleY:Number = 1;
        public var scaleZ:Number = 1;
        public var parent:DisplayObjectContainer;
        public var color:Number = 0xffffff;
        public var alpha:Number = 1;
        public var width:Number = 0;
        public var height:Number = 0;
		public var pivot:Vector3D;
        public var rotateX:Number = 0;
        public var rotateY:Number = 0;
        public var rotateZ:Number = 0;
       
		protected var mMatrix3D:Matrix3D;
		protected var mMyMatrix:Matrix3D;
        protected var mParent:DisplayObject;
        protected var mProgram3d:Program3D;
        protected var mOriginWidth:Number = 0;
        protected var mOriginHeight:Number = 0;
        protected var mColorData:Vector.<Number>;
        protected var mBaseMtx:Matrix3D;
        protected var mOutMatrix:Matrix3D;
		protected var mParentMatrix3D:Matrix3D
		
		
		//旋转注册cache
        private var _rotPivot:Vector3D;
		//临时计算cache
		private var _r1:Number;
        private var _r2:Number;
        private var _fx:Number;
        private var _fy:Number;
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
		private var _alpha:uint;
		private var _colTem:Number=1/255;
        public function DisplayObject()
        {
           
            _rotPivot = new Vector3D(0, 0, 1);
			pivot=new Vector3D(-.5,.5,0);
			
            mBaseMtx = new Matrix3D();
            mMatrix3D = new Matrix3D();
			mMyMatrix =new Matrix3D;
			
            mOutMatrix = new Matrix3D();
            mColorData = new Vector.<Number>;
            mColorData.push(1,1,1,1);
      
			
        }// end function

        
        override protected function preRender() : void
        {
			var col:uint=color-_color;
			_color=color;
			if(col!=0)
			{
				mColorData[0]=(color>>16)*_colTem;
				mColorData[1]=(color>>8&0xff)*_colTem;
				mColorData[2]=(color&0xff)*_colTem;
			}
			mColorData[3]=alpha;
        }// end function
        protected function init():void
		{
			mBaseMtx.identity();
			mMatrix3D.identity();
			mBaseMtx.prependTranslation(pivot.x,pivot.y,pivot.z);
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
			_fx = _r1 * 2;
			_fy = _r2 * 2 * world.scale;
			_fz = 1 / (World.far - World.near);
			//----------------------原始缩放计算----------------------
			
			if(mOriginWidth!=0)
			{
				var tx:Number=mOriginWidth*_fx;
				
				mBaseMtx.appendScale(tx,1,1);
				//trace("原始缩放x")
			}	
			if(mOriginHeight!=0)
			{
				var ty:Number=mOriginHeight*_fy;
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
				tx=tx*_fx;
				mMatrix3D.appendTranslation(tx,0, 0);
				_rotPivot.x+=tx;
				//trace("位移x")
			}	
			if(ty!=0)
			{
				ty=ty*_fy;
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
                mParentMatrix3D=parent.getMatrix3D();
				mOutMatrix.append(mParentMatrix3D);
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
