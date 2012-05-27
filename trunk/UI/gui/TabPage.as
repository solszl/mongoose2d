package gui
{
    import mongoose.display.DisplayObject;
    import mongoose.display.Sprite2D;
    import mongoose.display.TextureData;

    /**
     * 切页控件 
     * @author genechen
     * 
     */    
    public class TabPage extends Sprite2D
    {
        /**
         * tab按钮 
         */        
        protected var mTabButtons:Vector.<Button>;
        
        protected var mButtonSkin:ButtonStateSkin;
        /**
         * tab间的间隔距离 
         */        
        protected var mTabSep:int=2;
        
        public function TabPage(texture:TextureData=null)
        {
            super(texture);
        }
        
        /**
         * 设置页签按钮的皮肤 
         * @param btnSkin
         * 
         */        
        public function setTabBtnSkin(btnSkin:ButtonStateSkin):void
        {
            mButtonSkin = btnSkin;
            
            _updateTabBtns();
        }
        
        /**
         * 设置页签按钮的文字 
         * @param names
         * 
         */        
        public function setTabLabels(names:Array):void
        {
            if(names)
            {
                _clearTabBtns();
                
                var hasBtnSkin:Boolean = (mButtonSkin && mButtonSkin.normalState);
                var len:uint = names.length;
                mTabButtons = new Vector.<Button>(len);
                
                for(var i:int=0; i<len; ++i)
                {
                    mTabButtons[i] = new Button(hasBtnSkin ? mButtonSkin.normalState : null);
                    mTabButtons[i].label = String(names[i]);
                    
                    addChild(mTabButtons[i]);
                }
                
                _updateTabBtns();
            }
        }
        
        protected function _updateTabBtns():void
        {
            if(mTabButtons && mButtonSkin)
            {
                var len:uint = mTabButtons.length;
                var tab:Button;
                for(var i:int=0; i<len; ++i)
                {
                    tab = mTabButtons[i];
                    if(tab)
                    {
                        tab.setStateSkin(mButtonSkin);
                        tab.x = i*mButtonSkin.normalState.width+mTabSep;
                    }
                }
            }
        }
        
        protected function _clearTabBtns():void
        {
            if(mTabButtons)
            {
                var len:uint = mTabButtons.length;
                var tab:Button;
                for(var i:int=0; i<len; ++i)
                {
                    tab = mTabButtons[i];
                    if(tab && tab.parent)
                    {
                        tab.parent.removeChild(tab);
                    }
                    mTabButtons[i] = null;
                }
            }
        }
        
        /**
         * 显示内容 
         * @param content
         * 
         */        
        public function setContent(content:DisplayObject):void
        {
            
        }
    }
}