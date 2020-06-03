---
title: 使用ffmpeg拼接合并(concat)不同分辨率、编码、采样宽高比(SAR)、码率、格式、容器的视频
date: 2019-08-15 11:46:18
tags:
- ffmpeg
- 转码
- 硬件加速
- hevc
- h265
- 码率
- 软压
- 硬压
---
在使用ffmpeg进行h.265硬压（显卡加速）转码下的不同参数对画质的影响。
<!-- more -->
好像多媒体方面的文章浏览量高一点，那我多写一点吧。

# 1. 引言

很多文章都会介绍使用concat参数去合并相同编码的视频，这里就不多说了，[官方文档](https://trac.ffmpeg.org/wiki/Concatenate)已经说的很清楚了。

但是其实官方文档同时说的很清楚的还有对于不同编码的视频合并并不能直接用concat协议，但是搜了下好像文章不是很多。那就写一点人生的经验吧。

# 2. 概念

根据经验来看，其实影响多个视频拼接的因素，无外乎：

 - 分辨率是否一致
 - 编码是否一致
 - SAR是否一致

假设我们有三个完全不同的文件
最简单的concat用法，假设有一个```files.txt```的文本文件记录了需要拼接的视频顺序：
```
file '1.mp4'
file '2.mov'
```
然后用
```
ffmpeg -f concat -i file.txt -c copy output.mp4
```
此时导出的文件，要不然第二段是黑屏的，要不然第二段是速度不正常的，反正就是不正常。

# 3. 不同分辨率的情况

假设有两个文件：
```
1.mp4
Input #0, mov,mp4,m4a,3gp,3g2,mj2, from '1.mp4':
  Metadata:
    major_brand     : isom
    minor_version   : 512
    compatible_brands: isomiso2avc1mp41
    encoder         : Lavf58.30.100
  Duration: 00:00:09.76, start: 0.000000, bitrate: 2717 kb/s
    Stream #0:0(und): Video: h264 (High) (avc1 / 0x31637661), yuv420p, 1280x720 [SAR 1:1 DAR 16:9], 2582 kb/s, 25 fps, 25 tbr, 12800 tbn, 50 tbc (default)
    Metadata:
      handler_name    : VideoHandler
    Stream #0:1(und): Audio: aac (LC) (mp4a / 0x6134706D), 44100 Hz, stereo, fltp, 127 kb/s (default)
    Metadata:
      handler_name    : SoundHandler
```
```
2.mp4
Input #0, mov,mp4,m4a,3gp,3g2,mj2, from '2.mp4':
  Metadata:
    major_brand     : isom
    minor_version   : 512
    compatible_brands: isomiso2avc1mp41
    encoder         : Lavf58.30.100
  Duration: 00:00:08.36, start: 0.000000, bitrate: 1904 kb/s
    Stream #0:0(und): Video: h264 (High) (avc1 / 0x31637661), yuv420p, 640x640 [SAR 1:1 DAR 1:1], 1769 kb/s, 25 fps, 25 tbr, 12800 tbn, 50 tbc (default)
    Metadata:
      handler_name    : VideoHandler
    Stream #0:1(und): Audio: mp3 (mp4a / 0x6134706D), 44100 Hz, stereo, fltp, 127 kb/s (default)
    Metadata:
      handler_name    : SoundHandler
```
可以看到主要差别是在分辨率上，1.mp4的分辨率是```1280x720 [SAR 1:1 DAR 16:9]```，2.mp4的分辨率是```640x640 [SAR 1:1 DAR 1:1]```
然后创建一个用于描述拼接的文件```files.txt```：
```
file '1.mp4'
file '2.mp4'
```
如果直接使用：
```
ffmpeg -f concat -i files.txt -c copy output.mp4
```