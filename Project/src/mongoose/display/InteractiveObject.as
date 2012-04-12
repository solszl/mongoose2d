package mongoose.display
{
    import flash.events.*;
    import flash.geom.Point;
    import flash.utils.Dictionary;
    
    public class InteractiveObject extends DisplayObject
    {
        
        [Event(name="click", type="flash.events.MouseEvent")]
        [Event(name="mouseDown", type="flash.events.MouseEvent")]
        [Event(name="mouseMove", type="flash.events.MouseEvent")]
        [Event(name="mouseUp", type="flash.events.MouseEvent")]
        [Event(name="mouseOver", type="flash.events.MouseEvent")]
        [Event(name="mouseOut", type="flash.events.MouseEvent")]
        
        protected var m_mouseEnabled:Boolean = true;
        protected var m_mouseChildren:Boolean = true;
        
        protected var handleMap:Dictionary;;
        
        public function InteractiveObject()
        {
			handleMap=new Dictionary;
            
        }// end function

       
        public function enterFrameEvent(name:String,handle:Function):void
		{
			handleMap[name]=handle;
		}
		public function removeFrameEvent(name:String,handle:Function):void
		{
			if(handleMap[name])
				delete handleMap[name];
		}
		override protected function preRender():void
		{
			super.preRender();
			for each(var handle:Function in handleMap)
			{
				handle(this);
			}
		}
        
        public function set mouseEnabled( bool:Boolean ):void
        {
            m_mouseEnabled = bool;
        }
        
        public function get mouseEnabled():Boolean
        {
            return m_mouseEnabled;
        }
        
        public function set mouseChildren( bool:Boolean ):void
        {
            m_mouseChildren = bool;
        }
        
        public function get mouseChildren():Boolean
        {
            return m_mouseChildren;
        }
        
		protected var mGlobalPoint:Point = new Point();
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
		
        protected var m_inBound:Boolean;
        /**
         * 事件的传递和回冒 
         * @param event 鼠标事件
         * @param isBubbled 是否冒泡上来
         * @return 
         * 
         */  
        internal function _passMouseEvent( event:MouseEvent, isBubbled:Boolean=false ):Boolean
        {
            m_inBound =  _checkPointHasPixel( event.stageX, event.stageY );
            
            switch( event.type )
            {
                case 'mouseMove':
                {
                    _mouseMove( event, m_inBound );
                    break;
                }
                case 'click':
                {
                    if( m_inBound )
                        _mouseClick( event );
                    break;
                }
                case 'mouseDown':
                {
                    if( m_inBound )
                        _mouseDown( event );
                    break;
                }
                case 'mouseUp':
                {
                    if( m_inBound )
                        _mouseUp( event );
                    break;
                }
            }
            
            return m_inBound;
        }
        
        /**
         * 检测是否有真实像素
         * @param pointX
         * @param pointY
         * @return 
         * 
         */        
        protected function _checkPointHasPixel( pointX:Number, pointY:Number ):Boolean
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
            
            return _isContainPoint( pointX, pointY );
        }
        /**
         * 检测点的位置是否在矩形内 
         * @param pointX
         * @param pointY
         * @return 
         * 
         */        
        protected function _isContainPoint( pointX:Number, pointY:Number ):Boolean
        {
			mGlobalPoint.x = x;
			mGlobalPoint.y = y;
			if (parent != null)
			{
				mGlobalPoint = mGlobalPoint.add(parent.globalPosition);
			}
			
            if( pointX > mGlobalPoint.x && 
                pointY > mGlobalPoint.y && 
                pointX < (mGlobalPoint.x+width) && 
                pointY < (mGlobalPoint.y+height) )
            {
                return true;
            }
            
            return false;
        }
        
        protected function _mouseDown( event:MouseEvent ):void
        {
            if( hasEventListener( 'mouseDown') )
            {
                dispatchEvent( event );
                //trace('down')
            }
        }
        
        protected function _mouseUp( event:MouseEvent ):void
        {
            if( hasEventListener( 'mouseUp' ) )
            {
                dispatchEvent( event );
                //trace('up')
            }
        }
        
        protected function _mouseClick( event:MouseEvent ):void
        {
            if( hasEventListener( 'click' ) )
            {
                dispatchEvent( event );
            }
        }
        
        protected var m_isMouseOver:Boolean = false;
        protected function _mouseMove( event:MouseEvent, hasPixel:Boolean ):void
        {
            if( hasPixel )
            {
                if( hasEventListener( 'mouseMove' ) )
                {
                    dispatchEvent( event );
                }
                
                if( !m_isMouseOver && hasEventListener( 'mouseOver' ) )
                {
                    m_isMouseOver = true;
                    dispatchEvent( new MouseEvent('mouseOver',true,false,event.stageX- parent.x,event.stageY-parent.y) );
                }
            }
            else
            {
                if( m_isMouseOver )
                {
                    m_isMouseOver = false;
                    
                    if( hasEventListener('mouseOut') )
                        dispatchEvent( new MouseEvent('mouseOut',true,false,event.stageX-parent.x,event.stageY-parent.y) );
                }
            }
        }
        
        /**
         * 传递鼠标事件，进行处理 
         * @param event
         * 
         */        
        public function triggerMouseEvent( event:MouseEvent ):void
        {
            _passMouseEvent( event );
        }
    }
}
