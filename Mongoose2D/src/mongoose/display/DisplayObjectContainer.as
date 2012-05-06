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
            var step:int;
            var total:uint = mChilds.length;
            while (step<total)
            {
                
                if (mChilds[step] == child)
                {
                    return true;
                }
				step++;
            }
            return false;
        }
		
        public function removeChild(object:DisplayObject) : void
        {
			var step:uint=0;
			while(step<mChilds.length)
			{
				if(mChilds[step]==object)
				{
					mChilds.splice(step,1);
					
				}	
				step++;
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
            var step:uint;
            var total:uint = this.mChilds.length;
			super.render();
			if(enableSort)mChilds.sortOn(_sortBy,_sortParam);
            while (step< total)
            {
                
                mChilds[step].render();
				step++;
            }
        }
		override internal function hitTest(type:String,x:Number,y:Number):Boolean
		{
			iHitObj=null;
			var step:uint=0;
			var obj:InteractiveObject,oop:InteractiveObject;
			var hit:InteractiveObject;
			
			while(step<mChilds.length)
			{
				obj=mChilds[step] as InteractiveObject;
				if(obj!=null)
				{
					
					var re:Boolean=obj.hitTest(type,x,y);
					//if(obj!=null&&prevObj!=null&&type==MouseEvent.MOUSE_MOVE)prevObj.triggerEvent(MouseEvent.MOUSE_OUT);
					if(re)hit=obj.iHitObj;
					
					
				}
				step++;
			}
			if(hit!=null)
			{
				iHitObj=hit;
			}
			else
			{
				if(super.hitTest(type,x,y))
				{
					iHitObj=this;
				}
			}
			if(iHitObj==null)
			    return false;
			else
				return true;
		}
		
    }
}
