package mongoose.display
{
	import flash.display.BitmapData;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import flashx.textLayout.formats.TextAlign;
	
	import mongoose.geom.MPoint;
	import mongoose.geom.MRectangle;
	import mongoose.math.getUpPower2;
	
	public class TextField extends Image
	{
		public var text:String;
		protected var mTextField:flash.text.TextField;
		public var textWidth:Number,textHeight:Number;
		public var autoSize:String;
		public var wordWarp:Boolean;
		protected var mTextTexture:TextureData;
		protected var mBitmapData:BitmapData
		
		private var _text:String;
		private var _rw:Number,_rh:Number;
		private var _maxWidth:Number,_maxHeight:Number;
		public function TextField()
		{
			
			mTextTexture=new TextureData;
			mTextField=new flash.text.TextField;

		}
		
		public function setTextFormat(format:TextFormat):void
		{

			mTextField.defaultTextFormat=format;
			
		}
		public function set multiline(value:Boolean):void
		{
			mTextField.multiline=value;
		
		}
		public function setText(value:String):void
		{
			if(_text!=value)
			{
				mTextField.text=value;
				mTextField.wordWrap=wordWarp;
				mTextField.autoSize=TextAlign.LEFT;
				//need redraw;
				width=mTextField.width;
				
				
				height=mTextField.height;
				
				_maxWidth=getUpPower2(int(width));
				_maxHeight=getUpPower2(int(height));
				if(mBitmapData==null)
				{
					mBitmapData=new BitmapData(_maxWidth,_maxHeight,true,0xffffff);
				}
				else
				{
					mBitmapData.dispose();
					if(mBitmapData.width!=_maxWidth||mBitmapData.height!=_maxHeight)
					{
						mBitmapData=new BitmapData(_maxWidth,_maxHeight,true,0xffffff);
					}
				}
				mBitmapData.draw(mTextField);
				
				//mTextField.x=100;
				//mTextField.y=100;
				//stage.addChild(new Bitmap(mBitmapData));
				
				mTextTexture.bitmapData = mBitmapData;
				mTextTexture.setUVData(new MRectangle(0,0,width,height),new MPoint(0,0));
				setTexture(mTextTexture);
				_text=value;
			}
			
			
			
			//mBitmapData.draw(mTextField);
			
			//mTextTexture.setBitmap(mBitmapData);
			//mTextTexture.setUVData(new Rectangle(0,0,width,height),new Point(0,0));
			//this.setTexture(mTextTexture);
		}
		
		
	}
}