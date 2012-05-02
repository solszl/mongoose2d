package mongoose.display
{
    
    import flash.events.*;

    public class DisplayObjectContainer extends InteractiveObject
    {
        protected var mChilds:Vector.<DisplayObject>;
        public var mouseChildren:Boolean=true;
		internal var iTestObject:InteractiveObject;
        public function DisplayObjectContainer(texture:TextureData = null)
        {
            mChilds = new Vector.<DisplayObject>;
            
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
            
            for( var i:int=beginIndex; i<=endIndex; ++i )
            {
                mChilds[i].parent = null;
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

        override public function render() : void
        {
            var step:uint;
            var total:* = this.mChilds.length;
			super.render();
            while (step< total)
            {
                
                mChilds[step].render();
				step++;
            }
        }
        override internal function onMouseEvent(type:String, x:Number, y:Number,view:Number):Boolean
		{
			var hit:Boolean;
			//var obj:DisplayObject;
			var index:uint;
			if(mouseChildren)
			{
				var step:uint=0;
				var obj:InteractiveObject,oop:InteractiveObject;
				
				while(step<mChilds.length)
				{
					obj=mChilds[step] as InteractiveObject;
					if(obj!=null)
					{
						hit=obj.onMouseEvent(type,x,y,view);
						if(hit)
						{
							oop=obj;
						}
					}
					step++;
				}
			}
			//记录当前被点中的对象
			iTestObject=oop;
			if(mouseEnabled)
			{
				hit=super.onMouseEvent(type,x,y,view);
				if(iTestObject==null&&hit)
				{
					//如果子对象没有被点中,且自身被点中则记录自己
					iTestObject=this;
				}
			}
			
			return hit;
		}
		
		/*override internal function _passMouseEvent(event:MouseEvent, isBubbled:Boolean=false):Boolean
		{
			//假如是禁止鼠标的，那直接向上冒泡
			if(!mMouseEnabled)
			{
				return false;
			}
			
			//假如是冒泡上来的 只需要继续向上冒泡
			if(isBubbled)
			{
				switch(event.type)
				{
					case 'click':
					{
						_mouseClick(event);
						break;
					}
					case 'mouseDown':
					{
						_mouseDown(event);
						break;
					}
					case 'mouseUp':
					{
						_mouseUp(event);
						break;
					}
				}
				
				if(parent)
					parent._passMouseEvent(event, true);
				
			}
			else
			{
				//是否有孩子响应了鼠标事件
				var hasTriggerChild:Boolean = false;
				
				if(mMouseChildren)
				{
					var len:uint = mChilds.length;
					//倒序检测
					for( var i:int = len-1; i >= 0;  --i )
					{
						if( mChilds[i] is InteractiveObject )
						{
							if( InteractiveObject(mChilds[i])._passMouseEvent( event ) )
							{
								hasTriggerChild = true;
								break;
							}
							else
								continue;
						}
					}
				}
				
				//没有孩子响应，就检测是否点在自己身上
				if( !hasTriggerChild )
				{
					if( super._passMouseEvent( event ) && parent )
					{
						parent._passMouseEvent( event, true );
						return true;
					}
					return false;
					
					//                    return super._passMouseEvent( event );
				}
				else
				{
					return true;
				}   
				
			}
			
			return false;
		}*/
    }
}
