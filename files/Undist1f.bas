CLS

LINE INPUT "Enter csv filename? "; DTA$
LINE INPUT "Enter output filename? "; RAW$

OPUT$ = "mod.csv"
OPEN DTA$ FOR INPUT AS #1
OPEN OPUT$ FOR OUTPUT AS #2
' $ DYNAMIC
DIM csvx(120, 90)
DIM csvy(120, 90)


PRINT "Reading data"
FOR y = 1 TO 90
FOR x = 1 TO 120
INPUT #1, DUMMY
INPUT #1, DUMMY
INPUT #1, DUMMY$
IF ASC(DUMMY$) = 120 THEN DUMMY$ = "120"
csvx(x, y) = VAL(DUMMY$)
INPUT #1, DUMMY$
IF ASC(DUMMY$) = 120 THEN DUMMY$ = "120"
csvy(x, y) = VAL(DUMMY$)
NEXT x
NEXT y


PRINT "Interpolating missing csv values"
FOR y = 1 TO 89

left = 1
DO UNTIL csvx(left, y) <> 120
left = left + 1
LOOP


x = 1
DO UNTIL x = left

a = 1
DO UNTIL csvx(x, y) <> 120
IF csvx(x, y) = 120 THEN csvx(x, y) = csvx(x + a, y)
IF csvx(x, y) = 120 THEN csvx(x, y) = csvx(x + a - 1, y + 1)
IF x + a = 120 THEN
  PRINT "Interpolation failed"
  GOTO Fail
END IF
a = a + 1
LOOP

x = x + 1
LOOP



right = 120
DO UNTIL csvx(right, y) <> 120
right = right - 1
LOOP


x = 120
DO UNTIL x = right

a = 1
DO UNTIL csvx(x, y) <> 120
IF csvx(x, y) = 120 THEN csvx(x, y) = csvx(x - a, y)
IF csvx(x, y) = 120 THEN csvx(x, y) = csvx(x - a + 1, y + 1)
a = a + 1
LOOP

x = x - 1
LOOP



lx = 120
FOR x = left TO right
IF csvx(x, y) = 120 AND x <= lx THEN lx = x
IF csvx(x, y) <> 120 THEN GOTO Fill
Rtrn:
NEXT x

NEXT y
GOTO Continue


Fill:
rx = x - 1
n = rx - lx + 2
FOR xi = lx TO rx
csvx1 = csvx(lx - 1, y)
csvx2 = csvx(rx + 1, y)
csvx(xi, y) = csvx1 + ((csvx2 - csvx1) * ((xi - lx + 1) / n))
NEXT xi
lx = 120
GOTO Rtrn



Continue:

FOR y = 1 TO 89

left = 1
DO UNTIL csvy(left, y) <> 120
left = left + 1
LOOP


x = 1
DO UNTIL x = left

a = 1
DO UNTIL csvy(x, y) <> 120
IF csvy(x, y) = 120 THEN csvy(x, y) = csvy(x + a, y)
IF csvy(x, y) = 120 THEN csvy(x, y) = csvy(x + a - 1, y + 1)
IF x + a = 120 THEN
  PRINT "Interpolation failed"
  GOTO Fail
END IF
a = a + 1
LOOP

x = x + 1
LOOP



right = 120
DO UNTIL csvy(right, y) <> 120
right = right - 1
LOOP


x = 120
DO UNTIL x = right

a = 1
DO UNTIL csvy(x, y) <> 120
IF csvy(x, y) = 120 THEN csvy(x, y) = csvy(x - a, y)
IF csvy(x, y) = 120 THEN csvy(x, y) = csvy(x - a + 1, y + 1)
a = a + 1
LOOP

x = x - 1
LOOP



lx = 120
FOR x = left TO right
IF csvy(x, y) = 120 AND x <= lx THEN lx = x
IF csvy(x, y) <> 120 THEN GOTO Fill2
Rtrn2:
NEXT x

NEXT y
GOTO Continue2


