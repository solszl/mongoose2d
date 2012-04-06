package mongoose.core
{
    import flash.geom.*;
    
    import mongoose.display.*;

    public class Camera extends BaseObject
    {
        public var target:DisplayObject;
        public var matrix:Matrix3D;
        public static var current:Camera;

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
          
            this.matrix.appendTranslation(mX, mY, mZ);
            return;
        }// end function

    }
}
