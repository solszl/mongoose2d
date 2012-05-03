package mongoose.filter
{
    import flash.display3D.Context3D;

    public class BlurFilter implements IFilter
    {
        protected var mFilterConst:Vector.<Number>;
        protected var mFilterConst2:Vector.<Number>;
        
        protected var mBlurIntensity:Number;
        protected var mFragmentIndex:uint;
        protected var mVertexIndex:uint;
        
        public function BlurFilter( intensity:Number=0.004)
        {
            super();
            
			mBlurIntensity = intensity;
            mFilterConst = Vector.<Number>([mBlurIntensity, -mBlurIntensity, 0.0,0.0]);
            mFilterConst2 = Vector.<Number>([0.2,0.2,0.2,0.2]);
        }
        
        public function getVsCode(regIndex:uint):String
        {
            return '';
        }
        
        public function getPsCode(regIndex:uint):String
        {
            var fs:String = 
                
                "tex ft1, v0, fs0 <2d,linear,nomip>\n" +
                "mov ft3, ft1\n" +
                
                "add ft1.xy, v0.xy, fc"+mFragmentIndex+".xx\n" +
                "tex ft2, ft1, fs0 <2d,linear,nomip>\n" +
                "add ft3, ft3, ft2\n" +
                
                "add ft1.xy, v0.xy, fc"+mFragmentIndex+".yx\n" +
                "tex ft2, ft1, fs0 <2d,linear,nomip>\n" +
                "add ft3, ft3, ft2\n" +
                
                "add ft1.xy, v0.xy, fc"+mFragmentIndex+".yy\n" +
                "tex ft2, ft1, fs0 <2d,linear,nomip>\n" +
                "add ft3, ft3, ft2\n" +
                
                "add ft1.xy, v0.xy, fc"+mFragmentIndex+".xy\n" +
                "tex ft2, ft1, fs0 <2d,linear,nomip>\n" +
                "add ft3, ft3, ft2\n" +
                
                "mul ft3, ft3, fc"+(mFragmentIndex+1)+"\n";
			
			if(regIndex>0)
			{
				fs = fs + "mul ft1, ft3, v1\n" +
					"add ft0, ft1, ft0\n";
			}
			else
			{
				fs = fs + "mul ft0, ft3, v1\n";
			}
            
            return fs;
        }
        
        public function apply(context:Context3D):void
        {
            context.setProgramConstantsFromVector("fragment", mFragmentIndex, mFilterConst);
            context.setProgramConstantsFromVector("fragment", mFragmentIndex+1, mFilterConst2);
        }
        
        public function get endPsReg():uint
        {
            return mFragmentIndex+2;
        }
        
        
        public function get endVsReg():uint
        {
            return mVertexIndex+0;
        }
        
        public function set intensity(value:Number):void
        {
            if( value<=0 )
            {
				value = 0.0001;
            }
            
			mBlurIntensity = value;
            
            mFilterConst[0] = value;
            mFilterConst[1] = -value;
        }
        
        public function get intensity():Number
        {
            return mBlurIntensity
        }
    }
}