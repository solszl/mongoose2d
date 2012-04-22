package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.ui.Mouse;
	
	import mongoose.core.Camera;
	import mongoose.core.World;
	import mongoose.display.DisplayObject;
	import mongoose.display.MovieClip;
	import mongoose.display.Sprite2D;
	import mongoose.display.TextureData;
	import mongoose.geom.Point;
	import mongoose.geom.Rectangle;
	
	import tools.FormatFrame;
	import tools.FrameRater;

	[SWF(frameRate="120",width="1920",height="700",backgroundcolor="0xffffff")]
	public class MongooseTest extends Sprite
	{
		[Embed(source="fighter.png")]
		private var fighter:Class;
		private var world:World;
		private var texture:TextureData;
		
		private var rols:Vector.<DisplayObject>;
		private var t:Number=0;
		
		private var bd:BitmapData;
		private var frameData:FormatFrame;
		public function MongooseTest()
		{
			bd=(new fighter as Bitmap).bitmapData;
			rols=new Vector.<DisplayObject>;
			world=new World(stage,new Rectangle(0,0,640,400));
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
		    texture.setBitmap(bd);
			texture.setUVData(new Rectangle(0,0,64,128),new Point(0,0));
		    
			frameData=new FormatFrame(bd,16,1,1,11);
			stage.addEventListener(MouseEvent.MOUSE_DOWN,onCK);
			stage.addEventListener(MouseEvent.MOUSE_UP,onCK);
			stage.addEventListener(TouchEvent.TOUCH_MOVE,onAddRoll);
			stage.addEventListener(Event.RESIZE,onResize);
		    //stage.addEventListener(Event.ENTER_FRAME,onFrame);
			createRols(1600);
			//Camera.current.enterFrameEvent(Event.ENTER_FRAME,onCamera);
		}
		
		private function onCamera(tar:Camera):void
		{
			tar.z+=10;
			var num:Number=Number(2);
			
			/*tar.x=world.width/4*Math.sin(num*.1+(num*.01+t));
			tar.y=world.height/6*Math.sin(num*.1+(num*.01+t));*/
			
			tar.z=10000*Math.sin(num*t+(num*.01+t));
			
		}
		private function onResize(e:Event):void
		{
			for(var i:uint=0;i<rols.length;i++)
			{
				rols[i].x=world.width/2;
				rols[i].y=world.height/2;
			}
		}
		private function createRols(num:uint):void
		{
			
			for(var i:uint=0;i<num;i++)
			{
				texture=new TextureData;
				texture.setBitmap(bd);
				var f:uint=int(Math.random()*10);
				if(i==num-1)
				{
					f=0;
				}
				texture.setUVData(new Rectangle(f*64,0,64,128),new Point(0,0));
				var sprite1:MovieClip=new MovieClip(frameData.data,24);
				
				//sprite1.rotateZ=Math.random()*360;
				sprite1.enterFrameEvent(onEnter);
				sprite1.data=i;
				sprite1.x=world.width/2;
				sprite1.y=world.height/2;
				
                sprite1.color=Math.random()*0xffffff;
				//sprite1.scaleX=sprite1.scaleY=(Math.sqrt((i)*.001));
				//if(i==0)sprite1.color=0xffffff;
				//sprite1.alpha=Math.random()*1.0;
				
				//sprite1.alpha=Math.random()*1;
				//sprite1.z=i*50;
				//sprite1.x=0;//world.width/2;
				//sprite1.y=0;
				
				world.addChild(sprite1);
				rols.push(sprite1);
				
			}
			//sprite1.scaleX=sprite1.scaleY=2.5;
			//sprite1.x-=10;
			//sprite1.y-=30;
			//sprite1.color=0xffffff;
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
			
			num++;
			tar.data=num;
			
			tar.y+=Math.cos(num*(.6/world.height)+(num*.04+t))*2//world.height*.2*Math.cos(num*.01+(num*.001+t))+world.height/2;
			tar.x+=Math.sin(num*(.8/world.width)+(num*.01+t))*2;
			//tar.rotateZ
			//tar.scaleX=tar.scaleY=1.5;
			//tar.alpha=Math.sin(num*.01);
			tar.z=5000*Math.sin(num*.09+(num*.001+t))+3000;
			tar.rotateZ=Math.sin(num*.06+(num*.0001+t))*60;
			
			//tar.color=Math.sin(num*.006+(num*.001+t))*0xffff;
			//tar.rotateY=Math.sin(num*.006+(num*.001+t))*180;
			//tar.color=Math.random()*0x00ff00;
			//tar.x+=(Number(num)*.01);
			//tar.rotateZ+=.1;
			//tar.data+=.3;
			
		}
	}
}