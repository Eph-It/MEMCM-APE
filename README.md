# MEMCM-APE

## Introduction

This project is open sourcing a process that has been in use over a decade to add a peer review system to MEMCM. Effectively, when this system goes into place, no one will be able to directly deploy Applications, Packages, or Task Sequences, or edit any objects related to a deployment without first going through peer review.

## How does it work?

This system works through status messages to detect whenever there is an edit to an object and it then delays the corresponding deployment 10 years. It will then call a webhook to send the deployment information off-box and into whatever approval system you use. The code contained in this repository is *only* the "delay" code and the code to reset the deployment. Because each environment is different and process are so different, the approval system is left up to the implementer. **Note** I will be writing an example blog series on creating an approval system with Flow and PowerApps. So if you don't have one already, you can implement one with this.

## Setup

1) Download the release and then place the files wherever you want them to live on your Primary (or CAS if you have one). If you have HA set up, it will need to be set in the same place on both Primaries or both CAS servers.
2) Edit APE-Settings.json with the values of your CM environment. 
   1) Make sure the account that will be resetting the deployments is listed in the ExcludedUsers array in the form of ```DOMAIN\\USERNAME```.
   2) Also in my testing and creation I used a Logic Apps webhook to start this, but any webhook or URL to a custom WebAPI will work for the StartWebhook field. This is called at the end to notify your approval system a new deployment is ready for review. 
   3) Leave "ReadOnly" to "true" until you test this out a few times. ReadOnly will run every step except "Delay Deployment 10 years" so you can run it in ready only mode to verify your approval system is hooked up right and everything else is operational.
3) To create the status message triggers auto-magically, run InstallScripts\SetupStatusMessageTriggers.ps1. This will use the values in the settings json to find your CM environment and create all your status message triggers. If you later need to move the files, just move them and re-run this script and it will update the triggers to the new location.
4) Upload the runbook APE-ResetDeployment to AzureAutomation (or wherever your automation stuff is) and make it run at the end of your approval process.

Now it's all set! That seemed like a lot, but really you just need to copy the files somewhere, add your environment's settings to APESettings.json, and then run the install script. After that, it's all ready to start delaying deployments and sending them to your approval system.

## What is coming?

I've thought of a few additional features I'd like to add to this.

1) Blog posts! I'll write some blog posts showing more in-depth how to set this up and create an approval system.
1) Log entries to a SQLLite / MSSQL DB so we have better record keeping of what was delayed (in case the webhook fails it can re-notify then)
2) Log the properties of the objects modified and then finally approved so we can have a revision history of all objects and add the ability to only stop a deployment if a "high risk" setting is edited.

File issues for any additional features you want added. 

Also file issues for any problems you encounter!