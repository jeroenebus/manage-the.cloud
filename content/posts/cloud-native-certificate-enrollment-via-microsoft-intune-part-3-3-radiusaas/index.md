---
title: "Cloud native certificate enrollment via Microsoft Intune (Part 3/3) – RADIUSaaS"
date: 2023-08-09T21:46:14
lastmod: 2023-08-10T11:55:57
slug: "cloud-native-certificate-enrollment-via-microsoft-intune-part-3-3-radiusaas"
categories: ["Certificate Authority", "Certificates", "Microsoft Intune", "Public-Key Infrastructure", "RADIUSaaS", "SCEPman"]
tags: ["802.1X", "CA", "Certificates", "Microsoft Intune", "PKI", "RADIUSaaS", "SCEP", "Ubiquiti", "Unifi"]
description: "Part 3 of 3: securely authenticate to Wi-Fi and network resources with certificates by setting up RADIUSaaS with Intune-issued certificates."
---

This is the third and last part of a (for now) 3-part blog series about how to enroll user/device certificates via Microsoft Intune. In this series I’m going to show you:

- [**How to you can easily set-up a cloud-based Certification Authority (part 1).**](/2023/07/04/cloud-native-certificate-enrollment-via-microsoft-intune-part-1-3/)

- **[The deployment of user and/or device (SCEP) certificates to Windows devices (part 2).](/2023/07/13/cloud-native-certificate-enrollment-via-microsoft-intune-part-2-3-intune-configuration/)**

- **How to securely authenticate to network resources with a certificate via Radius (part 3).**

First, again let’s start with a few clarifications. To start is what is network access control? And why do you want to use it? NAC, also known as network admission control, enables an organization to restrict unauthorized or non-compliant devices and users from accessing the corporate network.

To authenticate on a secure way to the corporate network a commonly used method is through RADIUS. When connecting to network resources via RADIUS the Authentication is based on certificates.

