package math
{
	/**
	 *感谢blueshell提供函数支持
	 * 向上取任意整数的最靠近的2的n次方数 
	 */	
	public function getUpPower2(n:uint):uint
	{
		if((n & n - 1) == 0) return n;
		if ((n & 0x80000000) != 0) return 0; //overflow
		
		var i:uint = 1;
		while(i < n)
		{
			i <<= 1;
		}
		return i;
	}
	
}