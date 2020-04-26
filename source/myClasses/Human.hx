package myClasses;

import flixel.system.FlxSound;
import myClasses.Pickup.PickupType;
import flixel.tweens.FlxEase;
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

	var canMove:Bool; // flag used to decide if updateMovemement should be called

	var up:Bool = false;
	var down:Bool = false;
	var left:Bool = false;
	var right:Bool = false;
	var running:Bool = false;
	var j:Bool = false; // variables for chucking items
	var k:Bool = false;
	var l:Bool = false;
	var e:Bool = false;

	public var interactOption(default, null):Int = 0; // contains 1 to 4 based on what number is pressed

	var one:Bool = false;
	var two:Bool = false;
	var three:Bool = false;
	var four:Bool = false;

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

	var pickupTimer:FlxTimer;

	/// SOUNDS
	var footstepsSound:FlxSound;
	var runSound:FlxSound;

	// for things that are only set once
	public function new() {
		super();

		/// PHYSICS
		drag.x = drag.y = 1200;
		angularDrag = 5;

		/// EMITTER
		emitter = new FlxEmitter(x, y);
		emitter.loadParticles(AssetPaths.virusSprite__png, 50);
		emitter.maxSize = 50;

		/// TIMER
		healthRegenTimer = new FlxTimer();
		sicknessTimer = new FlxTimer();
		immunityTimer = new FlxTimer();
		sicknessEffectsInterval = new FlxTimer();
		pickupTimer = new FlxTimer();

		/// SOUNDS
		footstepsSound = FlxG.sound.load(AssetPaths.footsteps__wav);
		footstepsSound.volume = 0.2;
		runSound = FlxG.sound.load(AssetPaths.footstepsRun__wav);
		runSound.volume = 0.2;
	}

	// for things that need to be set each time we recycle
	public function initialize(_x:Float, _y:Float, ?_sprite:String) {
		x = _x;
		y = _y;

		if (FlxG.random.bool(80)) {
			health = FlxG.random.int(35, 40);
		} else {
			health = FlxG.random.int(5, 10);
		}
		speed = BASE_SPEED;
		runSpeed = BASE_RUNSPEED;
		isInfected = false;
		isImmune = false;
		canBeInfected = true;
		infectionChance = BASE_INFECTIONCHANCE;
		coinAmount = FlxG.random.int(1, 5);
		items = new FlxTypedGroup<Item>(3);
		canPickUp = true;
		canMove = true;

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
		angle = 0;
		alpha = 1;

		/// HITBOX
		setSize(8, 8); // setting hitbox size to half the graphic (also half of the tiles)
		offset.set(4, 8); // setting the offset of the hitbox to the player's feet

		/// ANIMATIONS
		animation.add("walkLeft", [0, 1, 0, 2], 6, false);
		animation.add("walkRight", [0, 1, 0, 2], 6, false, true);
		animation.add("walkUp", [6, 7, 6, 8], 6, false);
		animation.add("walkDown", [3, 4, 3, 5], 6, false);

		/// EMITTER
		emitter.allowCollisions = FlxObject.ANY; // you need this for overlap checks to work!
		emitter.color.set(FlxColor.PURPLE, FlxColor.MAGENTA, FlxColor.YELLOW, FlxColor.GREEN);
		germAlpha = FlxG.random.float(0.3, 0.5);
		emitter.alpha.set(germAlpha - 0.1, germAlpha, 0.15);
		emitter.lifespan.set(1, 30);
		emitter.drag.set(1);
		maxGermSpeed = 30;
		emitter.speed.set(5, maxGermSpeed);
		emitter.launchMode = FlxEmitterMode.CIRCLE;
		emitter.scale.set(1, 1, 1, 1, 1.5, 1.5, 3.5, 3.5);
		emitter.autoUpdateHitbox = true;

		/// HEALTH REGEN
		healthRegenTimer.start(10, function(_) health += 1, 0);
	}

	override function update(elapsed:Float) {
		updateMovement();
		updateChucking();

		emitter.focusOn(this);

		super.update(elapsed);
	}

	function updateMovement() {
		if (canMove) {
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

				if (running) {
					runSound.proximity(x, y, PlayState.player, 150, false);
					runSound.play();
				}
				if (!running) {
					footstepsSound.proximity(x, y, PlayState.player, 150, false);
					footstepsSound.play();
				}

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
	}

	function updateChucking() {
		if (j) {
			if (items.members[0] != null) {
				chuckItem(items.members[0]);
			} else {
				if (items.members[1] != null) {
					chuckItem(items.members[1]);
				} else {
					if (items.members[2] != null) {
						chuckItem(items.members[2]);
					}
				}
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
		FlxTween.tween(_item, { // we move the item to player's position before chucking (prevents items getting chucked when inside solids)
			x: this.x,
			y: this.y,
		}, 0.07, {
			onComplete: function(_) {
				// prevent human from picking up the item right away
				canPickUp = false;
				pickupTimer.start(0.25, function(_) canPickUp = true);
				// unequip item
				_item.unEquip();
				items.members[_item.slot] = null;
				// set velocity
				_item.velocity.set(500, 0);
				_item.velocity.rotate(FlxPoint.weak(0, 0), directionAngle);
				// modify stats
				infectionChance += _item.infectionChanceReduction;
				maxGermSpeed += _item.germSpeedReduction;
				emitter.speed.set(5, maxGermSpeed);
			}
		});
	}

	public function interactPressed():Bool {
		return e;
	}

	public function interactOptionsPressed():Bool {
		if (one || two || three || four) {
			return true;
		} else {
			return false;
		}
	}

	public function pickupPickup(_pickup:Pickup) {
		if (canPickUp) {
			switch _pickup.type {
				case Coin:
					coinAmount += 1;

				case Paracetamol:
					heal(5);
			}
		}
	}

	public function loseCoins(_amountLost:Int) {
		coinAmount -= _amountLost;
	}

	function dropCoins(_amount:Int) {
		coinAmount -= _amount;
		for (i in 0..._amount) {
			var newCoin = PlayState.pickups.recycle(Pickup.new);
			newCoin.initialize(x, y, PickupType.Coin);
			PlayState.pickups.add(newCoin);

			var maxVel = 200;
			newCoin.velocity.set(FlxG.random.float(-maxVel, maxVel), FlxG.random.float(-maxVel, maxVel));
		}
		canPickUp = false;
		var t = new FlxTimer().start(0.2, function(_) canPickUp = true);
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
			var t = new FlxTimer().start(0.7, function(_) canBeInfected = true);
		}
	}

	public function infect() {
		isInfected = true;

		emitter.start(false, 0.55);

		sicknessTimer.start(30, cure);
		sicknessEffectsInterval.start(2, function(_) doDamage(2), 0);
	}

	public function cure(_) {
		isInfected = false;
		isImmune = true;

		emitter.emitting = false;
		sicknessEffectsInterval.cancel();

		immunityTimer.start(FlxG.random.int(2, 10),
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
		alive = false;

		PlayState.deadCount++;

		unEquipItems();
		dropCoins(coinAmount);

		sicknessTimer.cancel();
		sicknessEffectsInterval.cancel();
		healthRegenTimer.cancel();
		emitter.emitting = false; // otherwise the emitter will keep emitting from where the body was prior to being killed

		canMove = false; // we stop current movement

		setColorTransform(1, 1, 1, 1, 255, 0, 0);
		FlxTween.tween(this, {
			angle: 90
		}, 0.5).then(FlxTween.tween(this, {
			alpha: 0.1
		}, 0.5, {onComplete: function(_) kill()}));
	}

	function unEquipItems() {
		for (i in 0...items.members.length) {
			if (items.members[i] != null) {
				items.members[i].unEquip();
				items.members[i] = null;
			}
		}

		canPickUp = false;
		var t = new FlxTimer().start(1, function(_) canPickUp = true);
	}
}
