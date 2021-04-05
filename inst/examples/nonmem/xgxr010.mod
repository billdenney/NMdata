$PROBLEM    PK. MISSING COMPARISON OPERATOR IN ACCEPT

$INPUT ROW ID TIME EVID CMT AMT DV FLAG STUDY BLQ CYCLE DOSE NOMTIME
PART PROFDAY PROFTIME WEIGHTB eff0

$DATA ../data/xgxr1.csv IGNORE=@
      ACCEPT=(DOSE 10)

$SUBROUTINE ADVAN4 TRANS4

$PK
KA=THETA(1)*EXP(ETA(1))
V2=THETA(2)*EXP(ETA(2))
CL=THETA(3)*EXP(ETA(3))
V3=THETA(4)*EXP(ETA(4))
Q=THETA(5)*EXP(ETA(5))

$ERROR
  IPRED=F
  IRES=DV-IPRED

  IF (IPRED.GT.1) THEN
    W = SQRT(IPRED**2*SIGMA(1,1)**2 + SIGMA(2,2)**2)
  ELSE
    W=1
  ENDIF

  IWRES=IRES/W
  Y=F+F*ERR(1)+ERR(2)

;-----------------------INITIAL ESTIMATES---------------------------------
$THETA  (0,0.9)           ; POPKA
$THETA  (0,4.2)             ; POPCL
$THETA  (0,3.6)             ; POPV2
$THETA  (0,5.81)             ; POPV3
$THETA  (0,3.44)           ; POPQ 

$OMEGA 0.1
$OMEGA 0.1
$OMEGA 0.1
$OMEGA 0 FIX
$OMEGA 0 FIX

$SIGMA .2
$SIGMA .2

$ESTIMATION METHOD=1 POSTHOC INTER MAXEVAL=9999 NSIG=2 SIGL=9
            PRINT=10 NOABORT


$TABLE KA V2 CL V3 Q IPRED DV FILE=xgxr010_res.txt
