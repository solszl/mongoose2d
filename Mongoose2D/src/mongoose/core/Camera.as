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
        }// end function

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
        }// end function
        
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
			super.preRender();
			for each(var handle:Function in mHandleMap)
			{
				handle(this);
			}
		}
        public function watch(scale:DisplayObject) : void
        {
            this.target = scale;
            return;
        }// end function

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
          
            this.matrix.appendTranslation(mX, mY, -mZ);
			this.matrix.appendTranslation(-1, World.SCALE, 1);
            return;
        }// end function

    }
}
