package;

import flixel.math.FlxMath;
import flixel.math.FlxAngle;
import nape.geom.Vec2;
import flixel.addons.nape.FlxNapeSprite;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.FlxSprite;

class Human extends FlxNapeSprite {
	static inline final SPEED:Float = 5;

	var direction:Vec2; // direction vector used to apply movement impulse

	var up:Bool = false;
	var down:Bool = false;
	var left:Bool = false;
	var right:Bool = false;

	public function new(x:Float = 0, y:Float = 0, sprite:String) {
		super(x, y);

		createCircularBody(5);
		setBodyMaterial(1, 0.001, 0.001, 1, 0.001);
		setDrag(0.85, 0.85);

		loadGraphic(sprite, true, 16, 16);

		animation.add("walkLeft", [0, 1, 0, 2], 6, false);
		animation.add("walkRight", [0, 1, 0, 2], 6, false, true);
		animation.add("walkUp", [6, 7, 6, 8], 6, false);
		animation.add("walkDown", [3, 4, 3, 5], 6, false);
	}

	override function update(elapsed:Float) {
		updateMovement();

		super.update(elapsed);
	}

	function updateMovement() {
		// opposing directions cancel each other out
		if (up && down)
			up = down = false;
		if (left && right)
			left = right = false;

		if (up || down || left || right) {
			var directionAngle:Float = 0;
			if (up) {
				directionAngle = -90;
				if (left)
					directionAngle -= 45;
				else if (right)
					directionAngle += 45;
				facing = FlxObject.UP;
			} else if (down) {
				directionAngle = 90;
				if (left)
					directionAngle += 45;
				else if (right)
					directionAngle -= 45;
				facing = FlxObject.DOWN;
			} else if (left) {
				directionAngle = 180;
				facing = FlxObject.LEFT;
			} else if (right) {
				directionAngle = 0;
				facing = FlxObject.RIGHT;
			}

			direction = Vec2.fromPolar(SPEED, directionAngle * FlxAngle.TO_RAD); // I have no clue how to use radians so I'm just gonna convert the value
			body.applyImpulse(direction);

			// if the player is moving (velocity is not 0 for either axis), we change the animation to match their facing
			if (Math.abs(body.velocity.x) >= SPEED || Math.abs(body.velocity.y) >= SPEED) {
				switch (facing) {
					case FlxObject.LEFT:
						animation.play("walkLeft");
					case FlxObject.RIGHT:
						animation.play("walkRight");
					case FlxObject.UP:
						animation.play("walkUp");
					case FlxObject.DOWN:
						animation.play("walkDown");
				}
			}
		}
	}
}
