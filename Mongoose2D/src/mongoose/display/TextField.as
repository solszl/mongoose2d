package mongoose.display
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import flashx.textLayout.formats.TextAlign;
	
	import mongoose.geom.MPoint;
	import mongoose.geom.MRectangle;
	import mongoose.math.getUpPower2;
	
	public class TextField extends Image
	{
		protected var mTextField:flash.text.TextField;
		public var textWidth:Number,textHeight:Number;
		public var autoSize:String;
		public var wordWarp:Boolean;
		protected var mTextTexture:TextureData;
		protected var mBitmapData:BitmapData
		
		private var _text:String;
		private var _rw:Number,_rh:Number;
		private var _maxWidth:Number,_maxHeight:Number;
		private var _format:TextFormat;
        
		public function TextField()
		{
			mTextField=new flash.text.TextField;
		}
		
		public function setTextFormat(format:TextFormat):void
		{
			_format=format;
			mTextField.defaultTextFormat=format;
			mTextField.setTextFormat(_format);
		}
        
		public function set multiline(value:Boolean):void
		{
			mTextField.multiline=value;
		}
        
		public function set text(value:String):void
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
//					if(mBitmapData.width!=_maxWidth||mBitmapData.height!=_maxHeight)
//					{
						mBitmapData=new BitmapData(_maxWidth,_maxHeight,true,0xffffff);
//					}
				}
				mBitmapData.draw(mTextField);
				
//                var tx:Bitmap = new Bitmap(mBitmapData)
//                tx.x = 100;
//                tx.y = 100;
//				stage.addChild(tx);
				
                if(mTextTexture==null)
                {
                    mTextTexture=new TextureData(mBitmapData);
                }
                else
                {
                    mTextTexture.bitmapData = mBitmapData;
                }
				
				mTextTexture.setUVData(new Rectangle(0, 0, mBitmapData.width, mBitmapData.height));
				setTexture(mTextTexture);
                
				_text=value;
			}
			
			
			
			//mBitmapData.draw(mTextField);
			
			//mTextTexture.setBitmap(mBitmapData);
			//mTextTexture.setUVData(new Rectangle(0,0,width,height),new Point(0,0));
			//this.setTexture(mTextTexture);
		}
		
		public function get text():String
		{
			return _text;
		}
	}
}