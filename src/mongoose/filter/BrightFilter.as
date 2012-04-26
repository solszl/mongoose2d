package mongoose.filter
{
    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
    /**
     * 高亮滤镜 
     * @author genechen
     * 
     */
    public class BrightFilter implements IFilter
    {
        protected var mFilterConst:Vector.<Number>;
        protected var mFragmentIndex:uint;
        protected var mVertexIndex:uint;
        /**
         * 高亮级别
         * @param level
         * 
         */        
        public function BrightFilter(level:Number)
        {
            super();
            
            mFilterConst = Vector.<Number>([1,1,1,level]);
        }
        
        public function getVsCode(regIndex:uint):String
        {
            mVertexIndex = regIndex;
            
            return '';    
        }
        
        public function getPsCode(regIndex:uint):String
        {
            mFragmentIndex = regIndex;
            
            return "add ft0.xyz, ft0.xyz, fc"+ regIndex +".w\n";
        }
        
        public function apply(context:Context3D):void
        {
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT,mFragmentIndex,mFilterConst);
        }
        
        public function get endPsReg():uint
        {
            return mFragmentIndex+1;
        }
        

        public function get endVsReg():uint
        {
            return mVertexIndex+0;
        }
        
        /**
         * 亮度级别 
         * @param value
         * 
         */        
        public function set level(value:Number):void
        {
            mFilterConst[3] = value;
        }
        
        public function get level():Number
        {
            return mFilterConst[3];
        }
    }
}