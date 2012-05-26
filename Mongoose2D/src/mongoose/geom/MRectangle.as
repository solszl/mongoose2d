package mongoose.geom
{
   
    public class MRectangle extends MPoint
    {
        public var width:Number;
        public var height:Number;

        public function MRectangle(x:Number, y:Number, width:Number,height:Number)
        {
            super(x,y);
            this.width = width;
            this.height = height;
        }

    }
}
