package mongoose.display
{
    import flash.display.*;
    import flash.display3D.*;
    import flash.display3D.textures.Texture;
    import flash.events.*;
    
    import mongoose.core.*;

    public class BaseObject extends EventDispatcher
    {
       
		
        public var x:Number = 0,
                   y:Number = 0,
                   z:Number = 0;
        public var data:Object={};
		public var name:String;
		
		public var id:uint;
        public static var context3d:Context3D;
        public static var stage:Stage;
        public static var world:World;
       
		
        public function BaseObject()
        {
			
            return;
        }

        protected function preRender() : void
        {
          
            return;
        }

    }
}
