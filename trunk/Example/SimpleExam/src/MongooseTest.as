package
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.ui.Mouse;
	
	import mongoose.core.Camera;
	import mongoose.core.World;
	import mongoose.display.DisplayObject;
	import mongoose.display.Sprite2D;
	import mongoose.display.TextureData;
	import mongoose.geom.Point;
	import mongoose.geom.Rectangle;
	
	import tools.FrameRater;

	[SWF(frameRate="120",width="2048",height="1024",backgroundcolor="0xffffff")]
	public class MongooseTest extends Sprite
	{
		[Embed(source="fighter.png")]
		private var fighter:Class;
		private var world:World;
		private var texture:TextureData;
		public function MongooseTest()
		{
			world=new World(stage,new Rectangle(0,0,400,300));
			//world.initialize(stage,);
			world.addEventListener(Event.COMPLETE,onStart);
			world.fullScreen=true;
			world.showFps(true);
			//world.x=10;
			world.start();
		}
		private function onStart(e:Event=null):void
		{
			
			trace("COMPLETE");
			texture=new TextureData;
		    texture.setBitmap(Bitmap(new fighter).bitmapData);
			texture.setUVData(new Rectangle(5,25,64,128),new Point(0,0));
		
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN,onCK);
			stage.addEventListener(MouseEvent.MOUSE_UP,onCK);
			stage.addEventListener(TouchEvent.TOUCH_MOVE,onAddRoll);
		
			createRols(1600);
			//Camera.current.enterFrameEvent(Event.ENTER_FRAME,onCamera);
		}
		private function onCamera(tar:Camera):void
		{
			tar.z+=10;
		}
		private function createRols(num:uint):void
		{
			for(var i:uint=0;i<num;i++)
			{
				var sprite1:Sprite2D=new Sprite2D(texture);
				sprite1.x=Math.random()*world.width;
				sprite1.y=Math.random()*world.height;
				sprite1.rotateZ=Math.random()*360;
				sprite1.enterFrameEvent("enterFrame",onEnter);
				sprite1.data=Math.random()*5;
				sprite1.color=Math.random()*0xffffff;
				sprite1.alpha=Math.random()*1;
				sprite1.z=Math.random()*10000;
				world.addChild(sprite1);
			}
		}
		private function onCK(e:MouseEvent):void
		{
			if(e.type==MouseEvent.MOUSE_DOWN)
			    stage.addEventListener(MouseEvent.MOUSE_MOVE,onAddRoll);
			else
				stage.removeEventListener(MouseEvent.MOUSE_MOVE,onAddRoll);
		}
		private function onAddRoll(e:MouseEvent):void
		{
			createRols(5);
		}
		private function onEnter(tar:DisplayObject):void
		{
			//var tar:Sprite2D=Sprite2D(e.currentTarget);
			tar.x+=tar.data;
			
			//tar.rotateZ+=.1;
			if(tar.x>world.width+100)tar.x=-100;
		}
	}
}