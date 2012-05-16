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
        private  var _width:Number = 0;
        private  var _height:Number = 0;
		
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
		private var _twidth:Number,_theight:Number;
        public function DisplayObject()
        {
			id=INSTANCE_NUM++;
			_tempDepth=.00001/id;
            mRotPivot = new Vector3D(0, 0, 1);
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
		public function set width(value:Number):void
		{
			_width=value;
			_twidth=_width/mOriginWidth*scaleX;
		}
        public function get width():Number
		{
			return _width;
		}
		public function set height(value:Number):void
		{
			_height=value;
			_theight=_height/mOriginHeight*scaleY
		}
		public function get height():Number
		{
			return _height;
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
			mMatrix3D.identity();
			mBaseMatrix.prependTranslation(mPivot.x,mPivot.y,mPivot.z);
			
			
			mRemOrignWidth=mOriginWidth;
			mRemOrignHeight=mOriginHeight;
			_remScaleX=_remScaleY=1;
			_remX=_remY=_remZ=0;
			_remRotX=_remRotY=_remRotZ=0;
			mRotPivot.x=0;
			mRotPivot.y=0;
			mRotPivot.z=1;
			
			//_widthRecip = world.iwidthRecip;
			//_heightRecip = world.iheightRecip;
			mWidthRecipDbl = world.iwidthRecipDble;
			mHeightRecipDbl = world.iheightRecipDbl;
			_zScale = 1 / (World.far - World.near);
			//----------------------原始缩放计算----------------------
			
			if(mOriginWidth!=0)
			{
				var tx:Number=mOriginWidth*mWidthRecipDbl;
				
				mBaseMatrix.appendScale(tx,1,1);
				//trace("原始缩放x")
			}	
			if(mOriginHeight!=0)
			{
				var ty:Number=mOriginHeight*mHeightRecipDbl*world.scale;
				mBaseMatrix.appendScale(1,ty, 1);
				//trace("原始缩放y")
			}  
			
		}
        protected function composeMatrix() : void
        {
			/*depth=z+_tempDepth;
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
			
			//var tx:Number,ty:Number,tz:Number;
			
			//------------------------尺寸缩放计算------------------------------
			_tempX=width-mRemOrignWidth;
			_tempY=height-mRemOrignHeight;
			
			
			if(_tempX!=0||_tempY!=0)
			{
				
				mMatrix3D.prependScale(width/mRemOrignWidth,height/mRemOrignHeight, 1);
				mRemOrignWidth=width;
				mRemOrignHeight=height;
				//trace("尺寸缩放x")
			}	
			
			//-----------------------直接缩放------------------------------------
			_tempX=scaleX-_remScaleX;
			_tempY=scaleY-_remScaleY;
			_remScaleX=scaleX;
			_remScaleY=scaleY;
			if(_tempX!=0||_tempY!=0)
			{
				mMatrix3D.prependScale(_tempX+1,_tempY+1, 1);
				//trace("直接缩放x")
			}	
			
			//--------------------------------------------------------
			_tempX=rotateX-_remRotX;
			_tempY=rotateY-_remRotY;
			_tempZ=rotateZ-_remRotZ;
			
			_remRotX=rotateX;
			_remRotY=rotateY;
			_remRotZ=rotateZ;
			
			if(_tempX!=0)
			{
				mMatrix3D.appendRotation(_tempX, Vector3D.X_AXIS, mRotPivot);
				//trace("旋转x")
			}
			if(_tempY!=0)
			{
				mMatrix3D.appendRotation(_tempY, Vector3D.Y_AXIS, mRotPivot);
				//trace("旋转y")
			}
			if(_tempZ!=0)
			{
				mMatrix3D.appendRotation(_tempZ, Vector3D.Z_AXIS, mRotPivot);
				//trace("旋转z")
			}
			
			
			//---------------------------------------------------------------
			_tempX=x-_remX;
			_tempY=y-_remY;
			_tempZ=z-_remZ;
			_remX=x;
			_remY=y;
			_remZ=z;
			if(_tempX!=0||_tempY!=0||_tempZ!=0)
			{
				_tempX=_tempX*mWidthRecipDbl;
				_tempY=_tempY*mHeightRecipDbl*world.scale;
				_tempZ=_tempZ*_zScale;
				mMatrix3D.appendTranslation(_tempX,-_tempY, _tempZ);
				mRotPivot.x+=_tempX;
				mRotPivot.y-=_tempY;
				mRotPivot.z+=_tempZ;
				//trace("位移x")
			}	

            mOutMatrix.append(mBaseMatrix);
            mOutMatrix.append(mMatrix3D);
            if (parent != null)
            {
				//this.alpha=_alpha*parent.alpha;
				mConstrants[4]=r*parent.getRed();
				mConstrants[5]=g*parent.getGreen();
				mConstrants[6]=b*parent.getBlue();
				mConstrants[7]=alpha*parent.getAlpha();
                mParentMatrix3D=parent.getMatrix3D();
				if(mParentMatrix3D!=null)
				    mOutMatrix.append(mParentMatrix3D);
            }
			else
			{
				this.alpha=_remAlpha;
				//mConstrants[7]=this.alpha;
			}*/
			depth=z+_tempDepth;
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
			mMatrix3D.prependScale(_twidth,_theight,1);
			if(rotateX!=0)
				mMatrix3D.appendRotation(rotateX, Vector3D.X_AXIS, mRotPivot);
			if(rotateY!=0)
				mMatrix3D.appendRotation(rotateY, Vector3D.Y_AXIS, mRotPivot);
			if(rotateZ!=0)
				mMatrix3D.appendRotation(rotateZ, Vector3D.Z_AXIS, mRotPivot);
			mMatrix3D.appendTranslation(x*mWidthRecipDbl,-y*mHeightRecipDbl*world.scale,z*_zScale);
			mOutMatrix.append(mBaseMatrix);
			mOutMatrix.append(mMatrix3D);
        }// end function
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
        }// end function

        protected function draw() : void
        {
            
        }// end function

    }
}
