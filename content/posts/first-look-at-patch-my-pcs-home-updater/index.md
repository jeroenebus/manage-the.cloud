---
title: "First look at Patch my PC’s Home Updater!"
date: 2024-10-27T12:22:05
lastmod: 2024-10-27T12:27:56
slug: "first-look-at-patch-my-pcs-home-updater"
wpid: 859
categories: ["Home Updater", "Patch my PC"]
tags: ["Patching", "Software Deployment", "Software Updates"]
description: "A first look at Patch My PC Home Updater, the free tool that keeps home computers up to date: silent install options and the installation wizard."
---

I recently saw a post on LinkedIn from Patch my PC’s Founder/CEO [Justin Chalfant](https://www.linkedin.com/in/justin-chalfant/) about the release of a improved version of their home users solution. Immediately I send him a DM to get an opportunity to assess the application early.

Patch my PC Home Updater is a free solution for home users to keep their home computers up-to-date and secure. Everyone works incredibly hard to keep computers in their business environment up-to-date and secure, but often forget about the vulnerable home computers.

Patch my PC got you covered and released a brand new version of their Home Updater software. This free application is designed to keep your home computers secure and up-to-date on a easy way.

The best of all, like I said, it’s free and you can download it from [here](https://homeupdater.patchmypc.com/public/PatchMyPC-HomeUpdater.msi)!

Well of course the first thing I tried is to check which possibilities there are for application deployment, maybe some of you home users have a fully automated deployment solution in place for your home computers. 😀

But yes, the application is downloadable as a msi, and works with regular parameters, for example, silent install, no reboot, create an installation log:

![Screenshot: But yes, the application is downloadable as a msi, and works with regular parameters, for example,…](/wp-content/uploads/2024/10/image-1024x144.png)

*msiexec.exe /i “C:\TEMP\PatchMyPC-HomeUpdater-EarlyAccess.msi” /qn /norestart /L*V “C:\TEMP\home_updater.log”*

But hey, it is a solution for home users, so let’s test the regular install wizard just as normal computer users would do. You get the possibility to install the application on a different location, decide to launch the application after installation or not.

![Screenshot: You get the possibility to install the application on a different location, decide to launch the…](/wp-content/uploads/2024/10/image-1.png)

It is immediately starting with installing prerequisites and the application itself.

![Screenshot: It is immediately starting with installing prerequisites and the application itself](/wp-content/uploads/2024/10/image-2.png)

After the installation succeeds the application launches, off course just as chosen in the installation wizard.

![Screenshot: After the installation succeeds the application launches, off course just as chosen in the…](/wp-content/uploads/2024/10/image-3-1024x508.png)

Time to check the version and evaluate the self update mechanism. And guess what, there is a new release already!

![Screenshot: And guess what, there is a new release already!](/wp-content/uploads/2024/10/image-4-1024x507.png)

Installing the new release directly to test out the latest version.

![Screenshot: Installing the new release directly to test out the latest version](/wp-content/uploads/2024/10/image-5.png)

After the installation, the windows disappears, there is no message displayed about the update being successful. But a quick look at the installed applications tells me that the version is successful updated!

![Screenshot: But a quick look at the installed applications tells me that the version is successful updated!](/wp-content/uploads/2024/10/image-6-1024x125.png)

So, let’s dive into the application catalog!

Let’s search for the almighty application for application deployment testing: Notepad++.  When I search for it and click on “Install” it downloads and installs (silent) in just a blink of an eye.

![Screenshot: When I search for it and click on “Install” it downloads and installs (silent) in just a blink of…](/wp-content/uploads/2024/10/image-7-1024x508.png)

Now let’s test if the Home Updater can take control over the updating mechanism of an app that isn’t installed via Patch my PC’s Home Updater. As an example I installed Visual Studio Code from the Microsoft website. When you hit the “Re-scan” button the application is directly found by Home Updater.

You also get a few nice features per application, also for the apps that are installed via the catalog off course.

- Disable Scanning

- Disable Silent Installation

- Disable Auto Updating

- Reinstall App

- Uninstall App

![Screenshot: Uninstall App](/wp-content/uploads/2024/10/image-8-1024x508.png)

## Conclusion

Patch my PC is perfect solution for home users to install their favorite free application on a safe and controlled way. 

- Application are being kept up-to-date.

- Long list of default applications (512 and counting).

- Easy overview of all installed applications.

- Uninstaller for other applications on your computer, so no need for using Windows Add/Remove Programs.

- Advanced features to for example opt-out the automatic updating for a specific application.

- Create a task scheduler to check for new software updates just when it suits you.

- Patch my PC Home Updater will keep itself up-to-date.

So, impressive job Patch my PC team, keep up the good work to keep everybody’s home computer up-to-date and safe! Making IT admins life easier step by step, I supposed they will get lesser questions from family and friends to help them out updating their computers! 😉

