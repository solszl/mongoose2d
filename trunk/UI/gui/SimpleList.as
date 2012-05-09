package gui
{
	import flash.events.Event;
	
	import gui.AbstractList;
	
	import mongoose.display.TextureData;

	public class SimpleList extends AbstractList
	{
		public function SimpleList(texture:TextureData=null)
		{
			super(texture);
		}
		
		public function setSize(width:Number, height:Number):void 
		{
			this.width = width;
            this.height = height;
			setShowSize(width, height);
		}
		//-----------------------------------------------------------------
		override protected function initItem():void 
		{
			super.initItem();
			updatePage();
		}
		//
		override protected function modelChange(e:Event):void 
		{
			super.modelChange(e);
			updatePage();
		}
		//
		public function updatePage():void
		{
			//pageSize  pageCount  currentPage
			pageSize = itemCount;
			pageCount= Math.ceil(model.count / itemCount);
		}
		//
		//{page...
		public var pageSize:uint;
		public var pageCount:uint;
		//{currentPage
		public function set page(value:uint):void
		{
			firstindex = value * pageSize;
		}
		public function get page():uint
		{
			return Math.floor(firstindex / pageSize);
		}
		//}
		//}
		
	}
}