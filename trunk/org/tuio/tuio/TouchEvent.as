package org.tuio.tuio {
	
	import flash.display.*;
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	 * The TochEvent is a multitouch version of Flash's MouseEvent.
	 * 
	 * @author Immanuel Bauer
	 */
	public class TouchEvent extends Event {
		
		public static const MOUSE_UP:String = "org.tuio.tuio.TouchEvent.MOUSE_UP";
		public static const MOUSE_DOWN:String = "org.tuio.tuio.TouchEvent.MOUSE_DOWN";
		public static const MOUSE_MOVE:String = "org.tuio.tuio.TouchEvent.MOUSE_MOVE";
		public static const MOUSE_OUT:String = "org.tuio.tuio.TouchEvent.MOUSE_OUT";
		public static const MOUSE_OVER:String = "org.tuio.tuio.TouchEvent.MOUSE_OVER";
		public static const ROLL_OUT:String = "org.tuio.tuio.TouchEvent.ROLL_OUT";
		public static const ROLL_OVER:String = "org.tuio.tuio.TouchEvent.ROLL_OVER";
		
		public static const CLICK:String = "org.tuio.tuio.TouchEvent.CLICK";
		public static const DOUBLE_CLICK:String = "org.tuio.tuio.TouchEvent.DOUBLE_CLICK";
		
		private var _tuioContainer:TuioContainer;
		
		public var localX:Number = NaN;
		public var localY:Number = NaN;
		public var stageX:Number = NaN;
		public var stageY:Number = NaN;
		public var relatedObject:DisplayObject;
		
		public function TouchEvent(type:String, bubbles:Boolean = true, cancelable:Boolean = false, localX:Number = NaN, localY:Number = NaN, stageX:Number = NaN, stageY:Number = NaN, relatedObject:DisplayObject = null, tuioContainer:TuioContainer = null) {
			super(type, bubbles, cancelable);
			this._tuioContainer = tuioContainer;
			
			this.relatedObject = relatedObject;
			
			this.stageX = stageX;
			this.stageY = stageY;
				
			this.localX = localX;
			this.localY = localY;
		}
		
		public function get tuioContainer():TuioContainer {
			return this._tuioContainer;
		}
		
	}
	
}