package mongoose.core
{
    import flash.display.Stage;
    import flash.events.Event;
    import flash.geom.*;
    import flash.utils.Dictionary;
    
    import mongoose.display.*;

    public class Camera extends BaseObject
    {
        public var target:DisplayObject;
        public var matrix:Matrix3D;
        public static var current:Camera;
        public static var stage:Stage;
		
		protected var mHandleMap:Dictionary=new Dictionary;
        public function Camera()
        {
            this.matrix = new Matrix3D();
			
            return;
        }

        public function set active(identity:Boolean) : void
        {
            if (identity == true)
            {
                current = this;
				
            }
            else
            {
                current = null;
            }
            return;
        }
        
	    public function enterFrameEvent(name:String,handle:Function):void
		{
			mHandleMap[name]=handle;
		}
		public function removeEnterFrameEvent(name:String,handle:Function):void
		{
			if(mHandleMap[name])
				delete mHandleMap[name];
		}
		override protected function preRender():void
		{
			
			for each(var handle:Function in mHandleMap)
			{
				handle(this);
			}
		}
        public function watch(scale:DisplayObject) : void
        {
            this.target = scale;
            return;
        }

        public function capture() : void
        {
            preRender();
            this.matrix.identity();
            if (this.target != null)
            {
				var mt:Matrix3D=this.target.getMatrix3D();
                mt.invert();
                this.matrix.append(mt);
            }
            
            this.matrix.appendTranslation(-x, y, z);
			
            return;
        }

    }
}
