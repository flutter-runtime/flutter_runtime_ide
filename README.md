## 备注

采用 get_cli 进行开发，因为自己开发研究无所谓了。
工作时间硬挤出来一小时进行开发，开发进度无法保证。

目前所有的代码都只在 macOS运行
测试机器

- 2019年 Macbook Pro
- macOS 13.3
- flutter 3.3.10

## 下一步计划

- [x] 新增配置页面可以自定义修复生成的运行库
- [ ] 修改生成分析配置可以支持分析缓存调用提升分析效率
- [ ] 生成运行是中心库可以通过这个库动态调用

## 更新日志

### 2023 年  7  月  6  日

- [change] 修改生成运行时库不存在版本号为依赖库本地路径的md5 值，防止存在多个 flutter 版本的情况

### 2023 年 7  月  5  号

- 支持通过自定义配置将生成的运行库代码进行修复

### 2023 年 6 月 29 号
- 支持将依赖的库生成为动态运行库

### 2023年 6 月 25  号
- 对于依赖库常量/全局方法/类/扩展/mixin运行时的生成

### 2023年5月19号
- 新增 打开 Flutter 项目自动分析 项目依赖库列表

### 2023年5月18日
- 新增了欢迎页面 可以选择存在的 Flutter 工程
