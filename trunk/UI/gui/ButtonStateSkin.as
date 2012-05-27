package gui
{
    import mongoose.display.TextureData;
    /**
     * 按钮各个状态皮肤 
     * @author genechen
     * 
     */
    public class ButtonStateSkin
    {
        /**
         * 正常状态 
         */        
        public var normalState:TextureData;
        /**
         * 按下状态 
         */        
        public var downState:TextureData;
        /**
         * 弹起状态 
         */        
        public var upState:TextureData;
        /**
         * 鼠标移入状态
         */        
        public var overState:TextureData;
        /**
         * 鼠标移出状态
         */        
        public var outState:TextureData;
        /**
         * 选中状态 
         */        
        public var selectState:TextureData;
    }
}