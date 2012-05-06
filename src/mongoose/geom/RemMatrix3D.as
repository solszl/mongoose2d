package mongoose.geom
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import mongoose.display.World;
	
	public class RemMatrix3D extends Matrix3D
	{
		public var world:World;
		
		private var _rotX:Number=0,
			        _rotY:Number=0,
					_rotZ:Number=0;
		
		private var _xScale:Number=0,
			        _yScale:Number=0,
					_zScale:Number=0;
		
		private var _x:Number=0,
			        _y:Number=0,
					_z:Number=0;
		
		private var _dsx:Number=0,
		            _dsy:Number=0;
		
		public var fx:Number,fy:Number,fz:Number;
		public function RemMatrix3D(v:Vector.<Number>=null)
		{
			super(v);
		}
		override public function appendRotation(degrees:Number, axis:Vector3D, pivotPoint:Vector3D=null):void
		{
			var rx:Number,ry:Number,rz:Number;
			if(axis==Vector3D.X_AXIS)
			{
				rx=degrees-_rotX;
				_rotX=degrees;
				if(rx!=0)
				{
					super.appendRotation(rx,axis,pivotPoint);
					trace("xRotation..");
				}
				    
			}
			if(axis==Vector3D.Y_AXIS)
			{
				ry=degrees-_rotY;
				_rotY=degrees;
				if(ry!=0)
				{
					super.appendRotation(ry,axis,pivotPoint);
					//trace("yRotation..");
				}
					
			}
			if(axis==Vector3D.Z_AXIS)
			{
				rz=degrees-_rotZ;
				_rotZ=degrees;
				if(rz!=0)
				{
					super.appendRotation(rz,axis,pivotPoint);
					//trace("zRotation..");
				}
					
			}
		}
		/*_r1 = 1 / world.width;
		_r2 = 1 / world.height;
		_r3 = _r1 * 2;
		_r4 = _r2 * 2 * world.scale;
		_r5 = 1 / (World.far - World.near);*/
		public function updateConstant():void
		{
			
		}
		public function appendDirectScale(xScale:Number,yScale:Number):void
		{
			xScale==0?xScale=1:xScale;
			yScale==0?yScale=1:yScale;
			
			var tx:Number=xScale-_dsx;
			var ty:Number=yScale-_dsy;
			
			_dsx=xScale;
			_dsy=yScale;
			if(tx!=0)
			{
				
				super.appendScale(tx,1,1);
			}
			if(ty!=0)
			{
				
				super.appendScale(ty,1,1);
			}
		}
		override public function appendScale(xScale:Number, yScale:Number, zScale:Number):void
		{
			
			var sx:Number=xScale-_xScale;
			var sy:Number=yScale-_yScale;
			var sz:Number=zScale-_zScale;
			_xScale=xScale;
			_yScale=yScale;
			_zScale=zScale;
			
			if(sx!=0)
			{
				sx=sx*fx;
				sx==0?sx=1:sx;
				super.appendScale(sx,1,1);
				//trace("xScale..");
			}
			   
			if(sy!=0)
			{
				sy=sy*fy;
				sy==0?sy=1:sy;
				super.appendScale(1,sy,1);
				//trace("yScale");
			}
			   
			if(sz!=0)
			{
				sz=sz*fz;
				sz==0?sz=1:sz;
				//super.appendScale(1,1,sz);
			}
		       
		} 
		override public function appendTranslation(x:Number, y:Number, z:Number):void
		{
			var tx:Number=x-_x;
			var ty:Number=y-_y;
			var tz:Number=z-_z;
			_x=x;
			_y=y;
			_z=z;
			if(tx!=0)
			{
				tx=tx*fx;
				super.appendTranslation(tx,0,0);
				//trace("xTranslation..");
			}
			   
			if(ty!=0)
			{
				ty=ty*fy;
				super.appendTranslation(0,-ty,0);
				//trace("yTranslation..");
			}
			   
			if(tz!=0)
			{
				tz=tz*fz;
				super.appendTranslation(0,0,tz);
				//trace("zTranslation..");
			}
				
		}
	}
}