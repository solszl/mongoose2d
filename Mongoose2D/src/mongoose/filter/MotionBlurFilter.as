package mongoose.filter
{
    import flash.display3D.Context3D;
    /**
     * 运动模糊 
     * @author genechen
     * 
     */
    public class MotionBlurFilter implements IFilter
    {
        protected var mFragmentIndex:uint;
        protected var mVertexIndex:uint;

        protected var mFilterConst:Vector.<Number>;
        protected var mFilterConst2:Vector.<Number>;
        
//        protected var motionBlurTexture;
        protected var motionBlurIndex:Vector.<int>;
        protected var motionBlurTemp0:Vector.<Number>;
        protected var motionBlurTemp1:Vector.<Number>;
        
        public function MotionBlurFilter()
        {
            super();
//            motionBlurTexture = new Vector.<TextureData>(7);
            motionBlurIndex = new Vector.<int>(7);
            motionBlurTemp0 = Vector.<Number>([0.35, 0.2, 0.15, 0.15]);
            motionBlurTemp1 = Vector.<Number>([0.15, 0.15, 0.1, 0.1]);
            
            
        }
        
        public function getVsCode(regIndex:uint):String
        {
            return '';
        }
        
        public function getPsCode(regIndex:uint):String
        {
            mFragmentIndex = regIndex;
            
            var fs:String = 
                "tex ft0, v0, fs0 <2d,linear> \n" +
                "tex ft1, v0, fs1 <2d,linear> \n" +
                "tex ft2, v0, fs2 <2d,linear> \n" +
                "tex ft3, v0, fs3 <2d,linear> \n" +
                "tex ft4, v0, fs4 <2d,linear> \n" +
                "tex ft5, v0, fs5 <2d,linear> \n" +
                "tex ft6, v0, fs6 <2d,linear> \n" +
                "tex ft7, v0, fs7 <2d,linear> \n" +
                "mul ft0.xyz, ft0.xyz, fc"+mFragmentIndex+".x \n" +
                "mul ft1.xyz, ft1.xyz, fc"+mFragmentIndex+".y \n" +
                "mul ft2.xyz, ft2.xyz, fc"+mFragmentIndex+".z \n" +
                "mul ft3.xyz, ft3.xyz, fc"+mFragmentIndex+".w \n" +
                "mul ft4.xyz, ft4.xyz, fc"+(mFragmentIndex+1)+".x \n" +
                "mul ft5.xyz, ft5.xyz, fc"+(mFragmentIndex+1)+".y \n" +
                "mul ft6.xyz, ft6.xyz, fc"+(mFragmentIndex+1)+".z \n" +
                "mul ft7.xyz, ft7.xyz, fc"+(mFragmentIndex+1)+".w \n" +
                "add ft0, ft0, ft1 \n " +
                "add ft0, ft0, ft2 \n " +
                "add ft0, ft0, ft3 \n " +
                "add ft0, ft0, ft4 \n " +
                "add ft0, ft0, ft5 \n " +
                "add ft0, ft0, ft6 \n " +
                "add ft0, ft0, ft7 \n ";
            
            if(regIndex>0)
            {
                fs = fs + "add ft0, ft1, ft0\n";
            }
            
            return fs;
        }
        
        public function apply(context:Context3D):void
        {
            context.setProgramConstantsFromVector("fragment", mFragmentIndex, motionBlurTemp0);
            context.setProgramConstantsFromVector("fragment", mFragmentIndex+1, motionBlurTemp1);
        }
        
        public function get endPsReg():uint
        {
            return mFragmentIndex+2;
        }
        
        
        public function get endVsReg():uint
        {
            return mVertexIndex+0;
        }
    }
}