JsOsaDAS1.001.00bplist00бVscript_/г
// App written by Daniel Stoiber
// Original reMouseable executable written by Kevin Conway (https://github.com/kevinconway/remouseable)
// GitHub: https://github.com/da-stoi/remouseable-app
// Website: https://daniel.stoiber.network
// Project Page: https://daniel.stoiber.network/project/remouseable-app

const app = Application.currentApplication()
app.includeStandardAdditions = true

const Finder = Application("Finder")
const TextEdit = Application("TextEdit")
const Terminal = Application("Terminal")

// Get computer user for Application Support path
const user = app.pathTo("home folder").toString().split("/")[2]
const appSupport = Finder.startupDisk.folders.byName("Users").folders.byName(user).folders.byName("Library").folders.byName("Application Support")

// Read config.json file
function readFile(file) {
  // Convert the file to a string
  var fileString = file.toString()

  // Read the file and return its contents
  return app.read(Path(fileString))
}

// Write to config.json file
function writeTextToFile(text, file, overwriteExistingContent) {
  try {

    // Convert the file to a string
    var fileString = file.toString()

    // Open the file for writing
    var openedFile = app.openForAccess(Path(fileString), { writePermission: true })

    // Clear the file if content should be overwritten
    if (overwriteExistingContent) {
      app.setEof(openedFile, { to: 0 })
    }

    // Write the new content to the file
    app.write(text, { to: openedFile, startingAt: app.getEof(openedFile) })

    // Close the file
    app.closeAccess(openedFile)

    // Return a boolean indicating that writing was successful
    return true
  }
  catch (error) {

    try {
      // Close the file
      app.closeAccess(file)
    }
    catch (error) {
      // Report the error is closing failed
      console.log(`Couldn't close file: ${error}`)
    }

    // Return a boolean indicating that writing was successful
    return false
  }
}

// Add reMouseable file in Application Support to store reMouseable config and executable
function makeAppFile() {

  try {
    Finder.make({ new: "folder", at: appSupport, withProperties: { name: "reMouseable" } })
    return true
  } catch {
    app.displayDialog("Error setting up reMouseable, app file already exists.", {
      buttons: ["Quit", "Try Again"],
      defaultButton: "Try Again",
      withIcon: "caution"
    })

    return false
  }

}

function checkForUpdate(version) {

  // Get latest release data from GitHub API
  const releases = JSON.parse(app.doShellScript("curl https://api.github.com/repos/kevinconway/remouseable/releases"))
  const latestVersion = releases[0].tag_name
  let latestDownload

  // Get mac os download link
  releases[0].assets.forEach((asset) => {
    if (asset.name === "osx") {
      latestDownload = asset.browser_download_url
    }
  })

  if (latestDownload && (!version || version !== latestVersion)) {
    return { name: releases[0].name, version: latestVersion, download: latestDownload }
  }

  return false
}

function addDevice() {
  const config = JSON.parse(readFile(`/Users/${user}/Library/Application Support/reMouseable/config.json`))
  const devices = config.devices

  // Prompt for custom reMarkable name
  const deviceNamePrompt = app.displayDialog("Give your reMarkable a name", {
    defaultAnswer: "",
    buttons: ["Continue"],
    defaultButton: "Continue"
  })

  // Prompt for reMarkable type
  const deviceTypePrompt = app.displayDialog("What model reMarkable are you trying to connect?", {
    buttons: ["reMarkable 1", "reMarkable 2"],
    defaultButton: "reMarkable 2"
  })

  // Prompt for IP Address
  const ipPrompt = app.displayDialog("reMarkable IP Address", {
    defaultAnswer: "",
    buttons: ["Continue"],
    defaultButton: "Continue"
  })

  // Prompt for ssh password
  const passwordPrompt = app.displayDialog("reMarkable SSH password", {
    defaultAnswer: "",
    buttons: ["Continue"],
    defaultButton: "Continue",
    hiddenAnswer: true
  })


  const newDevice = JSON.stringify({
    ...config,
    devices: [...devices, {
      id: Date.now(),
      name: deviceNamePrompt.textReturned,
      type: deviceTypePrompt.buttonReturned === "reMarkable 1" ? "1" : "2",
      ip: ipPrompt.textReturned,
      password: passwordPrompt.textReturned
    }]
  })

  // Update config.json
  writeTextToFile(newDevice, `/Users/${user}/Library/Application Support/reMouseable/config.json`, true)

  return true
}

