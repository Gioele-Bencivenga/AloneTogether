package;

import myClasses.Item.ItemType;
import flixel.ui.FlxButton.FlxTypedButton;
import myClasses.Pickup.PickupType;
import myClasses.Building.BuildingType;
import flixel.text.FlxText;
import openfl.filters.ShaderFilter;
import flixel.util.FlxTimer;
import openfl.ui.GameInputControl;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.effects.particles.FlxParticle;
import flixel.effects.particles.FlxEmitter;
import flixel.math.FlxMath;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.tile.FlxTilemap;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.FlxState;
import myClasses.*;

class PlayState extends FlxState {
	public static var player:Player; // only public static to be able to access the player for proximity sounds

	public static var pickups:FlxTypedGroup<Pickup>; // group of pickups
	public static var items:FlxTypedGroup<Item>; // group of items

	public static var npcs:FlxTypedGroup<NPC>; // group of npcs
	public static var npcTexts:FlxTypedGroup<FlxText>; // group of npcs
	public static var actors:FlxTypedGroup<Human>; // group of npcs + player
	public static var spawners:FlxTypedGroup<NPCSpawner>; // group of spawners
	public static var buildings:FlxTypedGroup<Building>; // group of buildings
	public static var emitters:FlxTypedGroup<FlxEmitter>; // group of emitters
	public static var radios:FlxTypedGroup<Radio>; // group of radios

	public static var collidingObjects:FlxGroup; // objs that collide with tilemap

	public static var deadCount:Int; // how many people died from the virus

	var map:FlxOgmo3Loader;
	var collisionsLayer:FlxTilemap;
	var groundLayer:FlxTilemap;
	var objectsLayer:FlxTilemap;
	var buildingsLayer:FlxTilemap;
	var rooftopsLayer:FlxTilemap;

	var hud:HUD;

	var gameCamera:FlxCamera;
	var hudCamera:FlxCamera;
	var shaderCamera:FlxCamera;

	var npcDetectionTimer:FlxTimer;

	override public function create():Void {
		FlxG.fixedTimestep = false;

		deadCount = 0;

		/// TILEMAP STUFF
		map = new FlxOgmo3Loader(AssetPaths.cityTilemap__ogmo, AssetPaths.city1__json);
		collisionsLayer = map.loadTilemap(AssetPaths.tiles__png, "collisions");
		collisionsLayer.setTileProperties(1, FlxObject.NONE);
		collisionsLayer.setTileProperties(2, FlxObject.ANY);
		collisionsLayer.useScaleHack = false;
		collisionsLayer.immovable = true;
		add(collisionsLayer);
		groundLayer = map.loadTilemap(AssetPaths.tilemap_packed__png, "ground");
		groundLayer.useScaleHack = false;
		add(groundLayer);
		buildingsLayer = map.loadTilemap(AssetPaths.tilemap_packed__png, "buildings");
		buildingsLayer.useScaleHack = false;
		add(buildingsLayer);
		objectsLayer = map.loadTilemap(AssetPaths.tilemap_packed__png, "objects");
		objectsLayer.useScaleHack = false;
		add(objectsLayer);

		/// CAMERA STUFF
		gameCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		gameCamera.bgColor = FlxColor.TRANSPARENT;
		collisionsLayer.follow(gameCamera); // lock the camera to the wall map edges
		gameCamera.zoom = 2.4;
		FlxG.cameras.add(gameCamera);
		// hud camera
		hudCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		hudCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(hudCamera);

		FlxCamera.defaultCameras = [gameCamera];

		/// GROUPS STUFF
		pickups = new FlxTypedGroup<Pickup>();
		add(pickups);
		items = new FlxTypedGroup<Item>();
		items.maxSize = 1000;
		add(items);
		emitters = new FlxTypedGroup<FlxEmitter>();
		add(emitters);
		radios = new FlxTypedGroup<Radio>();
		add(radios);
		npcs = new FlxTypedGroup<NPC>();
		add(npcs);
		npcTexts = new FlxTypedGroup<FlxText>();
		add(npcTexts);
		spawners = new FlxTypedGroup<NPCSpawner>();
		add(spawners);
		buildings = new FlxTypedGroup<Building>();
		add(buildings);
		actors = new FlxTypedGroup<Human>();
		// no need to add(actors) since npcs are already added and player gets added later

		/// PLAYER STUFF
		player = new Player();
		player.initialize(0, 0);
		add(player);
		actors.add(player);
		add(player.emitter);
		emitters.add(player.emitter);
		gameCamera.follow(player, FlxCameraFollowStyle.LOCKON);

		/// OBJECTS GROUP
		collidingObjects = new FlxGroup();
		collidingObjects.add(actors);
		collidingObjects.add(pickups);
		collidingObjects.add(items);

		/// ENTITY PLACEMENT
		map.loadEntities(placeEntities, "entities");

		// randomly infect some people
		var inf = 0;
		while (inf < 5) {
			var npcToInfect = npcs.getRandom();
			if (npcToInfect != null) {
				npcToInfect.infect();
			}
			inf++; // move this inside the if statement
		}

		// we put the rooftops after the player so they get rendered in front of it
		rooftopsLayer = map.loadTilemap(AssetPaths.tilemap_packed__png, "rooftops");
		rooftopsLayer.useScaleHack = false;
		add(rooftopsLayer);

		// text should appear over rooftops
		for (radio in radios) {
			add(radio.proximityText);
		}
		for (spawner in spawners) {
			add(spawner.proximityText);
		}
		for (building in buildings) {
			add(building.titleText);
			add(building.proximityText);

			if (building.type == BuildingType.Research) {
				add(building.cureProgressBar);
				add(building.cureProgressText);
			}
		}

		/// HUD STUFF
		hud = new HUD(player, actors);
		hud.forEach(function(element) {
			element.cameras = [hudCamera];
		});
		add(hud);

		/// TIMER STUFF
		npcDetectionTimer = new FlxTimer();
		npcDetectionTimer.start(1, callNpcDetectMethod, 0);

		super.create();
	}

