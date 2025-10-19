return {
    ["Button.Primary"] = {
        Class = "TextButton",
        Properties = {
            BackgroundColor3 = { token = "primary" },
            TextColor3 = { token = "text" },
            Font = Enum.Font.GothamBold,
            Size = UDim2.new(0, 150, 0, 40),
            TextSize = 16
        },
        States = {
            hover = {
                Properties = {
                    BackgroundTransparency = 0.1
                }
            },
            pressed = {
                Properties = {
                    BackgroundTransparency = 0.3
                }
            }
        }
    },
    ["Frame.Dark"] = {
        Class = "Frame",
        Properties = {
            BackgroundColor3 = { token = "secondary" },
            BorderSizePixel = 0
        }
    }
}
