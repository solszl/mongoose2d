package mongoose.display
{
	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.display3D.textures.Texture;

	// 图片对象
	public class Image extends DisplayObject
	{
		
		
		public function Image(texture:TextureData)
		{
			super();
			this.texture=texture;
			
		}
	}
}