function selectDevice(action) {

  // Get existing config file
  const config = JSON.parse(readFile(`/Users/${user}/Library/Application Support/reMouseable/config.json`))
  const devices = config.devices

  // Prompt to create a new device if there are no existing devices
  if (devices.length <= 0) {
    addDevice()
    return selectDevice("connect")
  }

  // Generate device list
  let deviceList = devices.map((device) => {
    return `${device.name} | reMarkable${device.type} (${device.ip})`
  })

  // Prompt user for device selection
  const device = app.chooseFromList(deviceList, {
    withPrompt: `Select device to ${action}`,
    defaultItems: deviceList[0]
  })

  // Return selected device
  let selected
  devices.forEach((dev) => {
    if (device[0] === `${dev.name} | reMarkable${dev.type} (${dev.ip})`) {
      selected = dev
    }
  })

  if (selected) {
    return selected
  }

  return false
}

// Download latest reMouseable executable from GitHub
function update(version, releaseLink) {

  const config = JSON.parse(readFile(`/Users/${user}/Library/Application Support/reMouseable/config.json`))

  // Download latest release
  app.doShellScript(`cd /Users/${user}/Library/Application\\ Support/reMouseable && curl -L -o 'osx' ${releaseLink} && chmod +x osx`)

  // Update config.json file
  writeTextToFile(JSON.stringify({ ...config, version }), `/Users/${user}/Library/Application Support/reMouseable/config.json`, true)

  // Restart app after update
  appStart()
}

function startUp(addMissing) {

  let hasConfig = false
  let hasBinary = false
  let appFile

  // Setup environment for the app if none exists
  try {
    appFile = appSupport.folders.byName("reMouseable").entireContents()
  } catch {
    if (makeAppFile()) {
      appStart(true)
    }
  }

  // Check for config.json and reMouseable executable
  try {
    for (let i = 0; i < appFile.length; i++) {
      const file = appFile[i]
      const fileName = file.name()

      if (fileName === "config.json") {
        hasConfig = true
      }

      if (fileName === "osx") {
        hasBinary = true
      }
    }
  } catch (e) {
    return false
  }

  // Check for update if it has config.json and reMouseable executable
  if (hasConfig && hasBinary) {

    const config = JSON.parse(readFile(`/Users/${user}/Library/Application Support/reMouseable/config.json`))

    const latest = checkForUpdate(config.version)

    if (latest) {

      const updatePrompt = app.displayDialog(`reMouseable update available! \n${latest.version}: ${latest.name}`, {
        buttons: ["Update Later", "Update Now"],
        defaultButton: "Update Now"
      })

      if (updatePrompt.buttonReturned === "Update Now") {

        update(latest.version, latest.download)
        return true
      } else {
        return true
      }
    } else {
      return true
    }
  } else {

    // Prepare reMouseable app environment
    if (addMissing) {
      const latest = checkForUpdate()

      if (!latest) {
        return false
      }

      // Download latest release
      app.doShellScript(`cd /Users/${user}/Library/Application\\ Support/reMouseable && curl -L -o 'osx' ${latest.download} && chmod +x osx`)

      // Add config.json file
      writeTextToFile(JSON.stringify({ version: latest.version, devices: [] }), `/Users/${user}/Library/Application Support/reMouseable/config.json`, true)

      if (startUp(false)) {
        return true
      }
      return false
    }
    return false
  }

}

function terminateSsh() {
  const running = app.doShellScript("ps -ax | grep osx")
  const connectionList = running.split("\r")

  connectionList.forEach(connection => {
    if (connection.includes("./osx")) {
      const id = connection.split(" ")[0]

      app.doShellScript(`kill ${id}`)

      app.displayNotification(`Disconnected from your reMarkable.`, {
        withTitle: "Disconnected",
        subtitle: ""
      })
    }
  })

  return
}

