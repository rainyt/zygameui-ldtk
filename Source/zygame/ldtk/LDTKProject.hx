package zygame.ldtk;

import openfl.geom.Rectangle;
import zygame.utils.Lib;
import zygame.display.batch.BImage;
import zygame.utils.ZAssets;
import zygame.display.batch.ImageBatchs;
import zygame.utils.StringUtils;
import zygame.components.ZBox;
import haxe.Json;

class LDTKProject {
	/**
	 * 世界瓦片的宽度
	 */
	public var worldGridWidth:Int = 0;

	/**
	 * 世界瓦片的高度
	 */
	public var worldGridHeight:Int = 0;

	/**
	 * 默认的瓦片尺寸
	 */
	public var defaultGridSize:Int = 0;

	/**
	 * 背景颜色
	 */
	public var bgColor:Int = 0;

	/**
	 * 默认关卡颜色
	 */
	public var defaultLevelBgColor:Int = 0;

	/**
	 * 地图的所有第一关系
	 */
	public var defs:LDTKDefs = null;

	/**
	 * 关卡数据
	 */
	public var levels:Array<LDTKLevel> = [];

	/**
	 * 资源引用
	 */
	public var assets:ZAssets;

	/**
	 * 瓦片路径绑定UID
	 */
	public var tilesetPathByUid:Map<Int, String>;

	public function new(data:String) {
		var ldtkData = Json.parse(data);
		zygame.macro.JsonSet.setData(this, ldtkData);
		tilesetPathByUid = [];
		for (index => value in this.defs.tilesets) {
			tilesetPathByUid.set(value.uid, StringUtils.getName(value.relPath));
		}
	}

	/**
	 * 创建当前项目里的世界内容
	 * @return LDTKWorld
	 */
	public function createLDTKWorld():LDTKWorld {
		var world = new LDTKWorld();
		world.tileSize = defaultGridSize;
		for (level in levels) {
			var map = createLDTKMap(level.identifier);
			world.addMap(map);
		}
		return world;
	}

	/**
	 * 创建LDTK地图
	 * @param levelid 
	 */
	public function createLDTKMap(levelid:String):LDTKMap {
		var level = getLDTKLevel(levelid);
		var box = new LDTKMap(level.pxWid, level.pxHei, level.layerInstances[0].__gridSize);
		box.x = level.worldX;
		box.y = level.worldY;
		box.offestWorldX = Std.int(level.worldX / level.layerInstances[0].__gridSize);
		box.offestWorldY = Std.int(level.worldY / level.layerInstances[0].__gridSize);
		// 开始渲染
		var len = level.layerInstances.length;
		while (len > 0) {
			len--;
			var value = level.layerInstances[len];
			// var fixFloat = value.__gridSize * 0.002;
			var fixFloat = 0;
			switch (value.__type) {
				case "Entities":
					// 事件渲染
					var layer = new ZBox();
					layer.name = value.__identifier;
					box.addChild(layer);
					for (index => value in value.entityInstances) {
						var entity = new LDTKEntity(this, value);
						layer.addChild(entity);
						entity.x = value.px[0];
						entity.y = value.px[1];
					}
				case "IntGrid", "AutoLayer":
					var tilesetId = StringUtils.getName(value.__tilesetRelPath);
					var batch = new ImageBatchs(assets.getTextureAtlas(tilesetId), -1, -1, false);
					batch.name = value.__identifier;
					batch.width = level.pxWid;
					batch.height = level.pxHei;
					for (tile in value.autoLayerTiles) {
						var bimg = new BImage(assets.getBitmapData(tilesetId + ":" + tile.src[0] + "x" + tile.src[1]));
						batch.addChild(bimg);
						bimg.x = tile.px[0] - fixFloat * 2;
						bimg.y = tile.px[1] - fixFloat * 2;
						bimg.width += fixFloat * 4;
						bimg.height += fixFloat * 4;
						switch (tile.f) {
							case 1:
								bimg.scaleX = -1;
								bimg.x += bimg.width;
							case 2:
								bimg.scaleY = -1;
								bimg.y += bimg.height;
							case 3:
								bimg.scaleX = -1;
								bimg.scaleY = -1;
								bimg.x += bimg.width;
								bimg.y += bimg.height;
						}
					}
					box.addChild(batch);
					batch.alpha = value.__opacity;
					if (value.__type == "IntGrid")
						box.bindIntGridCsv(value.intGridCsv);
			}
		}
		return box;
	}