	function placeEntities(entity:EntityData) {
		switch (entity.name) {
			case "player":
				player.setPosition(entity.x, entity.y);

			case "coin": // the +4 is to center the coin in the middle of the tile
				var newCoin = new Pickup();
				newCoin.initialize(entity.x + 4, entity.y + 4, PickupType.Coin);
				emitters.add(newCoin.emitter);
				pickups.add(newCoin);

			case "paracetamol":
				var newPara = new Pickup();
				newPara.initialize(entity.x, entity.y, PickupType.Paracetamol);
				emitters.add(newPara.emitter);
				pickups.add(newPara);

			case "mask":
				var newMask = new Item();
				newMask.initialize(entity.x, entity.y, Mask);
				items.add(newMask);

			case "gloves":
				var newGloves = new Item();
				newGloves.initialize(entity.x, entity.y, Gloves);
				items.add(newGloves);

			case "sanitizer":
				var newSanitizer = new Item();
				newSanitizer.initialize(entity.x, entity.y, Sanitizer);
				items.add(newSanitizer);

			case "npcSpawner":
				var newSpawner = new NPCSpawner(entity.x, entity.y, player);
				spawners.add(newSpawner);

			case "npc":
				var newNpc = new NPC();
				newNpc.initialize(entity.x + 4, entity.y + 4);
				emitters.add(newNpc.emitter);
				npcTexts.add(newNpc.thanksText);
				npcs.add(newNpc);
				actors.add(newNpc);

			case "research":
				var newBuilding = new Building(entity.x, entity.y, BuildingType.Research, player);
				buildings.add(newBuilding);

			case "pharmacy":
				var newBuilding = new Building(entity.x, entity.y, BuildingType.Pharmacy, player);
				buildings.add(newBuilding);

			case "radio":
				var newRadio = new Radio(entity.x - 8, entity.y - 8);
				radios.add(newRadio);
		}
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		// collisions between actors
		FlxG.collide(actors, actors, humanTouchesHuman);
		// collisions between actors, pickups and items against tilemap
		FlxG.collide(collidingObjects, collisionsLayer);

		// overlaps between actors and virus
		FlxG.overlap(actors, emitters, humanTouchesVirus);
		// overlaps between actors and pickups
		FlxG.overlap(actors, pickups, humanTouchesPickup);
		// overlaps between actors and items
		FlxG.overlap(actors, items, humanTouchesItem);
		// overlaps between player and spawners
		FlxG.overlap(player, spawners, playerOverSpawner);
		// overlaps between player and buildings
		FlxG.overlap(player, buildings, playerOverBuilding);

		FlxG.overlap(player, radios, playerOverRadio);

		// pressing period/comma zooms in/out
		if (FlxG.keys.justPressed.PERIOD) {
			SetZoom(FlxG.camera.zoom += 0.2);
		}
		if (FlxG.keys.justPressed.COMMA) {
			SetZoom(FlxG.camera.zoom -= 0.2);
		}
	}

