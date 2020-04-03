package;

import haxe.Json;
import flixel.tile.FlxTilemap;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.addons.nape.FlxNapeTilemap;
import flixel.addons.nape.FlxNapeSpace;
import flixel.FlxState;

class PlayState extends FlxState {
	var player:Player;

	var map:FlxOgmo3Loader;
	var walls:FlxNapeTilemap;

	override public function create():Void {
		// initializing the space for physics simulation
		FlxNapeSpace.init();
		FlxNapeSpace.velocityIterations = 5;
		FlxNapeSpace.positionIterations = 5;

		// map.loadMapFromCSV(AssetPaths.cityMap_WallsLayer__csv, AssetPaths.tilemap_packed__png, 16, 16, ) if you decide to go down the csv route

		map = new FlxOgmo3Loader(AssetPaths.cityTilemap__ogmo, AssetPaths.city1__json);
		walls = loadTilemap(AssetPaths.tilemap_packed__png, "walls");
		walls.follow(); // lock the camera to the wall map edges
		walls.setupCollideIndex();
		add(walls);

		player = new Player();
		map.loadEntities(placeEntities, "entities");
		add(player);

		super.create();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}

	function placeEntities(entity:EntityData) {
		if (entity.name == "player") {
			player.setPosition(entity.x, entity.y);
		}
	}

	function loadTilemap(tileGraphic:Dynamic, tileLayer:String = "tiles"):FlxNapeTilemap {
		var project:ProjectData = cast Json.parse(AssetPaths.cityTilemap__ogmo);
		var level:LevelData = cast Json.parse(AssetPaths.city1__json);

		var tilemap = new FlxNapeTilemap();
		var layer = getTileLayer(level, tileLayer);
		var tileset = getTilesetData(project, layer.tileset);

		switch (layer.arrayMode) {
			case 0:
				tilemap.loadMapFromArray(layer.data, layer.gridCellsX, layer.gridCellsY, tileGraphic, tileset.tileWidth, tileset.tileHeight);
			case 1:
				tilemap.loadMapFrom2DArray(layer.data2D, tileGraphic, tileset.tileWidth, tileset.tileHeight);
		}
		return tilemap;
	}

	/**
	 * Get Tile Layer data matching a given name
	 */
	static function getTileLayer(data:LevelData, name:String):TileLayer {
		for (layer in data.layers)
			if (layer.name == name)
				return cast layer;

		return null;
	}

	/**
	 * Get matching Tileset data from a given name
	 */
	static function getTilesetData(data:ProjectData, name:String):ProjectTilesetData {
		for (tileset in data.tilesets)
			if (tileset.label == name)
				return tileset;

		return null;
	}
}
