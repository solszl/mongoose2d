package mongoose.display
{
    
    import flash.events.*;

    public class DisplayObjectContainer extends InteractiveObject
    {
        protected var mChilds:Vector.<DisplayObject>;

        public function DisplayObjectContainer()
        {
            mChilds = new Vector.<DisplayObject>;
           
        }// end function

        public function addChild(child:DisplayObject) : void
        {
            if (!this.hasChild(child))
            {
                this.mChilds.push(child);
            }
            child.parent = this;
            dispatchEvent(new Event(Event.ADDED));
        }// end function

        private function hasChild(child:DisplayObject) : Boolean
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
        }// end function

        public function removeChild(uint:DisplayObject) : void
        {
            return;
        }// end function

        public function get numChildren() : Number
        {
            return 0;
        }// end function

        public function getChildByName(name:String) : DisplayObject
        {
            return null;
        }// end function

        public function getChildByIndex(index:uint) : DisplayObject
        {
            return null;
        }// end function

        override public function render() : void
        {
            var step:uint;
            var total:* = this.mChilds.length;
            while (step< total)
            {
                
                mChilds[step].render();
				step++;
            }
			super.render();
        }// end function

    }
}
