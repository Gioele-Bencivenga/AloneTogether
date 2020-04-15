package myClasses;

import flixel.tile.FlxTilemap;
import flixel.util.FlxTimer;
import flixel.FlxG;

class NPC extends Human {
	var idleTimer:FlxTimer;

	var isUpFree:Bool;
	var isDownFree:Bool;
	var isLeftFree:Bool;
	var isRightFree:Bool;

	var viewLenght:Int;

	public function new() {
		super();

		idleTimer = new FlxTimer();
	}

	override public function initialize(_x:Float, _y:Float, ?_sprite:String) {
		super.initialize(_x, _y, _sprite);

		isUpFree = true;
		isDownFree = true;
		isLeftFree = true;
		isRightFree = true;	
		
		viewLenght = 55;
	}

	override function update(elapsed:Float) {
		idle();

		super.update(elapsed);
	}

	function idle() {
		if (!idleTimer.active) {
			idleTimer.start(FlxG.random.float(0.5, 2.5), MoveInRandomDirection);
		}
	}

	function MoveInRandomDirection(_) {
		var upTimer:FlxTimer = new FlxTimer();
		var downTimer:FlxTimer = new FlxTimer();
		var leftTimer:FlxTimer = new FlxTimer();
		var rightTimer:FlxTimer = new FlxTimer();

		var currXDir = FlxG.random.getObject(["left", "right"]);
		var currYDir = FlxG.random.getObject(["up", "down"]);
		if (!isLeftFree) {
			currXDir = "right";
		} else if (!isRightFree) {
			currXDir = "left";
		} else if (!isLeftFree && !isRightFree) {
			currXDir = "none";
		}
		if (!isUpFree) {
			currYDir = "down";
		} else if (!isDownFree) {
			currYDir = "up";
		} else if (!isUpFree && !isDownFree) {
			currYDir = "none";
		}

		var maxWalkTime:Float = FlxG.random.float(0.5, 3.5);
		if (FlxG.random.bool(20)) { // chance of running instead of walking
			running = true;
		}

		if (currXDir == "left") {
			left = true;
			leftTimer.start(FlxG.random.float(0, maxWalkTime), function(_) {
				left = false;
				running = false;
			});
		} else if (currXDir == "right") {
			right = true;
			rightTimer.start(FlxG.random.float(0, maxWalkTime), function(_) {
				right = false;
				running = false;
			});
		}
		if (currYDir == "up") {
			up = true;
			upTimer.start(FlxG.random.float(0, maxWalkTime), function(_) {
				up = false;
				running = false;
			});
		} else if (currYDir == "down") {
			down = true;
			downTimer.start(FlxG.random.float(0, maxWalkTime), function(_) {
				down = false;
				running = false;
			});
		}
	}

	public function detectSurroundings(_tilemap:FlxTilemap) {
		if (_tilemap.ray(getPosition(), getPosition().add(viewLenght, 0))) {
			isRightFree = true;
		} else {
			isRightFree = false;
		}
		if (_tilemap.ray(getPosition(), getPosition().subtract(viewLenght, 0))) {
			isLeftFree = true;
		} else {
			isLeftFree = false;
		}
		if (_tilemap.ray(getPosition(), getPosition().add(0, viewLenght))) {
			isDownFree = true;
		} else {
			isDownFree = false;
		}
		if (_tilemap.ray(getPosition(), getPosition().subtract(0, viewLenght))) {
			isUpFree = true;
		} else {
			isUpFree = false;
		}
	}
}
