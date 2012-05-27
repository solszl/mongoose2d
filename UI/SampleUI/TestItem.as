package
{
    import flash.display.BitmapData;
    
    import gui.item.BaseItem;
    
    import mongoose.display.TextureData;
    import mongoose.geom.MRectangle;
    
    public class TestItem extends BaseItem
    {
        public function TestItem(texture:TextureData=null)
        {
            super(texture);
        }
        
        override protected function _initialize():void
        {
            super._initialize();
            
            var downtexture:TextureData=new TextureData();
            downtexture.setUVData(new MRectangle(0,0,300,20));
            
            setTexture(downtexture);
            
//            label = "testitem";
        }
        
        override protected function _update():void
        {
            label = String(dataValue);
        }
    }
}