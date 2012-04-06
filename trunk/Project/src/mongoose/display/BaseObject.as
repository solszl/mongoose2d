package mongoose.display
{
    import flash.display.*;
    import flash.display3D.*;
    import flash.events.*;
    import mongoose.core.*;

    public class BaseObject extends EventDispatcher
    {
        protected var mX:Number = 0;
        protected var mY:Number = 0;
        protected var mZ:Number = 0;
        public var x:Number = 0;
        public var y:Number = 0;
        public var z:Number = 0;
        public var data:Object;
        public static var context3d:Context3D;
        public static var stage:Stage;
        public static var world:World;

        public function BaseObject()
        {
            return;
        }// end function

        protected function preRender() : void
        {
            this.mX = this.x / world.width * 2;
            this.mY = (-this.y) / world.height * 2 * world.scale;
            this.mZ = this.z / (World.far - World.near);
            return;
        }// end function

    }
}
