package myClasses;

import flixel.util.FlxTimer;
import flixel.math.FlxVelocity;
import flixel.FlxG;
import flixel.math.FlxPoint;

class NPC extends Human {
	var brain:FSM;
	var idleTimer1:Float;
	var moveDirection:Float;

	var seesHuman:Bool;
	var humanPosition:FlxPoint;

	var idleTimer:FlxTimer;

	public function new(_x:Float = 0, _y:Float = 0, _sprite:String) {
		super(_x, _y, _sprite);

		// brain = new FSM(idle);
		// idleTimer1 = 0;
		// humanPosition = FlxPoint.get();

		idleTimer = new FlxTimer();
	}

	override function update(elapsed:Float) {
		// brain.update(elapsed);
		idle();

		super.update(elapsed);
	}

	// idle function by rpg tutorial

	/*function idle(elapsed:Float) {
		if (seesHuman) {
			brain.activeState = chase;
		} else if (idleTimer1 <= 0) {
			if (FlxG.random.bool(1)) {
				moveDirection = -1;
				velocity.x = velocity.y = 0;
			} else {
				moveDirection = FlxG.random.int(0, 8) * 45;

				velocity.set(speed, 0);
				velocity.rotate(FlxPoint.weak(), moveDirection);
			}
			idleTimer1 = FlxG.random.int(1, 4);
		} else
			idleTimer1 -= elapsed;
	}*/

	function idle() {
		if(!idleTimer.active){
			idleTimer.start(FlxG.random.int(1, 3), MoveInRandomDirection);
		}
	}

	function MoveInRandomDirection(_) {
		var upTimer:FlxTimer = new FlxTimer();
		var downTimer:FlxTimer = new FlxTimer();
		var leftTimer:FlxTimer = new FlxTimer();
		var rightTimer:FlxTimer = new FlxTimer();

		var currXDir = FlxG.random.getObject(["left", "right"]);
		var currYDir = FlxG.random.getObject(["up", "down"]);

		var maxWalkTime:Float = 2;

		if (currXDir == "left") {
			left = true;
			leftTimer.start(FlxG.random.float(0, maxWalkTime), function(_) left = false);

			if (currYDir == "up") {
				up = true;
				upTimer.start(FlxG.random.float(0, maxWalkTime), function(_) up = false);
			} else if (currYDir == "down") {
				down = true;
				downTimer.start(FlxG.random.float(0, maxWalkTime), function(_) down = false);
			}
		} else if (currXDir == "right") {
			right = true;
			rightTimer.start(FlxG.random.float(0, maxWalkTime), function(_) right = false);

			if (currYDir == "up") {
				up = true;
				upTimer.start(FlxG.random.float(0, maxWalkTime), function(_) up = false);
			} else if (currYDir == "down") {
				down = true;
				downTimer.start(FlxG.random.float(0, maxWalkTime), function(_) down = false);
			}
		}
	}

	/*function chase(elapsed:Float) {
		if (!seesHuman) {
			brain.activeState = idle;
		} else {
			FlxVelocity.moveTowardsPoint(this, humanPosition, Std.int(runSpeed));
		}
	}*/
}
