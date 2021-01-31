CLS

DIM ampl(1) AS SINGLE
INPUT "Enter amplification factor"; ampl(1)
ampl(1) = ampl(1) - 1

DATA1$ = "f1.raw"
DATA2$ = "f2.raw"


DIM f1(720) AS STRING * 1
DIM f2(720) AS STRING * 1
DIM diff(720) AS INTEGER
DIM p AS STRING * 1


FOR y = 0 TO 572

OPEN DATA1$ FOR BINARY AS #1

FOR x = 1 TO 720
GET #1, x + (720 * y), f1(x)
NEXT x

CLOSE #1


OPEN DATA2$ FOR BINARY AS #1


FOR x = 1 TO 720
GET #1, x + (720 * y), f2(x)
NEXT x

CLOSE #1



OUTPUT$ = "f1_mod.raw"
OPEN OUTPUT$ FOR BINARY AS #2


FOR x = 1 TO 720

diff(x) = ASC(f1(x)) - ASC(f2(x))
k = ASC(f1(x)) + INT(ampl(1) * diff(x))
IF k < 0 THEN k = 0
IF k > 255 THEN k = 255
p = CHR$(k)
PUT #2, x + (720 * y), p

NEXT x


CLOSE #2



OUTPUT$ = "f2_mod.raw"
OPEN OUTPUT$ FOR BINARY AS #2


FOR x = 1 TO 720

diff(x) = ASC(f2(x)) - ASC(f1(x))
k = ASC(f2(x)) + INT(ampl(1) * diff(x))
IF k < 0 THEN k = 0
IF k > 255 THEN k = 255
p = CHR$(k)
PUT #2, x + (720 * y), p

NEXT x


CLOSE #2



NEXT y


PRINT "Finished"

