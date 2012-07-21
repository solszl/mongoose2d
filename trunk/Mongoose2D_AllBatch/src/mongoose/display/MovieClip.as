package mongoose.display
{
	import flash.display3D.textures.Texture;

	public class MovieClip extends Sprite2D
	{
		public var currentFrame:uint=1;
		public var totalFrames:uint=0;
		private var _fps:int;
		private var _pause:Boolean;
		private var _frames:Vector.<TextureData>;
		private var _step:uint;
		private var _delay:uint;
		public function MovieClip(frames:Vector.<TextureData>=null,fps:int=24)
		{
			if(frames==null)return;
			this.fps=fps;
			_frames=frames;
			currentFrame=1;
			
			this.texture=_frames[currentFrame-1];
		}
		public function set frames(value:Vector.<TextureData>):void
		{
			_frames=value;
			currentFrame=1;
		}
		public function set fps(value:int):void
		{
			_fps=value;
			_delay=Math.round(60/value);
		}
		override public function render():void
		{
			if(!_pause&&_frames!=null)
			{
				if(_step==_delay)
				{
					currentFrame++;
					if(currentFrame>_frames.length)
						currentFrame=1;
					this.texture=_frames[currentFrame-1];
					
					_step=0;
				}
				else
				{
					_step++;
				}
			}
			super.render();
		}
		
		public function gotoAndPlay(frame:int):void
		{
			currentFrame=frame;
		}
		public function play():void
		{
			_pause=false;
		}
		public function stop():void
		{
			_pause=true;
		}
	}
}