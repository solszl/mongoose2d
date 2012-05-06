package mongoose.display
{
	import flash.display.BitmapData;
	import flash.display3D.textures.Texture;
	import flash.events.TimerEvent;
	import flash.utils.setInterval;
	
	import mongoose.display.Sprite2D;
	import mongoose.display.TextureData;
	
	import mx.messaging.AbstractConsumer;
	

	public class MovieClip extends Sprite2D
	{
		
		protected var mCurrentFrame:int=0;
		protected var mTotalFrames:uint=0;
		protected var mFrameData:Vector.<TextureData>;
		protected var mPause:Boolean=false;
		
		protected var mFps:uint;
		
		private var _ff:int;
		private var _tf:int;
		public function MovieClip(frames:Vector.<TextureData>,fps:uint=60)
		{
			super();
			mFrameData=frames;
		    mTotalFrames=frames.length;
			mCurrentFrame=1;
			mFps=fps;
			setTexture(frames[0]);
			_ff=Math.round(60/mFps);
		}
		public function set fps(value:uint):void{this.mFps=value;_ff=Math.round(60/mFps)}
	    override protected function preRender():void
		{
			
			if(_tf==_ff)
			{
				updateFrame();
				_tf=0;
			}	
			_tf++;
			super.preRender();
		}
		public function get currentFrame():uint
		{
			return mCurrentFrame;
		}
		
		public function get totalFrames():uint
		{
			return mTotalFrames;
		}
		
		public function gotoAndPlay(value:uint):void
		{
			mCurrentFrame=value;
		}
	    
		protected function updateFrame():void
		{
			if(!mPause)
			{
				mCurrentFrame++;
				//trace("go")
			}
			else
			{
				return;
			}
			if(mCurrentFrame<1)
			{
				mCurrentFrame=1;
			}
		    if(mCurrentFrame>mTotalFrames)
			{
				mCurrentFrame=1;
			}
			
			setTexture(mFrameData[mCurrentFrame-1]);
			
			
		}
		
		public function gotoAndStop(value:uint):void
		{
			mCurrentFrame=value;
			if(mCurrentFrame<1)
			{
				mCurrentFrame=1;
			}
			if(mCurrentFrame>mTotalFrames)
			{
				mCurrentFrame=1;
			}
			setTexture(mFrameData[mCurrentFrame-1]);
			mPause=true;
			
		}
		public function stop():void
		{
			mPause=true;
			
		}
		public function play():void
		{
			mPause=false;
			
		}
	}
}