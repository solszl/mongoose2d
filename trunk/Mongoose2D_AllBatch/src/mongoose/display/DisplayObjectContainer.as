package mongoose.display
{
    
    import flash.events.*;

    public class DisplayObjectContainer extends InteractiveObject
    {
		internal var childs:Array=[];
		
		public var enableSort:Boolean=true;
		
		public var sortName:String="z";
		public var sortParam:int=Array.DESCENDING|Array.NUMERIC;
		
		
		private var _step:uint,_len:uint;
		
		
		
        public function DisplayObjectContainer(texture:TextureData = null)
        {
			childs = [];
            
            super(texture);
           
        }
		/**
		 *添加一个显示对象 
		 * @param child
		 * 
		 */        
        public function addChild(child:DisplayObject) : void
        {
			//modify by gene,  avoid calc via contain()
			if (child.parent == null)
			{
				childs.push(child);
				child.parent = this;
			}
			else
			{
				if(child.parent != this)
				{
					child.parent.removeChild(child);
					childs.push( child );
					child.parent = this;
				}
				else
				{
					this.setChildIndex(child,childs.length-1);
				}
			}
			child.dispatchEvent(new Event(Event.ADDED));
			
			/*
            if (!this.contains(child))
            {
                this.childs.push(child);
				
            }
			else
			{
				this.setChildIndex(child,childs.length-1);
			}
			if(child.parent!=null&&child.parent!=this)
				DisplayObjectContainer(child.parent).removeChild(child);
            child.parent = this;*/
        }
		
		/**
		 *是否包含子对象，如果是返回true，否则返回falsh 
		 * @param child 添加的对象
		 * @return true\false
		 * 
		 */        
        public function contains(child:DisplayObject) : Boolean
        {
			_step=0;
			_len = childs.length;
            while (_step<_len)
            {
                
                if (childs[_step] == child)
                {
                    return true;
                }
				_step++;
            }
            return false;
        }
		/**
		 *移除一个子对象 
		 * @param object
		 * 
		 */		
        public function removeChild(object:DisplayObject) : void
        {
			_step=0;
			while(_step<childs.length)
			{
				if(childs[_step]==object)
				{
					childs.splice(_step,1);
					
				}	
				_step++;
			}
            return;
        }
		/**
		 *返回子对象数量 
		 * @return 
		 * 
		 */        
        public function get numChildren() : Number
        {
            return childs.length;
        }
		/**
		 *添加一个显示对象到指定位置 
		 * @param child 子对象
		 * @param index index
		 * @return 返回对象本身
		 * 
		 */        
        public function addChildAt( child:DisplayObject, index:int ):DisplayObject
        {
            if( index < childs.length )
            { 
				childs.splice( index, 0 , child );
                child.parent = this;
            }
            else
            {
				childs.push( child );
                child.parent = this;
            }
            
            return this;
        }
		/**
		 *移除一个指定位置的显示对象 
		 * @param index
		 * @return 
		 * 
		 */        
        public function removeChildAt( index:int ):DisplayObject
        {
            if( index > childs.length-1 )
                throw new Error('超出子对象列表索引');
            
			childs[index].parent = null;
			childs.splice( index, 1 );
            
            return this;
        }
		/**
		 *移除指定范围内的子对象 
		 * @param beginIndex
		 * @param endIndex
		 * 
		 */        
        public function removeChildren( beginIndex:int=0, endIndex:int=2147483647 ):void
        {
            if( beginIndex<0 ) beginIndex = 0;
            if( endIndex > childs.length-1 ) endIndex = childs.length-1;
            var step:uint=0;
            while(step<childs.length)
            {
				childs[step].parent = null;
				step++;
            }
            
			childs.splice( beginIndex, endIndex-beginIndex );
        }
		/**
		 *设置子对象到指定位置 
		 * @param child 
		 * @param index
		 * 
		 */        
        public function setChildIndex( child:DisplayObject, index:int ):void
        {
            if( null==child )
                throw new Error('child不能为空');
            
            if( index > childs.length-1 ) index = childs.length-1;
            
            removeChild( child );
            addChildAt( child, index );
        }
		/**
		 *交换两个显示对象的位置 
		 * @param child1 对象1
		 * @param child2 对象2
		 * 
		 */        
        public function swapChildren( child1:DisplayObject, child2:DisplayObject ):void
        {
            var index1:int = childs.indexOf( child1 );
            var index2:int = childs.indexOf( child2 );
            swapChildrenAt( index1, index2 );
        }
		/**
		 *交换两个位置上的子对象 
		 * @param index1
		 * @param index2
		 * 
		 */        
        public function swapChildrenAt( index1:int, index2:int ):void
        {
            var child:DisplayObject = childs[index1];
			childs[index1] = childs[index2];
			childs[index2] = child;
        }      
		/**
		 *返回子对象的位置 
		 * @param child
		 * @return 
		 * 
		 */		
        public function getChildIndex( child:DisplayObject ):int
        {
            if( null == child )
                throw new Error('child不能为空对象');
            
            return childs.indexOf( child );
        }
		/**
		 *获取指定位置的显示对象 
		 * @param index
		 * @return 
		 * 
		 */		

        public function getChildAt(index:uint) : DisplayObject
        {
            return childs[index];
        }

        public function getChildByName(name:String):DisplayObject
        {
            for each( var o:DisplayObject in childs )
            {
                if(o.name == name)
                    return o;
            }

            return null;
        }
    }
}