Fill2:
rx = x - 1
n = rx - lx + 2
FOR xi = lx TO rx
csvy1 = csvy(lx - 1, y)
csvy2 = csvy(rx + 1, y)
csvy(xi, y) = csvy1 + ((csvy2 - csvy1) * ((xi - lx + 1) / n))
NEXT xi
lx = 120
GOTO Rtrn2



Continue2:

FOR y = 0 TO 89
FOR x = 0 TO 119
PRINT #2, x
PRINT #2, y
PRINT #2, csvx(x + 1, y + 1)
PRINT #2, csvy(x + 1, y + 1)
NEXT x
NEXT y


ERASE csvx
ERASE csvy
CLOSE #1
CLOSE #2




PRINT "Upscaling to 1920X90"
DTA$ = "mod.csv"
OPUT$ = "raw.txt"
OPEN DTA$ FOR INPUT AS #1
OPEN OPUT$ FOR OUTPUT AS #2
DIM csv$(4)
DIM x1(120)
DIM y1(120)


FOR y = 1 TO 90

FOR x = 1 TO 120

INPUT #1, csv$(1)
INPUT #1, csv$(2)
INPUT #1, csv$(3)
INPUT #1, csv$(4)

z = (16 * VAL(csv$(1))) + VAL(csv$(3)) - 960

x1(x) = z + 960 + .677157215# - (.00627464474# * z) - (.00000647508015# * (z ^ 2)) + (.0000000472352485# * (z ^ 3))


IF x1(x) > 1920 THEN x1(x) = 1920
IF x1(x) < 0 THEN x1(x) = 0

NEXT x



FOR a = 8 TO 1 STEP -1
PRINT #2, (x1(1) - a); " ";
NEXT a

FOR x = 1 TO 119
FOR a = 1 TO 16
x0 = x1(x) + ((x1(x + 1) - x1(x)) * (a / 16))
PRINT #2, x0; " ";
NEXT a
NEXT x

FOR a = 1 TO 8
PRINT #2, (x0 + a); " ";
NEXT a

PRINT #2, CHR$(13);
NEXT y
CLOSE #1


OPEN DTA$ FOR INPUT AS #1

FOR y = 1 TO 90

FOR x = 1 TO 120

INPUT #1, csv$(1)
INPUT #1, csv$(2)
INPUT #1, csv$(3)
INPUT #1, csv$(4)

y1(x) = (12 * VAL(csv$(2))) + VAL(csv$(4))
IF y1(x) > 1080 THEN y1(x) = 1080
IF y1(x) < 0 THEN y1(x) = 0
NEXT x


FOR a = 1 TO 8
PRINT #2, (y1(1)); " ";
NEXT a

FOR x = 1 TO 119
FOR a = 1 TO 16
y0 = y1(x) + ((y1(x + 1) - y1(x)) * (a / 16))
PRINT #2, y0; " ";
NEXT a
NEXT x

FOR a = 1 TO 8
PRINT #2, y0; " ";
NEXT a

PRINT #2, CHR$(13);
NEXT y

CLOSE #1
CLOSE #2



PRINT "Upscaling to 1920X1080 and writing data to output file"
DTA$ = "raw.txt"
OPUT$ = RAW$
OPEN DTA$ FOR INPUT AS #1
OPEN OPUT$ FOR OUTPUT AS #2
DIM d(1920, 2)
DIM dp(1920)
DIM x2$(1920, 12)

PRINT #2, "Width=1920"
PRINT #2, "Height=1080"
PRINT #2, ""
PRINT #2, "X Trans -----------------------------------"


FOR yb = 1 TO 2
FOR x = 1 TO 1920
INPUT #1, d(x, yb)
dp(x) = d(x, yb)
NEXT x
NEXT yb

FOR a = 1 TO 6
FOR x = 1 TO 1920
PRINT #2, d(x, 1); "    ";
NEXT x
PRINT #2, CHR$(13);
NEXT a

