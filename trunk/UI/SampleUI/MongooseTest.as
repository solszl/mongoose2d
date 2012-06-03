package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import gui.AbstractList;
	import gui.Button;
	import gui.ButtonStateSkin;
	import gui.Component;
	import gui.Dialog;
	import gui.SimpleList;
	import gui.TabPage;
	import gui.model.DefaultListModel;
	
	import mongoose.core.Camera;
	import mongoose.display.DisplayObject;
	import mongoose.display.Sprite2D;
	import mongoose.display.TextField;
	import mongoose.display.TextureData;
	import mongoose.display.World;
	import mongoose.filter.BlurFilter;
	import mongoose.filter.BrightFilter;
	import mongoose.filter.RadialBlurFilter;
	import mongoose.geom.MPoint;
	import mongoose.geom.MRectangle;

	[SWF(frameRate="120",width="1280",height="680",backgroundcolor="0xffffff")]
	public class MongooseTest extends Sprite
	{
		[Embed(source="baodianbtn.png")]
		private var fighter:Class;
        
        [Embed(source="star.jpg")]
        private var anim:Class;
        [Embed(source="dialogbg.png")]
        private var dialogBG:Class;
		private var world:World;
		private var texture:TextureData;
		Component; 
		private var rols:Vector.<Sprite2D>;
        private var farther:Sprite2D;
		private var t:Number=0;
		public function MongooseTest()
		{
			rols=new Vector.<Sprite2D>;
            
			world=new World(stage,new MRectangle(0,0,400,300));
			world.addEventListener(Event.COMPLETE,onStart);
            world.showFps = true;
			world.fullScreen=true;
			world.start();
		}
		private function onStart(e:Event=null):void
		{
			trace("COMPLETE");
			texture=new TextureData;
            texture.bitmapData = (new anim()).bitmapData;
            var btdata:BitmapData = (new fighter()).bitmapData;
            
            var normaltexture:TextureData=new TextureData();
            normaltexture.bitmapData = btdata;
            
            var btnSkin:ButtonStateSkin = new ButtonStateSkin();
            btnSkin.normalState = normaltexture;
            
            var icon:TextureData=new TextureData();
            icon.bitmapData = new BitmapData(16,16,false,0x11667733);
            icon.setUVData(new MRectangle(0,0,16,16),new MPoint(2,2));
            
            var button:Button = new Button();
            button.setStateSkin(btnSkin);
//            button.label = "带图标按钮";
//            button.setIconTexture(icon);
            button.x = 150;
            button.y = 200;
            world.addChild(button);
            
            var diaglogtexture:TextureData = new TextureData(new dialogBG().bitmapData);
            var dialog:Dialog = new Dialog(diaglogtexture);
            dialog.x = 300;
            dialog.y = 50;
            world.addChild(dialog);
            
            
            var listbg:TextureData=new TextureData();
            var list:SimpleList = new SimpleList(listbg);
            list.cellRenderer = TestItem;
            list.model = new DefaultListModel([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]);
            list.setShowSize(300,300);
            list.x = 15;
            list.y = 70;
            dialog.addChild(list);
//            dialog.filters = [new RadialBlurFilter(20)]
//            list.firstindex = 2;
            
            var text:TextField = new TextField();
            text.text = "是是是是是事实事实丝";
            world.addChild(text);
            
            var tab:TabPage = new TabPage(new TextureData());
            tab.setTabBtnSkin(btnSkin);
            tab.setTabLabels(['tab1','tab2','tab3','tab4']);
            dialog.addChild(tab);
            
//            for(var i:int=0;i<1000;++i)
//            {
//            var tx:TextureData = new TextureData((new anim()).bitmapData)
            var sprite:Sprite2D = new Sprite2D(texture);
            sprite.filters = [new RadialBlurFilter(7,0.3,0.17)]
//            sprite.x = Math.random()*800;
//            sprite.y = Math.random()*800;
            sprite.mouseEnabled =false;
            sprite.mouseChildren = false;
            world.addChild(sprite);
//            }
            
        }
        
	}
}