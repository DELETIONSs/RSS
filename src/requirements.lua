local Importation = {
    NotificationLibrary = "",
    RobloxServiceGrabber = "",
    WaveEnvironment = "",
    ExecutorDetection = ""
}

for i in Importation do
loadstring(game:HttpGet(i))()
end
