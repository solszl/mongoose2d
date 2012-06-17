package mongoose.geom
{
	/**
	 *感谢blueshell提供函数支持 
	 * 向下取任意整数的最靠近的2的n次方数 
	 */	
	public function getDownPower2(n:uint):uint
	{
		if((n & n - 1) == 0) return n;
		
		var i : uint = 1;
		while(i < n)
		{
			i <<= 1;
		}
		return (i>>1);
	}
}