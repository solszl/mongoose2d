package yellmer.engine.ps
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mongoose.display.DisplayObject;
	import mongoose.display.Sprite2D;
	import mongoose.display.TextureData;
	import mongoose.display.World;
	
	import mx.controls.Text;
	
	import spark.primitives.Rect;
	
	

	public class ParticleSprite
	{
		private var m_brush:Bitmap;
		private var m_texture:BitmapData;
		private var m_col:uint
		private var m_rcSrc:Rectangle = new Rectangle;
		private var m_mat:Matrix = new Matrix;
		private var m_ct:ColorTransform = new ColorTransform(1,1,1,1);
		private var _world:World;
		private var m_ptDst:Point = new Point;
		
		
		private var _particles:Array=[];
		public function ParticleSprite(w:Number, h:Number)
		{
			m_texture = new BitmapData(w,h);
			
		}
		
		public function GetColor():uint
		{
			return this.m_col;
		}
		
		
		public function SetColor(col:uint):void
		{
			this.m_col = col;
		}
		
		public function SetColorA(a:uint):void
		{
			m_col = (((m_col) & 0x00FFFFFF) + (uint(a)<<24));
		}
		
		
		public function setTextureData(world:World):void
		{
			_world=world;
		}
		

		
		public function BeginRender():void
		{
			
			
			//var rect:Rectangle = new Rectangle(0,0,bitmapData.width,bitmapData.height);
			//this.bitmapData.fillRect(rect, 0x00000000);
		}
		
		
		public function RenderBundled(drawingBlock:Function):void
		{
			
		}
		
		
		public function Render(i:int, x:Number, y:Number, rot:Number, hscale:Number = 1.0, vscale:Number = 0.0):void
		{
			if(true)
			{
				m_mat.a = 1;
				m_mat.b = 0;
				m_mat.c = 0;
				m_mat.d = 1;
				m_mat.tx = 0;
				m_mat.ty = 0;
	
				m_mat.rotate(rot);
				m_mat.scale(hscale, vscale == 0 ? hscale : vscale);
				
				m_mat.tx = x;
				m_mat.ty = y;
				
				
				/*
				m_ct.alphaMultiplier = 	(((m_col)>>24) & 0xFF) / 255.0;
				m_ct.redMultiplier = 	(((m_col)>>16) & 0xFF) / 255.0;
				m_ct.greenMultiplier = 	(((m_col)>>08) & 0xFF) / 255.0;
				m_ct.blueMultiplier = 	(((m_col)>>00) & 0xFF) / 255.0;
				*/
				
				
				
				m_ct.alphaMultiplier = 	(((m_col)>>24) & 0xFF) / 255.0;
				m_ct.redMultiplier = 	(((m_col)>>16) & 0xFF) / 255.0;
				m_ct.greenMultiplier = 	(((m_col)>>08) & 0xFF) / 255.0;
				m_ct.blueMultiplier = 	(((m_col)>>00) & 0xFF) / 255.0;
				
				//m_brush.x = x;
				//m_brush.y = y;
				//m_brush.rotation = rot;
				//m_brush.alpha = m_ct.alphaMultiplier;
				
				
				if(_particles[i]==null)
				{
					var txt:TextureData=new TextureData(null,true);
					var sp:Sprite2D=new Sprite2D(txt);
					_particles[i]=sp;
					_world.addChild(sp);
				}
				DisplayObject(_particles[i]).x=x;
				DisplayObject(_particles[i]).y=y;
				DisplayObject(_particles[i]).rotationZ=rot;
				DisplayObject(_particles[i]).alpha=m_ct.alphaMultiplier;
				
				DisplayObject(_particles[i]).setColor(m_ct.redMultiplier,m_ct.greenMultiplier,m_ct.blueMultiplier);
				
				
				
				//DisplayObject(_particles[i]).x=x;
				//m_brush.color = m_col;
				//m_brush.scaleX = hscale;
				//m_brush.scaleY = vscale;
				
				
				//m_texture.draw(m_brush,0);
				

				
				//this.bitmapData.draw(m_texture, m_mat, m_ct, BlendMode.ADD,null, true);
			}
			
		}
		
		
		public function EndRender():void
		{
			
		}
	}
}