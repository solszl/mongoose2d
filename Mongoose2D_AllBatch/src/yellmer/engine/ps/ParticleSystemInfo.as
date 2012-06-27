package yellmer.engine.ps
{
	import flash.display.Bitmap;

	public class ParticleSystemInfo
	{
		public var sprite:ParticleSprite;
		public var nEmission:int;//0~1000
		public var fLifetime:Number = 0;//0~10
		
		public var fParticleLifeMin:Number = 0;//0~5
		public var fParticleLifeMax:Number = 0;//0~5
		
		public var fDirection:Number = 0;//0~2PI
		public var fSpread:Number = 0;//0~2PI
		public var bRelative:Boolean = false;
		
		public var fSpeedMin:Number = 0;//-300,300
		public var fSpeedMax:Number = 0;//-300,300
		
		public var fGravityMin:Number = 0;//-900,900
		public var fGravityMax:Number = 0;//-900,900
		
		public var fRadialAccelMin:Number = 0;//-900,900
		public var fRadialAccelMax:Number = 0;//-900,900
		
		public var fTangentialAccelMin:Number = 0;//-900,900
		public var fTangentialAccelMax:Number = 0;//-900,900
		
		public var fSizeStart:Number = 0;//1,100
		public var fSizeEnd:Number = 0;//1,100
		public var fSizeVar:Number = 0;//0,1
		
		
		public var fSpinStart:Number = 0;//-50,50
		public var fSpinEnd:Number = 0;//-50,50
		public var fSpinVar:Number = 0;//0,1
		
		public var colColorStart:Color = new Color;
		public var colColorEnd:Color = new Color;
		public var fColorVar:Number = 0;
		public var fAlphaVar:Number = 0;
		
		
		

		
	}
}