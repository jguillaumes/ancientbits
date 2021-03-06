        TITLE 'STRING REVERSING IN 360 ASM USING MVCIN'

        COPY REGS
BUFSIZ  EQU    80

REVERS  CSECT
        SAVE   (14,12)             SAVE GPRS IN PARENT SAVEAREA
        BALR   R12,0               GET BASE ADDRESS IN R12
        USING  *,R12
        LA     R2,SAVEA            GET ADDRESS OF OWN SAVEAREA
        ST     R2,8(,R13)          CHAIN OLD AND...
        ST     R13,SAVEA+4         ... NEW SAVEAREAS
        LR     R13,R2              GET NEW SAVEAREA READY
*
        OPEN   (SYSIN,(INPUT))     OPEN SYSIN
        OPEN   (SYSOUT,(OUTPUT))   OPEN SYSOUT
*
        PUT    SYSOUT,HELLO        PRINT HEADER MESSAGE
LOOP    GET    SYSIN,BUFFIN        READ INPUT LINE (80 CHARS)
        PUT    SYSOUT,INLINE       ECHO INPUT LINE
        MVC    BUFOUT,ALLBLNK      CLEAN OUTPUT BUFFER
        LA     R2,BUFSIZ-1         R2: CHARACTERS REMAINING - 1
        LA     R4,BUFFIN
        AR     R4,R2               R4: CHARACTER TO CHECK
SKIPB   CLI    0(R4),X'40'         DOES R2 POINT TO A BLANK?
        BNE    DOREV               NO: START INVERTING
        BCTR   R4,0
        BCT    R2,SKIPB            YES: SKIP CHARACTER
*
REVTPL  MVCIN  0(0,R3),0(R4)       TEMPLATE FOR MOVE INVERSE
*                                  R4 POINTS TO LAST CHAR => FIRST
DOREV   LA     R3,BUFOUT           R3: BEGIN OF OUTPUT BUFFER
        EX     R2,REVTPL           EXECUTE WITH LENGHT R2
*
        PUT    SYSOUT,OUTLINE      DISPLAY INVERTED LINE
        B      LOOP                AND GET A NEW ONE
*
HNDEOF  PUT    SYSOUT,BYE          DISPLAY GOODBYE MESSAGE
*
        L      R13,SAVEA+4         RECOVER CALLER'S SA PTR
        LM     R14,R12,12(R13)     RECOVER SAVED REGISTERS
        LA     R15,0               CLEAR THE RETURN CODE...
        BR     R14                 ... AND RETURN!

        DS     0F
SAVEA   DS     18F         OWN SAVE AREA
ALLBLNK DC     CL(BUFSIZ)' '
HELLO   DC     CL133' REVERSING STRING PROGRAM'
INLINE  DS     0CL133
SPACE   DC     C' '
PROMPT  DC     CL20'ENTERED STRING:    '
BUFFIN  DC     CL(BUFSIZ)' '
        DC     CL(133-(BUFSIZ+21))' '
OUTLINE DS     0CL133
        DC     C' '
INVER   DC     CL20'REVERSED STRING:   '
BUFOUT  DC     CL(BUFSIZ)' '
        DC     CL(133-(BUFSIZ+21))' '
BYE     DC     CL133' FINISHED'
*
SYSIN   DCB    RECFM=F,                                                X
               DSORG=PS,                                               X
               LRECL=BUFSIZ,                                           X
               MACRF=(GM),                                             X
               EODAD=HNDEOF,                                           X
               EROPT=ACC,                                              X
               DDNAME=SYSIN
SYSOUT  DCB    RECFM=FBA,                                              X
               DSORG=PS,                                               X
               LRECL=133,                                              X
               MACRF=(PM),                                             X
               DDNAME=SYSOUT
        LTORG
        END

