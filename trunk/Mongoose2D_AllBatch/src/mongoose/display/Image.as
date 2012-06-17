package mongoose.display
{
	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.display3D.textures.Texture;

	public class Image extends DisplayObject
	{
		static public var stage:Stage;
		public var texture:TextureData;
		public function Image(texture:TextureData)
		{
			super();
			this.texture=texture;
			
		}
	}
}