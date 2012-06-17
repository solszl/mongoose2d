package mongoose.geom
{
   
    public class Rectangle extends Point
    {
        public var width:Number;
        public var height:Number;

        public function Rectangle(x:Number, y:Number, width:Number,height:Number)
        {
            super(x,y);
            this.width = width;
            this.height = height;
        }

    }
}
