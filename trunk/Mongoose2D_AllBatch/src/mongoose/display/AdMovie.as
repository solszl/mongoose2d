package mongoose.display
{
	import flash.utils.Dictionary;
	
	import mongoose.display.MovieClip;
	import mongoose.display.TextureData;
	
	public class AdMovie extends MovieClip
	{
		private var _map:Dictionary=new Dictionary;
		public function AdMovie()
		{
			
		}
		public function addClip(name:String,data:Vector.<TextureData>):void
		{
			_map[name]=data;
		}
		public function playClip(name:String,fps:int=60):void
		{
			this.fps=fps;
			if(_map[name])
			frames=_map[name];
			else
			{
				throw Error( new Error("movie:"+name+"is not exited"));
			}
		}
	}
}