function checkConnection() {
  const running = app.doShellScript("ps -ax | grep osx")
  const connectionList = running.split("\r")
  let existingConnection = false

  connectionList.forEach(connection => {
    if (connection.includes("./osx")) {
      existingConnection = true
    }
  })

  return existingConnection
}

function waitForConnection(ssh, device) {
  let isRunning = false
  let checkCount = 0

  while (!isRunning && checkCount < 5000) {
    checkCount++
    list = ssh.processes()

    if (ssh.contents().includes("connected")) {

      app.displayNotification(`Connected to reMarkable${device.type} at ${device.ip}.`, {
        withTitle: "Connected!",
        subtitle: ""
      })
      isRunning = true
    }
  }

  if (!isRunning && checkCount >= 5000) {

    terminateSsh()

    app.displayDialog("Unable to connect to reMarkable.\nMake sure your device is on and connected either to USB or WiFi. Also make sure you have entered the correct IP address and password.", {
      buttons: ["Ok"],
      defaultButton: "Ok"
    })

    return promptAction()
  }

  const connectedPrompt = app.displayDialog(`reMarkable${device.type} connected\n`, {
    buttons: ["Quit Without Disconnecting", "Disconnect"],
    defaultButton: "Disconnect"
  })

  if (connectedPrompt.buttonReturned === "Disconnect") {
    terminateSsh()
    promptAction()
  }
}

// Prompt user for main actions
function promptAction() {
  const actionPrompt = app.displayDialog("What do you want to do?", {
    buttons: ["Quit", "Manage Devices", "Connect"],
    defaultButton: "Connect"
  })

  if (actionPrompt.buttonReturned === "Connect") {
    const device = selectDevice("connect")

    app.displayNotification(`Connecting to reMarkable${device.type} at ${device.ip}.`, {
      withTitle: "Connecting...",
      subtitle: ""
    })

    if (device.type === "2") {
      const ssh = Terminal.doScript(`cd /Users/${user}/Library/Application\\ Support/reMouseable && ./osx --event-file /dev/input/event1 --ssh-ip="${device.ip}:22" --ssh-password="${device.password}"`)

      waitForConnection(ssh, device)
    } else {
      const ssh = Terminal.doScript(`cd /Users/${user}/Library/Application\\ Support/reMouseable && ./osx --ssh-ip="${device.ip}:22" --ssh-password="${device.password}"`)

      waitForConnection(ssh, device)
    }

    return
  } else if (actionPrompt.buttonReturned === "Manage Devices") {
    const managePrompt = app.displayDialog("Would you like to add or remove a device?", {
      buttons: ["Back", "Remove", "Add"],
      defaultButton: "Add"
    })

    if (managePrompt.buttonReturned === "Add") {
      addDevice()
    } else if (managePrompt.buttonReturned === "Remove") {
      const device = selectDevice("remove")
      const config = JSON.parse(readFile(`/Users/${user}/Library/Application Support/reMouseable/config.json`))
      let devices = config.devices


      devices = devices.filter(function (dev) {
        return dev.id !== device.id;
      });

      // Update config.json file
      writeTextToFile(JSON.stringify({ ...config, devices }), `/Users/${user}/Library/Application Support/reMouseable/config.json`, true)

    } else {
      return
    }
  } else {
    return
  }

  promptAction()
}

function appStart(addMissing) {
  if (startUp(addMissing || false)) {
    if (checkConnection()) {
      const existingConnectionPrompt = app.displayDialog("Your reMarkable is already connected.", {
        buttons: ["Ignore", "Disconnect"],
        defaultButton: "Disconnect"
      })

      if (existingConnectionPrompt.buttonReturned === "Disconnect") {
        terminateSsh()
      }
    }

    promptAction()
    return
  } else {
    app.displayDialog("Something went wrong starting up reMouseable.", {
      buttons: ["Ok"],
      defaultButton: "Ok",
      withIcon: "caution"
    })
  }
}

appStart()                              /щ jscr  њоо­