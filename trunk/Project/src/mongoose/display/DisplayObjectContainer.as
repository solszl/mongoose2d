package mongoose.display
{
    
    import flash.events.*;

    public class DisplayObjectContainer extends InteractiveObject
    {
        protected var mChilds:Vector.<DisplayObject>;

        public function DisplayObjectContainer()
        {
            mChilds = new Vector.<DisplayObject>;
           
        }// end function

        public function addChild(child:DisplayObject) : void
        {
            if (!this.hasChild(child))
            {
                this.mChilds.push(child);
            }
            child.parent = this;
            dispatchEvent(new Event(Event.ADDED));
        }// end function

        private function hasChild(child:DisplayObject) : Boolean
        {
            var step:int;
            var total:uint = mChilds.length;
            while (step<total)
            {
                
                if (mChilds[step] == child)
                {
                    return true;
                }
				step++;
            }
            return false;
        }// end function

        public function removeChild(uint:DisplayObject) : void
        {
            return;
        }// end function

        public function get numChildren() : Number
        {
            return 0;
        }// end function

        public function getChildByName(name:String) : DisplayObject
        {
            return null;
        }// end function

        public function getChildByIndex(index:uint) : DisplayObject
        {
            return null;
        }// end function

        override public function render() : void
        {
            var step:uint;
            var total:uint = this.mChilds.length;
            while (step< total)
            {
                
                mChilds[step].render();
				step++;
            }
			super.render();
        }// end function

        
        override internal function _passMouseEvent(event:MouseEvent, isBubbled:Boolean=false):Boolean
        {
            //假如是禁止鼠标的，那直接向上冒泡
            if( !m_mouseEnabled )
            {
                return false;
            }
            
            //假如是冒泡上来的 只需要继续向上冒泡
            if( isBubbled )
            {
                switch( event.type )
                {
                    case 'click':
                    {
                        _mouseClick( event );
                        break;
                    }
                    case 'mouseDown':
                    {
                        _mouseDown( event );
                        break;
                    }
                    case 'mouseUp':
                    {
                        _mouseUp( event );
                        break;
                    }
                }
                
                if( parent )
                    parent._passMouseEvent( event, true );
                
            }
            else
            {
                //是否有孩子响应了鼠标事件
                var _hasTriggerChild:Boolean = false;
                
                if( m_mouseChildren )
                {
                    var _len:uint = mChilds.length;
                    //倒序检测
                    for( var i:int = _len-1; i >= 0;  --i )
                    {
                        if( mChilds[i] is InteractiveObject )
                        {
                            if( InteractiveObject(mChilds[i])._passMouseEvent( event ) )
                            {
                                _hasTriggerChild = true;
                                break;
                            }
                            else
                                continue;
                        }
                    }
                }
                
                //没有孩子响应，就检测是否点在自己身上
                if( !_hasTriggerChild )
                {
                    if( super._passMouseEvent( event ) && parent )
                    {
                        parent._passMouseEvent( event, true );
                        return true;
                    }
                    return false;
                    
                    //                    return super._passMouseEvent( event );
                }
                else
                {
                    return true;
                }   
                
            }
            
            return false;
        }
    }
}