	function humanTouchesPickup(_actor:Human, _pickup:Pickup) {
		if (_actor.alive && _actor.exists && _pickup.alive && _pickup.exists) {
			if (_actor.canPickUp) {
				switch _pickup.type {
					case Coin:
						_pickup.myKill();
						_actor.pickupPickup(_pickup);
					case Paracetamol:
						if (_actor.health < _actor.MAX_HEALTH) {
							_pickup.myKill();
							_actor.pickupPickup(_pickup);
						}
				}
			}
		}
	}

	function humanTouchesItem(_actor:Human, _item:Item) {
		if (_actor.alive && _actor.exists && _item.alive && _item.exists && !_item.isEquipped) {
			if (_actor.canPickUp) {
				if (_actor.items.members[_item.slot] == null) {
					_item.tryToEquipTo(_actor);
					_actor.equipItem(_item);
				} else if (_item.type == ItemType.Syringe) {
					if (_actor.items.members[_item.slot + 1] == null) {
						_item.tryToEquipTo(_actor);
						_actor.equipItem(_item);
					} else if (_actor.items.members[_item.slot + 2] == null) {
						_item.tryToEquipTo(_actor);
						_actor.equipItem(_item);
					}
				}
			}
		}
	}

	function humanTouchesVirus(_actor:Human, _particle:FlxParticle) {
		if (_actor.alive && _actor.exists && _particle.alive && _particle.exists) {
			if (!_actor.isInfected && !_actor.isImmune) {
				_actor.tryToInfect();
			}
		}
	}

	function humanTouchesHuman(_actor1:Human, _actor2:Human) {
		if (_actor1.alive && _actor1.exists && _actor2.alive && _actor2.exists) {
			if (_actor1.isInfected) {
				if (!_actor2.isInfected && !_actor2.isImmune) {
					_actor2.tryToInfect();
				}
			}
			if (_actor2.isInfected) {
				if (!_actor1.isInfected && !_actor1.isImmune) {
					_actor1.tryToInfect();
				}
			}
		}
	}

	function playerOverSpawner(_player:Player, _spawner:NPCSpawner) {
		if (_player.alive && _player.exists && _spawner.alive && _spawner.exists) {
			if (!_spawner.isTextVisible) {
				_spawner.showProximityText();
			}
			if (_player.interactPressed()) {
				_spawner.interact();
			}
		}
	}

	function playerOverRadio(_player:Player, _radio:Radio) {
		if (_player.alive && _player.exists && _radio.alive && _radio.exists) {
			if (!_radio.isTextVisible) {
				_radio.showProximityText();
			}
			if (_player.interactPressed()) {
				_radio.interact();
			}
		}
	}

	function playerOverBuilding(_player:Player, _building:Building) {
		if (_player.alive && _player.exists && _building.alive && _building.exists) {
			if (!_building.isTextVisible) {
				_building.showProximityText();
			}
			if (_player.interactOptionsPressed()) {
				_building.interact(_player.interactOption);
			}
		}
	}

	function callNpcDetectMethod(_) { // called each second by the timer so that NPCs run less into walls
		for (npc in npcs) {
			npc.detectSurroundings(collisionsLayer);
		}
	}

	private function SetZoom(_zoom:Float) {
		gameCamera.zoom = FlxMath.bound(_zoom, 1.5, 3);
	}
}
