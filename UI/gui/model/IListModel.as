package gui.model
{
	import flash.events.IEventDispatcher;
	
	/**
	 * ...
	 * @author roading
	 */
	public interface IListModel extends IEventDispatcher
	{
		function get count():int;
		//
		function get data():Object;
		function set data(value:Object):void;
		//
		
		function get selectedIndex():int;
		function set selectedIndex(value:int):void;
		
		function get selectedData():Object;
		function set selectedData(value:Object):void;
		
		function getDataByIndex(index:uint):Object;
		//
		function sort(name:String):void;
	}
	
}