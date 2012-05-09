package gui.model
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class DefaultListModel extends EventDispatcher implements IListModel
	{
		
		protected var _data:Object;
		protected var _selectedIndex:int = -1;
		
		public function DefaultListModel(source:Object)
		{
			_data = source;
		}
		
		//
		public function get data():Object
		{
			return _data;
		}
		public function set data(value:Object):void
		{
			_data = value;
			dispatchEvent(new Event('change'));
		}
		//
		
		public function get count():int
		{
			return _data.length;
		}
		
		public function get selectedIndex():int
		{
			return _selectedIndex;
		}
		public function set selectedIndex(value:int):void
		{
			_selectedIndex = value;
		}
		
		public function getDataByIndex(index: uint): Object
		{
			if (index > count)
				return null;
			return _data[index];
		}
		
		public function get selectedData():Object
		{
			if (_selectedIndex >= 0) return _data[_selectedIndex];
			return null;
		}
		
		public function set selectedData(value:Object):void
		{
			var c:int = count;
			var i:int =0;
			for (i = 0; i < c; i++)
			{
				if (_data[i] == value)
				{
					_selectedIndex = i;
					return;
				}
			}
		}
		
		
		public function sort(name:String):void
		{
			/*if (_data is Array)
			{
				var sd:Object = selectedData;
				(_data as Array).sortOn(name);
				selectedData = sd;
			}*/
		}
		
	}
}