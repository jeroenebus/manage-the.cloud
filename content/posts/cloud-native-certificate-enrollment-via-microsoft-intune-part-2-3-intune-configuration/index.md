---
title: "Cloud native certificate enrollment via Microsoft Intune (Part 2/3) – Intune Configuration"
date: 2023-07-13T20:42:28
lastmod: 2023-08-10T11:53:52
slug: "cloud-native-certificate-enrollment-via-microsoft-intune-part-2-3-intune-configuration"
wpid: 550
categories: ["Certificate Authority", "Certificates", "Microsoft Intune", "Public-Key Infrastructure", "SCEPman"]
tags: ["802.1X", "Certificates", "Configuration Profiles", "Microsoft Intune", "SCEP"]
description: "Part 2 of 3: configure Microsoft Intune to deploy trusted root and SCEP user or device certificates to Windows devices using SCEPman."
---

This is the second part of a (for now) 3-part blog series about how to enroll user/device certificates via Microsoft Intune. In this series I’m going to show you:

- [**How to you can easily set-up a cloud-based Certification Authority (part 1).**](/2023/07/04/cloud-native-certificate-enrollment-via-microsoft-intune-part-1-3/)

- **The deployment of user and/or device (SCEP) certificates to Windows devices (part 2).**

- [**How to securely authenticate to network resources with a certificate via Radius (part 3)**](/2023/08/09/cloud-native-certificate-enrollment-via-microsoft-intune-part-3-3-radiusaas/).

Last time I covered how to deploy the SCEPman Certificate Authority via Azure Marketplace. This time I’m going to show you how you can easily deploy SCEP user and/or device certificates via Microsoft Intune.

To get started you first download the CA Root Cert from the SCEPman portal. This Root Cert do we need to deploy to all our devices that are receiving certificates via SCEPman, only with the Root Cert installed it is possible to verify the authenticity of the certificates that are being deployed.

Now, let’s go to the SCEPman portal and download the CA Root Cert, you can retrieve the URL via the Azure portal, go to the App Services, select app-scepman-xxxxxxxxxxxxx and click on the “Default domain” URL.

![Screenshot: Now, let’s go to the SCEPman portal and download the CA Root Cert, you can retrieve the URL via the…](/wp-content/uploads/2023/07/image-19.png)

When you have downloaded the Root Cert the download will look something like:

![Screenshot: When you have downloaded the Root Cert the download will look something like](/wp-content/uploads/2023/07/image-20.png)

Now let’s go to the [**Intune**](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesWindowsMenu/~/windowsDevices) portal, select **Devices** followed by **Overview** and then **Windows**.

![Screenshot: Now let’s go to the Intune portal, select Devices followed by Overview and then Windows](/wp-content/uploads/2023/07/image-21.png)

Select **Configuration profiles** and select **Create profile**.

![Screenshot: Select Configuration profiles and select Create profile](/wp-content/uploads/2023/07/image-22.png)

On the next screen select **Windows 10 and later** followed by **Templates**.

Note: I always prefer to use the **Settings Catalog** but unfortunately this is not (yet) possible for Trusted certificates. 

![Screenshot: I always prefer to use the Settings Catalog but unfortunately this is not (yet) possible for…](/wp-content/uploads/2023/07/image-36.png)

![Screenshot: I always prefer to use the Settings Catalog but unfortunately this is not (yet) possible for… (image 2)](/wp-content/uploads/2023/07/image-23.png)

Select **Trusted certificate** and then **Create** in the template selection overview.

![Screenshot: Select Trusted certificate and then Create in the template selection overview](/wp-content/uploads/2023/07/image-24.png)

Give the template a proper name and description and click on **Next**.

![Screenshot: Give the template a proper name and description and click on Next](/wp-content/uploads/2023/07/image-25.png)

Upload the Root Cert that you have downloaded in an earlier stage, choose as the destination store **Computer certificate store – Root**. Now click **Next** to proceed.

![Screenshot: Now click Next to proceed](/wp-content/uploads/2023/07/image-26.png)

Add a group (of devices) that you want to deploy the Root Cert to and click **Next**. 

