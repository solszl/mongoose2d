package mongoose.display
{
    import com.adobe.utils.*;
    
    import flash.display3D.*;
    
    import mongoose.filter.IFilter;

    public class Sprite2D extends DisplayObjectContainer
    {
        protected var mFilters:Array;
        protected var mFilterChanged:Boolean;
        
        public function Sprite2D(texture:TextureData = null)
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
                
                vs ="m44 vt0, va0,vc[va2.x]\n"+
                    "m44 vt0, vt0,vc0\n"+
                    "m44 vt0, vt0,vc4\n"+
                    "mov op,vt0\n"+
                    
                    //根据UV索引获得UV坐标,va1->vertex,vt0->UV
                    "mov vt0,vc[va3.x]\n"+
                    
                    "mul vt1.x,va1.x,vt0.z\n"+
                    "mul vt2.x,va1.x,vt0.x\n"+
                    "sub vt3.x,vt1.x,vt2.x\n"+
                    "add vt3.x,vt3.x,vt0.x\n"+
                    
                    "mul vt1.y,va1.y,vt0.w\n"+
                    "mul vt2.y,va1.y,vt0.y\n"+
                    "sub vt3.y,vt1.y,vt2.y\n"+
                    "add vt3.y,vt3.y,vt0.y\n"+
                    "mov v1,vc[va4.x]\n"+
                    "mov v0,vt3.xy";
                
                var temp:String = _generateFilterShader();
                if(temp == "")
                {
                    fs ="tex ft0, v0, fs0 <2d,clamp,linear> \n" + 
						"mul oc, ft0, v1\n" ; 
                        //"mul ft0.w,v1.z,ft0.w\n"+
                }
                else
                {
                    fs = temp + "mul oc, ft0, v1\n" ;
                }
                
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
        
        private function _generateFilterShader():String
        {
            var tempfs:String = "";
            if(mFilters)
            {
                var regIndex:int = -1;
                var filter:IFilter;
                var len:uint = mFilters.length;
                for(var i:int=0; i<len; ++i)
                {
                    filter = IFilter(mFilters[i]);
                    if(regIndex<0)
                    {
                        tempfs += filter.getPsCode(1);
                    }
                    else
                    {
                        tempfs += filter.getPsCode(regIndex);
                    }
                    
                    regIndex = filter.endPsReg;
                }
            }
            
            return tempfs;
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
