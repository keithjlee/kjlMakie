# base colours
green  = colorant"#48B674"
blue = colorant"#3EA8DE"
orange = colorant"#F9A11D"
gray1 = colorant"#B2B2B2"
gray2 = colorant"#808080"
pink = colorant"#FF7BAC"

pink2blue = cgrad([pink, :white, blue])

white2blue = cgrad([:white, blue])
white2pink = cgrad([:white, pink])
white2black = cgrad([:white, :black])

trans2blue = cgrad([:transparent, blue])
trans2pink = cgrad([:transparent, pink])
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