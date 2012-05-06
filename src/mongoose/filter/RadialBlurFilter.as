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
        
        protected var mFragmentIndex:uint;
        protected var mVertexIndex:uint;
        
        protected var mGradation:uint;
        protected var mNullMatrix:Matrix3D;
        
        protected var mParamScale:Number = 0.005;
        
        public function RadialBlurFilter( gradation:uint=10, params:Vector.<Number>=null)
        {
            mGradation = gradation;
            
            if(params == null)
            {
                mFilterConst = Vector.<Number>([mGradation, 0.005, 0.01, mGradation]);
            }
            else
            {
                mFilterConst = params; 
            }
            
            mNullMatrix = new Matrix3D();
        }
        
        public function getVsCode(regIndex:uint):String
        {
            return '';
        }
        
        public function getPsCode(regIndex:uint):String
        {
            mFragmentIndex = regIndex;
            //将变换矩阵拷到临时寄存器
            //进行采样
            var fragment0:String =   
                "mov ft3, fc"+(mFragmentIndex+1)+"\n" +
                "mov ft4, fc"+(mFragmentIndex+2)+"\n" +
                "mov ft5, fc"+(mFragmentIndex+3)+"\n" +
                "mov ft6, fc"+(mFragmentIndex+4)+"\n" +
                "tex ft1, v0, fs0<2d,nearest,nomip>\n";
            
            //对矩阵按中心等比缩小固定值
            //对采样点应用矩阵变换以向中心移动位置
            //对变换后的采样点进行采样，并将颜色值累计到中间变量
            var fragment1:String =   
				"sub ft3.x, ft3.x, fc"+mFragmentIndex+".z\n" +
                "sub ft4.y, ft4.y, fc"+mFragmentIndex+".z\n" +
                "add ft3.w, ft3.w, fc"+mFragmentIndex+".y\n" +
                "add ft4.w, ft4.w, fc"+mFragmentIndex+".y\n" +
                "m44 ft5, v0, ft3\n" +
                "tex ft2, ft5, fs0<2d,nearest,nomip>\n" +
                "add ft1, ft1, ft2\n";
            
			var fragment2:String;
			if(regIndex>0)
			{
				//对累计的颜色值除以采样次数得到采样平均值，输出颜色值
				fragment2 = 
					"div ft1, ft1, fc"+mFragmentIndex+".x\n" +
					"add ft0, ft1, ft0\n";
			}
			else
			{
				fragment2 = "div ft0, ft1, fc"+mFragmentIndex+".x\n";
			}
            
            //组合shader片段
            for (var i:int = 1; i < mGradation; i++)
            {
                fragment0 = fragment0 + fragment1;
            }
			fragment0 = fragment0 + fragment2;
            
            return fragment0;
        }
        
        public function apply(context:Context3D):void
        {
            context.setProgramConstantsFromVector("fragment", mFragmentIndex, mFilterConst);
            context.setProgramConstantsFromMatrix("fragment", mFragmentIndex+1, mNullMatrix);
        }
        
        public function get endPsReg():uint
        {
            return mFragmentIndex+2;
        }
        
        
        public function get endVsReg():uint
        {
            return mVertexIndex+0;
        }
        
        public function set param( scale:Number ):void
        {
            if( scale<=0 )
            {
                scale = 0.001;
            }
            
            mParamScale = scale;
            
            mFilterConst[1] = mParamScale;
            mFilterConst[2] = mParamScale*2;
        }
        
        public function get param():Number
        {
            return mParamScale;
        }
    }
}