package myClasses;

import flixel.tweens.FlxTween;
import haxe.Timer;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.effects.particles.FlxParticle;
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
	static final BASE_INFECTIONCHANCE = 70;

	public final MAX_HEALTH = 30;

	var speed:Float;
	var runSpeed:Float;

	var up:Bool = false;
	var down:Bool = false;
	var left:Bool = false;
	var right:Bool = false;
	var running:Bool = false;
	var j:Bool = false; // variables for chucking items
	var k:Bool = false;
	var l:Bool = false;

	var directionAngle:Float;

	public var isInfected(default, null):Bool;
	public var emitter(default, null):FlxEmitter;

	var germAlpha:Float; // germ shade, unique for each person
	var germLifespan:Int; // how long the germs (emitter particles) survive for
	var maxGermSpeed:Int;

	var healthRegenTimer:FlxTimer;
	var sicknessTimer:FlxTimer; // how long a human is sick for
	var immunityTimer:FlxTimer; // how long a human is immune for

	var sicknessEffectsInterval:FlxTimer; // interval at which effects are applied

	public var isImmune(default, null):Bool; // used for immunity gained after being sick

	var canBeInfected:Bool; // flag used for the check of whether we can get infected or not

	public var infectionChance(default, null):Float; // chance to get infected on virus contact

	public var coinAmount(default, null):Int;

	public var items(default, null):FlxTypedGroup<Item>;

	public var canPickUp(default, null):Bool; // flag for determining if objects should be picked up or not

	// for things that are only set once
	public function new() {
		super();

		/// PHYSICS
		drag.x = drag.y = 1200;
		angularDrag = 5;

		/// EMITTER
		emitter = new FlxEmitter(x, y);
		emitter.loadParticles(AssetPaths.virusSprite__png, 400);

		/// TIMER
		healthRegenTimer = new FlxTimer();
		sicknessTimer = new FlxTimer();
		immunityTimer = new FlxTimer();
		sicknessEffectsInterval = new FlxTimer();
	}

	// for things that need to be set each time we recycle
	public function initialize(_x:Float, _y:Float, ?_sprite:String) {
		x = _x;
		y = _y;

		health = FlxG.random.int(5, 30);
		speed = BASE_SPEED;
		runSpeed = BASE_RUNSPEED;
		isInfected = false;
		isImmune = false;
		canBeInfected = true;
		infectionChance = BASE_INFECTIONCHANCE;
		coinAmount = 0;
		items = new FlxTypedGroup<Item>(3);
		canPickUp = true;

		/// GRAPHICS
		if (_sprite == null) {
			_sprite = FlxG.random.getObject([
				AssetPaths.bob__png,
				AssetPaths.boba__png,
				AssetPaths.bobby__png,
				AssetPaths.bobert__png,
				AssetPaths.bobesha__png,
				AssetPaths.bobunter__png
			]);
		}
		loadGraphic(_sprite, true, 16, 16);
		scale.set(1, 1);

		/// HITBOX
		setSize(8, 8); // setting hitbox size to half the graphic (also half of the tiles)
		offset.set(4, 8); // setting the offset of the hitbox to the player's feet

		/// ANIMATIONS
		animation.add("walkLeft", [0, 1, 0, 2], 6, false);
		animation.add("walkRight", [0, 1, 0, 2], 6, false, true);
		animation.add("walkUp", [6, 7, 6, 8], 6, false);
		animation.add("walkDown", [3, 4, 3, 5], 6, false);

		/// EMITTER
		emitter.solid = true; // you need this for overlap checks to work!
		emitter.allowCollisions = FlxObject.ANY;
		emitter.color.set(FlxColor.PURPLE, FlxColor.MAGENTA, FlxColor.YELLOW, FlxColor.GREEN);
		germAlpha = FlxG.random.float(0.2, 0.5);
		emitter.alpha.set(germAlpha, germAlpha, 0);
		germLifespan = FlxG.random.int(15, 35);
		emitter.lifespan.set(germLifespan - 15, germLifespan);
		emitter.drag.set(2);
		maxGermSpeed = 22;
		emitter.speed.set(5, maxGermSpeed);
		emitter.launchMode = FlxEmitterMode.CIRCLE;

		/// HEALTH REGEN
		healthRegenTimer.start(13, function(_) heal(1), 0);
	}

	override function update(elapsed:Float) {
		updateMovement();
		updateChucking();

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
			directionAngle = 0;
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

	function updateChucking() {
		if (j) {
			if (items.members[0] != null) {
				chuckItem(items.members[0]);
			}
		} else if (k) {
			if (items.members[1] != null) {
				chuckItem(items.members[1]);
			}
		} else if (l) {
			if (items.members[2] != null) {
				chuckItem(items.members[2]);
			}
		}
	}

	function chuckItem(_item:Item) {
		canPickUp = false;
		var t = new FlxTimer().start(0.2, function(_) canPickUp = true);

		FlxTween.tween(_item, { // we move the item to player's position before chucking (prevents items getting chucked when inside solids)
			x: this.x,
			y: this.y,
		}, 0.05);
		_item.velocity.set(600, 0);
		_item.velocity.rotate(FlxPoint.weak(0, 0), directionAngle);
		_item.unEquip();
		items.members[_item.slot] = null;

		infectionChance += _item.infectionChanceReduction;
		maxGermSpeed += _item.germSpeedReduction;
		emitter.speed.set(5, maxGermSpeed);
	}

	public function gainCoin(_amountGained:Int) {
		coinAmount += _amountGained;
	}

	public function equipItem(_item:Item) {
		items.members[_item.slot] = _item;
		infectionChance -= _item.infectionChanceReduction;
		maxGermSpeed -= _item.germSpeedReduction;

		emitter.speed.set(5, maxGermSpeed);
	}

	public function tryToInfect() {
		if (canBeInfected) {
			if (FlxG.random.bool(infectionChance)) {
				infect();
			}
			canBeInfected = false;
			var t = new FlxTimer().start(1, function(_) canBeInfected = true);
		}
	}

	public function infect() {
		isInfected = true;

		emitter.start(false, 0.5);

		sicknessTimer.start(30, cure);
		sicknessEffectsInterval.start(5, function(_) doDamage(4), 0); // virus debuffs are applied every 3 seconds (for now only damage is felt)
	}

	public function cure(_) {
		isInfected = false;
		isImmune = true;

		emitter.emitting = false;
		sicknessEffectsInterval.cancel();

		immunityTimer.start(FlxG.random.int(5, 20),
			function(_) isImmune = false); // once a person is cured from the virus it becomes immune to it for some time
	}

	public function doDamage(_damageAmount:Float) {
		health -= _damageAmount;

		setColorTransform(1, 1, 1, 1, 255, 0, 0); // colors the sprite
		FlxTween.tween(this.scale, {
			x: 0.5,
			y: 1.5,
		}, 0.10).then(FlxTween.tween(this.scale, {
			x: 1,
			y: 1
		}, 0.10, {onComplete: function(_) setColorTransform()}));

		if (health < 0)
			myKill();
	}

	function heal(_healthAmount:Float) {
		if (health < MAX_HEALTH) {
			health += _healthAmount;
		}
	}

	function myKill() {
		unEquipItems();

		up = left = right = down = false; // we stop current movement

		setColorTransform(1, 1, 1, 1, 255, 0, 0);
		FlxTween.tween(this, {
			angle: 90
		}, 0.3);

		FlxTween.tween(this, {
			alpha: 0.1
		}, 0.5, {onComplete: function(_) kill()});
	}

	override function kill() {
		emitter.emitting = false; // otherwise the emitter will keep emitting from where the body was prior to being killed

		super.kill();
	}

	function unEquipItems() {
		for (i in 0...items.members.length) {
			if (items.members[i] != null) {
				items.members[i].unEquip();
				items.members[i] = null;
			}
		}
	}
}
