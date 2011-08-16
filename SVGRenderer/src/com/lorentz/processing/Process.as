package com.lorentz.processing
{
	public class Process implements IProcess
	{
		public static const CONTINUE:int = 0;
		public static const SKIP_FRAME:int = 1;
		public static const COMPLETE:int = 2;
		
		public function Process(startFunction:Function, loopFunction:Function, completeFunction:Function = null)
		{
			_startFunction = startFunction;
			_loopFunction = loopFunction;
			_completeFunction = completeFunction;
		}
		
		private var _loopFunction:Function;
		public function get loopFunction():Function {
			return _loopFunction;
		}
		
		private var _completeFunction:Function;
		public function get completeFunction():Function {
			return _completeFunction;
		}
		
		private var _startFunction:Function;
		public function get startFunction():Function {
			return _startFunction;
		}
		
		internal var _isComplete:Boolean = false;
		public function get isComplete():Boolean {
			return _isComplete;
		}
		
		internal var _isRunning:Boolean = false;
		public function get isRunning():Boolean {
			return _isRunning;
		}
		
		public function start():void {
			if(_isRunning)
				throw new Error("This process is already running.");
			
			if(_isComplete)
				throw new Error("This process is complete.");
			
			_isRunning = true;
			
			if(startFunction != null)
				startFunction();
			
			ProcessExecutor.instance.addProcess(this);
		}
		
		public function stop():void {
			_isRunning = false;
			ProcessExecutor.instance.removeProcess(this);
		}
		
		public function complete():void {
			_isRunning = false;
			_isComplete = true;
			
			if(completeFunction != null)
				completeFunction();
			
			ProcessExecutor.instance.removeProcess(this);
		}
		
		public function reset():void {
			if(_isRunning)
				stop();
			
			_isComplete = false;
		}
		
		public function executeLoop():Boolean {
			var r:* = loopFunction();
			if(r == COMPLETE)
				complete();			
			return r;
		}
	}
}