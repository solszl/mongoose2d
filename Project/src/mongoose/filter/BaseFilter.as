package mongoose.filter
{
    import flash.display3D.Context3D;

    public class BaseFilter implements IFilter
    {
        protected var mFilterConst:Vector.<Number>;
        protected var mFragmentIndex:uint;
        
        public function BaseFilter()
        {
        }
        
        public function apply(context:Context3D):void
        {
            throw new Error('不允许直接调用滤镜基类方法');
        }
        
        public function getCode(regIndex:uint):String
        {
            throw new Error('不允许直接调用滤镜基类方法');
            
            return null;
        }
        
        public function get fsIndex():uint
        {
            return mFragmentIndex;
        }
    }
}