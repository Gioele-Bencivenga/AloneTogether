package;

import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.FlxSprite;

class Human extends FlxSprite {
	static inline final SPEED:Float = 150;

	var up:Bool = false;
	var down:Bool = false;
	var left:Bool = false;
	var right:Bool = false;

	public function new(x:Float, y:Float, sprite:String) {
		super(x, y);

		drag.x = drag.y = 1200;

		loadGraphic(sprite, true, 16, 16);

		setSize(8, 8); // setting hitbox size to half the graphic (also half of the tiles)
		offset.set(4, 8); // setting the offset of the hitbox to the player's feet

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

			velocity.set(SPEED, 0);
			velocity.rotate(FlxPoint.weak(0, 0), directionAngle);

			// if the player is moving (velocity is not 0 for either axis), we change the animation to match their facing
			if ((velocity.x != 0 || velocity.y != 0) && touching == FlxObject.NONE) {
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
