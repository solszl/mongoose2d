package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import mongoose.display.Sprite2D;
	import mongoose.display.TextureData;
	import mongoose.display.World;
	import mongoose.geom.MRectangle;
	
	public class MusicGame extends Sprite
	{
		[Embed(source="arrow.png")]
		private var arrowData:Class;
		private var arrow:BitmapData;
		private var world:World;
		private var arrowTex:TextureData;
		private var arrows:Array=[];
		public function MusicGame()
		{
			arrow=Bitmap(new arrowData).bitmapData;
			
			world=new World(stage,new MRectangle(0,0,960,560));
			world.addEventListener(Event.COMPLETE,onComplete);
			world.showFps(true);
			world.start();
		}
		private function onComplete(e:Event):void
		{
			arrowTex=new TextureData();
			arrowTex.bitmapData=arrow;
			for(var i:uint=0;i<400;i++)
			{
				var sprite:Sprite2D=new Sprite2D(arrowTex);
				    sprite.setRegisterPoint(-.5,1,0);
					sprite.x=200;
					sprite.y=200;
					world.addChild(sprite);
			}
		}
	}
}