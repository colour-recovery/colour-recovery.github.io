loadplugin("FQuiver.dll")
loadplugin("rawsource.dll")

rawinput = RawSource("F:\totp_ch03(undist).y", 1920, 1080, "Y8")
f1mask = RawSource("F:\VERTFILT field 1.y", 1920, 1080, "Y8")
f1mask2 = F2Quiver(f1mask,"bhh",70,15,degree=32)
f2mask = RawSource("F:\VERTFILT field 2.y", 1920, 1080, "Y8")
f2mask2 = F2Quiver(f2mask,"bhh",70,15,degree=32)


f1partial = mt_lutxy(rawinput, f1mask2, expr = "x y * 255 /")
f2partial = mt_lutxy(rawinput, f2mask2, expr = "x y * 255 /")



LanczosResize(f1partial, 720, 576)
SeparateFields()
f1partial720 = SelectEven()


LanczosResize(f2partial, 720, 576)
SeparateFields()
f2partial720 = SelectOdd()


f1full = mt_lutxy(f1partial720, f2partial720, expr = "x y - 2 * x +")
f1fullshift = AddBorders(f1full,0,2,0,0)
f1fullshift2 = Crop(f1fullshift,0,0,0,-2)

f2full = mt_lutxy(f1partial720, f2partial720, expr = "y x - 2 * y +")


Interleave(f1fullshift2, f2full)
LanczosResize(720, 576)


loadplugin("fft3dfilter.dll")
F1Quiver(last,"bh",304,15,degree=32)
fft3dfilter(sigma=10)