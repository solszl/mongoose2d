package mongoose.filter
{
    import flash.display3D.Context3D;
    /**
     * 模糊滤镜 
     * @author genechen
     * 
     */
    public class BlurFilter implements IFilter
    {
        protected var mFilterConst:Vector.<Number>;
        protected var mFilterConst2:Vector.<Number>;
        
        protected var mBlurIntensity:Number;
        protected var mFragmentIndex:uint;
        protected var mVertexIndex:uint;
        /**
         * @param intensity 模糊等级。 建议值:1-100
         * 
         */        
        public function BlurFilter( intensity:Number=20)
        {
            super();
            
			mBlurIntensity = intensity*0.001;
            
            mFilterConst = Vector.<Number>([mBlurIntensity, -mBlurIntensity, mBlurIntensity*.5,-mBlurIntensity*.5]);
            mFilterConst2 = Vector.<Number>([0.12,0.12,0.12,0.12]);
        }
        
        public function getVsCode(regIndex:uint):String
        {
            return '';
        }
        
        public function getPsCode(regIndex:uint):String
        {
            mFragmentIndex = regIndex;
            
            var fs:String = 
                
                "tex ft1, v0, fs0 <2d,linear,nomip>\n" +
                "mul ft3, ft1, fc"+(mFragmentIndex+1)+".x\n"+
                //"mov ft3, ft1\n" +
                
                "add ft1.xy, v0.xy, fc"+mFragmentIndex+".xx\n" +
                "tex ft2, ft1, fs0 <2d,linear,nomip>\n" +
                "mul ft2, ft2, fc"+(mFragmentIndex+1)+".x\n"+
                "add ft3, ft3, ft2\n" +
                
                "add ft1.xy, v0.xy, fc"+mFragmentIndex+".yx\n" +
                "tex ft2, ft1, fs0 <2d,linear,nomip>\n" +
                "mul ft2, ft2, fc"+(mFragmentIndex+1)+".x\n"+
                "add ft3, ft3, ft2\n" +
                
                "add ft1.xy, v0.xy, fc"+mFragmentIndex+".yy\n" +
                "tex ft2, ft1, fs0 <2d,linear,nomip>\n" +
                "mul ft2, ft2, fc"+(mFragmentIndex+1)+".x\n"+
                "add ft3, ft3, ft2\n" +
                
                "add ft1.xy, v0.xy, fc"+mFragmentIndex+".xy\n" +
                "tex ft2, ft1, fs0 <2d,linear,nomip>\n" +
                "mul ft2, ft2, fc"+(mFragmentIndex+1)+".x\n"+
                "add ft3, ft3, ft2\n" +
                
                "add ft1.xy, v0.xy, fc"+mFragmentIndex+".zz\n" +
                "tex ft2, ft1, fs0 <2d,linear,nomip>\n" +
                "mul ft2, ft2, fc"+(mFragmentIndex+1)+".x\n"+
                "add ft3, ft3, ft2\n" +
                
                "add ft1.xy, v0.xy, fc"+mFragmentIndex+".wz\n" +
                "tex ft2, ft1, fs0 <2d,linear,nomip>\n" +
                "mul ft2, ft2, fc"+(mFragmentIndex+1)+".x\n"+
                "add ft3, ft3, ft2\n" +
                
                "add ft1.xy, v0.xy, fc"+mFragmentIndex+".ww\n" +
                "tex ft2, ft1, fs0 <2d,linear,nomip>\n" +
                "mul ft2, ft2, fc"+(mFragmentIndex+1)+".x\n"+
                "add ft3, ft3, ft2\n" +
                
                "add ft1.xy, v0.xy, fc"+mFragmentIndex+".zw\n" +
                "tex ft2, ft1, fs0 <2d,linear,nomip>\n" +
                "mul ft2, ft2, fc"+(mFragmentIndex+1)+".x\n"+
                "add ft3, ft3, ft2\n" ;
			
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
        /**
         * 模糊等级。 建议值:1-100
         * @param value 
         * 
         */        
        public function set intensity(value:Number):void
        {
            if( value<=0 )
            {
				value = 0.0001;
            }
            
			mBlurIntensity = value*0.001;
            
            mFilterConst[0] = mBlurIntensity;
            mFilterConst[1] = -mBlurIntensity;
            mFilterConst[2] = mBlurIntensity*.5;
            mFilterConst[3] = -mBlurIntensity*.5;
        }
        
        public function get intensity():Number
        {
            return mBlurIntensity
        }
    }
}