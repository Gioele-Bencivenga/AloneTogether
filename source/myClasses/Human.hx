package myClasses;

import flixel.tile.FlxTilemap;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.effects.particles.FlxEmitter;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.FlxSprite;

class Human extends FlxSprite {
	static final BASE_SPEED = 80;
	static final BASE_RUNSPEED = 120;

	public final MAX_HEALTH = 30;

	var speed:Float;
	var runSpeed:Float;

	var up:Bool = false;
	var down:Bool = false;
	var left:Bool = false;
	var right:Bool = false;
	var running:Bool = false;

	public var isInfected(default, null):Bool;
	public var emitter(default, null):FlxEmitter;

	var germAlpha:Float; // germ shade, unique for each person
	var germLifespan:Int; // how long the germs (emitter particles) survive for

	var sicknessTimer:FlxTimer; // how long a human is sick for
	var immunityTimer:FlxTimer; // how long a human is immune for

	var sicknessEffectsInterval:FlxTimer; // interval at which effects are applied

	public var isImmune(default, null):Bool;

	public function new(_x:Float, _y:Float, _sprite:String) {
		super(_x, _y);

		health = FlxG.random.int(5, 30);
		speed = BASE_SPEED;
		runSpeed = BASE_RUNSPEED;
		isInfected = false;
		isImmune = false;

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
		emitter.solid = true; // you need this for overlap checks to work!
		emitter.allowCollisions = FlxObject.ANY;
		emitter.makeParticles(2, 2, FlxColor.PURPLE, 1000);
		emitter.color.set(FlxColor.PURPLE, FlxColor.MAGENTA);
		germAlpha = FlxG.random.float(0.1, 0.5);
		emitter.alpha.set(germAlpha, germAlpha, 0, 0.1);
		germLifespan = FlxG.random.int(10, 30);
		emitter.lifespan.set(germLifespan - 9, germLifespan);
		emitter.drag.set(1);
		emitter.speed.set(6, 10);
		emitter.launchMode = FlxEmitterMode.CIRCLE;

		/// TIMER
		sicknessTimer = new FlxTimer();
		immunityTimer = new FlxTimer();
		sicknessEffectsInterval = new FlxTimer();

		/// HITBOX
		setSize(8, 8); // setting hitbox size to half the graphic (also half of the tiles)
		offset.set(4, 8); // setting the offset of the hitbox to the player's feet
	}

	override function update(elapsed:Float) {
		updateMovement();

		emitter.focusOn(this);

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
				if (facing != touching) {
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

	public function infect() {
		isInfected = true;

		speed -= 20;
		runSpeed -= 20;

		emitter.start(false, 0.05);
		sicknessTimer.start(30, cure);

		sicknessEffectsInterval.start(3, function(_) doDamage(1), 0); // virus debuffs are applied every 3 seconds (for now only damage is felt)
	}

	public function cure(_) {
		isInfected = false;
		isImmune = true;

		speed = BASE_SPEED;
		runSpeed = BASE_RUNSPEED;

		emitter.emitting = false;
		sicknessEffectsInterval.cancel();

		immunityTimer.start(FlxG.random.int(5, 20),
			function(_) isImmune = false); // once a person is cured from the virus it becomes immune to it for some time
	}

	public function doDamage(_damageAmount:Float) {
		health -= _damageAmount;

		setColorTransform(1, 1, 1, 1, 255, 0, 0); // colors the sprite
		var feedback = new FlxTimer().start(0.1,
			function(_) setColorTransform()); // starts a timer that changes the sprite back to the original color after n seconds

		if (health < 0)
			kill();
	}

	override function kill() {
		emitter.emitting = false; // otherwise the emitter will keep emitting from where the body was prior to being killed
		super.kill();
	}
}
