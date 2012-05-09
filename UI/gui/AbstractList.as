package gui
{
    import flash.events.Event;
    import flash.events.MouseEvent;
    
    import gui.model.IListModel;
    
    import mongoose.display.DisplayObject;
    import mongoose.display.TextureData;
    
    public class AbstractList extends Component
    {
        public function AbstractList(texture:TextureData=null)
        {
            super(texture);
        }


        /**
         * @private
         */
        protected var __initItemed:Boolean = false;
        /**
         * @private
         * items length
         */
        protected var _itemCount:Number = 0; 
        /**
         * @private
         * cellRenderer BaseItem
         */
        protected var _cellRenderer:Class;
        /**
         * @private
         */
        protected var items:Array = [];
        /**
         * @private
         */
        protected var _sepW:int = 2;
        /**
         * @private
         */
        protected var _sepH:int = 2;
        /**
         * @private
         */
        protected var itemWidth:Number;
        /**
         * @private
         */
        protected var itemHeight:Number;
        /**
         * @private
         */
        protected var oldFirstIndex:int = -10;
        //}	
        /**
         * 
         * @param	sepW   水平方向两个item的间隔
         * @param	sepH   竖直方向两个item的间隔
         */
        public function setSeperate(sepW:int=0,sepH:int=0):void
        {
            this.sepW = sepW;
            this.sepH = sepH;
        }	
        /**
         * 水平方向两个item的间隔
         */
        public function set sepW(value:int):void
        {
            _sepW = value;
        }
        public function get sepW():int
        {
            return _sepW;
        }
        /**
         * 竖直方向两个item的间隔
         */
        public function set sepH(value:int):void
        {
            _sepH = value;
        }
        public function get sepH():int
        {
            return _sepH;
        }
        /**
         * item的类
         */
        public function get cellRenderer():Class
        {
            return _cellRenderer;
        }
        public function set cellRenderer(value:Class):void
        {
            var test:* = new value();
            itemWidth = test.width;
            itemHeight = test.height;
            test = null;
            //-------------------------
            _cellRenderer = value;
        }
        //}
        //{--------------show size----------------
        /**
         * @private
         */
        protected var _showHeight:Number;
        /**
         * @private
         */
        protected var _showWidth:Number;
        /**
         * 显示的高度
         */
        public function get showHeight():int
        {
            return _showHeight;
        }
        /**
         * 显示的宽度
         */
        public function get showWidth():int
        {
            return _showWidth;
        }
        /**
         * 设置显示的大小
         */
        public function setShowSize(w:Number,h:Number):void
        {
            _showWidth = w;
            _showHeight = h;
            //
            initItem();
            updateItem(false);
        }
        //}-----------------------------
        /**
         * 单屏显示的item数量
         */
        public function set itemCount(value:Number):void
        {
            _itemCount = value;
        }
        public function get itemCount():Number
        {
            _itemCount = int((showHeight + sepH) / (itemHeight + sepH));
            return _itemCount;
        }
        
        /**
         * 选中item的数据
         */
        public function get selectedData():Object
        {
            return model.selectedData;
        }
        /**
         * 选中item的索引
         */
        public function set selectedIndex(index:int):void
        {
            model.selectedIndex = index;
            scrollToIndex(index);
            updateItem(false);
        }
        public function get selectedIndex():int
        {
            return model.selectedIndex;
        }
        /**
         * @private
         */
        protected function refreshItems():void
        {	
            if (!model) return;
            var item:*;
            //trace('_firstindex===',firstindex);
            for(var i:uint=0;i<_itemCount;i++)
            {
                item = items[i];
                if (item)
                {
                    if(_model.count > i + firstindex)
                    {
                        item.show(_model.getDataByIndex(firstindex + i));
                        moveItem(item, i);
                        item.selected = (firstindex + i == model.selectedIndex);
                    }
                    else
                    {
                        item.hide();
                    }
                }
            }
            oldFirstIndex = firstindex;
        }
        
        
        
        
        /**
         * @private
         */
        public function updateItem(checkFirstIndex:Boolean=true):void
        {
            if (!__initItemed) return;
            if (oldFirstIndex == firstindex && checkFirstIndex) return;
            //--------------------------------------------------------
        }
        /**
         * @private
         */
        protected function updateItemNow():void
        {
            //如果向上滚动一个item，不需要全部刷新内容，只需要把第一个元素放到最后就可以了
            if (oldFirstIndex == firstindex - 1)
            {
                items.push(items.shift());
            }//同理，向下滚动一个item
            else if (oldFirstIndex == firstindex + 1)
            {
                items.unshift(items.pop());
            }
            refreshItems();
        }
        //--------------------------------------------------
        //
        /**
         * 设置item的位置
         * @private
         */
        protected function moveItem(item:*,i:int):void
        {
            item.y = i * (itemHeight + sepH);
        }
        
        //
        protected var _firstindex:int = 0;
        /**
         * 当前页第一个可见data的index
         */
        public function get firstindex():int
        {	
            return _firstindex;
        }
        public function set firstindex(index:int):void
        {
            trace(index ,'>', model.count);
            if (index < 0) index = 0;
            else if (index > model.count) return;
            _firstindex = index;
            gridY = index * (itemHeight + sepH);
        }
        /**
         * 当前页最后一个可见data的index
         */
        public function get lastindex():int
        {
            return itemCount - 2 + firstindex;
        }
        
        //{grid
        /**
         * 竖直方向滚动的位置
         */
        protected var __y:Number;
        protected var __x:Number;
        public function set gridY(value:int):void
        {
            __y = -value;
            updateItem(false);
        }
        public function get gridY():int
        {
            return -__y;
        }
        /**
         * 水平方向滚动的位置
         */
        public function set gridX(value:int):void
        {
            //x = -value;
        }
        public function get gridX():int
        {
            return 0;// -x;
        }
        /**
         * @private
         */
        protected var _model:IListModel;
        /**
         * 数据中心
         */
        public function get model():IListModel
        {
            return _model;
        }
        public function set model(value:IListModel):void
        {
            if (_model)
            {
                _model.removeEventListener('change', modelChange);
            }
            _model = value;
            _model.addEventListener('change', modelChange);
            modelChange(null);
        }
        /**
         * @private
         */
        protected function modelChange(e:Event):void
        {
            //这里需要先广播让scrollpane计算,然后才是渲染自己
            dispatchEvent(new Event('heightChange'));
            updateItem(false);
        }
        /**
         * @private
         */
        protected function initItem():void
        {
            __initItemed = true;
            if (itemCount == items.length) return;
            //-------------------------------------
            var tempItems:Array = items.concat();
            items = [];
            //
            var item:*;
            var itemslen:int = tempItems.length;
            var len:int = Math.max(tempItems.length,itemCount);
            for(var i:uint=0;i<len;i++)
            {
                if(i<itemCount)
                {
                    if(i >= tempItems.length)
                    {
                        item = new cellRenderer();	
//                        item.tabEnabled = false;
                        item.width = _showWidth;
                        //item.drawNow();
                        initItemEvent(item);
                    }
                    else item = tempItems[i];
                    //----------------------------
                    items.push(item);
                    addChild(item);
                }
                else
                {
                    
                    if(tempItems[i] != null)
                    {
                        if (tempItems[i].parent) 
                        {
                            tempItems[i].parent.removeChild(tempItems[i]);
                        }
                        
                        //需要销毁掉
                        tempItems[i].dispose();
                        tempItems[i] = null;
                    }
                    
                }
            }
            tempItems = null;
            //--------------------
            updateItemNow();
        }
        /**
         * @private
         */
        protected function initItemEvent(item:*):void
        {
            item.addEventListener(Event.CHANGE, itemChange);
            item.addEventListener(MouseEvent.CLICK, itemClick);
            item.addEventListener(MouseEvent.MOUSE_DOWN, itemPress);
        }
        /**
         * @private
         */
        protected function itemChange(e:Event):void
        {
            e.stopPropagation();
            var item:* = e.target;
            model.selectedIndex = firstindex + items.indexOf(item);
            updateItem(false);
            dispatchEvent(new Event("change",true));
        }
        /**
         * @private
         */
        protected function itemPress(target:DisplayObject):void
        {
        }
        /**
         * @private
         */
        protected function itemClick(target:DisplayObject):void
        {
        }
        
        /**
         * 滚动到目标索引
         * @param	toindex
         */
        public function scrollToIndex(toindex:int):void
        {
        }
    }
}