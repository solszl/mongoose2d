package mongoose.display
{
    import flash.events.*;
    import flash.utils.Dictionary;

    public class InteractiveObject extends DisplayObject
    {
        protected var handleMap:Dictionary;;
        public function InteractiveObject()
        {
			handleMap=new Dictionary;
            
        }// end function

       
        public function enterFrameEvent(name:String,handle:Function):void
		{
			handleMap[name]=handle;
		}
		public function removeFrameEvent(name:String,handle:Function):void
		{
			if(handleMap[name])
				delete handleMap[name];
		}
		override protected function preRender():void
		{
			super.preRender();
			for each(var handle:Function in handleMap)
			{
				handle(this);
			}
		}
    }
}
