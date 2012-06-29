package mongoose.display
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;

	public class InteractiveObject extends Image
	{
		static public var stage:Stage;
		public var mouseEnabled:Boolean=true;
		public var mouseChildren:Boolean;
		public var alphaTest:Boolean=true;
		public var useHandCursor:Boolean;
		protected var mEventHandles:Dictionary=new Dictionary;
		internal var iuseMove:Boolean;
		internal var iOver:Boolean;
		public function InteractiveObject(texture:TextureData)
		{
			super(texture);
			mEventHandles["enterFrame"]=[];
			if(stage)
			stage.addEventListener(Event.RESIZE,onResize);
		}
		private function onResize(e:Event):void
		{
			this.dispatchEvent(e.clone());
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
			iuseMove = mEventHandles[MouseEvent.MOUSE_OVER]!=null||
				       mEventHandles[MouseEvent.MOUSE_OUT]!=null ||
					   mEventHandles[MouseEvent.MOUSE_MOVE]!=null
			   
		}
		private function addEvent(type:String,listener:Function):void
		{
			if(mEventHandles[type]==null)
				mEventHandles[type]=[];
			if(checkListener(type,listener)==-1)
			{
				mEventHandles[type].push(listener);
			}
		}
		private function delEvent(type:String,listener:Function):void
		{
			var index:int=checkListener(type,listener);
			if(index!=-1)
			{
				mEventHandles[type].splice(index,1);
			}
		}
		internal function triggerEvent(type:String,x:Number,y:Number):void
		{
			if(type==MouseEvent.MOUSE_OVER&&iOver)
				return;
			
			var functions:Array=mEventHandles[type];
			if(functions!=null)
			{
				var step:uint=0;
				var len:uint=functions.length;
				while(step<len)
				{
					functions[step](this,x,y);
					step++;
				}
			}
			if(type==MouseEvent.MOUSE_OVER)iOver=true;
			if(type==MouseEvent.MOUSE_OUT)iOver=false;
		}
		private function checkListener(type:String,listener:Function):int
		{
			var step:uint=0;
			var listeners:Array=mEventHandles[type];
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
					
				case MouseEvent.DOUBLE_CLICK:
					
				case MouseEvent.MOUSE_DOWN:
					
				case MouseEvent.MOUSE_MOVE:
					
				case MouseEvent.MOUSE_OUT:
					
				case MouseEvent.MOUSE_OVER:
					
				case MouseEvent.MOUSE_UP:
					
				case MouseEvent.MOUSE_WHEEL:
					
				case MouseEvent.ROLL_OUT:
					
				case MouseEvent.ROLL_OVER:
					delEvent(type,listener);
					break;
				default:
					super.removeEventListener(type,listener,useCapture);
					break;
			}
		}
	}
}