package mongoose.display
{
    import com.adobe.utils.*;
    
    import flash.display3D.*;
    
    import mongoose.filter.IFilter;

    public class Sprite2D extends DisplayObjectContainer
    {
        protected var mFilters:Array;
        
        public function Sprite2D(texture:TextureData = null)
        {
			super(texture);
			
        }

        public function set filters(filter:Array):void
        {
            mFilters = filter;
			if(mFilters!=null)
			{
				buildProgram();
			}
        }
        
       
        
        protected function buildProgram() : void
        {
                
                //var vg:AGALMiniAssembler;
                var fg:AGALMiniAssembler;
                var vs:String;
                var fs:String;
                
                //vg = new AGALMiniAssembler();
                fg = new AGALMiniAssembler();
                
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
                
               
                fg.assemble(Context3DProgramType.FRAGMENT, fs);
                
				mProgram3d = context3d.createProgram();
				mProgram3d.upload(VERTEX_SHADER, fg.agalcode);
				context3d.setProgram(mProgram3d);
  
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
                        tempfs += filter.getPsCode(0);
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
		   
		    if(mFilters!=null)
			{
				if(BATCH_INDEX>0)
				{
					//trace("如果Batch缓冲还有数据，输出batch缓冲",BATCH_INDEX)
					context3d.drawTriangles(CURRENT_INDEX_BUFFER,0,BATCH_INDEX*2);
					BATCH_INDEX=0;
				}
				if(CURRENT_PROGRAM!=mProgram3d)
				{
					context3d.setProgram(mProgram3d);
					CURRENT_PROGRAM=mProgram3d;
				}	
				    
				
				var len:uint = mFilters.length;
				for(var i:int=0; i<len; ++i)
					IFilter(mFilters[i]).apply(context3d);
				BATCH_INDEX=0;
				var mid:uint=REG_INDEX+BATCH_INDEX*4;
				var uid:uint=BATCH_NUM*4+REG_INDEX+BATCH_INDEX*2;
				//var cid:uint=BATCH_NUM*4+BATCH_NUM+REG_INDEX+BATCH_INDEX;
				//trace("数据:",mid,uid);
				context3d.setTextureAt(0,mTexture.texture);
				context3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX,mid, mOutMatrix, true);
				context3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX,uid,mConstrants,2);
				context3d.drawTriangles(CURRENT_INDEX_BUFFER,0,2);
				//trace("独立渲染一次")
			}
			else
			{
				//如果没有任何变化走batch路线
				super.draw();
			}
			
        }
    }
}
