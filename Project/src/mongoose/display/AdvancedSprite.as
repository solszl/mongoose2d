package mongoose.display
{
    import com.adobe.utils.AGALMiniAssembler;
    
    import flash.display3D.Context3DProgramType;
    
    import mongoose.filter.IFilter;

    public class AdvancedSprite extends Sprite2D
    {
        protected var mFilters:Array;
        
        protected var mFilterChanged:Boolean;
        
        public function AdvancedSprite(texture:TextureData=null)
        {
            super(texture);
        }
        
        public function set filters(filter:Array):void
        {
            mFilters = filter;
            
            mFilterChanged = true;
        }
        
        override protected function preRender():void
        {
            super.preRender();
            
            if(mFilterChanged)
                initProgram();
        }
        
        override protected function initProgram() : void
        {
            if (program3d == null || mFilterChanged)
            {
                var vg:AGALMiniAssembler;
                var fg:AGALMiniAssembler;
                var vs:String;
                var fs:String;
                
                vg = new AGALMiniAssembler();
                fg = new AGALMiniAssembler();
                
                vs =    "m44 vt0,va0,vc8\n" + 
                        "m44 vt0,vt0,vc4\n" + 
                        "m44 vt0,vt0,vc0\n" + 
                        "mov op vt0\n" + 
                        "mov v0,va1\n"+
                        "mov v1,vt0";
                
                var tempfs:String = "";
                if(mFilters)
                {
                    var len:uint = mFilters.length;
                    for(var i:int=0; i<len; ++i)
                        tempfs += IFilter(mFilters[i]).getCode(i+1);
                }
                
                fs =    "tex ft0, v0, fs0 <2d,clamp,linear> \n" + 
                        "mul ft0,ft0,fc0\n" + 
                        "mul ft0.w,v1.z,ft0.w\n" +
                        tempfs +
                        "mov oc ft0\n";
                
                vg.assemble(Context3DProgramType.VERTEX, vs);
                fg.assemble(Context3DProgramType.FRAGMENT, fs);
                
                if(program3d)
                    program3d.dispose();
                program3d = context3d.createProgram();
                program3d.upload(vg.agalcode, fg.agalcode);
                context3d.setProgram(program3d);
            }
            
            mFilterChanged = false;
        }
        
        override protected function draw():void
        {
            super.draw();
            if(mFilters)
            {
                var len:uint = mFilters.length;
                for(var i:int=0; i<len; ++i)
                   IFilter(mFilters[i]).apply(context3d);
            }
        }
    }
}