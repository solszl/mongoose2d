package mongoose.filter
{
// ceshi 
    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
    
    public class GrayFilter implements IFilter
    {
        protected var mFilterConst:Vector.<Number>;
        protected var mFragmentIndex:uint;
        
        public function GrayFilter()
        {
            super();
            
            mFilterConst = Vector.<Number>([0.30,0.59,0.11,1.0]);
        }
        
        public function apply(context:Context3D):void
        {
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT,mFragmentIndex,mFilterConst);
        }
        
        public function getPsCode(regIndex:uint):String
        {
            mFragmentIndex = regIndex;
            var fs:String;
            
            if(regIndex>0)
            {
                fs =
                    "tex ft1, v0, fs0 <2d,clamp,linear> \n" + 
                    "add ft0, ft0, ft1\n" +
                    "dp3 ft0, ft0, fc"+ regIndex +"\n";
            }
            else
            {
                fs = "tex ft0, v0, fs0 <2d,clamp,linear> \n" + 
                    "dp3 ft0, ft0, fc"+ regIndex +"\n";
            }
            
            return fs;
        }
        
        public function getVsCode(regIndex:uint):String
        {
           return '';
        }
        
        public function get endPsReg():uint
        {
            return mFragmentIndex+1;
        }
        
        public function get endVsReg():uint
        {
            return 0;
        }
    }
}