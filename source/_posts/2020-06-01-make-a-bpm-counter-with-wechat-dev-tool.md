---
title: BPM计数器小程序开发日志
date: 2020-06-01 23:22:18
tags:
---
用微信开发者工具制作一个bpm计数器的小程序日志。
<!-- more -->

# 20/06/01
之前听说小程序可以用react开发（刚好当作学习react），后来发现好像不能原生支持，需要在微信开发者工具上使用他们的语法（框架？）开发小程序，看了几篇文章，好像有点像vue+react的融合体。那就试试看吧。
在[官网](https://developers.weixin.qq.com/miniprogram/dev/devtools/download.html)下载微信开发者工具，打开之后有个示例，看了下代码还算比较好理解。

## # A SIMILAR STRUCTURE
这个项目目录格式真的十分熟悉了，可能大部分框架的格式都是这样吧，

{% asset_img 2020-06-01-23-55-59.png %}

很明显就是一个```app.js```是一个入口，```app.wxss```是项目的样式文件，虽然看起来是一个微信自己定义的样式格式```.wxss```，但是看了下就是css好像，```pages```目录下即使子页面的页面定义，那我直接去修改```index```目录下面的文件吧。

## # FRONT FIRST
先改一下门脸吧，毕竟我是视觉动物。
看了下html代码，有点像是xml，十分奇怪，但是好在容易理解，我希望整个页面只有一个文字区域用于显示欢迎消息和当前bpm，那就很简单了，稍加改造即可使用。

{% asset_img 2020-06-01-23-58-47.png %}

再来改一下CSS，搜索了下得知```page```即是定义页面样式的，有点像CSS中的```html, body {}```，那就先弄个黑色背景吧，然后用一个```view```框一个```text```，完事儿。

{% asset_img 2020-06-02-00-04-43.png %}

## # ANOTHER STATE?
打开```index.js```核心代码区域，```data```就像是react里面的```state```，同时使用```setData```函数来变更```data```的值。那么稍加改造即可使用：

{% asset_img 2020-06-01-23-44-54.png %}

其中：

{% codeblock %}
lastTs: 上次点击的时间戳；
tsDiff: 这次点击之后和上次点击的时间戳的时间差；
text:   显示文字
{% endcodeblock %}

这样就大概实现了想要的样子了：

{% asset_img 2020-06-02-21-55-58.png %}

## # VUE STYLE EVENT BINDING?
接下来需要在整个页面绑定触摸事件，这样的话只要点击页面任意一处即可开始计数，并显示BPM。
搜索了下得知触摸事件是```bindtap```，那就加上，绑定触摸事件到一个函数```tapHandler```上，console.log看下是否能用：

{% asset_img 2020-06-02-21-59-27.png %}

妥了。

## # MAKE IT WORK
接下来就是核心部分了，我打算用两个函数来实现：
1. ```counter```函数：用来计算bpm的函数，每次计算完成返回一个变更后的```data```；分三种情况：
a. 第一次点击：获取此时时间戳，更新到```data.lastTs```；
b. 第二次点击：获取此时时间戳，并求与```data.lastTs```的时间差，更新到```data.tsDiff```和```data.text```作为此时的bpm，然后将此时获取到的时间戳更新到```data.lastTs```；
c. 之后的点击：获取此时时间戳，并求与```data.lastTs```的时间差，更新到```data.tsDiff```，同时求此时的时间差和```data.tsDiff```的平均值作为bpm，更新到```data.text```中；

2. ```tapHandler```函数：点击之后调用的函数，不做bpm的计算，仅用来接受```counter```返回的结果并更新到```data```中。

先把所有的功能塞到```tapHandler```里面试试看效果：

{% codeblock lang:javascript %}
tapHandler: function() {
    let currTs = Date.now()
    let prevTs = this.data.lastTs
    let prevGap = this.data.tsDiff
    if(prevTs !== 0 && prevGap !== 0){
      //正常点击
      console.log(this.data)
      let currGap = currTs - prevTs
      let thisbpm = 60000 / currGap
      let avgbpm = (thisbpm + (60000 /prevGap)) / 2
      this.setData({
        lastTs: currTs,
        tsDiff: currGap,
        text: avgbpm
      })
    }else if(prevTs == 0 && prevGap == 0){
      //第一次点击
      console.log("第一次点击")
      console.log(this.data)
      this.setData({
        lastTs: currTs,
        text: 'Again'
      })
    }else if(prevTs !== 0 && prevGap == 0){
      //第二次点击
      console.log("第二次点击")
      console.log(this.data)
      this.setData({
        lastTs: currTs,
        tsDiff: currTs - prevTs,
        text: 60000 / (currTs - prevTs)
      })
    }
  }
{% endcodeblock %}

试了下可以用，接下来把代码完善下，完成他们各自的使命：

{% codeblock lang:javascript %}
//index.js
//获取应用实例
const app = getApp()

Page({
  data: {
    text: 'Tap anywhere to start counting',
    lastTs:0,
    tsDiff:0
  },
  counter: function(){
    let newData = {}
    let currTs = Date.now()
    let prevTs = this.data.lastTs
    let prevGap = this.data.tsDiff
    if(prevTs !== 0 && prevGap !== 0){
      //正常点击
      console.log(this.data)
      let currGap = currTs - prevTs
      let thisbpm = 60000 / currGap
      let avgbpm = (thisbpm + (60000 /prevGap)) / 2
      let newData = {
        lastTs: currTs,
        tsDiff: currGap,
        text: avgbpm
      }
      return newData
    }else if(prevTs == 0 && prevGap == 0){
      //第一次点击
      console.log("第一次点击")
      console.log(this.data)
      let newData = {
        lastTs: currTs,
        text: 'Again'
      }
      return newData
    }else if(prevTs !== 0 && prevGap == 0){
      //第二次点击
      console.log("第二次点击")
      console.log(this.data)
      let newData = {
        lastTs: currTs,
        tsDiff: currTs - prevTs,
        text: 60000 / (currTs - prevTs)
      }
      return newData
    }
  },
   //事件处理函数
  tapHandler: function() {
    const newData = this.counter()
    this.setData(newData)
  },
})
{% endcodeblock %}

今天结束。