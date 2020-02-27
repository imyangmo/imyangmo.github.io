---
title: 「初学者向」使用Python处理重复工作，解放工作量【上】
date: 2020-02-23 22:13:18
tags:
 - python
 - 重复劳动
 - 脚本
 - 工作
 - requests
---
最近需要在工作中重复劳动一些耗时且细碎的工作，写了个脚本解放工作时间，记录下整个流程。
<!-- more -->

## // 1. 起因
最近需要在公司内部系统上重复提交几百个任务，这项工作其实并不复杂，问题在于每执行一次操作需要耗时2分钟，几百个任务就是一下午的时间就没了，而且还容易出错，需要把这部分工作量解放出来，让python替我完成。

## // 2. 任务概述
我司内部系统是基于web的，我现在需要在gui上操作去添加任务，这个任务是从一个内部ftp上的，以日期命名的目录中取该目录下的所有文件，那么我在web gui上就需要填写：
 - 任务标题
 - 任务描述
 - ftp信息（地址，端口，类型，账号，密码）
 - 路径
添加完成任务之后，我需要每2分钟启动一个任务，因为如果一次性开启所有任务，后端可能会崩。

所以我需要实现的功能如下：
 - 在进入程序后输入列表ID和token，可以自动获取所需要的json；
 - 之后循环输入任务名称和ftp路径，即可自动添加任务；
 - 所有任务添加完成之后，每2分钟自动启动一个任务。

## // 3. 观察
浏览器中打开控制台的网络监控，然后尝试添加一个任务，会看到以下行为：
1. 打开添加任务页，会先看到向某个url发送了get请求，url的最后一个参数是该任务列表的列表ID，得到一个json，该json包含该任务列表的信息和列表下所有任务的信息；
2. 填写完成信息之后点击“提交”，看到向上述url发送了个put请求，请求体是个json。

把上述的两个json放到json compare工具中看下，发现第2步中put过去的json，就是第1步的json的缩略版，但是包含了个新的object，这个object中的内容就是填写的任务标题、ID等等信息。

然后启动个任务看看：
1. 点击“开始任务”，发现向某个url发送了post请求，url中参数包含该任务ID。

验证方式上，咨询我司工程师之后得知，只需要在请求头中包含token即可。
那流程和内容就很清晰了，接下来用代码实现就行了。

## // 4. 实现过程 - 任务批量添加器
由于是把所有任务添加完成之后再一个个启动任务，所以脚本分两个写。
本篇先写任务添加脚本。

### A. 规划
处理网络请求那肯定就是用requests库没跑了，而且需要处理json，那也先把Json库引入进来。先把程序结构写出来：
```python
import requests
import json

if __name__ == "__main__":
    # 主体结构在这里
```

先规划一下流程和函数：
 1. 进入程序之后先手动输入token和列表ID，因为这两个东西是在get列表的时候需要的内容，一次输入运行时可用，后续不用重复输入；
 2. 用上面的信息去get列表，如果成功的话：
 3. 删除json中不必要的信息；
 4. 手动输入任务名称和ftp路径；
 5. 把3和4的内容传给任务添加函数；
 6. 重复3 4 5。


