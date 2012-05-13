package mongoose.display
{
    
    import flash.events.*;

    public class DisplayObjectContainer extends InteractiveObject
    {
        protected var mChilds:Array;
        public var mouseChildren:Boolean=true;
		internal var iTestObject:InteractiveObject;
		
		
		private var _sortBy:String="z";
		private var _sortParam:int=Array.DESCENDING|Array.NUMERIC;
		public var enableSort:Boolean;
		private var _prevObj:InteractiveObject;
		
		private var _step:uint,_len:uint;
		private var _object:InteractiveObject;
		private var _hitObj:InteractiveObject;
        public function DisplayObjectContainer(texture:TextureData = null)
        {
            mChilds = [];
            
            super(texture);
           
        }

        public function addChild(child:DisplayObject) : void
        {
			
            if (!this.hasChild(child))
            {
                this.mChilds.push(child);
				
            }
            child.parent = this;
            dispatchEvent(new Event(Event.ADDED));
        }

        public function hasChild(child:DisplayObject) : Boolean
        {
			_step=0;
			_len = mChilds.length;
            while (_step<_len)
            {
                
                if (mChilds[_step] == child)
                {
                    return true;
                }
				_step++;
            }
            return false;
        }
		
        public function removeChild(object:DisplayObject) : void
        {
			_step=0;
			while(_step<mChilds.length)
			{
				if(mChilds[_step]==object)
				{
					mChilds.splice(_step,1);
					
				}	
				_step++;
			}
            return;
        }

        public function get numChildren() : Number
        {
            return mChilds.length;
        }

        public function addChildAt( child:DisplayObject, index:int ):DisplayObject
        {
            if( index < mChilds.length )
            { 
                mChilds.splice( index, 0 , child );
                child.parent = this;
            }
            else
            {
                mChilds.push( child );
                child.parent = this;
            }
            
            return this;
        }
        
        public function removeChildAt( index:int ):DisplayObject
        {
            if( index > mChilds.length-1 )
                throw new Error('超出子对象列表索引');
            
            mChilds[index].parent = null;
            mChilds.splice( index, 1 );
            
            return this;
        }
        
        public function removeChildren( beginIndex:int=0, endIndex:int=2147483647 ):void
        {
            if( beginIndex<0 ) beginIndex = 0;
            if( endIndex > mChilds.length-1 ) endIndex = mChilds.length-1;
            var step:uint=0;
            while(step<mChilds.length)
            {
                mChilds[step].parent = null;
				step++;
            }
            
            mChilds.splice( beginIndex, endIndex-beginIndex );
        }
        
        public function setChildIndex( child:DisplayObject, index:int ):void
        {
            if( null==child )
                throw new Error('child不能为空');
            
            if( index > mChilds.length-1 ) index = mChilds.length-1;
            
            removeChild( child );
            addChildAt( child, index );
        }
        
        public function swapChildren( child1:DisplayObject, child2:DisplayObject ):void
        {
            var index1:int = mChilds.indexOf( child1 );
            var index2:int = mChilds.indexOf( child2 );
            swapChildrenAt( index1, index2 );
        }
        
        public function swapChildrenAt( index1:int, index2:int ):void
        {
            var child:DisplayObject = mChilds[index1];
            mChilds[index1] = mChilds[index2];
            mChilds[index2] = child;
        }        
        public function getChildIndex( child:DisplayObject ):int
        {
            if( null == child )
                throw new Error('child不能为空对象');
            
            return mChilds.indexOf( child );
        }
        
        public function getChildByName(name:String) : DisplayObject
        {
            return null;
        }

        public function getChildAt(index:uint) : DisplayObject
        {
            return mChilds[index];
        }
		/**
		 *参照Array.sortOn 
		 * @param name 
		 * @param param
		 * 
		 */		
        public function sortOn(name:String,param:int):void
		{
			_sortBy=name;
			_sortParam=param;
		}
        override public function render() : void
        {
			_step=0;
            _len = this.mChilds.length;
			super.render();
			if(enableSort)mChilds.sortOn(_sortBy,_sortParam);
            while (_step< _len)
            {
                
                mChilds[_step].render();
				_step++;
            }
        }
		override internal function hitTest(type:String,x:Number,y:Number):InteractiveObject
		{
			
			_step=0;
			
			var last:InteractiveObject;
			while(_step<mChilds.length)
			{
				_object=mChilds[_step] as InteractiveObject;
				if(_object!=null)
				{
					_hitObj=_object.hitTest(type,x,y);
					if(_hitObj!=null)
					{
						last=_hitObj;
					}
				}
				_step++;
			}
			//trace(last)
			if(last!=null)
			{
				return last;
			}
			else
			{
				return super.hitTest(type,x,y);
			}
		}
		
    }
}
