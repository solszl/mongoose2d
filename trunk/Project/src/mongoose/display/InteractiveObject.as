package mongoose.display
{
    import flash.events.*;
    import flash.geom.Matrix3D;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.geom.Vector3D;
    import flash.utils.Dictionary;
    
    public class InteractiveObject extends DisplayObject
    {
        protected var mMouseEnabled:Boolean = true;
        protected var mMouseChildren:Boolean = true;
		protected var mMouseHandleMap:Dictionary;
		
		private var _mouseHandleFunc:Function;
		
        protected var mHandleMap:Dictionary;
		
		
		protected var mInBound:Boolean;
		protected var mRectangle:Rectangle;
		
		protected var mGlobalPoint:Point = new Point();
        
        public function InteractiveObject()
        {
			mHandleMap=new Dictionary;
			mMouseHandleMap = new Dictionary;
			mRectangle = new Rectangle();
        }// end function

       
        public function enterFrameEvent(name:String,handle:Function):void
		{
			mHandleMap[name]=handle;
		}
		public function removeFrameEvent(name:String,handle:Function):void
		{
			if(mHandleMap[name])
				delete mHandleMap[name];
		}
		override protected function preRender():void
		{
			super.preRender();
			for each(var handle:Function in mHandleMap)
			{
				handle(this);
			}
		}
        
        public function set mouseEnabled( bool:Boolean ):void
        {
            mMouseEnabled = bool;
        }
        
        public function get mouseEnabled():Boolean
        {
            return mMouseEnabled;
        }
        
        public function set mouseChildren( bool:Boolean ):void
        {
            mMouseChildren = bool;
        }
        
        public function get mouseChildren():Boolean
        {
            return mMouseChildren;
        }
        
		public function listenMouseEvent(name:String,handle:Function):void
		{
			mMouseHandleMap[name]=handle;
		}
		public function removeMouseEvent(name:String,handle:Function):void
		{
			if(mMouseHandleMap[name])
				delete mMouseHandleMap[name];
		}
		
		public function get globalPosition():Point
		{
			mGlobalPoint.x = x;
			mGlobalPoint.y = y;
			if (parent != null)
			{
				mGlobalPoint = mGlobalPoint.add(parent.globalPosition);
			};
			return (mGlobalPoint);
		}
		
        /**
         * 事件的传递和回冒 
         * @param event 鼠标事件
         * @param isBubbled 是否冒泡上来
         * @return 
         * 
         */  
        internal function _passMouseEvent(event:MouseEvent, isBubbled:Boolean=false):Boolean
        {
            mInBound =  _checkPointHasPixel(event.stageX, event.stageY);
            
            switch( event.type )
            {
                case 'mouseMove':
                {
                    _mouseMove(event, mInBound);
                    break;
                }
                case 'click':
                {
                    if( mInBound )
                        _mouseClick(event);
                    break;
                }
                case 'mouseDown':
                {
                    if( mInBound )
                        _mouseDown(event);
                    break;
                }
                case 'mouseUp':
                {
                    if( mInBound )
                        _mouseUp(event);
                    break;
                }
            }
            
			_mouseHandleFunc = null;
			
            return mInBound;
        }
        
        /**
         * 检测是否有真实像素
         * @param pointX
         * @param pointY
         * @return 
         * 
         */        
        protected function _checkPointHasPixel(pointX:Number, pointY:Number):Boolean
        {
            //todo:...
            //假如
//            if( _isContainPoint( pointX, pointY ) && m_sourceData )
//            {
//                if( (m_sourceData.getPixel32( 
//                    pointX-i_globalLocation.x, pointY-i_globalLocation.y ) >> 24 & 0xFF) != 0x00000000 )
//                {
//                    return true;
//                }
//                else
//                {
//                    return false;
//                }
//            }
            
            return hitTest( pointX, pointY );
        }
        /**
         * 检测点的位置是否在矩形内 
         * @param pointX
         * @param pointY
         * @return 
         * 
         */        
        protected function hitTest(pointX:Number, pointY:Number):Boolean
        {
			
			mGlobalPoint.x = x;
			mGlobalPoint.y = y;
			if (parent != null)
			{
				mGlobalPoint = mGlobalPoint.add(parent.globalPosition);
			}
			/*
			if(rotateZ == 0)
			{	
	            if( pointX > mGlobalPoint.x && 
					pointY > mGlobalPoint.y && 
					pointX < (mGlobalPoint.x+width) && 
					pointY < (mGlobalPoint.y+height) )
	            {
					
	                return true;
	            }
			}
			else
			{
				mRectangle.x = mGlobalPoint.x;
				mRectangle.y = mGlobalPoint.y;
				mRectangle.width = width;
				mRectangle.height = height;
				
				return getBoundsAfterTransformation(mRectangle, mOutMatrix).contains(pointX, pointY);
			}
            */
			if( pointX > mGlobalPoint.x && 
				pointY > mGlobalPoint.y && 
				pointX < (mGlobalPoint.x+width) && 
				pointY < (mGlobalPoint.y+height) )
			{
				
				return true;
			}
			
            return false;
        }
		
		public function getBoundsAfterTransformation(bounds:Rectangle, m:Matrix3D):Rectangle 
		{
			if (m == null) return bounds;
			
			var topLeft:Vector3D = m.transformVector(new Vector3D(bounds.topLeft.x, bounds.topLeft.y, 1));
			var topRight:Vector3D = m.transformVector(new Vector3D(bounds.right, bounds.top,1));
			var bottomRight:Vector3D = m.transformVector(new Vector3D(bounds.bottomRight.x, bounds.bottomRight.y, 1));
			var bottomLeft:Vector3D = m.transformVector(new Vector3D(bounds.left, bounds.bottom ,1));
			
			var left:Number = Math.min(topLeft.x, topRight.x, bottomRight.x, bottomLeft.x);
			var top:Number = Math.min(topLeft.y, topRight.y, bottomRight.y, bottomLeft.y);
			var right:Number = Math.max(topLeft.x, topRight.x, bottomRight.x, bottomLeft.x);
			var bottom:Number = Math.max(topLeft.y, topRight.y, bottomRight.y, bottomLeft.y);
			return new Rectangle(left, top, right - left, bottom - top);
		}
		
		private function insidePolygon(pointList:Array, p:Point):Boolean
		{
			var counter:int = 0;
			var i:int;
			var xinters:Number;
			var p1:Point;
			var p2:Point;
			var n:int = pointList.length;
			
			p1 = pointList[0];
			for (i = 1; i <= n; i++)
			{
				p2 = pointList[i % n];
				if (p.y > Math.min(p1.y, p2.y))
				{
					if (p.y <= Math.max(p1.y, p2.y))
					{
						if (p.x <= Math.max(p1.x, p2.x))
						{
							if (p1.y != p2.y) {
								xinters = (p.y - p1.y) * (p2.x - p1.x) / (p2.y - p1.y) + p1.x;
								if (p1.x == p2.x || p.x <= xinters)
									counter++;
							}
						}
					}
				}
				p1 = p2;
			}
			if (counter % 2 == 0)
			{
				return(false);
			}
			else
			{
				return(true);
			}
		}
        protected function _mouseDown(event:MouseEvent):void
        {
			_mouseHandleFunc = mMouseHandleMap['mouseDown'];
            if( _mouseHandleFunc != null)
            {
				_mouseHandleFunc(event);
                //trace('down')
            }
			
        }
        
        protected function _mouseUp(event:MouseEvent):void
        {
			_mouseHandleFunc = mMouseHandleMap['mouseUp'];
			if( _mouseHandleFunc != null)
			{
				_mouseHandleFunc(event);
				//trace('down')
			}
        }
        
        protected function _mouseClick(event:MouseEvent):void
        {
			_mouseHandleFunc = mMouseHandleMap['click'];
			if( _mouseHandleFunc != null)
			{
				_mouseHandleFunc(event);
				//trace('down')
			}
        }
        
        protected var mIsMouseOver:Boolean = false;
        protected function _mouseMove(event:MouseEvent, hasPixel:Boolean):void
        {
            if( hasPixel )
            {
				_mouseHandleFunc = mMouseHandleMap['mouseMove'];
				if( _mouseHandleFunc != null)
				{
					_mouseHandleFunc(event);
					//trace('down')
				}
				
				_mouseHandleFunc = mMouseHandleMap['mouseOver'];
                if( !mIsMouseOver &&  _mouseHandleFunc!= null)
                {
                    mIsMouseOver = true;
					_mouseHandleFunc(new MouseEvent('mouseOver',true,false,event.stageX- parent.x,event.stageY-parent.y));
                }
            }
            else
            {
                if( mIsMouseOver )
                {
                    mIsMouseOver = false;
					_mouseHandleFunc = mMouseHandleMap['mouseOut'];
                    if(_mouseHandleFunc != null)
						_mouseHandleFunc(new MouseEvent('mouseOut',true,false,event.stageX-parent.x,event.stageY-parent.y));
                }
            }
        }
        
        /**
         * 传递鼠标事件，进行处理 
         * @param event
         * 
         */        
        public function triggerMouseEvent(event:MouseEvent):void
        {
            _passMouseEvent( event );
        }
    }
}
