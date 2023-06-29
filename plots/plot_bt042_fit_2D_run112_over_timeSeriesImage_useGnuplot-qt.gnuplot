reset

set term qt size 1600,1024 font "DejaVuSerif, 15"
set output

# set term jpeg interlace enhanced giant font "DejaVuSerif, 10" crop

set grid 
set key above

set title "keep in mind that the timings were only optimized for 0.42"

set xlabel "x [{/Symbol m}m] (shifted)"
set ylabel "y [{/Symbol m}m] (shifted)"
set size ratio -1

set xrange [-100:5300]
set yrange [-100:2740]

set datafile separator ","

#conversion:1px = 4mum in raw images, but in montage it is 3.03 for Photron and 3.11 in Xray
#nope, changed back to 4mum per px in /home/maxkoch/POSTDOC/Collab_JJ/mainFigureGetItRight/Stack_para_fig_LUT_FLIP_Posta_put_to_same_scale_4mumPerPx.png

scale(x) = x*1e6
dinit(x) = scale(x*495e-6)
mumPerPxMontage = 4
# the image is scaled to 1mum per px so that x and y scale are correct in mum
# the orig size of the xray  images in x-dir is 160px at 6.5mum/px
# the orig size of the photr images in x-dir is 220px at 4  mum/px

zeroXxray01    = 563
zeroYxray01(x) = 2230 + dinit(x)

zeroXxray02    = 1610
zeroYxray02(x) = zeroYxray01(x)

zeroXxray03    = 2684
zeroYxray03(x) = zeroYxray01(x)

zeroXxray04    = 3707
zeroYxray04(x) = zeroYxray01(x)

zeroXxray05    = 4780
zeroYxray05(x) = zeroYxray01(x)

zeroXxray06    = zeroXxray01
zeroYxray06(x) = 1749 + dinit(x)

zeroXxray07    = zeroXxray02
zeroYxray07(x) = zeroYxray06(x)

zeroXxray08    = zeroXxray03
zeroYxray08(x) = zeroYxray06(x)

zeroXxray09    = zeroXxray04
zeroYxray09(x) = zeroYxray06(x)

zeroXxray10    = zeroXxray05
zeroYxray10(x) = zeroYxray06(x)

zeroXxray11    = zeroXxray01
zeroYxray11(x) = 1272 + dinit(x)

zeroXxray12    = zeroXxray02
zeroYxray12(x) = zeroYxray11(x)

zeroXxray13    = zeroXxray03
zeroYxray13(x) = zeroYxray11(x)

zeroXxray14    = zeroXxray04
zeroYxray14(x) = zeroYxray11(x)

zeroXxray15    = zeroXxray05
zeroYxray15(x) = zeroYxray11(x)



zeroXphotrA    = 470
zeroYphotrA(x) = 832 + dinit(x)

zeroXphotrB    = 1350
zeroYphotrB(x) = zeroYphotrA(x)

zeroXphotrC    = 2230
zeroYphotrC(x) = zeroYphotrA(x)

zeroXphotrD    = 3110
zeroYphotrD(x) = zeroYphotrA(x)

zeroXphotrE    = 4030
zeroYphotrE(x) = zeroYphotrA(x)

zeroXphotrF    = zeroXphotrA
zeroYphotrF(x) = 244 + dinit(x)

zeroXphotrG    = zeroXphotrB
zeroYphotrG(x) = zeroYphotrF(x)

zeroXphotrH    = zeroXphotrC
zeroYphotrH(x) = zeroYphotrF(x)

zeroXphotrI    = zeroXphotrD
zeroYphotrI(x) = zeroYphotrF(x)

zeroXphotrJ    = zeroXphotrE
zeroYphotrJ(x) = zeroYphotrF(x)


frame01 = 137
frame02 = 155
frame03 = 159
frame04 = 163
frame05 = 177

frame06 = 183
frame07 = 186
frame08 = 189
frame09 = 192
frame10 = 196

frame11 = 200
frame12 = 205
frame13 = 210
frame14 = 220
frame15 = 230

frameA = frame02
frameB = frame04
frameC = frame05
frameD = frame06
frameE = frame07

frameF = frame10
frameG = frame11
frameH = frame13
frameI = frame14
frameJ = frame15


# THIS is the solution on how to scale a grayscale image with dx=4 !!:
set palette grey

