# reMouseable App

## Links
- [Project Page](https://daniel.stoiber.network/project/remouseable-app)
- [Kevin Conway](https://github.com/kevinconway) (Original remouseable creator)
- [Original remouseable Project](https://github.com/kevinconway/remouseable)

## What is it?

I recently bought a [reMarkable](https://remarkable.com/) tablet, and I was curious to see what else it could do. I came across a few different pages showing off various ways to hack your reMarkable. One in particular caught my eye. It was a [project by Kevin Conway](https://github.com/kevinconway/remouseable) that turned your reMarkable into a drawing tablet by controlling your computer's mouse. The project worked great, but as a developer I execute a lot of terminal commands, and it was really annoying to try and find the start command. I also noticed that using it might be a little difficult for those who have never touched the Mac terminal. So I solved that issue. My approach is far from perfect, but for the fact that I have never built anything for MacOS I'm taking the victory that it works.

## Usage

Simply download the App from the releases tab in GitHub, unzip it, then run it. If you want to see what it looks like before downloading, you can see some screenshots of [the project page on my website](https://daniel.stoiber.network/project/remouseable-app). 

When you start the app for the first time you can either press `Manage Devices -> Add Device` or just press `Connect`. Both will bring you to the device setup screen where you can give your reMarkable a name and enter its IP address and password. The IP and password can be found on the reMarkable if you go to `Menu -> Settings -> Help -> Copyrights and licenses` and looking at the bottom of the page. 

#### Getting your IP Address
If you connect through a USB cable, your IP address should be `10.11.99.1`. If you are connecting through WiFi, your IP address should be the second to last set of numbers. Example: `192.168.1.24`. 

#### Getting your Password
The password is also found at the bottom of that page, it will be in single quotes. Example: __'ks0hG2B2x3'__

### MacOS Permissions

From [Kevin Conway](https://github.com/kevinconway/remouseable):

> If you are using this on an Apple or OSX device then you will need to give the
terminal or shell you are using permissions to control your mouse. Mouse
permissions are treated as an accessibility feature. If you are not prompted by
the operating system to update your permissions the first time you run the
application then you can navigate to
`System Preferences -> Security & Privacy -> Privacy -> Accessibility`. You will
see your terminal or shell in the list of applications that have requested
accessibility permissions.

Additional Permissions:

When you open the application it will ask you if you want to give permissions to access *Finder*, this is used to set up and store the credentials to connect to your reMarkable tablet. When you try to connect it will ask you to give permissions to control *Terminal*, this is used to actually connect to your reMarkable. Both of these are required, and the app will not work without allowing them.

## Thanks

Huge thanks to [Kevin Conway](https://github.com/kevinconway) for making the underlying software that makes this project possible! Don't forget to check out [his repository](https://github.com/kevinconway/remouseable) for more details about the remouseable project.

## Bugs / Future Features

Much like Kevin's project *"the current state of this project fulfills all of my needs so I'm not planning
on adding anything new for myself."* I do know that there are plenty of better approaches to make something like this, but for what it needs to do, it's more than good enough. That being said, feel free to submit an issue if you come across a bug, or even better, make a pull request with a fix. 


## Feature Requests
If you want to see some new functionality, feel free to submit a pull request. I will review and merge working ones, but I don't really have the time to fix any new broken code. If you want to test any code you have written just download the project and open the app in Apple's `Script Editor`. Unfortunately there are not too many great resources on making MacOS apps with JavaScript. However, in Script Editor you can press `Shift + Cmd + l` to open up the documentation for everything I use. Just don't forget to set the language to `JavaScript`.