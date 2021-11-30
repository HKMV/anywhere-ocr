# 随处ocr(anywhere-ocr)

> 现已完成:
>
> 1. 框选进行ocr功能: `win+鼠标左键拖动(按住 win 然后按住鼠标左键拖动 框出识别范围 松开即可)`
> 2. 对识别结果进行翻译；使用 “Microsoft Edge” 作为内核（Win10以上电脑，基本已经自动升级，如果你的电脑上没有，安装一下即可）
> 3. 翻译引擎切换；现支持 “百度翻译” 和 “搜狗翻译”

## 鸣谢

感谢 百度开发的飞浆[PaddleOCR](https://github.com/PaddlePaddle/PaddleOCR)

感谢 [@telppa](https://github.com/telppa)提供[AHK的PaddleOCR工具类](https://github.com/telppa/PaddleOCR-AutoHotkey)

感谢 [@telppa](https://github.com/telppa) 提供 [翻译工具类](https://github.com/telppa/Translation-Terminator)

这里我对[翻译工具类](https://github.com/telppa/Translation-Terminator)进行优化了，使用现在大部分Win电脑已经自带的Edge浏览器作为内核 [Edge.ahk](https://github.com/HKMV/Edge.ahk)

## 常见问题解决

1. 识别精度不高：
   解决方案：由于github限制文件大于100m文件提交，所以高精度service模型就没上传，如有需要可自行去[PaddleOCR地址](https://github.com/PaddlePaddle/PaddleOCR/blob/release/2.3/README_ch.md)下载
2. 翻译时弹出提示 “当前页面脚本发生错误”：
   解决方案：控制面板 -> Internet选项 -> 安全 -> 本地Internet -> 站点，把所有勾选取消
3. 无法正常翻译
   解决方案：安装最新 [Microsoft Edge](https://www.microsoft.com/zh-cn/edge)
