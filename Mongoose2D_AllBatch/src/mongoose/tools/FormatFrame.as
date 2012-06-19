package mongoose.tools
{
    import flash.display.BitmapData;
    import flash.geom.Rectangle;
    
    import mongoose.display.TextureData;


//    import mongoose.geom.Point;
//    import mongoose.geom.Rectangle;
 
 
	/**
	 *固定行列帧资源 格式化
	 * @author popplecui
	 * 
	 */	
	public class FormatFrame
	{
		
		public var data:Vector.<TextureData>;
		/**
		 * 
		 * @param bitmap 帧动画所需位图
		 * @param w 行数量
		 * @param h 列数量
		 * @param start 帧起点
		 * @param end 帧结束点
		 * @example
		   <listing version="3.0">
		     
		     var bd:BitmapData=new BitmapData(1024,128,true,0xffffffff);
			
             var formatFrame:FormatFrame=new FormatFrame(bd,8,4,1,32);
			 var mc:MovieClip=new MovieClip(formatFrame.data,24);
			
			 //todo same as flash.display.MovieClip
           </listing>
		 **/	
		public function FormatFrame(bitmap:BitmapData,w:uint,h:uint,start:int,end:int)
		{
			data=new Vector.<TextureData>;
			var width:uint=bitmap.width;
			var height:uint=bitmap.height;
			var wLen:Number=width/w;
			var hLen:Number=height/h;
			
			
			
			var temp:Vector.<Number>;
			var bmp:TextureData;
			for(var i:uint=start;i<=end;i++)
			{
				//每列中的第几个
				var wPos:int=Math.ceil(i/w)-1;
				//第几行
				var hPos:int=int(w*(i/w-int(i/w)));
				hPos==0?hPos=w-1:hPos--;
				//if(hPos==0){hPos=2-1}else{hPos--}
				/*temp=new Vector.<Number>([
					                        wPos*wLen      ,hPos*hLen,
											wPos*wLen+wLen ,hPos*hLen,
											wPos*wLen+wLen ,hPos*hLen+hLen,
											wPos*wLen,hPos*hLen+hLen
				                         ]);*/
				bmp=new TextureData(bitmap);
				//bmp.bitmapData = bitmap;
				bmp.setUVData(new Rectangle(hPos*wLen,wPos*hLen,wLen,hLen));//,new Point(0,0));
				data.push(bmp);
			}
		}
	}
}