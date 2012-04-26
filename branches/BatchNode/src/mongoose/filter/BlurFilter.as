package mongoose.filter
{
    import flash.display3D.Context3D;

    public class BlurFilter implements IFilter
    {
        protected var mFragmentIndex:uint;
        protected var mVertexIndex:uint;
        
        public function BlurFilter()
        {
            super();
        }
        
        public function getVsCode(regIndex:uint):String
        {
            return '';
        }
        
        public function getPsCode(regIndex:uint):String
        {
            return '';
        }
        
        public function apply(contex3d:Context3D):void
        {
            
        }
        
        public function get endPsReg():uint
        {
            return mFragmentIndex+1;
        }
        
        
        public function get endVsReg():uint
        {
            return mVertexIndex+0;
        }
    }
}