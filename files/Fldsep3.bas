CLS

DIM ampl(1) AS SINGLE
INPUT "Enter amplification factor"; ampl(1)
ampl(1) = ampl(1) - 1
INPUT "Enter start frame"; n1
INPUT "Enter end frame"; n2



DIM f1(720) AS STRING * 1
DIM f2(720) AS STRING * 1
DIM diff(720) AS INTEGER
DIM p AS STRING * 1


FOR n = n1 TO n2

DATA1$ = STR$(n)+"-1.raw"
DATA2$ = STR$(n)+"-2.raw"
l = LEN(DATA1$) - 1
IF LEFT$(DATA1$,1)=" " THEN DATA1$=RIGHT$(DATA1$,l)
IF LEFT$(DATA2$,1)=" " THEN DATA2$=RIGHT$(DATA2$,l)

PRINT "Processing files ";DATA1$;" and ";DATA2$


FOR y = 0 TO 574 STEP 2

OPEN DATA1$ FOR BINARY AS #1

FOR x = 1 TO 720
GET #1, x + (720 * y), f1(x)
NEXT x

CLOSE #1


OPEN DATA2$ FOR BINARY AS #1


FOR x = 1 TO 720
GET #1, x + (720 * y) + 720, f2(x)
NEXT x

CLOSE #1



OUTPUT$ = STR$(n)+"-1_mod.raw"
l = LEN(OUTPUT$) - 1
IF LEFT$(OUTPUT$,1)=" " THEN OUTPUT$=RIGHT$(OUTPUT$,l)
OPEN OUTPUT$ FOR BINARY AS #2


FOR x = 1 TO 720

diff(x) = ASC(f1(x)) - ASC(f2(x))
k = ASC(f1(x)) + INT(ampl(1) * diff(x))
IF k < 0 THEN k = 0
IF k > 255 THEN k = 255
p = CHR$(k)
PUT #2, x + (720 * y), p
PUT #2, x + (720 * y) + 720, p

NEXT x


CLOSE #2


OUTPUT$ = STR$(n)+"-2_mod.raw"
l = LEN(OUTPUT$) - 1
IF LEFT$(OUTPUT$,1)=" " THEN OUTPUT$=RIGHT$(OUTPUT$,l)
OPEN OUTPUT$ FOR BINARY AS #2



FOR x = 1 TO 720

diff(x) = ASC(f2(x)) - ASC(f1(x))
k = ASC(f2(x)) + INT(ampl(1) * diff(x))
IF k < 0 THEN k = 0
IF k > 255 THEN k = 255
p = CHR$(k)

IF y = 574 THEN GOTO Finished

PUT #2, x + (720 * y) + 1440, p
PUT #2, x + (720 * y) + 2160, p

NEXT x


CLOSE #2



NEXT y

Finished:

CLOSE #2

NEXT n


PRINT "Finished"

