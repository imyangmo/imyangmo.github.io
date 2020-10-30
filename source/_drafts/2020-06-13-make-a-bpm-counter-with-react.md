---
title: BPM计数器开发日志(React重制)
date: 2020-06-13 15:48:57
tags:
---
使用react继续开发上文的bpm计数器。
<!-- more -->

# 20/06/13
真的是深坑，上文说到想开发一个(BPM计数器的微信小程序)[http://prelude.cc/make-a-bpm-counter-with-wechat-dev-tool.html]，结果发现个人开发者已经注册不了小程序了。那算了还是用react做吧。

## BEGIN WITH A SCAFFOLDING
用```create-react-app```来创建一个项目。

{% codeblock lang:shell %}
npx create-react-app bpmcounter
{% endcodeblock %}

删掉不需要的内容，最后如下。