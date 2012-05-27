package gui
{
    import mongoose.display.Sprite2D;
    import mongoose.display.TextureData;
    /**
     * 组件基类
     * @author genechen
     * 
     */    
    public class Component extends Sprite2D
    {
        public function Component(texture:TextureData=null)
        {
            super(texture);
            
            alphaTest = false;
        }
        /**
         * 初始化数据 
         * 
         */        
        protected function _initialize():void
        {
            
        }
        /**
         * 状态切换 
         * @param state
         * 
         */        
        protected function _setState(state:String):void
        {
            
        }
        
        /**
         *更新显示数据 
         * 
         */        
        protected function _update():void
        {
            
        }
    }
}