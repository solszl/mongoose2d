package mongoose.filter
{
    import flash.display3D.Context3D;
    
    public class OutlineFilter implements IFilter
    {
        protected var mFilterConst:Vector.<Number>;
        protected var mFilterConst2:Vector.<Number>;
        
        protected var mFragmentIndex:uint;
        
        public function OutlineFilter()
        {
            mFilterConst =  Vector.<Number>([0, 0, 2, 0.32]);
            mFilterConst2 = Vector.<Number>([0.3, 0.59, 0.11, 1]);
        }
        
        public function apply(context:Context3D):void
        {
            context.setProgramConstantsFromVector("fragment", mFragmentIndex, mFilterConst);
            context.setProgramConstantsFromVector("fragment", mFragmentIndex+1, mFilterConst2);
        }
        
        public function getPsCode(regIndex:uint):String
        {
            var fs:String = 
                
                "mov ft0 v0 \n" +
                "sub ft0.x v0.x fc"+mFragmentIndex+".x \n" +
                "tex ft1, ft0, fs0 <2d,linear,nomip> \n" +
                "sub ft0.y v0.y fc"+mFragmentIndex+".y \n" +
                "tex ft2, ft0, fs0 <2d,linear,nomip> \n" +
                "add ft0.y v0.y fc"+mFragmentIndex+".y \n" +
                "tex ft3, ft0, fs0 <2d,linear,nomip> \n" +
                "add ft0.x v0.x fc"+mFragmentIndex+".x \n" +
                "tex ft4, ft0, fs0 <2d,linear,nomip> \n" +
                "mov ft0.y v0.y \n" +
                "tex ft5, ft0, fs0 <2d,linear,nomip> \n" +
                "sub ft0.y v0.y fc"+mFragmentIndex+".y \n" +
                "tex ft6, ft0, fs0 <2d,linear,nomip> \n" +
                "add ft1 ft1 ft1 \n" +
                "add ft1 ft1 ft2 \n" +
                "add ft1 ft1 ft3 \n" +
                "add ft5 ft5 ft5 \n" +
                "sub ft1 ft1 ft5 \n" +
                "sub ft1 ft1 ft4 \n" +
                "sub ft1 ft1 ft6 \n" +
                "mul ft1 ft1 fc"+(mFragmentIndex+1)+" \n" +
                "add ft1.x ft1.x ft1.y \n" +
                "add ft1.x ft1.x ft1.z \n" +
                "sub ft1.x fc"+(mFragmentIndex+1)+".w ft1.x \n" +
                "sge ft1.x ft1.x fc"+mFragmentIndex+".w \n" +
                "mov ft1.y ft1.x \n" +
                "mov ft1.z ft1.x \n" +
                "tex ft0, v0, fs0 <2d,linear,nomip> \n" +
                "mul ft1.xyz ft0.xyz ft1.x \n"// +
//                "mov oc, ft1 \n";
            
            if(regIndex>0)
            {
                fs = fs + "add ft0, ft1, ft0\n";
            }
            else
            {
                fs = fs + "mov ft0, ft1\n";
            }
            trace(fs)
            return fs;
        }
        
        public function getVsCode(regIndex:uint):String
        {
            return null;
        }
        
        public function get endPsReg():uint
        {
            return mFragmentIndex+2;
        }
        
        public function get endVsReg():uint
        {
            return 0;
        }
    }
}