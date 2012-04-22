package mongoose.display
{
    import flash.events.*;
    import flash.utils.Dictionary;

    public class InteractiveObject extends DisplayObject
    {
        protected var enterHandle:Array=[];
        public function InteractiveObject()
        {
			
            
        }// end function

       
        public function enterFrameEvent(handle:Function):void
		{
			enterHandle.push(handle);
		}
		public function removeFrameEvent(name:String,handle:Function):void
		{
			
		}
		override protected function preRender():void
		{
			super.preRender();
			var step:uint,item:Object;
			var len:uint=enterHandle.length;
			while(step<len)
			{
				enterHandle[step](this);
				step++;
			}
		}
    }
}
