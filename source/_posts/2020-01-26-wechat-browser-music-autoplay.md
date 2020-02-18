---
title: 微信浏览器h5页面音乐自动播放（2020.02可用）
date: 2020-01-26 11:01:52
tags:
- 微信
- Wechat
- audio
- 浏览器
- javascipt
- 自动播放

---
默认在Chromium内核或者Firefox中其实都已经禁止了音乐的自动播放，但是在微信浏览器中实际上可以实现音乐的自动播放。

<!-- more -->

在做一些基于微信浏览器的h5页面的过程中，客户会希望进入即播放音乐，在搜集资料后找到了一种实际可用的方法。
需要看Demo的可以直接看最后一个标题。

# 1. 传统方法的不可行性

 - **a. ``autoplay``属性**
HTML 5的 ``<audio>`` tag中实际上是有一个叫做 ``autoplay`` 的属性的，但是在大多数的现代浏览器中这个属性形同虚设，由于安全性的原因现代浏览器并不允许音频的自动播放，毕竟广告网页中会滥用这个属性导致体验非常不好。

 - **b. ``.play()`` 方法**
同样的，使用 ``<audio>`` tag的``.play()``方法也是一样无效，原因同上。

# 2. 方法

 - **先``append`` 一个 ``<audio>`` tag**
在document的DOM结构加载完成之后（当然你也可以用jQ的document.ready），append一个 ``<audio>`` tag上去，并指定源：

```javascript
//我这里用的是DOMContentLoaded的事件，有浏览器兼容性要求，但是此处不考虑
        document.addEventListener("DOMContentLoaded", function(e){ 
//创建一个<audio> tag，并指定属性
            var audioNode = document.createElement("audio");
            audioNode.setAttribute("src","./auto.mp3");
            audioNode.setAttribute("id","player");
            audioNode.controls = true;
            audioNode.setAttribute("preload","auto");
//append到body上
            document.body.appendChild(audioNode);
        })
```

 - **再利用微信sdk触发播放**
 在微信浏览器中打开的网页可以加载微信的js sdk，就是一般用来做微信登陆、分享等等功能的，在sdk ready时的callback可以用来触发``<audio>`` tag的 ``.play()``方法，从而自动播放音乐。

```javascript
//先引用下微信js sdk
<script src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
<script>
function autoPlayAudio() {
    wx.config({
// 配置信息, 即使不正确也能使用 wx.ready
        debug: false,
        appId: '',
        timestamp: 1,
        nonceStr: '',
        signature: '',
        jsApiList: []
    });
    wx.ready(function () {
        var globalAudio = document.getElementById("player");
        globalAudio.play();
    });
};
</script>
```

# 3. 音乐加载状态

在很多时候都会在用户进入首页前做一个加载页，``<audio>`` tag有``.oncanplay``和``.onloadstart``这两个事件用来监听音频加载进程：
```javascript
var globalAudio = document.getElementById("player");
var statusP = document.getElementById("status");
globalAudio.onloadstart = function(){
    console.log("开始加载")
    statusP.innerHTML = "正在加载";
    globalAudio.oncanplay = function(){
        statusP.innerHTML = "加载完成";
        autoPlayAudio();
    }
}
```

# 4. 完整代码
完整代码见 https://shiguang.us/demo_wx_autoplay/ 托管在github上加载可能有点慢。
{% asset_img demo.png %}