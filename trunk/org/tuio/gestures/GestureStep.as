package org.tuio.gestures {
	
	import flash.utils.getTimer;
	import flash.display.DisplayObject;
	import org.tuio.TuioContainer;
	
	public class GestureStep {
		
		private var _event:String;
		private var _targetAlias:String;
		private var _tuioContainerAlias:String;
		private var _frameIDAlias:String;
		private var _minDelay:uint;
		private var _maxDelay:uint;
		private var _die:Boolean;
		private var _optional:Boolean;
		private var _prepareTime:int;
		private var _goto:int;
		
		internal var group:GestureStepSequence;
		
		/**
		 * Creates a <code>GestureStep</code>. The <code>properties</code> Object can have certain values that will control the behaviour of the step.
		 * 
		 * <ul>
		 *	<li><b>targetAlias</b> This is a <code>String</code> that is used as an alias name for the event's target. By using the same targetAlias for different <code>GestureSteps</code> you can make sure that the event was dispatched on the same target.</li>
		 *	<li><b>tuioContainerAlias</b> This is again a <code>String</code> which if used for different <code>GestureStep</code>s makes sure that the tracked object that generated the event is the same.</li>
		 *	<li><b>frameIDAlias</b> This is also a <code>String</code> which can be used to make sure that the events were all generated by tracked objects from the same tuio frame. If you use a "!" as the first character the value behind the name will be overwritten if it has already been set. This might be useful within loops. Also a failed match will cause the <code>Gesture</code> to fail unlike the other alias types.</li>
		 *	<li><b>minDelay</b> Sets the minimum delay in ms for the specified event. After this delay an incoming event is accepted.</li>
		 *	<li><b>maxDelay</b> Sets the maximum allowed delay in ms for the specified event. After this the gesture fails.</li>
		 *	<li><b>die</b> If set true the gesture fails if the <code>GestureStep</code> is saturated. <code>GestureStep</code>s that have die set true are optional and if the next <code>GestureStep</code> with die set false is saturated will be skipped.</li>
		 *	<li><b>optional</b> If set true the <code>GestureStep</code> will be skipped if it doesn't saturate or dies and the next <code>GestureStep</code> is saturated. If an optional <code>GestureStep</code> dies this won't cause the whole gesture to die.
		 *	<li><b>goto</b> If set to a value between [1-n° of steps] the next check will occur on the specified <code>GestureStep</code>. This is basically for creating loops e.g. jump to an earlier step after reaching the final step.</li>
		 * </ul>
		 * 
		 * @param	event The events name that saturates this step.
		 * @param	properties The properties Object controlling the behaviour of this step.
		 */
		public function GestureStep(event:String, properties:Object) {
			this._event = event;
			this._targetAlias = (properties.targetAlias)?properties.targetAlias.toString():"*";
			this._tuioContainerAlias = (properties.tuioContainerAlias)?properties.tuioContainerAlias.toString():"*";
			this._frameIDAlias = (properties.frameIDAlias)?properties.frameIDAlias.toString():"*";
			this._minDelay = (properties.minDelay)?(properties.minDelay as uint):0;
			this._maxDelay = (properties.maxDelay)?(properties.maxDelay as uint):0;
			this._die = (properties.die)?(properties.die as Boolean):false;
			this._optional = (properties.optional)?(properties.optional as Boolean):false;
			this._goto = (properties.goto)?(properties.goto as int):0;
		}
		
		/**
		 * Starts the timeout counter for minDelay and maxDelay
		 */
		internal function prepare():void {
			if(this._maxDelay > 0 || this._minDelay > 0) this._prepareTime = getTimer();
		}
		
		/**
		 * Checks if a given event, target and tuioContainer saturate the <code>GestureStep</code>. If not it can either die or simply stay alive and wait for further checks.
		 * 
		 * @param	event The events name that shall be checked against.
		 * @param	target The target <code>DisplayObject</code> of the event.
		 * @param	tuioContainer The <code>TuioContainer</code> that triggered the event.
		 * @return A value stating whether the <code>GestureStep</code> is fully saturated, alive or died. Those values are constants of <code>Gesture</code>
		 */
		public function step(event:String, target:DisplayObject, tuioContainer:TuioContainer):uint {
			var wt:int = getTimer() - this._prepareTime;
			var tc:TuioContainer;
			var fID:uint;
			var dObj:DisplayObject;
			if ((this._minDelay <= wt || this._minDelay == 0) && (this._maxDelay >= wt || this._maxDelay == 0)) {
				if (this._event == event) {
					fID = group.getFrameID(this._frameIDAlias);
					if (this._frameIDAlias == "*" || fID == tuioContainer.frameID || (fID == 0 && !group.getFrameIDAlias(tuioContainer.frameID))) {
						tc = group.getTuioContainer(this._tuioContainerAlias);
						if (this._tuioContainerAlias == "*" || tc == tuioContainer || (!tc && !group.getTuioContainerAlias(tuioContainer))) {
							dObj = group.getTarget(this._targetAlias);
							if (this._targetAlias == "*" || dObj == target || (!dObj && !group.getTargetAlias(target))) {
								if ((!tc && this._tuioContainerAlias != "*") || this._tuioContainerAlias.charAt(0) == "!") group.addTuioContainer(this._tuioContainerAlias, tuioContainer);
								if ((!dObj && this._targetAlias != "*") || this._targetAlias.charAt(0) == "!") group.addTarget(this._targetAlias, target);
								if ((fID == 0 && this._frameIDAlias != "*") || this._frameIDAlias.charAt(0) == "!") group.addFrameID(this._frameIDAlias, tuioContainer.frameID);
								this._prepareTime = 0;
								return Gesture.SATURATED;
							} else {
								return Gesture.ALIVE;
							}
						} else {
							return Gesture.ALIVE;
						}
					} else {
						return Gesture.DEAD;
					}
				} else {
					return Gesture.ALIVE;
				}
			} else if (this._minDelay != 0 && this._minDelay >= wt) {
				return Gesture.ALIVE;
			} else {
				this._prepareTime = 0;
				return Gesture.DEAD;
			}
		}
		
		/**
		 * @return A copy of the <code>GestureStep</code> but with a reset timeout counter.
		 */
		public function copy():GestureStep {
			return new GestureStep(this._event, { 	
				targetAlias:this._targetAlias,
				tuioContainerAlias:this._tuioContainerAlias,
				frameIDAlias:this._frameIDAlias,
				minDelay:this._minDelay,
				maxDelay:this._maxDelay,
				goto:this._goto,
				die:this._die,
				optional:this._optional
			});
		}
		
		/**
		 * <code>true</code> if an actual saturation of the step causes a return of <code>Gesture.DEAD</code> if <code>step(...)</code> is called.
		 */
		public function get dies():Boolean {
			return this._die;
		}
		
		/**
		 * <code>true</code> if the <code>GestureStep</code> is optional and can be skipped
		 */
		public function get optional():Boolean {
			return this._optional;
		}
		
		/**
		 * The event's name that is needed to saturate this step.
		 */
		public function get event():String {
			return this._event;
		}
		
		/**
		 * The step to go to after this step saturated. <code>0</code> if there is no step specified.
		 */
		public function get goto():int {
			return this._goto;
		}
	}
	
}