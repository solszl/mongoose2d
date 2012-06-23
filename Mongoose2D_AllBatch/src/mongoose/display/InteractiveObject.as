package mongoose.display
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;

	public class InteractiveObject extends Image
	{
		
		public var mouseEnabled:Boolean;
		public var mouseChildren:Boolean;
		protected var mEventHandles:Dictionary=new Dictionary;
		public function InteractiveObject(texture:TextureData)
		{
			super(texture);
			mEventHandles["enterFrame"]=[];
		}
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			switch(type)
			{
				case MouseEvent.CLICK:
					
				case MouseEvent.DOUBLE_CLICK:
					
				case MouseEvent.MOUSE_DOWN:
					
				case MouseEvent.MOUSE_MOVE:
					
				case MouseEvent.MOUSE_OUT:
					
				case MouseEvent.MOUSE_OVER:
					
				case MouseEvent.MOUSE_UP:
					
				case MouseEvent.MOUSE_WHEEL:
					
				case MouseEvent.ROLL_OUT:
					
				case MouseEvent.ROLL_OVER:
					
				case Event.ENTER_FRAME:
					addEvent(type,listener);
					break;
				default:
					super.addEventListener(type,listener,useCapture,priority,useWeakReference);
					break;
			}
		}
		private function addEvent(type:String,listener:Function):void
		{
			if(mEventHandles[type]==null)
				mEventHandles[type]=[];
			if(checkListener(type,listener)==-1)
			{
				(mEventHandles[type] as Array).push(listener);
			}
		}
		private function delEvent(type:String,listener:Function):void
		{
			var index:int=checkListener(type,listener);
			if(index!=-1)
			{
				(mEventHandles[type] as Array).splice(index,1);
			}
		}
		private function checkListener(type:String,listener:Function):int
		{
			var step:uint=0;
			var listeners:Array=mEventHandles[type] as Array;
			if(listeners==null)return -1;
			while(step<listeners.length)
			{
				if(listeners[step]==listener)
					return step;
					step++;
			}
			return -1;
		}
		override public function render():void
		{
			var handles:Array=mEventHandles["enterFrame"];
			var step:uint=0;
			var total:uint=handles.length;
			while(step<total)
			{
				handles[step](this);
				step++;
			}
		}
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			switch(type)
			{
				case MouseEvent.CLICK:
					delEvent(type,listener);
					break;
				case MouseEvent.DOUBLE_CLICK:
					delEvent(type,listener);
					break;
				case MouseEvent.MOUSE_DOWN:
					delEvent(type,listener);
					break;
				case MouseEvent.MOUSE_MOVE:
					delEvent(type,listener);
					break;
				case MouseEvent.MOUSE_OUT:
					delEvent(type,listener);
					break;
				case MouseEvent.MOUSE_OVER:
					delEvent(type,listener);
					break;
				case MouseEvent.MOUSE_UP:
					delEvent(type,listener);
					break;
				case MouseEvent.MOUSE_WHEEL:
					delEvent(type,listener);
					break;
				case MouseEvent.ROLL_OUT:
					delEvent(type,listener);
					break;
				case MouseEvent.ROLL_OVER:
					delEvent(type,listener);
					break;
			}
		}
	}
}