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
		
		private var rols:Vector.<DisplayObject>;
		private var t:Number=0;
		public function MongooseTest()
		{
			rols=new Vector.<DisplayObject>;
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
		    //stage.addEventListener(Event.ENTER_FRAME,onFrame);
			createRols(1600);
			Camera.current.enterFrameEvent(Event.ENTER_FRAME,onCamera);
		}
		
		private function onCamera(tar:Camera):void
		{
			tar.z+=10;
			var num:Number=Number(2);
			
			/*tar.x=world.width/4*Math.sin(num*.1+(num*.01+t));
			tar.y=world.height/6*Math.sin(num*.1+(num*.01+t));*/
			
			tar.z=10000*Math.sin(num*t+(num*.01+t));
			
		}
		private function createRols(num:uint):void
		{
			
			for(var i:uint=0;i<num;i++)
			{
				var sprite1:Sprite2D=new Sprite2D(texture);
				
				sprite1.rotateZ=Math.random()*360;
				sprite1.enterFrameEvent("enterFrame",onEnter);
				sprite1.data=i;
				
				sprite1.color=Math.random()*0xffffff;
				//sprite1.alpha=Math.random()*1;
				//sprite1.z=i*10;
				sprite1.x=Math.random()*world.width;//world.width/2;
				sprite1.y=Math.random()*world.height;
				world.addChild(sprite1);
				rols.push(sprite1);
				
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
			
			var num:Number=Number(tar.data);
			//var k:Number=Math.sin(num*.1+(num*.1+t*2));
			//var tar:Sprite2D=Sprite2D(e.currentTarget);
			//tar.x=Math.cos(Number(tar.data)+Number(tar.data)*2)*world.width;
			
			var k:Number=Math.random()*100;
			var g:Number=2;
			if(k>90)g=Math.random()*10;
			
			
			var cx:Number=Math.cos(num*.1)*g;
			var cy:Number=Math.sin(num*.1)*g;
			
			
			num++;
			tar.data=num;
			
			tar.y=world.height*.2*Math.cos(num*.001+(num*.01+t))+world.height/2;
			tar.x+=Math.sin(num*.008+(num*.001+t))*2;
			
			tar.z=5000*Math.sin(num*.09+(num*.01+t))+3000;
			
			//tar.color=Math.random()*0x00ff00;
			//tar.x+=(Number(num)*.01);
			//tar.rotateZ+=.1;
			//tar.data+=.3;
			if(tar.x>world.width+100)tar.x=-100;
		}
	}
}