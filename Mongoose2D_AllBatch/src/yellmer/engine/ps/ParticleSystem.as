package yellmer.engine.ps
{
	import flash.display.Bitmap;
	import flash.geom.Rectangle;


	public class ParticleSystem
	{
		public static const MAX_PARTICLES:int = 500;
		
	
		public var info:ParticleSystemInfo = new ParticleSystemInfo;
		
		private var m_fAge:Number = 0;
		private var m_fEmissionResidue:Number = 0;
		
		private var m_vecPrevLocation:Vector2D = new Vector2D;
		private var m_vecLocation:Vector2D = new Vector2D;
		private var m_fTx:Number = 0, fTy:Number = 0;
		private var m_fScale:Number = 0;
		
		private var m_nParticlesAlive:int;
		private var m_rectBoundingBox:Rectangle = new Rectangle;
		private var m_bUpdateBoundingBox:Boolean = false;
		
		private var m_particles:Vector.<Particle>;
		
		
		public function ParticleSystem(psi:ParticleSystemInfo)
		{
			info = psi;
			m_particles = new Vector.<Particle>(MAX_PARTICLES);
			
			for(var i:int = 0; i < MAX_PARTICLES; ++i)
			{
				m_particles[i] = new Particle;
			}
			
			
			m_vecLocation.x = m_vecPrevLocation.x = 0.0;
			m_vecLocation.y = m_vecPrevLocation.y = 0.0;
			m_fTx = fTy = 0;
			m_fScale = 1.0;
			
			m_fEmissionResidue = 0.0;
			m_nParticlesAlive = 0;
			m_fAge = -2.0;
			
			m_rectBoundingBox.setEmpty();
			m_bUpdateBoundingBox = false;
		}
		
		public function Create(filename:String, sprite:ParticleSprite):void
		{
			//load filename
			
			
			info.sprite = sprite;
			
			m_vecLocation.x = m_vecPrevLocation.x = 0.0;
			m_vecLocation.y = m_vecPrevLocation.y = 0.0;
			m_fTx = fTy = 0;
			m_fScale = 1.0;
			
			m_fEmissionResidue = 0.0;
			m_nParticlesAlive = 0;
			m_fAge = -2.0;
			
			m_rectBoundingBox.setEmpty();
			m_bUpdateBoundingBox = false;
		}
		
		public function Release():void
		{
			
		}
		
		
		public function Render():void
		{
			var i:int = 0;
			var col:uint = 0;
			var par:Particle = m_particles[0];
			
			col = info.sprite.GetColor();
			
			info.sprite.BeginRender();
			
			
			
				for(i = 0; i < m_nParticlesAlive; ++i)
				{
					par = m_particles[i];
					
					if(info.colColorStart.r < 0)
					{	
						info.sprite.SetColorA(par.colColor.a*255);
					}
					else
					{
						info.sprite.SetColor(par.colColor.GetHWColor());
					}
					
					info.sprite.Render(i, par.vecLocation.x * m_fScale + m_fTx, par.vecLocation.y * m_fScale + fTy, par.fSpin * par.fAge, par.fSize * m_fScale);
					
				}		
			

			info.sprite.EndRender();
			
			info.sprite.SetColor(col);
		}
		
		
		
		public function FireAt(x:Number, y:Number):void
		{
			Stop();
			MoveTo(x,y);
			Fire();
		}
		
		public function Fire():void
		{
			if(info.fLifetime == -1)
			{
				m_fAge = -1;
			}
			else
			{
				m_fAge = 0;
			}
		}
		
		public function Stop(bKillParticles:Boolean = false):void
		{
			m_fAge = -2;
			if(bKillParticles)
			{
				m_nParticlesAlive = 0;
				m_rectBoundingBox.setEmpty();
			}
		}
		
		
		public function Update(fDeltaTime:Number):void
		{
			var i:int = 0;
			var ang:Number = 0;
			var par:Particle;
			var vecAccel:Vector2D = new Vector2D;
			var vecAccel2:Vector2D = new Vector2D;
			var tmpRect:Rectangle;
			
			
			if(m_fAge >= 0)
			{
				m_fAge += fDeltaTime;
				if(m_fAge >= info.fLifetime)
				{
					m_fAge = -2.0;
				}
			}
			
			
			//update all alive particles
			
			if(m_bUpdateBoundingBox)
			{
				m_rectBoundingBox.setEmpty();
			}
			
			
			for(i = 0; i < m_nParticlesAlive; ++i)
			{
				par = m_particles[i];
				
				par.fAge += fDeltaTime;
				if(par.fAge >= par.fTerminalAge)
				{
					--m_nParticlesAlive;
					par.value = m_particles[m_nParticlesAlive];
					--i;
					continue;
				}
			
				
				vecAccel = par.vecLocation.minu(m_vecLocation);
				vecAccel.normalize();
				vecAccel2 = vecAccel.clone();
				vecAccel.multEqual(par.fRadialAccel);
				
				
				//vecAccel2.Rotate(M_PI_2);
				//the following is faster;
				ang = vecAccel2.x;
				vecAccel2.x = -vecAccel2.y;
				vecAccel2.y = ang;
				
				
				vecAccel2.multEqual(par.fTangentialAccel);
				par.vecVelocity.plusEqual(vecAccel.plus(vecAccel2).mult(fDeltaTime));
				par.vecLocation.y += (par.fGravity*fDeltaTime);
				
				par.vecLocation.plusEqual(par.vecVelocity.mult(fDeltaTime));
				
				par.fSpin += par.fSpinDelta*fDeltaTime;
				par.fSize += par.fSizeDelta*fDeltaTime;
				par.colColor.plusEqual(par.colColorDelta.mult(fDeltaTime));
				
				
				if(m_bUpdateBoundingBox)
				{
					tmpRect = new Rectangle(par.vecLocation.x, par.vecLocation.y,1,1);
					m_rectBoundingBox = m_rectBoundingBox.union(tmpRect);
				}
				
				
			}
			
			
			
			//generate new particles
			
			if(m_fAge != -2.0)
			{
				var fParticlesNeeded:Number = info.nEmission*fDeltaTime + m_fEmissionResidue;
				var nParticlesCreated:int = fParticlesNeeded;
				m_fEmissionResidue = fParticlesNeeded - nParticlesCreated;
				
				
				for(i = 0; i < nParticlesCreated; ++i)
				{
					
					
					if(m_nParticlesAlive >= MAX_PARTICLES)
					{
						break;
					}
					
					par = m_particles[m_nParticlesAlive];
					
					//粒子的生命
					par.fAge = 0.0;
					par.fTerminalAge = MathUtils.random(info.fParticleLifeMin, info.fParticleLifeMax);
					
					
					//粒子的坐标
					par.vecLocation = m_vecPrevLocation.plus(m_vecLocation.minu(m_vecPrevLocation).mult(MathUtils.random(0,1)));
					par.vecLocation.x += MathUtils.random(-2,2);
					par.vecLocation.y += MathUtils.random(-2,2);
					
					
					
					//方向
					ang = info.fDirection - MathUtils.PI1_2 + MathUtils.random(0, info.fSpread) - info.fSpread/2;
					if(info.bRelative)
					{
						ang += m_vecPrevLocation.minu(m_vecLocation).angel() + MathUtils.PI1_2;
					}
					
					//速度
					par.vecVelocity.x = Math.cos(ang);
					par.vecVelocity.y = Math.sin(ang);
					par.vecVelocity.multEqual(MathUtils.random(info.fSpeedMin, info.fSpeedMax));
					
					
					//重力，轴另，切加
					par.fGravity = MathUtils.random(info.fGravityMin, info.fGravityMax);
					par.fRadialAccel = MathUtils.random(info.fRadialAccelMin, info.fRadialAccelMax);
					par.fTangentialAccel = MathUtils.random(info.fTangentialAccelMin, info.fTangentialAccelMax);
					
					
					//尺寸
					par.fSize = MathUtils.random(info.fSizeStart, info.fSizeStart + (info.fSizeEnd - info.fSizeStart)*info.fSizeVar);
					par.fSizeDelta = (info.fSizeEnd-par.fSize) / par.fTerminalAge;
					
					
					//旋转
					par.fSpin = MathUtils.random(info.fSpinStart, info.fSpinStart+(info.fSpinEnd-info.fSpinStart)*info.fSpinVar);
					par.fSpinDelta = (info.fSpinEnd-par.fSpin) / par.fTerminalAge;
					
					//颜色
					par.colColor.r = MathUtils.random(info.colColorStart.r, info.colColorStart.r+(info.colColorEnd.r-info.colColorStart.r)*info.fColorVar);
					par.colColor.g = MathUtils.random(info.colColorStart.g, info.colColorStart.g+(info.colColorEnd.g-info.colColorStart.g)*info.fColorVar);
					par.colColor.b = MathUtils.random(info.colColorStart.b, info.colColorStart.b+(info.colColorEnd.b-info.colColorStart.b)*info.fColorVar);
					par.colColor.a = MathUtils.random(info.colColorStart.a, info.colColorStart.a+(info.colColorEnd.a-info.colColorStart.a)*info.fAlphaVar);
					
					par.colColorDelta.r = (info.colColorEnd.r-par.colColor.r) / par.fTerminalAge;
					par.colColorDelta.g = (info.colColorEnd.g-par.colColor.g) / par.fTerminalAge;
					par.colColorDelta.b = (info.colColorEnd.b-par.colColor.b) / par.fTerminalAge;
					par.colColorDelta.a = (info.colColorEnd.a-par.colColor.a) / par.fTerminalAge;
					
					
					//边框
					if(m_bUpdateBoundingBox)
					{
						tmpRect = new Rectangle(par.vecLocation.x, par.vecLocation.y,1,1);
						m_rectBoundingBox.union(tmpRect);
					}
					
					++m_nParticlesAlive;
				}
				
				
			}
			
			
			m_vecPrevLocation = m_vecLocation;
			
		}
		
		public function MoveTo(x:Number, y:Number, bMoveParticles:Boolean = false):void
		{
			var i:int = 0;
			var dx:Number = 0, dy:Number = 0;
			
			if(bMoveParticles)
			{
				dx = x - m_vecLocation.x;
				dy = y - m_vecLocation.y;
				
				for(i = 0; i < m_nParticlesAlive; ++i)
				{
					m_particles[i].vecLocation.x += dx;
					m_particles[i].vecLocation.y += dy;
				}
				
				m_vecPrevLocation.x = m_vecPrevLocation.x + dx;
				m_vecPrevLocation.y = m_vecPrevLocation.y + dy;
				
			}
			else
			{
				if(m_fAge == -2)
				{
					m_vecPrevLocation.x = x;
					m_vecPrevLocation.y = y;
				}
				else
				{
					m_vecPrevLocation.x = m_vecLocation.x;
					m_vecPrevLocation.y = m_vecLocation.y;
				}
			}
			
			m_vecLocation.x = x;
			m_vecLocation.y = y;
		}
		
		
		
		
		public function Transpose(x:Number, y:Number):void
		{
			m_fTx = x; fTy = y;
		}
		
		public function SetScale(scale:Number):void
		{
			m_fScale = scale;
		}
		
		public function TrackBoundingBox(bTrack:Boolean):void
		{
			m_bUpdateBoundingBox = bTrack;
		}
		
		public function GetParticlesAlive():int{return m_nParticlesAlive;}
		public function GetAge():Number{return m_fAge;}
		public function GetPosition():Vector2D{return new Vector2D(m_vecLocation.x, m_vecLocation.y);}
		public function GetTransposition():Vector2D{return new Vector2D(m_fTx, fTy);}
		public function GetScale():Number{return m_fScale;}
		
		public function GetBoundingBox(rect:Rectangle):Rectangle
		{
			rect.x = m_rectBoundingBox.x;
			rect.y = m_rectBoundingBox.y;
			rect.width = m_rectBoundingBox.width;
			rect.height = m_rectBoundingBox.height;
			
			rect.x *= m_fScale;
			rect.y *= m_fScale;
			rect.width *= m_fScale;
			rect.height *= m_fScale;
			
			return rect;
				
		}
		
		
		
		
		
	}
}