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
		/**
		 * 深度
		 */		
		public var depth:Number;
		/**
		 *是否显示,注:visible=false的时候是不会提交渲染的. 
		 */		
		public var visible:Boolean=true;
        public var scaleX:Number = 1;
        public var scaleY:Number = 1;
        public var scaleZ:Number = 1;
        public var parent:DisplayObjectContainer;
        public var color:Number = 0xffffff;
        public var alpha:Number = 1;
        public  var width:Number = 0;
        public  var height:Number = 0;
		
        public var rotateX:Number = 0;
        public var rotateY:Number = 0;
        public var rotateZ:Number = 0;
		
		
		internal var r:Number,g:Number,b:Number;
        protected var sortByName:String="z";
		protected var mPivot:Vector3D;
		protected var mMatrix3D:Matrix3D;
		protected var mMyMatrix:Matrix3D;
        protected var mParent:DisplayObject;
        protected var mProgram3d:Program3D;
        protected var mOriginWidth:Number = 0;
        protected var mOriginHeight:Number = 0;
      
		protected var mConstrants:Vector.<Number>;
        protected var mBaseMatrix:Matrix3D;
        protected var mOutMatrix:Matrix3D;
		protected var mParentMatrix3D:Matrix3D
		
		
		//旋转注册cache
        protected var mRotPivot:Vector3D;
		//临时计算cache
		
        protected var mWidthRecipDbl:Number;
        protected var mHeightRecipDbl:Number;
        private var _zScale:Number;
		//位置cache
		private var _remX:Number=0,
			        _remY:Number=0,
					_remZ:Number=0;
		
		//尺寸缩放cache
		protected var mRemOrignWidth:Number=0,mRemOrignHeight:Number=0;
		//直接缩放cache
		private var _remScaleX:Number=1,_remScaleY:Number=1;
        private var _changed:Boolean = true;
        //旋转cache
        private var _remRotX:Number=0,
			        _remRotY:Number=0,
					_remRotZ:Number=0;
		
		private var _remColor:uint;
		private var _remAlpha:Number;
		private var _colorRecip:Number=1/255;
		private var _tempDepth:Number;
		
		private var _tempX:Number,_tempY:Number,_tempZ:Number;
		private var _tempColor:uint;
		
        public function DisplayObject()
        {
			id=++INSTANCE_NUM;
			_tempDepth=.00001/id;
            mRotPivot = new Vector3D(0, 0, 0);
			mPivot=new Vector3D(0,0,0);
            mBaseMatrix = new Matrix3D();
			
            mMatrix3D = new Matrix3D();
			mMyMatrix =new Matrix3D;
            mOutMatrix = new Matrix3D();
			mConstrants=new Vector.<Number>(8);
			mConstrants[4]=1;
			mConstrants[5]=1;
			mConstrants[6]=1;
			mConstrants[7]=1;
        }
		
		/**
		 *设置显示对象的注册点,数值范围是 归一化的.例如，注册点设置到中心位置setRegisterPoint(-.5,.5,0) 
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
			mBaseMatrix.identity();
			if(mPivot.x||mPivot.y!=0)
			mBaseMatrix.prependTranslation(mPivot.x,mPivot.y,mPivot.z);
			
			
			mWidthRecipDbl = World.WIDTH_RECIP;
			mHeightRecipDbl = World.HEIGHT_RECIP;
			_zScale = World.Z_SCALE;
			//----------------------原始缩放计算----------------------
			
			if(mOriginWidth!=0)
			{
				//var tx:Number=mOriginWidth*mWidthRecipDbl;
				
				mBaseMatrix.appendScale(mOriginWidth,1,1);
				//trace("原始缩放x")
			}	
			if(mOriginHeight!=0)
			{
				//var ty:Number=mOriginHeight*mHeightRecipDbl;
				mBaseMatrix.appendScale(1,mOriginHeight, 1);
				//trace("原始缩放y")
			}  
			
		}
        protected function composeMatrix() : void
        {
			
			depth=this[sortByName]+_tempDepth;
			_tempColor=color-_remColor;
			_remColor=color;
			_remAlpha=alpha;
			if(_tempColor!=0)
			{
				r=mConstrants[4]=(color>>16)*_colorRecip;
				g=mConstrants[5]=(color>>8&0xff)*_colorRecip;
				b=mConstrants[6]=(color&0xff)*_colorRecip;
			}
			mConstrants[7]=alpha;
			
			mOutMatrix.identity();
			mMatrix3D.identity();
			mMatrix3D.prependScale(width/mOriginWidth,height/mOriginHeight,1);
			mMatrix3D.prependScale(scaleX,scaleY,1);
			
			if(rotateX!=0)
				mMatrix3D.appendRotation(rotateX, Vector3D.X_AXIS, mRotPivot);
			if(rotateY!=0)
				mMatrix3D.appendRotation(rotateY, Vector3D.Y_AXIS, mRotPivot);
			if(rotateZ!=0)
				mMatrix3D.appendRotation(rotateZ, Vector3D.Z_AXIS, mRotPivot);
			
			mMatrix3D.appendTranslation(x,-y,z);
			mOutMatrix.append(mBaseMatrix);
			mOutMatrix.append(mMatrix3D);
			if (parent != null)
			{
				mConstrants[4]=r*parent.getRed();
				mConstrants[5]=g*parent.getGreen();
				mConstrants[6]=b*parent.getBlue();
				mConstrants[7]=alpha*parent.getAlpha();
				mParentMatrix3D=parent.getMatrix3D();
				mOutMatrix.append(mParentMatrix3D);
			}
			else
			{
				this.alpha=alpha;
			}
			mOutMatrix.append(Camera.current.matrix);
			//mOutMatrix.rawData;
        }
		internal function getRed():Number
		{
			if(parent!=null)
				return r*parent.getRed();
			else
				return r;
		}
		internal function getBlue():Number
		{
			if(parent!=null)
				return b*parent.getBlue();
			else
				return b;
		}
		internal function getAlpha():Number
		{
			if(parent!=null)
				return alpha*parent.getAlpha();
			else
				return alpha;
		}
		internal function getGreen():Number
		{
			if(parent!=null)
				return g*parent.getGreen();
			else
				return g;
		}
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
        }

        protected function draw() : void
        {
            
        }
    }
}
