package mongoose.geom
{
   
    public class Rectangle extends Point
    {
        public var width:Number;
        public var height:Number;
		public var rotation:Number;
		
        public function Rectangle(x:Number, y:Number, width:Number,height:Number)
        {
            super(x,y);
            this.width = width;
            this.height = height;
        }// end function
		
		public function isContainPoint( x:Number, y:Number ):Boolean
		{
			return false;
		}
    }
}
