---
title: HOW TO USE PYTHON TO RELEASE YOURSELF FROM WORKLOADS
date: 2020-02-23 22:13:18
tags:
 - python
---
I need to repeat some simple but time-consuming tasks at my work recently, so i wrote a python script to release my workloads.
<!-- more -->

## // 1. STARTER
Recently I need to submit hundreds to tasks on the internal system of my company, this job is not complicated, but I need to spend around 2 mins time on each task submitting process, and that means a whole afternoon will be consumed by doing this job, not to say doing this job manually might cause mistakes easily. So I need to release myself from this massive workload, let python do the job for me.

## // 2. TASK DESCRIPTION
The system is based on web gui, I need to add tasks on it. Those tasks would download all the files from directories that named after date from an internal sftp server. Therefore, for each task I would need to fill up a form on the web gui which contains following info:
 - task title
 - task description
 - sftp info, such as sftp address, port, type, username, and password
 - path to those files
After added tasks, I need to start each of them every two mins. The reason of doing so is that our engineer told me our back-end system would crash if I start them all at once.

So I need to achieve those functions on my python script:
 - Type in task list ID and my account token from the web gui system;
 - Type in task name and path in loop, and add tasks by the script;
 - After all the tasks were added, start a task every two mins.

## // 3. OBSERVATION
Open the network monitor in the browser and try to add a task, following actions were observed:
1. When the task list page was opened, it sent an GET request to an URL, the last param from the URL is the ID of the task list. After that, an JSON returned, which includes task list info and info of all the tasks under the list;
2. After fill up the form and clicked the submit button, it sent an PUT requests to the same URL from above. The request body contains an JSON.

After putting those two JSONs in the JSON comparison tool, the JSON was sent in the step 2 is actually an simplified version the JSON from step 1, it trimed some elements. But it also added an new object element to the JSON, this object contains infos we filled on the web gui form.

Then try start an task:
1. Once clicked "Start Task" button, it sent an POST request to an URL, one of the params on the URL contains ID of the task.

Verification wise, our engineer told me all I need to do is to include the token in the reuqest header.

## // 4. BUILDING IT UP

### A. PLAN
The most often used libaray for handling internet requests in the Requests, since I need to deal with JSON, so import this as well.
Construct the framework of the script:
```python
import requests
import json

if __name__ == "__main__":
    # main code goes here
```