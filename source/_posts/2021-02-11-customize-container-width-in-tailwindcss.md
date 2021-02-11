---
title: 如何自定义TailwindCSS的容器宽度
date: 2021-02-11 16:52:14
tags:
 - tailwindcss
 - css
---
如何自定义TailwindCSS的container宽度。

<!-- more -->

打开项目下的`tailwind.config.js`文件，编辑`plugins: []`，参考：
```
  plugins: [
    function ({ addComponents }) {
      addComponents({
        '.container': {
          maxWidth: '370px', //tailwind是mobile优先，所以首先定义缺省宽度为mobile端的宽度
          '@screen sm': {
            maxWidth: '640px', //其他屏幕大小的情况根据需求定义
          },
          '@screen md': {
            maxWidth: '700px',
          },
          '@screen lg': {
            maxWidth: '1126px',
          },
          '@screen xl': {
            maxWidth: '1126px',
          },
        }
      })
    }
  ],
```