p "/home/maxkoch/POSTDOC/Collab_JJ/mainFigureGetItRight/Stack_para_fig_LUT_FLIP_Posta_put_to_same_scale_4mumPerPx.png" \
  binary filetype=png dx=mumPerPxMontage w rgbimage not ,\
  sprintf("fit_2D_run112_dstar0.42/contour/bla0.%i.csv",frame01) u ( scale($6) + zeroXxray01):(scale($7) + zeroYxray01(0.42)) w p ps 0.5 lw 1 lc 7 t "D*=0.42",\
  ""                                                             u (-scale($6) + zeroXxray01):(scale($7) + zeroYxray01(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  sprintf("fit_2D_run112_dstar0.42/contour/bla0.%i.csv",frame02) u ( scale($6) + zeroXxray02):(scale($7) + zeroYxray02(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  ""                                                             u (-scale($6) + zeroXxray02):(scale($7) + zeroYxray02(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  sprintf("fit_2D_run112_dstar0.42/contour/bla0.%i.csv",frame03) u ( scale($6) + zeroXxray03):(scale($7) + zeroYxray03(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  ""                                                             u (-scale($6) + zeroXxray03):(scale($7) + zeroYxray03(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  sprintf("fit_2D_run112_dstar0.42/contour/bla0.%i.csv",frame04) u ( scale($6) + zeroXxray04):(scale($7) + zeroYxray04(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  ""                                                             u (-scale($6) + zeroXxray04):(scale($7) + zeroYxray04(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  sprintf("fit_2D_run112_dstar0.42/contour/bla0.%i.csv",frame05) u ( scale($6) + zeroXxray05):(scale($7) + zeroYxray05(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  ""                                                             u (-scale($6) + zeroXxray05):(scale($7) + zeroYxray05(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  sprintf("fit_2D_run112_dstar0.42/contour/bla0.%i.csv",frame06) u ( scale($6) + zeroXxray06):(scale($7) + zeroYxray06(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  ""                                                             u (-scale($6) + zeroXxray06):(scale($7) + zeroYxray06(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  sprintf("fit_2D_run112_dstar0.42/contour/bla0.%i.csv",frame07) u ( scale($6) + zeroXxray07):(scale($7) + zeroYxray07(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  ""                                                             u (-scale($6) + zeroXxray07):(scale($7) + zeroYxray07(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  sprintf("fit_2D_run112_dstar0.42/contour/bla0.%i.csv",frame08) u ( scale($6) + zeroXxray08):(scale($7) + zeroYxray08(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  ""                                                             u (-scale($6) + zeroXxray08):(scale($7) + zeroYxray08(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  sprintf("fit_2D_run112_dstar0.42/contour/bla0.%i.csv",frame09) u ( scale($6) + zeroXxray09):(scale($7) + zeroYxray09(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  ""                                                             u (-scale($6) + zeroXxray09):(scale($7) + zeroYxray09(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  sprintf("fit_2D_run112_dstar0.42/contour/bla0.%i.csv",frame10) u ( scale($6) + zeroXxray10):(scale($7) + zeroYxray10(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  ""                                                             u (-scale($6) + zeroXxray10):(scale($7) + zeroYxray10(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  sprintf("fit_2D_run112_dstar0.42/contour/bla0.%i.csv",frame11) u ( scale($6) + zeroXxray11):(scale($7) + zeroYxray11(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  ""                                                             u (-scale($6) + zeroXxray11):(scale($7) + zeroYxray11(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  sprintf("fit_2D_run112_dstar0.42/contour/bla0.%i.csv",frame12) u ( scale($6) + zeroXxray12):(scale($7) + zeroYxray12(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  ""                                                             u (-scale($6) + zeroXxray12):(scale($7) + zeroYxray12(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  sprintf("fit_2D_run112_dstar0.42/contour/bla0.%i.csv",frame13) u ( scale($6) + zeroXxray13):(scale($7) + zeroYxray13(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  ""                                                             u (-scale($6) + zeroXxray13):(scale($7) + zeroYxray13(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  sprintf("fit_2D_run112_dstar0.42/contour/bla0.%i.csv",frame14) u ( scale($6) + zeroXxray14):(scale($7) + zeroYxray14(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  ""                                                             u (-scale($6) + zeroXxray14):(scale($7) + zeroYxray14(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  sprintf("fit_2D_run112_dstar0.42/contour/bla0.%i.csv",frame15) u ( scale($6) + zeroXxray15):(scale($7) + zeroYxray15(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  ""                                                             u (-scale($6) + zeroXxray15):(scale($7) + zeroYxray15(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  sprintf("fit_2D_run112_dstar0.42/contour/bla0.%i.csv",frameA)  u ( scale($6) + zeroXphotrA):(scale($7) + zeroYphotrA(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  ""                                                             u (-scale($6) + zeroXphotrA):(scale($7) + zeroYphotrA(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  sprintf("fit_2D_run112_dstar0.42/contour/bla0.%i.csv",frameB)  u ( scale($6) + zeroXphotrB):(scale($7) + zeroYphotrB(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  ""                                                             u (-scale($6) + zeroXphotrB):(scale($7) + zeroYphotrB(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  sprintf("fit_2D_run112_dstar0.42/contour/bla0.%i.csv",frameC)  u ( scale($6) + zeroXphotrC):(scale($7) + zeroYphotrC(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  ""                                                             u (-scale($6) + zeroXphotrC):(scale($7) + zeroYphotrC(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  sprintf("fit_2D_run112_dstar0.42/contour/bla0.%i.csv",frameD)  u ( scale($6) + zeroXphotrD):(scale($7) + zeroYphotrD(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  ""                                                             u (-scale($6) + zeroXphotrD):(scale($7) + zeroYphotrD(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  sprintf("fit_2D_run112_dstar0.42/contour/bla0.%i.csv",frameE)  u ( scale($6) + zeroXphotrE):(scale($7) + zeroYphotrE(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  ""                                                             u (-scale($6) + zeroXphotrE):(scale($7) + zeroYphotrE(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  sprintf("fit_2D_run112_dstar0.42/contour/bla0.%i.csv",frameF)  u ( scale($6) + zeroXphotrF):(scale($7) + zeroYphotrF(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  ""                                                             u (-scale($6) + zeroXphotrF):(scale($7) + zeroYphotrF(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  sprintf("fit_2D_run112_dstar0.42/contour/bla0.%i.csv",frameG)  u ( scale($6) + zeroXphotrG):(scale($7) + zeroYphotrG(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  ""                                                             u (-scale($6) + zeroXphotrG):(scale($7) + zeroYphotrG(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  sprintf("fit_2D_run112_dstar0.42/contour/bla0.%i.csv",frameH)  u ( scale($6) + zeroXphotrH):(scale($7) + zeroYphotrH(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  ""                                                             u (-scale($6) + zeroXphotrH):(scale($7) + zeroYphotrH(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  sprintf("fit_2D_run112_dstar0.42/contour/bla0.%i.csv",frameI)  u ( scale($6) + zeroXphotrI):(scale($7) + zeroYphotrI(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  ""                                                             u (-scale($6) + zeroXphotrI):(scale($7) + zeroYphotrI(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  sprintf("fit_2D_run112_dstar0.42/contour/bla0.%i.csv",frameJ)  u ( scale($6) + zeroXphotrJ):(scale($7) + zeroYphotrJ(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  ""                                                             u (-scale($6) + zeroXphotrJ):(scale($7) + zeroYphotrJ(0.42)) w p ps 0.5 lw 1 lc 7 not        ,\
  \
  \
  \
  sprintf("fit_2D_run112_dstar0.4/contour/bla0.%i.csv",frame01)  u ( scale($6) + zeroXxray01):(scale($7) + zeroYxray01(0.40)) w p ps 0.5 lw 1 lc 1 t "D*=0.40",\
  ""                                                             u (-scale($6) + zeroXxray01):(scale($7) + zeroYxray01(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  sprintf("fit_2D_run112_dstar0.4/contour/bla0.%i.csv",frame02)  u ( scale($6) + zeroXxray02):(scale($7) + zeroYxray02(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  ""                                                             u (-scale($6) + zeroXxray02):(scale($7) + zeroYxray02(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  sprintf("fit_2D_run112_dstar0.4/contour/bla0.%i.csv",frame03)  u ( scale($6) + zeroXxray03):(scale($7) + zeroYxray03(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  ""                                                             u (-scale($6) + zeroXxray03):(scale($7) + zeroYxray03(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  sprintf("fit_2D_run112_dstar0.4/contour/bla0.%i.csv",frame04)  u ( scale($6) + zeroXxray04):(scale($7) + zeroYxray04(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  ""                                                             u (-scale($6) + zeroXxray04):(scale($7) + zeroYxray04(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  sprintf("fit_2D_run112_dstar0.4/contour/bla0.%i.csv",frame05)  u ( scale($6) + zeroXxray05):(scale($7) + zeroYxray05(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  ""                                                             u (-scale($6) + zeroXxray05):(scale($7) + zeroYxray05(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  sprintf("fit_2D_run112_dstar0.4/contour/bla0.%i.csv",frame06)  u ( scale($6) + zeroXxray06):(scale($7) + zeroYxray06(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  ""                                                             u (-scale($6) + zeroXxray06):(scale($7) + zeroYxray06(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  sprintf("fit_2D_run112_dstar0.4/contour/bla0.%i.csv",frame07)  u ( scale($6) + zeroXxray07):(scale($7) + zeroYxray07(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  ""                                                             u (-scale($6) + zeroXxray07):(scale($7) + zeroYxray07(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  sprintf("fit_2D_run112_dstar0.4/contour/bla0.%i.csv",frame08)  u ( scale($6) + zeroXxray08):(scale($7) + zeroYxray08(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  ""                                                             u (-scale($6) + zeroXxray08):(scale($7) + zeroYxray08(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  sprintf("fit_2D_run112_dstar0.4/contour/bla0.%i.csv",frame09)  u ( scale($6) + zeroXxray09):(scale($7) + zeroYxray09(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  ""                                                             u (-scale($6) + zeroXxray09):(scale($7) + zeroYxray09(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  sprintf("fit_2D_run112_dstar0.4/contour/bla0.%i.csv",frame10)  u ( scale($6) + zeroXxray10):(scale($7) + zeroYxray10(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  ""                                                             u (-scale($6) + zeroXxray10):(scale($7) + zeroYxray10(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  sprintf("fit_2D_run112_dstar0.4/contour/bla0.%i.csv",frame11)  u ( scale($6) + zeroXxray11):(scale($7) + zeroYxray11(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  ""                                                             u (-scale($6) + zeroXxray11):(scale($7) + zeroYxray11(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  sprintf("fit_2D_run112_dstar0.4/contour/bla0.%i.csv",frame12)  u ( scale($6) + zeroXxray12):(scale($7) + zeroYxray12(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  ""                                                             u (-scale($6) + zeroXxray12):(scale($7) + zeroYxray12(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  sprintf("fit_2D_run112_dstar0.4/contour/bla0.%i.csv",frame13)  u ( scale($6) + zeroXxray13):(scale($7) + zeroYxray13(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  ""                                                             u (-scale($6) + zeroXxray13):(scale($7) + zeroYxray13(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  sprintf("fit_2D_run112_dstar0.4/contour/bla0.%i.csv",frame14)  u ( scale($6) + zeroXxray14):(scale($7) + zeroYxray14(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  ""                                                             u (-scale($6) + zeroXxray14):(scale($7) + zeroYxray14(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  sprintf("fit_2D_run112_dstar0.4/contour/bla0.%i.csv",frame15)  u ( scale($6) + zeroXxray15):(scale($7) + zeroYxray15(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  ""                                                             u (-scale($6) + zeroXxray15):(scale($7) + zeroYxray15(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  sprintf("fit_2D_run112_dstar0.4/contour/bla0.%i.csv",frameA)   u ( scale($6) + zeroXphotrA):(scale($7) + zeroYphotrA(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  ""                                                             u (-scale($6) + zeroXphotrA):(scale($7) + zeroYphotrA(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  sprintf("fit_2D_run112_dstar0.4/contour/bla0.%i.csv",frameB)   u ( scale($6) + zeroXphotrB):(scale($7) + zeroYphotrB(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  ""                                                             u (-scale($6) + zeroXphotrB):(scale($7) + zeroYphotrB(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  sprintf("fit_2D_run112_dstar0.4/contour/bla0.%i.csv",frameC)   u ( scale($6) + zeroXphotrC):(scale($7) + zeroYphotrC(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  ""                                                             u (-scale($6) + zeroXphotrC):(scale($7) + zeroYphotrC(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  sprintf("fit_2D_run112_dstar0.4/contour/bla0.%i.csv",frameD)   u ( scale($6) + zeroXphotrD):(scale($7) + zeroYphotrD(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  ""                                                             u (-scale($6) + zeroXphotrD):(scale($7) + zeroYphotrD(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  sprintf("fit_2D_run112_dstar0.4/contour/bla0.%i.csv",frameE)   u ( scale($6) + zeroXphotrE):(scale($7) + zeroYphotrE(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  ""                                                             u (-scale($6) + zeroXphotrE):(scale($7) + zeroYphotrE(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  sprintf("fit_2D_run112_dstar0.4/contour/bla0.%i.csv",frameF)   u ( scale($6) + zeroXphotrF):(scale($7) + zeroYphotrF(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  ""                                                             u (-scale($6) + zeroXphotrF):(scale($7) + zeroYphotrF(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  sprintf("fit_2D_run112_dstar0.4/contour/bla0.%i.csv",frameG)   u ( scale($6) + zeroXphotrG):(scale($7) + zeroYphotrG(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  ""                                                             u (-scale($6) + zeroXphotrG):(scale($7) + zeroYphotrG(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  sprintf("fit_2D_run112_dstar0.4/contour/bla0.%i.csv",frameH)   u ( scale($6) + zeroXphotrH):(scale($7) + zeroYphotrH(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  ""                                                             u (-scale($6) + zeroXphotrH):(scale($7) + zeroYphotrH(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  sprintf("fit_2D_run112_dstar0.4/contour/bla0.%i.csv",frameI)   u ( scale($6) + zeroXphotrI):(scale($7) + zeroYphotrI(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  ""                                                             u (-scale($6) + zeroXphotrI):(scale($7) + zeroYphotrI(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  sprintf("fit_2D_run112_dstar0.4/contour/bla0.%i.csv",frameJ)   u ( scale($6) + zeroXphotrJ):(scale($7) + zeroYphotrJ(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  ""                                                             u (-scale($6) + zeroXphotrJ):(scale($7) + zeroYphotrJ(0.40)) w p ps 0.5 lw 1 lc 1 not        ,\
  \
  \
  \
  sprintf("fit_2D_run112_dstar0.38/contour/bla0.%i.csv",frame01) u ( scale($6) + zeroXxray01):(scale($7) + zeroYxray01(0.38)) w p ps 0.5 lw 1 lc 2 t "D*=0.38",\
  ""                                                             u (-scale($6) + zeroXxray01):(scale($7) + zeroYxray01(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  sprintf("fit_2D_run112_dstar0.38/contour/bla0.%i.csv",frame02) u ( scale($6) + zeroXxray02):(scale($7) + zeroYxray02(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  ""                                                             u (-scale($6) + zeroXxray02):(scale($7) + zeroYxray02(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  sprintf("fit_2D_run112_dstar0.38/contour/bla0.%i.csv",frame03) u ( scale($6) + zeroXxray03):(scale($7) + zeroYxray03(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  ""                                                             u (-scale($6) + zeroXxray03):(scale($7) + zeroYxray03(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  sprintf("fit_2D_run112_dstar0.38/contour/bla0.%i.csv",frame04) u ( scale($6) + zeroXxray04):(scale($7) + zeroYxray04(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  ""                                                             u (-scale($6) + zeroXxray04):(scale($7) + zeroYxray04(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  sprintf("fit_2D_run112_dstar0.38/contour/bla0.%i.csv",frame05) u ( scale($6) + zeroXxray05):(scale($7) + zeroYxray05(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  ""                                                             u (-scale($6) + zeroXxray05):(scale($7) + zeroYxray05(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  sprintf("fit_2D_run112_dstar0.38/contour/bla0.%i.csv",frame06) u ( scale($6) + zeroXxray06):(scale($7) + zeroYxray06(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  ""                                                             u (-scale($6) + zeroXxray06):(scale($7) + zeroYxray06(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  sprintf("fit_2D_run112_dstar0.38/contour/bla0.%i.csv",frame07) u ( scale($6) + zeroXxray07):(scale($7) + zeroYxray07(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  ""                                                             u (-scale($6) + zeroXxray07):(scale($7) + zeroYxray07(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  sprintf("fit_2D_run112_dstar0.38/contour/bla0.%i.csv",frame08) u ( scale($6) + zeroXxray08):(scale($7) + zeroYxray08(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  ""                                                             u (-scale($6) + zeroXxray08):(scale($7) + zeroYxray08(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  sprintf("fit_2D_run112_dstar0.38/contour/bla0.%i.csv",frame09) u ( scale($6) + zeroXxray09):(scale($7) + zeroYxray09(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  ""                                                             u (-scale($6) + zeroXxray09):(scale($7) + zeroYxray09(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  sprintf("fit_2D_run112_dstar0.38/contour/bla0.%i.csv",frame10) u ( scale($6) + zeroXxray10):(scale($7) + zeroYxray10(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  ""                                                             u (-scale($6) + zeroXxray10):(scale($7) + zeroYxray10(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  sprintf("fit_2D_run112_dstar0.38/contour/bla0.%i.csv",frame11) u ( scale($6) + zeroXxray11):(scale($7) + zeroYxray11(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  ""                                                             u (-scale($6) + zeroXxray11):(scale($7) + zeroYxray11(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  sprintf("fit_2D_run112_dstar0.38/contour/bla0.%i.csv",frame12) u ( scale($6) + zeroXxray12):(scale($7) + zeroYxray12(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  ""                                                             u (-scale($6) + zeroXxray12):(scale($7) + zeroYxray12(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  sprintf("fit_2D_run112_dstar0.38/contour/bla0.%i.csv",frame13) u ( scale($6) + zeroXxray13):(scale($7) + zeroYxray13(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  ""                                                             u (-scale($6) + zeroXxray13):(scale($7) + zeroYxray13(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  sprintf("fit_2D_run112_dstar0.38/contour/bla0.%i.csv",frame14) u ( scale($6) + zeroXxray14):(scale($7) + zeroYxray14(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  ""                                                             u (-scale($6) + zeroXxray14):(scale($7) + zeroYxray14(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  sprintf("fit_2D_run112_dstar0.38/contour/bla0.%i.csv",frame15) u ( scale($6) + zeroXxray15):(scale($7) + zeroYxray15(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  ""                                                             u (-scale($6) + zeroXxray15):(scale($7) + zeroYxray15(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  sprintf("fit_2D_run112_dstar0.38/contour/bla0.%i.csv",frameA)  u ( scale($6) + zeroXphotrA):(scale($7) + zeroYphotrA(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  ""                                                             u (-scale($6) + zeroXphotrA):(scale($7) + zeroYphotrA(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  sprintf("fit_2D_run112_dstar0.38/contour/bla0.%i.csv",frameB)  u ( scale($6) + zeroXphotrB):(scale($7) + zeroYphotrB(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  ""                                                             u (-scale($6) + zeroXphotrB):(scale($7) + zeroYphotrB(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  sprintf("fit_2D_run112_dstar0.38/contour/bla0.%i.csv",frameC)  u ( scale($6) + zeroXphotrC):(scale($7) + zeroYphotrC(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  ""                                                             u (-scale($6) + zeroXphotrC):(scale($7) + zeroYphotrC(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  sprintf("fit_2D_run112_dstar0.38/contour/bla0.%i.csv",frameD)  u ( scale($6) + zeroXphotrD):(scale($7) + zeroYphotrD(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  ""                                                             u (-scale($6) + zeroXphotrD):(scale($7) + zeroYphotrD(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  sprintf("fit_2D_run112_dstar0.38/contour/bla0.%i.csv",frameE)  u ( scale($6) + zeroXphotrE):(scale($7) + zeroYphotrE(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  ""                                                             u (-scale($6) + zeroXphotrE):(scale($7) + zeroYphotrE(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  sprintf("fit_2D_run112_dstar0.38/contour/bla0.%i.csv",frameF)  u ( scale($6) + zeroXphotrF):(scale($7) + zeroYphotrF(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  ""                                                             u (-scale($6) + zeroXphotrF):(scale($7) + zeroYphotrF(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  sprintf("fit_2D_run112_dstar0.38/contour/bla0.%i.csv",frameG)  u ( scale($6) + zeroXphotrG):(scale($7) + zeroYphotrG(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  ""                                                             u (-scale($6) + zeroXphotrG):(scale($7) + zeroYphotrG(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  sprintf("fit_2D_run112_dstar0.38/contour/bla0.%i.csv",frameH)  u ( scale($6) + zeroXphotrH):(scale($7) + zeroYphotrH(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  ""                                                             u (-scale($6) + zeroXphotrH):(scale($7) + zeroYphotrH(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  sprintf("fit_2D_run112_dstar0.38/contour/bla0.%i.csv",frameI)  u ( scale($6) + zeroXphotrI):(scale($7) + zeroYphotrI(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  ""                                                             u (-scale($6) + zeroXphotrI):(scale($7) + zeroYphotrI(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  sprintf("fit_2D_run112_dstar0.38/contour/bla0.%i.csv",frameJ)  u ( scale($6) + zeroXphotrJ):(scale($7) + zeroYphotrJ(0.38)) w p ps 0.5 lw 1 lc 2 not        ,\
  ""                                                             u (-scale($6) + zeroXphotrJ):(scale($7) + zeroYphotrJ(0.38)) w p ps 0.5 lw 1 lc 2 not
