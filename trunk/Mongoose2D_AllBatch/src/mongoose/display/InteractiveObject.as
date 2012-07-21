package mongoose.display
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;

	/**
	 * 可交互的图像对象
	 * 
	 */	
	public class InteractiveObject extends Image
	{
		static public var stage:Stage;        // 最底层的容器
		
		public var mouseEnabled:Boolean=true; // 受否对鼠标有感应？
		
		public var mouseChildren:Boolean;     // 是否鼠标子？
		
		public var alphaTest:Boolean=true;    // 是否进行Alpha测试
		
		public var useHandCursor:Boolean;     // 是否使用手型光标
		
		protected var mEventHandles:Dictionary=new Dictionary; // 事件字典
		
		internal var iuseMove:Boolean;                         // 是否对鼠标移动有感应
		
		internal var iOver:Boolean;                            // 是否对鼠标悬停有感应
		
		private var enterFrames:Array;                         // 进入每桢的回调数组
			
		public function InteractiveObject(texture:TextureData)
		{
			super(texture);
			enterFrames=mEventHandles["enterFrame"]=[];
			
			if(stage != null)
			{
				stage.addEventListener(Event.RESIZE,onResize);
			}
		}
		
		/**
		 *响应Resize 
		 * @param e
		 * 
		 */		
		private function onResize(e:Event):void
		{
			this.dispatchEvent(e.clone());
		}
		
		/**
		 *添加事件监听 
		 * @param type              事件类型
		 * @param listener          监听者
		 * @param useCapture        是否使用Capture
		 * @param priority          优先级
		 * @param useWeakReference  是否使用弱引用
		 * 
		 */		
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
		
		/**
		 *具体实现添加事件监听 
		 * @param type
		 * @param listener
		 * 
		 */		
		private function addEvent(type:String,listener:Function):void
		{
			if(mEventHandles[type]==null)
				mEventHandles[type]=[];
			if(checkListener(type,listener)==-1)
			{
				mEventHandles[type].push(listener);
			}
		}
		
		/**
		 *删除事件监听 
		 * @param type
		 * @param listener
		 * 
		 */		
		private function delEvent(type:String,listener:Function):void
		{
			var index:int=checkListener(type,listener);
			if(index!=-1)
			{
				mEventHandles[type].splice(index,1);
			}
		}
		
		/**
		 *触发事件 
		 * @param type
		 * @param x ？
		 * @param y ？
		 * 
		 */		
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
		
		/**
		 *检测监听者情况 
		 * @param type
		 * @param listener
		 * @return -1代表监听者为空，否则返回监听者所在事件队列中的位置
		 * 
		 */		
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
		
		/**
		 *进入桢中执行的操作（不包括渲染） 
		 * 
		 */
		override public function render():void
		{
			//var handles:Array=mEventHandles["enterFrame"];
			var step:uint=0;
			var total:uint=enterFrames.length;
			if(total==0)return;
			while(step<total)
			{
				enterFrames[step](this);
				step++;
			}
		}
		
		/**
		 *删除事件监听者 
		 * @param type
		 * @param listener
		 * @param useCapture
		 * 
		 */		
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