	/**
	 * 根据关卡ID获取关卡数据
	 * @param levelid 
	 * @return LDTKLevel
	 */
	public function getLDTKLevel(levelid:String):LDTKLevel {
		for (index => value in levels) {
			if (value.identifier == levelid) {
				return value;
			}
		}
		return null;
	}
}

class LDTKMap extends ZBox {
	public var offestWorldX:Int = 0;

	public var offestWorldY:Int = 0;

	public var tileWidth:Int = 0;

	public var tileHeight:Int = 0;

	public var tileSize:Int = 0;

	private var _mapInt:Array<Array<LDTKHitData>> = [];

	public function new(tileW:Int, tileH:Int, tileSize:Int) {
		super();
		this.tileSize = tileSize;
		this.tileWidth = Std.int(tileW / this.tileSize);
		this.tileHeight = Std.int(tileH / this.tileSize);
	}

	/**
	 * 绑定地图块数据
	 */
	public function bindIntGridCsv(data:Array<Int>):Void {
		var ix = 0;
		var iy = 0;
		trace(this.tileWidth, data.length);
		for (i in 0...data.length) {
			if (_mapInt[ix] == null)
				_mapInt[ix] = [];
			_mapInt[ix][iy] = {gid: data[i]};
			ix++;
			if (ix >= this.tileWidth) {
				ix = 0;
				iy++;
			}
		}
	}

	private function __hitGrid(x:Int, y:Int, array:Array<Int>):Void {
		if (x < 0 || y < 0 || x >= _mapInt.length)
			return;
		var value = _mapInt[x][y];
		if (value != null && value.gid != 0) {
			var data:LDTKHitData = value;
			if (array.indexOf(data.gid) == -1)
				array.push(data.gid);
		}
	}

	/**
	 * 碰撞逻辑
	 * @param rect
	 */
	public function hitGrid(rect:Dynamic):Array<Int> {
		var array:Array<Int> = [];
		var left = (rect.x - (rect.w - 2) * 0.5);
		var top = (rect.y - (rect.h - 2));
		var right = (rect.x + (rect.w - 2) * 0.5);
		var bottom = (rect.y);
		var xIndex = Std.int(left / tileSize);
		var yIndex = Std.int(top / tileSize);
		var xIndex2 = Std.int(right / tileSize);
		var yIndex2 = Std.int(bottom / tileSize);
		__hitGrid(xIndex, yIndex, array);
		__hitGrid(xIndex2, yIndex, array);
		__hitGrid(xIndex2, yIndex2, array);
		__hitGrid(xIndex, yIndex2, array);
		return array;
	}

	public function getGrid(cx:Int, cy:Int):Int {
		if (_mapInt[cx] == null)
			return 0;
		if (_mapInt[cx][cy] == null)
			return 0;
		return _mapInt[cx][cy].gid;
	}
}

typedef Rect = {
	x:Float,
	y:Float,
	w:Float,
	h:Float
}

typedef LDTKHitData = {
	gid:Int
}

/**
 * 关卡数据
 */
typedef LDTKLevel = {
	pxWid:Int,
	pxHei:Int,
	worldX:Int,
	worldY:Int,
	identifier:String,
	layerInstances:Array<{
		__gridSize:Int,
		__type:String,
		__identifier:String,
		__tilesetRelPath:String,
		__opacity:Float,
		autoLayerTiles:Array<{
			px:Array<Int>,
			src:Array<Int>,
			f:Int,
			t:Int,
			d:Array<Int>
		}>,
		intGridCsv:Array<Int>,
		entityInstances:Array<LDTKEventEntity>
	}>
};

/**
 * LDTK的事件实例
 */
typedef LDTKEventEntity = {
	__identifier:String,
	__grid:Array<Int>,
	__pivot:Array<Float>,
	__tile:{
		tilesetUid:Int, srcRect:Array<Int>
	},
	width:Int,
	height:Int,
	defUid:Int,
	px:Array<Int>,
	fieldInstances:Array<{
		__identifier:String,
		__value:String,
		__type:String,
		defUid:Int,
		realEditorValues:Array<Dynamic>
	}>
}

/**
 * LDTK的定义描述
 */
typedef LDTKDefs = {
	layers:Array<Dynamic>,
	entities:Array<Dynamic>,
	tilesets:Array<{
		relPath:String,
		pxWid:Int,
		pxHei:Int,
		tileGridSize:Int,
		spacing:Int,
		padding:Int,
		uid:Int
	}>,
	enums:Array<Dynamic>,
	externalEnums:Array<Dynamic>,
	levelFields:Array<Dynamic>
}