FOR x = 1 TO 1920
FOR a = 1 TO 12
IF a = 1 THEN x2$(x, a) = STR$(d(x, 1) + ((d(x, 2) - d(x, 1)) * (a / 12)))
NEXT a
NEXT x

FOR a = 1 TO 12
FOR x = 1 TO 1920
PRINT #2, x2$(x, a); "    ";
NEXT x
PRINT #2, CHR$(13);
NEXT a


FOR ya = 1 TO 44

FOR yb = 1 TO 2
FOR x = 1 TO 1920
INPUT #1, d(x, yb)
NEXT x
NEXT yb

FOR x = 1 TO 1920
FOR a = 1 TO 12
x2$(x, a) = STR$(dp(x) + ((d(x, 1) - dp(x)) * (a / 12)))
NEXT a
NEXT x

FOR a = 1 TO 12
FOR x = 1 TO 1920
PRINT #2, x2$(x, a); "    ";
NEXT x
PRINT #2, CHR$(13);
NEXT a


FOR x = 1 TO 1920
FOR a = 1 TO 12
x2$(x, a) = STR$(d(x, 1) + ((d(x, 2) - d(x, 1)) * (a / 12)))
NEXT a
NEXT x

FOR a = 1 TO 12
FOR x = 1 TO 1920
PRINT #2, x2$(x, a); "    ";
NEXT x
PRINT #2, CHR$(13);
NEXT a


FOR x = 1 TO 1920
dp(x) = d(x, 2)
NEXT x


NEXT ya

FOR a = 1 TO 6
FOR x = 1 TO 1920
PRINT #2, d(x, 2); "    ";
NEXT x
PRINT #2, CHR$(13);
NEXT a



PRINT #2, ""
PRINT #2, "Y Trans -----------------------------------"

FOR yb = 1 TO 2
FOR x = 1 TO 1920
INPUT #1, d(x, yb)
dp(x) = d(x, yb)
NEXT x
NEXT yb

FOR a = 6 TO 1 STEP -1
FOR x = 1 TO 1920
PRINT #2, (d(x, 1) - a); "    ";
NEXT x
PRINT #2, CHR$(13);
NEXT a

FOR x = 1 TO 1920
FOR a = 1 TO 12
IF a = 1 THEN x2$(x, a) = STR$(d(x, 1) + ((d(x, 2) - d(x, 1)) * (a / 12)))
NEXT a
NEXT x

FOR a = 1 TO 12
FOR x = 1 TO 1920
PRINT #2, x2$(x, a); "    ";
NEXT x
PRINT #2, CHR$(13);
NEXT a


FOR ya = 1 TO 44

FOR yb = 1 TO 2
FOR x = 1 TO 1920
INPUT #1, d(x, yb)
NEXT x
NEXT yb

FOR x = 1 TO 1920
FOR a = 1 TO 12
x2$(x, a) = STR$(dp(x) + ((d(x, 1) - dp(x)) * (a / 12)))
NEXT a
NEXT x

FOR a = 1 TO 12
FOR x = 1 TO 1920
PRINT #2, x2$(x, a); "    ";
NEXT x
PRINT #2, CHR$(13);
NEXT a


FOR x = 1 TO 1920
FOR a = 1 TO 12
x2$(x, a) = STR$(d(x, 1) + ((d(x, 2) - d(x, 1)) * (a / 12)))
NEXT a
NEXT x

FOR a = 1 TO 12
FOR x = 1 TO 1920
PRINT #2, x2$(x, a); "    ";
NEXT x
PRINT #2, CHR$(13);
NEXT a


FOR x = 1 TO 1920
dp(x) = d(x, 2)
NEXT x


NEXT ya

FOR a = 1 TO 6
FOR x = 1 TO 1920
PRINT #2, (d(x, 2) + a); "    ";
NEXT x
PRINT #2, CHR$(13);
NEXT a


PRINT "Finished"

Fail:
CLOSE #1
CLOSE #2

