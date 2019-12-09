---
title: hive中的数组、键值型和字符串的长度的坑
date: 2019-12-06 11:01:52
tags:
- hive
- 大数据
- mysql
- nosql
- hadoop
- size
- length
- 数组个数
- 数组长度
---
最近有个案例，需要数一张表里面每列有多少个值。

<!-- more -->

最近业务有个需求，需要计算一张大宽表中每一行的每一列中有多少个值，其实就是计算值的长度。因为有的列是字符串型，有的是数组型，有的是键值型，在值为空时的表现各不相同。

# 1. 准备数据

假设我们有下面的一张表，其中：
 - 第一行为每一列有多个值的情况
 - 第二行为每一列有单个值的情况
 - 第三行为每一列为**空值**的情况（**不是**null）
 - 第四行为每一列为**空**的情况（为null）

```sql
select *
from tmp.ym_test
```


**结果**

| array                     | key_value                         | string          |
|---------------------------|-----------------------------------|-----------------|
| ["item1","item2","item3"] | {"key1":"value1","key2":"value2"} | a sample string |
| ["item1"]                 | {"key1":"value1"}                 | string         |
| []                      | {}                                |             |
| null                      | null                              | null            |


# 2. 计算长度
```sql
select size(array), size(key_value), length(string)
from tmp.ym_test
```

**结果**

| array | key_value | string |
|-------|-----------|--------|
| 3     |  2        | 15     |
| 1     | 1         |  6     |
|  0    | 0         |  0     |
|  -1   |  -1       | null   |


# 3. 结论
根据以上结果，结论其实很明显了：
 - **第一行为每一列有多个值的情况：** 
    - array或map的长度，即元素个数；
    - string的字母个数，空格也算。
 - **第二行为每一列有单个值的情况：** 
    - array或map的长度，即元素个数；
    - string的字母个数，空格也算。
 - **第三行为每一列为*空值*的情况（*不是*null）：**
    - 皆为0；
 - **第四行为每一列为*空*的情况（为null）：**
    - array或map的长度为-1；
    - string则仍然是null。

# 4. 坑
为什么说是坑呢，因为结论的第三条和第四条，在计算中array和map是null和空值其实都是一样的视为0，如果我要求每条数据的长度和，那如果遇到为null的array和map就会变少，因为-1了；同理，如果是用length计算string长度其实也没有特别大的意义，因为string不为空那就肯定就是有值的，即为1，所以为了达到业务需求，还需要改一下query：

```sql
select 
if(size(array) == -1, 0, size(array)), 
if(size(key_value) == -1, 0, size(key_value)), 
if(length(string) is null, 0, 1)
from tmp.ym_test
```

**结果**

| array | key_value | string |
|-------|-----------|--------|
| 3     |  2        | 1      |
| 1     | 1         | 1      |
|  0    | 0         |  0     |
| 0     | 0         |  0     |

这样再去求和就能得出正确的元素长度了。