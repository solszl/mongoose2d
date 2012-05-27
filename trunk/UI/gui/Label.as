package gui
{
    import mongoose.display.Image;
    import mongoose.display.Sprite2D;
    import mongoose.display.TextField;
    import mongoose.display.TextureData;

    /**
     * 
     * @author genechen
     * 
     */    
    public class Label extends Component
    {
        protected var mTextFiled:TextField;
        protected var mIcon:Image;
        
        public function Label(texture:TextureData=null)
        {
            super(texture);
            
            _initialize();
        }
        
        override protected function _initialize():void
        {
            mouseEnabled = false;
            //temp
            setTexture(new TextureData());
            
            mTextFiled = new TextField();
            addChild(mTextFiled);
        }
        /**
         * 文本 
         * @param value
         * 
         */        
        public function set text(value:String):void
        {
            mTextFiled.text = value;
            
            _update();
        }
        
        public function get text():String
        {
            return mTextFiled.text;
        }
        
        /**
         * 图标贴图 
         * @param texture
         * 
         */        
        public function set iconTexture(texture:TextureData):void
        {
            if(null == mIcon)
            {
                mIcon = new Image();
                addChild(mIcon);
            }
            
            mIcon.setTexture(texture);
            
            _update();
        }
        
        public function get iconTexture():TextureData
        {
            return null;
        }
        
        override protected function _update():void
        {
            if(mTextFiled && mIcon)
                mTextFiled.x = mIcon.x + mIcon.width + 2;
        }
    }
}