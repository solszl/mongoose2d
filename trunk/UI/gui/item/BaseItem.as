package gui.item
{
    import gui.Button;
    
    import mongoose.display.TextureData;
    /**
     * 
     * @author genechen
     * 
     */    
    public class BaseItem extends Button
    {
        public var selected:Boolean;
        
        protected var dataValue:Object;
        
        public function BaseItem(texture:TextureData=null)
        {
            super(texture);
        }
        
        public function hide():void
        {
            visible = false;
        }
        
        public function show(value:Object):void
        {
            dataValue = value;
            
            visible = Boolean(value);
            if (!value) return;
            
            _update();
        }
    }
}