In the following screen choose **Next** in the **Applicability Rules** and **Create** in the **Review + create** section.

![Screenshot: In the following screen choose Next in the Applicability Rules and Create in the Review + create…](/wp-content/uploads/2023/07/image-28-1024x533.png)

When the newly created **Configuration Profile** arrives at the device, soon enough you will see the Root Cert being stored in the **Trusted Root Certification Authorities**!

![Screenshot: When the newly created Configuration Profile arrives at the device, soon enough you will see the…](/wp-content/uploads/2023/07/image-34.png)

Up next, we are going to create the SCEP configuration profile.

Go to the SCEPman portal (as described earlier) and copy **Intune MDM** URL.

![Screenshot: Go to the SCEPman portal (as described earlier) and copy Intune MDM URL](/wp-content/uploads/2023/07/image-29-1024x287.png)

Same as before, go to Devices, Windows, Configuration profiles and create a profile.

Select the platform and profile type and choose for the **SCEP certificate** template. Now click **Create**.

Note: I always prefer to use the **Settings Catalog** but unfortunately this is not (yet) possible for SCEP certificate.

![Screenshot: I always prefer to use the Settings Catalog but unfortunately this is not (yet) possible for SCEP…](/wp-content/uploads/2023/07/image-37.png)

![Screenshot: I always prefer to use the Settings Catalog but unfortunately this is not (yet) possible for SCEP… (image 2)](/wp-content/uploads/2023/07/image-30.png)

Again, fill in a proper name and description and click on **Next**.

![Screenshot: Again, fill in a proper name and description and click on Next](/wp-content/uploads/2023/07/image-31.png)

Now the fun part is going to start, we’re actually going to create the Configuration Profile that is going to deploy the SCEP certificate. Fill in the fields as in the image below.

SCEPman uses the CN field of the subject to identify the device and as a seed for the certificate serial number generation. Azure AD and Intune offer two different IDs:

- {{DeviceId}}: This ID is generated and used by Intune **(Recommended)**

(requires SCEPman 2.0 or higher and `AppConfig:IntuneValidation:DeviceDirectory` to be set to **Intune** or **AADAndIntune**)

- {{AAD_Device_ID}}: This ID is generated and used by Azure AD.

In the **Key usage**, activate both cryptographic actions:

`Digital signature` and `Key encipherment`

![Screenshot: Digital signature and Key encipherment](/wp-content/uploads/2023/07/image-32.png)

Now select the Root Cert that you have uploaded as **Trusted certificate** and paste the **Intune MDM** URL from the SCEPman portal

![Screenshot: Now select the Root Cert that you have uploaded as Trusted certificate and paste the Intune MDM URL…](/wp-content/uploads/2023/07/image-33.png)

When the configuration profile arrives on the device, soon enough you will see the SCEP certificate being installed in the **Personal** certificate store of the device.

![Screenshot: When the configuration profile arrives on the device, soon enough you will see the SCEP certificate…](/wp-content/uploads/2023/07/image-35.png)

When the certificate is deployed this will be visible in the SCEPman portal. All the deployed certificates are visible under **Intune Certificates**.

![Screenshot: All the deployed certificates are visible under Intune Certificates](/wp-content/uploads/2023/07/image-38-1024x304.png)

In Microsoft Intune, the issued certificates are also visible, go to **Configuration** and select **Certificates**.

![Screenshot: In Microsoft Intune, the issued certificates are also visible, go to Configuration and select…](/wp-content/uploads/2023/07/image-39.png)

All the issued certificates are visible, the device certificates and also the user certificates.

![Screenshot: All the issued certificates are visible, the device certificates and also the user certificates](/wp-content/uploads/2023/07/image-40-1024x235.png)

Of course, it is also possible to create user certificates or specific certificates for email signing with SCEPman and Microsoft Intune Configuration Profiles. Please let me know if you are interested in this and maybe I can also create a guide for this.

Thanks for reading, I hope that you enjoyed reading and maybe learned something from this part.

And again, stay tuned for the next part. Were I’m going to show how to authenticate against network gear with the SCEP certificate.

