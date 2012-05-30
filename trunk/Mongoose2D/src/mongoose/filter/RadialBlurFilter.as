package mongoose.filter
{
    import flash.display3D.Context3D;
    import flash.display3D.Context3DBlendFactor;
    import flash.display3D.Context3DProgramType;
    import flash.geom.Matrix3D;
    
    /**
     * 径向模糊 
     * @author genechen
     * 
     */    
    public class RadialBlurFilter implements IFilter
    {
        protected var mFilterConst:Vector.<Number>;
        protected var mFilterConst2:Vector.<Number>;
        
        protected var mFragmentIndex:uint;
        protected var mVertexIndex:uint;
        
        protected var mGradation:uint;
        
        public function RadialBlurFilter( gradation:uint=10, centerX:Number=0.5, centerY:Number=0.5)
        {
            mGradation = gradation;
            
            mFilterConst = Vector.<Number>([centerX,centerY, 0.99, 0.9]);
            mFilterConst2 =  Vector.<Number>([0, 0, 0, 0.1]);
        }
        
        public function getVsCode(regIndex:uint):String
        {
            return '';
        }
        
        public function getPsCode(regIndex:uint):String
        {
            mFragmentIndex = regIndex;
            
            var fragment0:String = "mov ft1, v0\n"+
                "tex ft2, ft1, fs0 <2d,clamp,linear>\n";
            
            //从中心点出发，向四周径向散发。径向取点平均像素值
            var fragment1:String =   
                "sub ft1.xy, ft1.xy, fc"+mFragmentIndex+".xy\n"+
                "mul ft1.xy, ft1.xy, fc"+mFragmentIndex+".z\n"+
                "add ft1.xy, ft1.xy, fc"+mFragmentIndex+".xy\n"+
                "tex ft3, ft1, fs0 <2d,clamp,linear>\n"+
                "mul ft3.xyz, ft3.xyz, fc"+(mFragmentIndex+1)+".w\n"+
                "mul ft2.xyz, ft2.xyz, fc"+mFragmentIndex+".w\n"+
                "add ft2.xyz, ft2.xyz, ft3.xyz\n";
            
            var fragment:String = fragment0;
            var fragment2:String;
            if(regIndex>0)
            {
                fragment2 =  "add ft0, ft2, ft0\n";
            }
            else
            {
                fragment2 = "mov ft0, ft2\n";
            }
            
            //组合shader片段
            for (var i:int = 1; i < mGradation; i++)
            {
                fragment = fragment + fragment1;
            }
            fragment = fragment + fragment2;
            
            return fragment;
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
    }
}