package mongoose.display
{
    import flash.display3D.*;
    import flash.events.*;
    import flash.geom.*;
    
    import mongoose.core.*;
    import mongoose.geom.RemMatrix3D;

    public class DisplayObject extends BaseObject
    {
		
        public var scaleX:Number = 1;
        public var scaleY:Number = 1;
        public var scaleZ:Number = 1;
        public var parent:DisplayObject;
        public var color:Number = 0xffffff;
        public var alpha:Number = 255;
        public var width:Number = 1;
        public var height:Number = 1;
		
        protected var mMatrix3D:Matrix3D;
		protected var mMyMatrix:Matrix3D=new Matrix3D;
        public var rotateX:Number = 0;
        public var rotateY:Number = 0;
        public var rotateZ:Number = 0;
       
        protected var mParent:DisplayObject;
        
        
        protected var mProgram3d:Program3D;
        protected var mOriginWidth:Number = 0;
        protected var mOriginHeight:Number = 0;
        protected var mColorData:Vector.<Number>;
		
        protected var mBaseMtx:Matrix3D;
        protected var mOutMatrix:Matrix3D;
        protected var mTemp:Matrix3D=new Matrix3D;
		protected var mParentMatrix3D:Matrix3D;
        private var _pivot:Vector3D;
        private var _r1:Number;
        private var _r2:Number;
        private var _fx:Number;
        private var _fy:Number;
        private var _fz:Number;
		
		//位置cache
		private var _mx:Number=0,
			        _my:Number=0,
					_mz:Number=0;
		//原始缩放cache
		private var _mosx:Number=0,_mosy:Number=0;
		//尺寸缩放cache
		private var _msx:Number=0,_msy:Number=0;
		//直接缩放cache
		private var _sx:Number=0,_sy:Number=0;
        private var _changed:Boolean = true;
        //旋转cache
        private var _rx:Number=0,
			        _ry:Number=0,
					_rz:Number=0;
        public function DisplayObject()
        {
           
            _pivot = new Vector3D(0, 0, 1);
			
            mBaseMtx = new Matrix3D();
			
			
            mMatrix3D = new Matrix3D();
			
			
            mOutMatrix = new Matrix3D();
            mColorData = new Vector.<Number>;
            mColorData.push(1,1,1,1);
            addEventListener(Event.ADDED, onChange);
			world.addEventListener(Event.CHANGE,onChange);
        }// end function

        protected function onChange(far:Event = null) : void
        {
			mBaseMtx.identity();
			mMatrix3D.identity();
			_mx=_my=_mz=0,
			_mosx=_mosy=0;
			_msx=_msy=0;
			_sx=_sy=0;
			_rx=_ry=_rz=0;
            _changed = true;
			
        }// end function

        override protected function preRender() : void
        {
           
            if (_changed)
            {
                _r1 = 1 / world.width;
                _r2 = 1 / world.height;
                _fx = _r1 * 2;
                _fy = _r2 * 2 * world.scale;
                _fz = 1 / (World.far - World.near);
				
                _changed = false;
            }
			
        }// end function

        protected function composeMatrix() : void
        {
            mOutMatrix.identity();
            
			var tx:Number,ty:Number,tz:Number;
			//----------------------原始缩放计算----------------------
			tx=mOriginWidth-_mosx;
			ty=mOriginHeight-_mosy;
			_mosx=mOriginWidth;
			_mosy=mOriginHeight;
		
			if(tx!=0)
			{
				tx=tx*_fx;
				mBaseMtx.appendScale(tx,1,1);
				//trace("原始缩放x")
			}	
			if(ty!=0)
			{
				ty=ty*_fy;
				mBaseMtx.appendScale(1,ty, 1);
				//trace("原始缩放y")
			}  
			//------------------------尺寸缩放计算------------------------------
			var scorex:Number=width-mOriginWidth;
			var scorey:Number=height-mOriginHeight;
			tx=scorex-_msx;
			ty=scorey-_msy;
			_msx=scorex;
			_msy=scorey;
			if(tx!=0)
			{
				tx=tx*_fx;
				mMatrix3D.appendScale(tx,1, 1);
				//trace("尺寸缩放x")
			}	
			if(ty!=0)
			{
				ty=ty*_fy;
				mMatrix3D.appendScale(1,ty, 1);
				//trace("尺寸缩放y")
			}  
			//-----------------------直接缩放------------------------------------
			tx=scaleX-_sx;
			ty=scaleY-_sy;
			_sx=scaleX;
			_sy=scaleY;
			if(tx!=0)
			{
				
				mMatrix3D.appendScale(tx,1, 1);
				//trace("直接缩放x")
			}	
			if(ty!=0)
			{
				
				mMatrix3D.appendScale(1,ty, 1);
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
				mMatrix3D.appendRotation(tx, Vector3D.X_AXIS, _pivot);
				//trace("旋转x")
			}
			if(ty!=0)
			{
				mMatrix3D.appendRotation(ty, Vector3D.Y_AXIS, _pivot);
				//trace("旋转y")
			}
			if(tz!=0)
			{
				mMatrix3D.appendRotation(tz, Vector3D.Z_AXIS, _pivot);
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
				//trace("位移x")
			}	
			if(ty!=0)
			{
				ty=ty*_fy;
				mMatrix3D.appendTranslation(0,-ty, 0);
				//trace("位移y")
			}  
			if(tz!=0)
			{
				tz=tz*_fz;
				mMatrix3D.appendTranslation(0,0, tz);
				//trace("位移z")
			} 
			
           
            if (parent != null)
            {
                mParentMatrix3D=parent.getMatrix3D();
            }
            mOutMatrix.append(mBaseMtx);
            mOutMatrix.append(mMatrix3D);
			mOutMatrix.append(mParentMatrix3D);
            mOutMatrix.appendTranslation(-1, world.scale, 0);
        }// end function
        public function getMatrix3D():Matrix3D
		{
			if(mParentMatrix3D!=null)
			{
				mMyMatrix.identity();
				mMyMatrix.append(mMatrix3D);
				mMyMatrix.append(mParentMatrix3D);
			}
				
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
            context3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 8, mOutMatrix, true);
           
            context3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, mColorData);
        }// end function

    }
}
