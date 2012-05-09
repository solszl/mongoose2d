package gui
{
	import flash.events.*;
	import flash.geom.*;
	
	import mongoose.display.TextureData;
	
	public class BaseList extends AbstractList /*implements IFocusManagerComponent,IScrollContent*/
	{
		/**
		 * 
		 * @param	sepW   水平方向两个item的间隔
		 * @param	sepH   竖直方向两个item的间隔
		 */
		public function BaseList(texture:TextureData=null)
		{
			super(texture);
		}	
		/**
		 * 获取list的宽高占位
		 * @return
		 */
		public function getSize():Rectangle
		{
			var _tempRect:Rectangle = new Rectangle(0, 0, itemWidth?itemWidth:_showWidth-1/*width?width:_showWidth*/, model?model.count * (itemHeight+sepH)-sepH:0);	
			return _tempRect;
		}
		/**
		 * 单屏显示的item数量
		 */
		override public function set itemCount(value:Number):void
		{
			_showHeight = (value-  1) * (itemHeight + sepH) - sepH;
			setShowSize(showWidth, _showHeight);
		}
		override public function get itemCount():Number
		{
			_itemCount = int((showHeight + sepH) / (itemHeight + sepH)) + int(hasHalfItem) + 1;
			return _itemCount;
		}
		/**
		 * 是否有只能显示一部分的item，这个会影响itemCount的计算
		 */
		public function get hasHalfItem():Boolean
		{
			return (showHeight+sepH)%(itemHeight+sepH)!=0;
		}		
		//}
		/**
		 * 设置item的位置
		 * @private
		 */
		override protected function moveItem(item:*,i:int):void
		{
			item.y = (i + firstindex) * (itemHeight + sepH);
		}
		/**
		 * 当前页第一个可见data的index
		 */
		override public function get firstindex():int
		{	
			var sy = -y;
			if (sy < 0 ) 
			{
				sy = 0;
				y = 0;
			}
			return int( sy / (itemHeight + sepH));
		}
		override public function set firstindex(index:int):void
		{
			trace(index ,'>', model.count);
			if (index < 0) index = 0;
			else if (index > model.count) return;
			gridY = index * (itemHeight + sepH);
		}
		/**
		 * 当前页最后一个可见data的index
		 */
		override public function get lastindex():int
		{
			return itemCount - 2 + firstindex;
		}
		/**
		 * 竖直方向滚动的位置
		 */
		override public function set gridY(value:int):void
		{
			y = -value;
			updateItem(false);
		}
		override public function get gridY():int
		{
			return -y;
		}
		/**
		 * 水平方向滚动的位置
		 */
		override public function set gridX(value:int):void
		{
			x = -value;
		}
		override public function get gridX():int
		{
			return -x;
		}
		/**
		 * 滚动到目标索引
		 * @param	toindex
		 */
		override public function scrollToIndex(toindex:int):void
		{
			var index:int = toindex;
			if (index > firstindex && index < lastindex) return;
			if (index >= lastindex) index = index + firstindex - lastindex + 2;
			//
			gridY = (index)*(itemHeight+sepH);
			//广播
			dispatchEvent(new Event('scroll',true));
		}
		//
	}
}