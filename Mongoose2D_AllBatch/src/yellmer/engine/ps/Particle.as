package yellmer.engine.ps
{
	import flash.display.BitmapData;
	import flash.geom.Vector3D;

	public class Particle
	{
		public var vecLocation:Vector2D = new Vector2D();
		public var vecVelocity:Vector2D = new Vector2D();
		
		public var fGravity:Number = 0;
		public var fRadialAccel:Number = 0;
		public var fTangentialAccel:Number = 0;
		
		public var fSpin:Number = 0;
		public var fSpinDelta:Number = 0;
		
		public var fSize:Number = 0;
		public var fSizeDelta:Number = 0;
		
		public var colColor:Color = new Color;
		public var colColorDelta:Color = new Color;
		
		
		public var fAge:Number = 0;
		public var fTerminalAge:Number = 0;

		
		public function clone():Particle
		{
			var par:Particle = new Particle;
			var o:Particle = this;
			
			
			par.vecLocation = o.vecLocation.clone();
			par.vecVelocity = o.vecVelocity.clone();
			
			par.fGravity = o.fGravity;
			par.fRadialAccel = o.fRadialAccel;
			par.fTangentialAccel = o.fTangentialAccel;
			
			par.fSpin = o.fSpin;
			par.fSpinDelta = o.fSpinDelta;
			
			par.fSize = o.fSize;
			par.fSizeDelta = o.fSizeDelta;
			
			par.colColor = o.colColor.clone();
			par.colColorDelta = o.colColorDelta.clone();
			
			par.fAge = o.fAge;
			par.fTerminalAge = o.fTerminalAge;
			
			return par;
		}
		
		public function set value(o:Particle):void
		{
			this.vecLocation = o.vecLocation.clone();
			this.vecVelocity = o.vecVelocity.clone();
			
			this.fGravity = o.fGravity;
			this.fRadialAccel = o.fRadialAccel;
			this.fTangentialAccel = o.fTangentialAccel;
			
			this.fSpin = o.fSpin;
			this.fSpinDelta = o.fSpinDelta;
			
			this.fSize = o.fSize;
			this.fSizeDelta = o.fSizeDelta;
			
			this.colColor = o.colColor.clone();
			this.colColorDelta = o.colColorDelta.clone();
			
			this.fAge = o.fAge;
			this.fTerminalAge = o.fTerminalAge;
		}
	}
}