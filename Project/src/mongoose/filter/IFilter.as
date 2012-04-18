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
        function getCode(regIndex:uint):String;
        /**
         * 片段常量寄存器索引 
         * @return 
         * 
         */        
        function get fsIndex():uint;
    }
}