### 1.5.7
- [改进] 改进增量储存支持：已支持数组下标上传；动态对象上传；数据差异比对上传。

### 1.5.4
- [修复] 修复使用字段压缩时，会让`zbmap`参数失效的问题：请在对应的继承类上，添加@:keep。

### 1.5.3
- [新增] 新增`V3Api.wechatWithdrawApplyApiVersion`提现APIVersion控制：
    提现APIVersion设置，默认为1003，如果使用了`mgc_graph_code`验签宏，则为1004

### 1.4.9
- [新增] 新增`V3Api.getInvitees`获取好友邀请列表。
- [弃用] 即将弃用`V3Api.getInvites`接口。
- [新增] 新增`V3Api.listRecord`获取提现数据列表。

### 1.4.8
- [改进] 改进`V3Api.getRankList`的获取排行榜的排名计算问题。

### 1.4.7
- [新增] 新增`<haxedef name="mgc_graph_code"/>`宏，用于开启验证码校验功能。

### 1.4.6
- [改进] 改进`V3Api.loginByOpenId`接口，减少可能造成卡死的问题。
- [改进] 改进`V3Api.getRankList`接口，data扩展参数会自动转换为`Dynamic`。
- [改进] 改进`V3Api.getRankList`接口，新增city参数，可定位到城市排行榜。
- [新增] 新增`V3Api.eventGlobal`全局统计接口。
- [新增] 新增`V3Api.getEventGlobal`获取全局统计的数据接口。

### 1.4.4
- [升级] 升级`getServerTime`接口为v3服务器接口。
- [升级] 升级`getCity`获取物理地址接口为v3服务器接口。
- [改进] 改进`V3Api.wechatWithdrawApply(提现key,微信appid,有点意思WID,回调)`用于支持有点意思多个WID传递，需要使用`Haxe4.2.x`版本。

### 1.4.1
- [新增] 当线上映射表不一致时，则进行全量更新。

### 1.4.0
- [新增] `@:build(zygame.macro.OnlineUserDataCompress.build())`新增用户在线数据压缩映射表功能。
    在线用户数据字段压缩：使用一份映射表进行压缩处理，与服务器沟通的时候，使用映射表进行解压和压缩；
    服务器需要存一份zip压缩的Base64映射表，当用户下载数据时，需要使用服务器的映射表进行解压。
    服务器的映射表仅在读取用户数据的时候同步一次，上传用户数据时，映射表不一致的时候才会重新上传。

### 1.3.6
- [新增] 新增纯JS编写的API接口，可用于COCOS使用。

### 1.3.5
- [兼容] 兼容`V3Api.wechatWithdrawApply()`有点意思提现接口支持，需要配置`<define name="ydysApplyWID" value="WID值，与对方运营获取"/>`。

### 1.3.3
- [修复] 修复签名排序不正确的问题。

### 1.3.0
- [兼容] 兼容HL请求数据处理。
- [兼容] 兼容YY存档独立。
- [兼容] HTML5平台新增https/http协议自动切换支持。
- [兼容] 兼容用户数据存档数组处理。

### 1.2.8
- [改进] 移除v2统计接口的支持。

### 1.2.1
- [改进] `V3Api.wechatWithdrawApply()`接口不允许超时，永远等待服务器响应。

### 1.2.0
- [新增] 新增curlEncode可使用Base64编码来显示curl。

### 1.1.7
- [改进] 增量存档支持Dynamic类型的增量识别。

### 1.1.6
- [新增] 新增API超时错误上报。
- [改进] 超时时间改为8秒超时。

### 1.1.5
- [新增] 新增`v3small`宏可开启v3存档API的增量存档支持。（Bate功能）
- [性能优化] OnlineUserData.async()接口不可频繁调用。

### 1.1.4
- [新增] 新增梦工厂验证API。

### 1.0.2
- [回退] 所有API接口回退到1000签名，仅提现API升级到1002接口。

### 1.0.6
- [增强] 对微信支付提现功能做了防抓包加密。
- [升级] api版本提升至1002。

### 1.0.1
- [新增] `API`新增`requestHeaders`对头信息传递支持。
- [新增] `API`新增`enbleAndroidnHeader`接口，用于收集wifi、插卡、root、Android版本、手机型号、xp框架以及USB调试等数据，仅按照有效。

### 1.0.0
- [分离] 初次由zygameui分离。