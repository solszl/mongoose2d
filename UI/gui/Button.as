package gui
{
    import flash.events.MouseEvent;
    
    import mongoose.display.DisplayObject;
    import mongoose.display.TextureData;
    import mongoose.filter.BrightFilter;
    import mongoose.geom.MRectangle;

    /**
     * 按钮
     * @author genechen
     * 
     */    
    public class Button extends Component
    {
        /**
         * 各状态皮肤 
         */        
        protected var mBtnStateSkin:ButtonStateSkin;
        /**
         * 标签 
         */        
        protected var mLabel:Label;
        
        public function Button(texture:TextureData=null)
        {
            super(texture);
            
            _initialize();
        }
        
        override protected function _initialize():void
        {
//            addEventListener(MouseEvent.MOUSE_OVER,_mouseOverHandler);
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
        public function setStateSkin(btnSkin:ButtonStateSkin):void
        {
            mBtnStateSkin = btnSkin;
            
            setTexture(mBtnStateSkin.normalState);
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
        
        /**
         * 状态皮肤切换 
         * @param state
         * 
         */        
        override protected function _setState(state:String):void
        {
            switch(state)
            {
                case "mouseOver":
                {
                    if(mBtnStateSkin && mBtnStateSkin.overState)
                    {
                        mTexture = mBtnStateSkin.overState;
                    }
                    else
                    {
                        color = 0x03b08d;
                    }
                    break; 
                }
                case "mouseDown":
                {
                    if(mBtnStateSkin && mBtnStateSkin.downState)
                    {
                        mTexture = mBtnStateSkin.downState;
                    }
                    else
                    {
                        color = 0xff88dd;
                    }
                    break;
                }
                case "mouseUp":
                {
                    if(mBtnStateSkin && mBtnStateSkin.upState)
                    {
                        mTexture = mBtnStateSkin.upState;
                    }
                    else
                    {
                        color = 0xffffff;
                    }
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