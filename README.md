## LDtk
LDTk的Github：https://github.com/deepnight/ldtk
关卡设计器工具包（LDtk）是一种现代，高效且开源的2D关卡编辑器，其重点是用户友好性。

## 使用
现在可以在zygameui中使用LDtk了：
```xml
<haxelib name="zygameui-ldtk"/>
```

## 缩放比例
需要固定缩放比例为0.5跳转，这样可以避免出现tilemap的缝隙问题：
```haxe
class Main extends Start {
	private var assets:ZAssets = new ZAssets();
	public function new() {
		super(640, 1000, false, true);
    }
}
```
注意地图的缩放不要出现不可被0.5整除的缩放比例。

## 简单的使用例子：
```haxe
var ldtkid = "WorldMap_GridVania_layout";
// 加载LDTK地图
assets.loadFile("assets/samples/" + ldtkid + ".ldtk");
assets.start(function(f) {
    if (f == 1) {
        // 获取LDTK项目数据
        var project = assets.getLDTKProject(ldtkid);
        // 开始创建地图
        var map = project.createLDTKMap("Hidden_cave");
        // 添加地图
        this.addChild(map);
        map.scale(1.5);

    }
});
```