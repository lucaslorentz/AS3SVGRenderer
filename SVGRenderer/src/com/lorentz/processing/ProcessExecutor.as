package com.lorentz.processing
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.getTimer;

	public class ProcessExecutor
	{		
		private static var _allowInstantiation:Boolean = false;
		private static var _instance:ProcessExecutor;
		
		public static function get instance():ProcessExecutor {
			if(_instance == null){
				_allowInstantiation = true;
				_instance = new ProcessExecutor();
				_allowInstantiation = false;
			}
			
			return _instance;
		}
		
		private var _stage:Stage;
		private var _processes:Vector.<IProcess>;
		private var _percentFrameProcessingTime:Number = 0.25; //Considering the use of 25% of the available time
		
		public function ProcessExecutor()
		{
			if(!_allowInstantiation)
				throw new Error("The class 'ProcessExecutor' is singleton.");
		}
		
		public function initialize(stage:Stage):void {
			_stage = stage;
			_processes = new Vector.<IProcess>();
		}
				
		public function get percentFrameProcessingTime():Number {
			return _percentFrameProcessingTime;
		}
		public function set percentFrameProcessingTime(value:Number):void {
			_percentFrameProcessingTime = value;
		}
		
		private function get internalFrameProcessingTime():Number {
			return 1000 / _stage.frameRate * _percentFrameProcessingTime; 
		}
		
		private function ensureInitialized():void {
			if(_stage == null)
				throw new Error("You must initialize the ProcessExecutor. Ex: ProcessExecutor.instance.initialize(stage)");
		}
		
		public function addProcess(process:IProcess):void {
			ensureInitialized();
			
			if(_processes.length == 0)
				_stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
				
			_processes.push(process);
		}
		
		public function containsProcess(process:IProcess):Boolean {
			return _processes.indexOf(process) != -1;
		}
		
		public function removeProcess(process:IProcess):void {
			var index:int = _processes.indexOf(process);
			
			if(index == -1)
				return;
			
			_processes.splice(index, 1);
			
			if(_processes.length == 0)
				_stage.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function enterFrameHandler(e:Event):void {
			var timePerProcess:int = internalFrameProcessingTime / _processes.length;
			
			for each(var process:IProcess in _processes)
				executeProcess(process, timePerProcess);
		}
		
		private function executeProcess(process:IProcess, duration:int):void {
			var endTime:int = getTimer() + duration;
			var executeFunction:Function = process.executeLoop; 
			while(getTimer() < endTime)
				if(executeFunction())
					break;
		}
	}
}