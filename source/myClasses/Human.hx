package myClasses;

import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.effects.particles.FlxEmitter;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.FlxSprite;

class Human extends FlxSprite {
	var speed:Float = 80;
	var runSpeed:Float = 120;

	var up:Bool = false;
	var down:Bool = false;
	var left:Bool = false;
	var right:Bool = false;
	var running:Bool = false;

	public var isInfected(default, null):Bool;
	public var emitter:FlxEmitter;

	var virusAlpha:Float;
	var virusLifespan:Int;

	public function new(_x:Float, _y:Float, _sprite:String) {
		super(_x, _y);

		isInfected = false;

		/// PHYSICS
		drag.x = drag.y = 1200;

		/// GRAPHICS
		loadGraphic(_sprite, true, 16, 16);

		/// ANIMATIONS
		animation.add("walkLeft", [0, 1, 0, 2], 6, false);
		animation.add("walkRight", [0, 1, 0, 2], 6, false, true);
		animation.add("walkUp", [6, 7, 6, 8], 6, false);
		animation.add("walkDown", [3, 4, 3, 5], 6, false);

		/// EMITTER
		emitter = new FlxEmitter(x, y);
		emitter.makeParticles(2, 2, FlxColor.PURPLE, 1000);
		emitter.color.set(FlxColor.PURPLE, FlxColor.MAGENTA);
		virusAlpha = FlxG.random.float(0.06, 0.5);
		emitter.alpha.set(virusAlpha, virusAlpha, 0, 0.05);
		virusLifespan = FlxG.random.int(5, 10);
		emitter.lifespan.set(virusLifespan - 4, virusLifespan);
		emitter.drag.set(30);
		emitter.speed.set(20, 35);
		emitter.launchMode = FlxEmitterMode.CIRCLE;

		/// HITBOX
		setSize(8, 8); // setting hitbox size to half the graphic (also half of the tiles)
		offset.set(4, 8); // setting the offset of the hitbox to the player's feet
	}

	override function update(elapsed:Float) {
		updateMovement();

		if (isInfected) {
			if (!emitter.emitting) {
				emitter.focusOn(this);
				emitter.start(false, 0.05, 1);
			}
		} else if (!isInfected) {
			if (emitter.emitting) {
				emitter.emitting = false;
			}
		}

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

			if (running) {
				velocity.set(runSpeed, 0);
			} else {
				velocity.set(speed, 0);
			}
			velocity.rotate(FlxPoint.weak(0, 0), directionAngle);

			// if the player is moving (velocity is not 0 for either axis), we change the animation to match their facing
			if (velocity.x != 0 || velocity.y != 0) {
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

	public function infect() {
		isInfected = true;
	}
}
