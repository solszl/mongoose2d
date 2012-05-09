package mongoose.filter
{
    import flash.display3D.Context3D;

    /**
     * 滤镜接口 
     * @author genechen
     * 
     */    
    public interface IFilter
    {
        /**
         * 设置片段常量寄存器 
         * @param context
         * 
         */        
        function apply(context:Context3D):void;
        /**
         * 生成片段着色器汇编码 
         * @param regIndex 常量寄存器索引
         * @return 
         * 
         */        
        function getPsCode(regIndex:uint):String;
        /**
         *  生成顶点着色器汇编码 
         * @param regIndex
         * @return 
         * 
         */        
        function getVsCode(regIndex:uint):String;
        /**
         * 该滤镜使用像素着色器后的寄存器索引 
         * @return 
         * 
         */        
        function get endPsReg():uint;
        /**
         * 该滤镜使用顶点着色器后的寄存器索引 
         * @return 
         * 
         */
        function get endVsReg():uint;
    }
}