### B. 列表获取函数
然后来实现第1步，先get任务列表，写一个函数：
```python
def listgetter(auth, requrl):
    headers = {"Content-Type":"application/json","Authorization":auth}
    # 实例url为：https://example.com/api/data_sources/task_list_id
    r = requests.get(requrl, headers=headers)
    return r.text
```
这个函数有三个作用：
 1. 会接收两个参数，这两个参数需要用户（也就是我）在进入程序之后手动输入，一个是token，一个是请求地址，但是由于请求地址变化的只是最后一个url中的参数，所以其实只需要手动输入这个参数就行，然后在主流程中拼接一个url出来，作为参数给到这个函数；
 2. 然后用requests带headers请求一个get，具体文档可以看[ 这里 ](https://2.python-requests.org/en/v2.0-0/)；
 3. 把get的结果返回出来。

### C. json处理函数
获取到json之后，也就是收到listgetter()函数的返回结果之后， 要对结果进行裁切，那再写一个函数进行json裁切：
```python
def tailor(content):
        gd = json.loads(content)
        del gd['created_at']
        del gd['user_id']
        del gd['group']
        del gd['group_id']
        del gd['logo']
        del gd['name']
        del gd['updated_at']
        del gd['desc']
        return gd
```
这个函数有四个作用：
 1. 接受get到的json，此时为一个字符串；
 2. 用json.loads方法将json字符串解析为dict；
 3. 删除不需要的对象；
 4. 返回删除后的dict。

### D. 任务json生成函数
获取到处理过后的json dict之后，就需要在指定的对象中假如我们需要提交的任务的信息，这样添加完的最终结果就是需要在最后一步put的json。
裁剪过后的json大概是这样：
```json
{
"elementA":"elementa",
"elementB":"elementb",
"tasks":{
"task1ID":{
"id": "任务ID", 
"desc": "", 
"host": "ip地址", 
"port": "1024", 
"status": "", 
"password": "密码", 
"taskname": "任务名", 
"username": "登陆用户名", 
"createdAt": "日期", 
"updatedAt": "日期", 
"remotepath": "ftp路径", 
"compressionmode": "targz"}
}
}
```
其中tasks中的每一个object即是一个任务，所以就需要在tasks中添加object，之后put完整的json即可添加一个任务。
那么函数如下：
```python
def idgen():
    rdm = ''.join(random.sample(string.ascii_uppercase + string.digits, 24))
    return "AA" + rdm

def taskadder(content, taskname):   # 1
    newid = idgen()                 # 2
    created_at = time.strftime("%Y-%m-%dT%H:%M:%S.000Z", time.localtime())
    remote_path = "/path/to/" + taskname + "/*.tar.gz"
    
    newtask = {'id': newid, 'desc': '', 'host': 'ip地址', 'port': '1024', 'status': '', 'password': '密码', 'taskname': taskname, 'username': '登陆用户名', 'createdAt': created_at, 'updatedAt': created_at, 'remotepath': [remote_path], 'compressionmode': 'targz'} # 3

    content['tasks'][newid] = newtask #4
    return content #5
```
解释：
 1. 这个函数接收两个参数，```content```是C中返回的裁剪过的json，```taskname```这里偷了个懒，因为除了任务名之外我还需要手动输入ftp路径中的变量部分，就是ftp路径中的日期部分（因为每天会有一个以当日日期命名的目录），那我干脆就把taskname和日期部分输入成一样的，那就可以少输入一次了；
 2. 上面的json中的“任务ID”，在咨询工程师之后告知其实是生成的随机字符串，所以就写个函数用来生成字符串。为了和其他任务区分，使用AA开头表示是我使用脚本生成的任务；
 3. 这一串就是实际新增任务，等会需要加到json里面的object；
 4. 往这个dict里面插入这个新任务；
 5. 返回这个dict。

 ## E. 任务提交函数
 最后一个函数就是提交了：
 ```python
 def taskputter(content, auth, requrl):
    headers = {"Content-Type":"application/json","Authorization":"token"}
    # 实例url为：https://example.com/api/data_sources/task_list_id
    p = requests.put(requrl,headers=headers, data=json.dumps(content) )
    return p
```
这个个B大同小异，就是多了个content，这个content就是D处理完成之后返回的那个dict。

## F. 主流程
函数都写好了之后把主流程写到主体结构中：
```python
if __name__ == "__main__":
    token  = input("token?")         #用户输入token
    url = input("request url?")  #用户输入请求地址

    for i in range(0,1000):         #因为要让下面的部分循环，所以就循环1000次
        tname = input("task name / path?") #输入任务名，其实也是路径
        g = listgetter(token, url)
        t = tailor(g)
        a = taskadder(t, tname)
        r = taskputter(a, token, url)
```

完成。