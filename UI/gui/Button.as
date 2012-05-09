package gui
{
    import flash.events.MouseEvent;
    
    import mongoose.display.DisplayObject;
    import mongoose.display.TextureData;
    import mongoose.geom.MRectangle;

    /**
     * 
     * @author genechen
     * 
     */    
    public class Button extends Component
    {
        protected var mDownState:TextureData;
        protected var mUpState:TextureData;
        protected var mOverState:TextureData;
        protected var mNormalState:TextureData;
        
        protected var mLabel:Label;
        
        public function Button(texture:TextureData=null)
        {
            super(texture);
            
            _initialize();
        }
        
        override protected function _initialize():void
        {
            addEventListener(MouseEvent.MOUSE_OVER,_mouseOverHandler);
            addEventListener(MouseEvent.MOUSE_DOWN,_mouseDownHandler);
            addEventListener(MouseEvent.MOUSE_UP,_mouseUpHandler);
        }
        /**
         * 不同按钮状态的贴图 
         * @param normal
         * @param down
         * @param up
         * @param over
         * 
         */        
        public function setStateTexture(normal:TextureData,
                                        down:TextureData,
                                        up:TextureData, 
                                        over:TextureData):void
        {
            mNormalState = normal;
            mDownState = down;
            mOverState = over;
            mUpState = up;
        }
        
        protected function _mouseOverHandler(target:DisplayObject):void
        {
            _setState('mouseOver');
        }

        protected function _mouseDownHandler(target:DisplayObject):void
        {
            _setState("mouseDown");
        }
        
        protected function _mouseUpHandler(target:DisplayObject):void
        {
            _setState("mouseUp");
        }
        
        protected function _mouseClickHandler(target:DisplayObject):void
        {
        }
        
        override protected function _setState(state:String):void
        {
            switch(state)
            {
                case "mouseOver":
                {
                    //mTexture = mOverState;
                    color = 0x03b08d
                    break; 
                }
                case "mouseDown":
                {
                    color = 0x4195dd;
                    break;
                }
                case "mouseUp":
                {
                    //mTexture = mUpState;
                    color = 0xcc9d0d;
                    break;
                }
            }
            
            trace('stateChange->',state);
        }
        /**
         * 图标 
         * @param texture
         * 
         */        
        public function setIconTexture(texture:TextureData):void
        {
            mLabel.iconTexture = texture;
        }
        /**
         * 标签文本 
         * @param value
         * 
         */        
        public function set label(value:String):void
        {
            if(null == mLabel)
            {
                mLabel = new Label();
                addChild(mLabel);
            }
            
            mLabel.text = value;
        }
        
        public function get label():String
        {
            return mLabel.text;
        }
    }
}