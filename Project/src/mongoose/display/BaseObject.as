package mongoose.display
{
    import flash.display.*;
    import flash.display3D.*;
    import flash.display3D.textures.Texture;
    import flash.events.*;
    
    import mongoose.core.*;

    public class BaseObject extends EventDispatcher
    {
        protected var mX:Number = 0,
                      mY:Number = 0,
                      mZ:Number = 0;
		
        public var x:Number = 0,
                   y:Number = 0,
                   z:Number = 0;
        public var data:Object;
        public static var context3d:Context3D;
        public static var stage:Stage;
        public static var world:World;
        static private const TOTAL_REG:uint=128;
		//系统占用8个,包括透视和相机
		static private const SYSTEM_USED_REG:uint=8;
		//预留寄存器数量
		static private const REG_SAVE:uint=8;
		static private var REG_INDEX:uint;
		
        public function BaseObject()
        {
			REG_INDEX=SYSTEM_USED_REG;
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
