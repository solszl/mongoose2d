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
            var fragmentProgram_0:String =   
                "mov ft3, fc"+(mFragmentIndex+1)+"\n" +
                "mov ft4, fc"+(mFragmentIndex+2)+"\n" +
                "mov ft5, fc"+(mFragmentIndex+3)+"\n" +
                "mov ft6, fc"+(mFragmentIndex+4)+"\n" +
                "tex ft1, v0, fs0<2d,nearest,nomip>\n";
            
            //对矩阵按中心等比缩小固定值
            //对采样点应用矩阵变换以向中心移动位置
            //对变换后的采样点进行采样，并将颜色值累计到中间变量
            var fragmentProgram_1:String =   
				"sub ft3.x, ft3.x, fc"+mFragmentIndex+".z\n" +
                "sub ft4.y, ft4.y, fc"+mFragmentIndex+".z\n" +
                "add ft3.w, ft3.w, fc"+mFragmentIndex+".y\n" +
                "add ft4.w, ft4.w, fc"+mFragmentIndex+".y\n" +
                "m44 ft0, v0, ft3\n" +
                "tex ft2, ft0, fs0<2d,nearest,nomip>\n" +
                "add ft1, ft1, ft2\n";
            
            //对累计的颜色值除以采样次数得到采样平均值，输出颜色值
            var fragmentProgram_2:String = "div ft0, ft1, fc"+mFragmentIndex+".x\n";
            
            //在agal中累计STEP - 1次采样，注意不要超过程序最大长度
            //这个方法有点土，不知各路大大有没高招
            for (var i:int = 1; i < mGradation; i++)
            {
                fragmentProgram_0 = fragmentProgram_0 + fragmentProgram_1;
            }
            fragmentProgram_0 = fragmentProgram_0 + fragmentProgram_2;
            
            return fragmentProgram_0;
        }
        
        public function apply(context:Context3D):void
        {
            //0.0025为一次缩放步长，0.005为一次缩放步长两倍
            context.setProgramConstantsFromVector("fragment", mFragmentIndex, mFilterConst);
            //单位矩阵，采用时候用
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