Because this 3-part series is all about cloud native certificate enrollment the next step is to authenticate with the certificate that we deployed in the previous parts to a cloud-native RADIUS solution. If you want to go fully cloud native, you could consider using [**RADIUSaaS (RADIUS-as-a-Service)**](https://www.radius-as-a-service.com/).

Otherwise, if you already have network gear in house that support RADIUS you also can use Cisco ISE, Aruba ClearPass or a Microsoft Network Policy Server (NPS).

So, let’s start with configuring RADIUSaaS then!

If you activated your RADIUSaaS instance you receive a personal link to manage your RADIUSaaS environment, go to the RADIUSaaS Admin Portal and log in.

![Screenshot: If you activated your RADIUSaaS instance you receive a personal link to manage your RADIUSaaS…](/wp-content/uploads/2023/07/image-41.png)

When first logging in the RADIUSaaS portal ask to give the portal access to your Azure AD environment. You have to consent this on behalf of your organization.

![Screenshot: You have to consent this on behalf of your organization](/wp-content/uploads/2023/07/image-44.png)

When consenting the permissions your now able to log in to the admin portal with your organization’s credentials.

![Screenshot: When consenting the permissions your now able to log in to the admin portal with your…](/wp-content/uploads/2023/07/image-43.png)

In a brand new RADIUSaaS environment there is no proxy available, only a RadSec instance.

What is RadSec? RadSec is a feature supported by some RADIUS servers. Because RadSec forms an encrypted TLS tunnel between the client and server, it’s even more secure than your standard RADIUS. It can be used by any organization using RADIUS servers but is commonly used in situations where employees are expected to roam between networks, such as businesses with multiple locations. 

Source: [**https://www.securew2.com/blog/what-is-radsec** ](https://www.securew2.com/blog/what-is-radsec)

![Screenshot: It can be used by any organization using RADIUS servers but is commonly used in situations where…](/wp-content/uploads/2023/07/image-50.png)

For now, we are not going to use RadSec because the network gear I’m using for the lab environment is not supporting this at the moment ([**Unifi Ubiquiti**](https://community.ui.com/questions/Is-RADSec-on-the-roadmap/39b373e7-b244-4d12-95ea-4cabc92450d3)). This means we need to set up a RADIUS proxy.

First of all, let’s talk about the performance of a RADIUS proxy, regarding the official [**docs**](https://docs.radiusaas.com/portal/settings/settings-proxy):[](#performance)

Each proxy can handle up to **1,500** **concurrent** connections flawlessly.

This corresponds to a time-based performance of **10,000 authentications per minute per proxy**.

So, for my lab environment setting up 1 proxy does the job for me. If you have to possibility to configure a primary and a secondary proxy on your network gear, you should definitely do this. Thereby, the second public IP address should be located in a different geo-region than the primary address.

Go to **Settings** followed by **Proxy Settings** and select **+ Add**.

![Screenshot: Go to Settings followed by Proxy Settings and select + Add](/wp-content/uploads/2023/07/image-45.png)

Select **region** where you want to create the proxy in (primary and secondary in different regions) and select **Create**.

![Screenshot: Select region where you want to create the proxy in (primary and secondary in different regions)…](/wp-content/uploads/2023/07/image-46.png)

The proxy is now installing..

![Screenshot: The proxy is now installing](/wp-content/uploads/2023/07/image-47.png)

This takes a while, let’s grab a coffee 🙂

![Screenshot: This takes a while, let’s grab a coffee 🙂](/wp-content/uploads/2023/07/image-48.png)

Definitely worth grabbing a coffee because it took about 10 minutes.

![Screenshot: Definitely worth grabbing a coffee because it took about 10 minutes](/wp-content/uploads/2023/07/image-49.png)

If we you now the **Server Settings** the proxy is available.

![Screenshot: If we you now the Server Settings the proxy is available](/wp-content/uploads/2023/07/image-52.png)

Next step, downloading the server certificate that is needed to deploy as a trusted certificate to the devices that are connecting through RADIUS. This is also possible with a certificate created with SCEPman, please let me now if you want to see a follow up regarding this method.).

For now, click on the **Download** icon behind the **Server Certificate**.

![Screenshot: For now, click on the Download icon behind the Server Certificate](/wp-content/uploads/2023/07/image-53-1024x714.png)

Download the server certificate.

![Screenshot: Download the server certificate](/wp-content/uploads/2023/07/image-54.png)

The next step is to configure the SCEPman instance in the **Trusted Roots for client authentication**.

Go to **Settings** followed by **Authentication Certificates** and click on **+ Add**.

![Screenshot: Go to Settings followed by Authentication Certificates and click on + Add](/wp-content/uploads/2023/07/image-55-1024x841.png)

Copy the URL of your SCEPman instance from the **SCEPman Server Node** and click on **Save.**

![Screenshot: Copy the URL of your SCEPman instance from the SCEPman Server Node and click on Save](/wp-content/uploads/2023/07/image-56-1024x461.png)

The URL will be validated and look like underneath.

![Screenshot: The URL will be validated and look like underneath](/wp-content/uploads/2023/07/image-57-1024x453.png)

Next, we are going to configure the network gear. In my lab environment this is a Unifi Dream Router.

Go to the Unifi OS admin portal and log in.

![Screenshot: Go to the Unifi OS admin portal and log in](/wp-content/uploads/2023/07/image-58-1024x704.png)

In the side menu select **Applications** and choose **Network**.

![Screenshot: In the side menu select Applications and choose Network](/wp-content/uploads/2023/07/image-59-955x1024.png)

Click on the gear icon to go to the settings.

![Screenshot: Click on the gear icon to go to the settings](/wp-content/uploads/2023/07/image-60.png)

Select **Profiles**, to go to the part where the RADIUS servers can be configured.

![Screenshot: Select Profiles, to go to the part where the RADIUS servers can be configured](/wp-content/uploads/2023/07/image-61.png)

Select the **RADIUS** button to configure the RADIUS servers.

![Screenshot: Select the RADIUS button to configure the RADIUS servers](/wp-content/uploads/2023/07/image-63-1024x498.png)

Fill in the details from the Server Settings page in the RADIUSaaS admin portal (server ip address, port numbers and shared secret).

![Screenshot: Fill in the details from the Server Settings page in the RADIUSaaS admin portal (server ip address,…](/wp-content/uploads/2023/07/image-64-1024x925.png)

Now we have come to the last part, we are going to deploy the root certificate and Wi-Fi profile to the devices that you want to connect with a certificate to the designated Wi-Fi network.

Now let’s go to the [**Intune**](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesWindowsMenu/~/windowsDevices) portal, select **Devices** followed by **Overview** and then **Windows**.

![Screenshot: Now let’s go to the Intune portal, select Devices followed by Overview and then Windows](/wp-content/uploads/2023/07/image-65.png)

Select **Configuration profiles** and select **Create profile**.

![Screenshot: Select Configuration profiles and select Create profile](/wp-content/uploads/2023/07/image-66.png)

On the next screen select **Windows 10 and later** followed by **Templates**.

Note: I always prefer to use the **Settings Catalog** but unfortunately this is not (yet) possible for Trusted certificates.

![Screenshot: I always prefer to use the Settings Catalog but unfortunately this is not (yet) possible for…](/wp-content/uploads/2023/07/image-36.png)

![Screenshot: I always prefer to use the Settings Catalog but unfortunately this is not (yet) possible for… (image 2)](/wp-content/uploads/2023/07/image-23.png)

Select **Trusted certificate** and then **Create** in the template selection overview.

![Screenshot: Select Trusted certificate and then Create in the template selection overview](/wp-content/uploads/2023/07/image-24.png)

Give the profile a proper name and description and click on **Next**.

![Screenshot: Give the profile a proper name and description and click on Next](/wp-content/uploads/2023/07/image-67-1024x708.png)

Upload the Root Cert that you have downloaded in an earlier stage, choose as the destination store **Computer certificate store – Root**. Now click **Next** to proceed.

![Screenshot: Now click Next to proceed](/wp-content/uploads/2023/07/image-68-1024x637.png)

Add a group (of devices) that you want to deploy the Root Cert to and click **Next**.

In the following screen choose **Next** in the **Applicability Rules** and **Create** in the **Review + create** section.

![Screenshot: In the following screen choose Next in the Applicability Rules and Create in the Review +…](/wp-content/uploads/2023/07/image-69-1024x533.png)

When the newly created **Configuration Profile** arrives at the device, soon enough you will see the Root Certificate being stored in the **Trusted Root Certification Authorities**!

![Screenshot: When the newly created Configuration Profile arrives at the device, soon enough you will see the…](/wp-content/uploads/2023/07/image-70-1024x752.png)

Up next, we are going to create the Wi-Fi configuration profile.

Same as before, go to Devices, Windows, Configuration profiles and create a profile.

Select the platform and profile type and choose for the **Wi-Fi** template. Now click **Create**.

Note: I always prefer to use the **Settings Catalog** but unfortunately this is not (yet) possible for the Wi-Fi connection.

![Screenshot: I always prefer to use the Settings Catalog but unfortunately this is not (yet) possible for the…](/wp-content/uploads/2023/07/image-73.png)

![Screenshot: I always prefer to use the Settings Catalog but unfortunately this is not (yet) possible for the… (image 2)](/wp-content/uploads/2023/07/image-75.png)

Select **Wi-Fi** and then **Create** in the template selection overview.

![Screenshot: Select Wi-Fi and then Create in the template selection overview](/wp-content/uploads/2023/07/image-76.png)

Give the profile a proper name and description and click on **Next**.

![Screenshot: Give the profile a proper name and description and click on Next](/wp-content/uploads/2023/07/image-77-1024x641.png)

Fill in the details like on the screenshots below.

See **[Windows – RADIUSaaS](https://docs.radiusaas.com/azure/microsoft-intune/wifi-profile/windows)** for more detailed information about the configuration of the Wi-Fi profile.

![Screenshot: See Windows – RADIUSaaS for more detailed information about the configuration of the Wi-Fi profile](/wp-content/uploads/2023/07/image-78-1014x1024.png)

![Screenshot: See Windows – RADIUSaaS for more detailed information about the configuration of the Wi-Fi profile (image 2)](/wp-content/uploads/2023/07/image-79-1024x396.png)

Now click **Next** to proceed.

![Screenshot: Now click Next to proceed](/wp-content/uploads/2023/07/image-81-976x1024.png)

Add a group (of devices) that you want to deploy the Root Cert to and click **Next**.

In the following screen choose **Next** in the **Applicability Rules** and **Create** in the **Review + create** section.

When the newly created **Configuration Profile** arrives at the device, soon enough your device will automatically connect to the SSID if it is broadcasting already!

What about monitoring? How do we see which devices are authenticating against the RADIUSaaS instance?

Well, let’s go to the RADIUSaaS admin portal again and select **Rule Engine**.

![Screenshot: Well, let’s go to the RADIUSaaS admin portal again and select Rule Engine](/wp-content/uploads/2023/07/image-82.png)

When devices are connecting successfully the rules would look some like below. The column **Engine-Decision** will report **Accept** for devices that are successfully authenticated.

![Screenshot: The column Engine-Decision will report Accept for devices that are successfully authenticated](/wp-content/uploads/2023/07/image-83-1024x287.png)

Thanks for reading the third and for now last past of the journey for Cloud Native certificate enrollment.

What we have done/ achieved so far:

- Set-up SCEPman as a Cloud Native Certificate Authority.

- Connected the Certificate Authority to Microsoft Entra ID (Azure AD) and Microsoft Intune.

- Created Configuration Profiles to: 
 - Deploy a root certificate to devices. - Deploy SCEP device/ user certificates to devices. 

- Set-up RADIUSaaS as Cloud Radius provider.

- Connected RADIUSaaS to network gear (Ubiquiti Unifi).

- Created Configuration Profiles to: 
 - Deploy a Radius root certificate. - Deployed a Wi-Fi configuration profile. 

- Successfully connected a device to the network gear with a Cloud issued certificate.

If you want to see me writing some more stuff about certificate enrollment or other related things, feel free to reach out to me!

