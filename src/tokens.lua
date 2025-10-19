local tokens = {}

-- Colors
tokens.color = {
    primary = Color3.fromRGB(52,120,246),
    secondary = Color3.fromRGB(35,39,42),
    surface = Color3.fromRGB(18,18,18),
    text = Color3.fromRGB(235,235,235),
    muted = Color3.fromRGB(145,145,145),
}

-- Sizes / spacing
tokens.size = {
    buttonHeight = UDim2.new(0, 36, 0, 36),
    controlPadding = 8
}

-- Fonts / text
tokens.font = {
    heading = Enum.Font.GothamBold,
    body = Enum.Font.Gotham
}

return tokens
