---
title: "Default open behaviour for Microsoft 365 Apps (Office) documents in Outlook"
date: 2023-12-16T17:26:12
lastmod: 2023-12-17T22:30:20
slug: "default-open-behaviour-for-microsoft-365-apps-office-documents-in-outlook"
categories: ["Microsoft Intune", "PowerShell"]
tags: ["Administrative Template", "Detection", "Office", "Outlook", "Remediation", "Script", "Settings Catalog"]
description: "Make Office documents linked in Outlook open in the desktop Microsoft 365 Apps instead of the browser, using Intune settings, a script or a remediation."
---

This post is about the default behaviour of opening Microsoft 365 Apps (Office) (e.g. Word, Excel, PowerPoint etc.) documents in your Outlook client. When you receive an e-mail similar as below with a link to a document, the default behaviour for opening that file when you click on the link is that it’s going to open in the default browser.

As we have installed the Microsoft 365 Apps on client devices it would be also nice if the documents will open in de “Desktop” version of the application.

At the moment of writing there isn’t a Configuration Profile (neither Settings catalog or Administrative Template) available for managing this setting.

![Screenshot: At the moment of writing there isn’t a Configuration Profile (neither Settings catalog or…](/wp-content/uploads/2023/12/image.png)

Within the settings of Outlook this can be done manually easy as following.

![Screenshot: Within the settings of Outlook this can be done manually easy as following](/wp-content/uploads/2023/12/image-1.png)

But if we want to manage this setting for all users/ devices, a better way to achieve this is via a Remediation in Microsoft Intune.

I’ve created a little detection and remediation script for this which can be downloaded from my [**GitHub**](https://github.com/jeroenebus/remediations/tree/main/DefaultOpenOptionSettings)!

To add the detection and remediation go to the Microsoft Intune portal and Create a new **Remediation**.

![Screenshot: To add the detection and remediation go to the Microsoft Intune portal and Create a new Remediation](/wp-content/uploads/2023/12/image-2.png)

Upload the detection and remediation script. Make sure that **“Run this script using the logged-on credentials”** is set to **“Yes”** (because it is a setting that is targeted to the user.

Also check if **“Run script in 64-bit PowerShell”** is set to “**Yes**“. But no worries, the script on my GitHub will cover that for you if you forget.

![Screenshot: But no worries, the script on my GitHub will cover that for you if you forget](/wp-content/uploads/2023/12/image-4.png)

Now target the Remediation to the group that you would like to receive this specific setting. Choose when and how often the Remediation should run and your all set.

I hope that you’re enjoyed this post and it helped you with setting up this specific Outlook setting.

Thanks for reading!

