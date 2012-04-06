package mongoose.display
{
    import flash.events.*;

    public class InteractiveObject extends DisplayObject
    {

        public function InteractiveObject()
        {
            stage.addEventListener(Event.ENTER_FRAME, onEnter);
        }// end function

        private function onEnter(event:Event) : void
        {
            dispatchEvent(event);
        }// end function

    }
}
