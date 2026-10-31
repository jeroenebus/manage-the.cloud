---
title: "Windows Autopilot not showing keyboard selection during OOBE"
date: 2023-06-14T16:34:05
lastmod: 2023-06-20T22:43:36
slug: "windows-autopilot-not-showing-keyboard-selection-during-oobe"
wpid: 361
categories: ["Autopilot", "ESP", "Microsoft Intune", "OOBE"]
tags: ["Country", "Deployment Profile", "ESP", "Keyboard", "Language", "OOBE", "Region", "Windows Autopilot"]
description: "Windows Autopilot skips the keyboard layout page during OOBE after choosing the region? A workaround I found for user-driven enrollments."
---

A while ago I encountered something strange during a user-driven Windows Autopilot enrollment. I didn’t quite find a reason for this behavior, but I did find a workaround to fix it.

The situation was as following: during the Windows Autopilot enrollment the user can select the country or region that is preferred. Normally after choosing the setting, you would expect the keyboard selection page as following. 

![Screenshot: Normally after choosing the setting, you would expect the keyboard selection page as following](/wp-content/uploads/2023/06/image-19-1024x768.png)

To my surprise I saw that after the region selection the page skipped directly to the “Let’s set things up for your work or school” screen. 

So, the keyboard selection is being skipped? What now? I started another enrollment, and again, the keyboard selection screen again is being skipped  

![Screenshot: I started another enrollment, and again, the keyboard selection screen again is being skipped](/wp-content/uploads/2023/06/image-20-1024x768.png)

So, let’s jump into the deployment profile of we can find any setting that could cause that. Well, at first sight, no keyboard selection available? The language is configured as “User select”. You would assume that this would mean if the user can select the language/region, they would also have the possibility to select a keyboard setting they like. Unfortunately, this wasn’t the case.  

![Screenshot: Unfortunately, this wasn’t the case](/wp-content/uploads/2023/06/image-21-1024x1016.png)

Now, what if I try to select a default language or when selecting “Operating system default”?  Now the keyboard selection automagically appears! 

Next change the “Automatically configure keyboard” to “No” and switch the language back to “User select”. 

![Screenshot: Next change the “Automatically configure keyboard” to “No” and switch the language back to “User…](/wp-content/uploads/2023/06/image-22-986x1024.png)

Save the deployment profile and start the Autopilot enrollment again.

![Screenshot: Save the deployment profile and start the Autopilot enrollment again](/wp-content/uploads/2023/06/image-23-1024x768.png)

And voila the keyboard selection can be made again!

![Screenshot: And voila the keyboard selection can be made again!](/wp-content/uploads/2023/06/image-24-1024x768.png)

Hopefully, these steps helped you when encountering the issue when there is no keyboard selection visible during the ESP.

Thanks for reading!

