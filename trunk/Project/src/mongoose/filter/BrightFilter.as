package mongoose.filter
{
    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
    /**
     * 高亮滤镜 
     * @author genechen
     * 
     */
    public class BrightFilter extends BaseFilter implements IFilter
    {
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
        
        override public function getCode(regIndex:uint):String
        {
            mFragmentIndex = regIndex;
            
            return "add ft0.xyz, ft0.xyz, fc"+ regIndex +".w\n";
        }
        
        override public function apply(context:Context3D):void
        {
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT,mFragmentIndex,mFilterConst);
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