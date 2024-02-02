# base colours
kjl_pink = colorant"#f52565"
kjl_blue = colorant"#2559f5"
kjl_green = colorant"#58bc82"
kjl_turquoise = colorant"#119da4"
kjl_orange = colorant"#f5bb25"
kjl_tan = colorant"#e9d985"
kjl_brown = colorant"#c3b299"
kjl_gray = colorant"#cbd4c2"
kjl_darkgray = colorant"#50514f"

# Legacy
caitlin_blue = colorant"#3EA8DE"
caitlin_pink = colorant"#FF7BAC"

# Colour gradients

pink2blue = cgrad([kjl_pink, :white, kjl_blue])

white2blue = cgrad([:white, kjl_blue])
white2pink = cgrad([:white, kjl_pink])
white2black = cgrad([:white, :black])

trans2blue = cgrad([:transparent, kjl_blue])
trans2pink = cgrad([:transparent, kjl_pink])
trans2black = cgrad([:transparent, :black])
trans2white = cgrad([:transparent, :white])

# custom color gradient (from PixelFrame)
c1 = colorant"#7e90b7"
c2 = colorant"#c1cbe8"
c3 = colorant"#c59e64"
c4 = colorant"#e2caa9"
c5 = colorant"#debac1"
c6 = colorant"#e1d5d7"

pastel = cgrad([c1, c2, c3, c4, c5, c6])