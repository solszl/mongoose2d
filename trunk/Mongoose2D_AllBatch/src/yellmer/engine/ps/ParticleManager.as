package yellmer.engine.ps
{
	import flash.geom.Vector3D;

	public class ParticleManager
	{
		public static const MAX_PSYSTEMS:int = 100;
		
		private var m_nPS:int;
		private var m_tX:Number = 0;
		private var m_tY:Number = 0;
		
		private var psList:Vector.<ParticleSystem>;
		
		public function ParticleManager()
		{
			psList = new Vector.<ParticleSystem>(MAX_PSYSTEMS);
			m_nPS = 0;
			m_tX = m_tY = 0;
		}
		
		
		public function Update(dt:Number):void
		{
			var i:int = 0;
			for(i = 0; i < m_nPS; ++i)
			{
				psList[i].Update(dt);
				if(psList[i].GetAge() == -2 && psList[i].GetParticlesAlive() == 0)
				{
					psList[i].Release();
					psList[i] = psList[m_nPS - 1];
					psList[m_nPS - 1] = null;
					--m_nPS;
					--i;
				}
			}
		}
		
		public function Render():void
		{
			var i:int = 0;
			
			for(i = 0; i < m_nPS; ++i)
			{
				psList[i].Render();
			}
		}
		
		
		
		
		public function SpawnPS(psi:ParticleSystemInfo, x:Number, y:Number):ParticleSystem
		{
			if(m_nPS == MAX_PSYSTEMS)
			{
				return null;
			}
			
			psList[m_nPS] = new ParticleSystem(psi);
			psList[m_nPS].FireAt(x,y);
			psList[m_nPS].Transpose(m_tX,m_tY);
			++m_nPS;
			
			return psList[m_nPS - 1];
		}
		
		public function IsPSAlive(ps:ParticleSystem):Boolean
		{
			var i:int = 0;
			for(i = 0; i < m_nPS; ++i)
			{
				if(psList[i] == ps)
				{
					return true;
				}
			}
			
			return false;
		}
		
		public function Transpose(x:Number, y:Number):void
		{
			var i:int = 0;
			for(i = 0; i < m_nPS; ++i)
			{
				psList[i].Transpose(x,y);
			}
			
			m_tX = x;
			m_tY = y;
		}
		
		public function GetTransposition():Vector3D
		{
			return new Vector3D(m_tX, m_tY);
		}
		
		public function KillPS(ps:ParticleSystem):void
		{
			var i:int = 0;
			for(i=0;i<m_nPS;i++)
			{
				if(psList[i]==ps)
				{
					psList[i].Release();
					psList[i]=psList[m_nPS-1];
					psList[m_nPS-1] = null;
					m_nPS--;
					return;
				}
			}
		}
		
		public function KillAll():void
		{
			var i:int = 0;
			for(i=0;i<m_nPS;i++)
			{
				psList[i].Release();
				psList[i] = null;
			}
			m_nPS=0;
		}
		
		
	}
}