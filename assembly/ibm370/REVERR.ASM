        TITLE 'STRING REVERSING IN 360 ASM, REENTRANT'

        COPY REGS
BUFSIZ  EQU    80

REVERS  CSECT
        USING  *,R15               TEMPORAL ADDRESSABILITY VIA R15
        SAVE   (14,12),,REVERR-&SYSDATE-&SYSTIME SAVE REGS
        LR     R12,R15             R12 => PROC. ENTRY POINT
        USING  REVERS,R12          ESTABLISH ADDRESSABILITY
        DROP   R15
        GETMAIN R,LV=LAUTO         GET DYNAMIC STORAGE
        LTR    R15,R15             GETMAIN OK?
        BE     GOTSTG              OK, GO ON
        ABEND  901,DUMP            NO: BLOW UP
GOTSTG  LR     R11,R1              R11=> ADDRESS OF OBTAINED STORAGE
        USING  AUTO,R11            ADDRESSABILITY FOR STORAGE
        LA     R2,SAVEA            GET ADDRESS OF OWN SAVEAREA
        ST     R2,8(,R13)          CHAIN OLD AND...
        ST     R13,SAVEA+4         ... NEW SAVEAREAS
        LR     R13,R2              GET NEW SAVEAREA READY
*
        MVC    OPENCL,MODOPEN      COPY MODEL OPEN PLIST TO REAL ONE
        LA     R2,SYSIN            R2: @SYSIN DCB
        MVC    0(LSYSIN,R2),TSYSIN COPY MODEL SYSIN DCB TO REAL ONE
        OPEN   ((R2),INPUT),MF=(E,OPENCL) OPEN SYSIN
*
        LA     R2,SYSOUT           R2: @SYSOUT DCB
        MVC    0(LSYSOUT,R2),TSYSOUT COPY MODEL SYSOUT DCB...
        OPEN   ((R2),OUTPUT),MF=(E,OPENCL) ... AND OPEN IT
*
        MVC    OUTLINE,ALLBLNK     CLEAN OUTPUT BUFFER
        PUT    SYSOUT,HELLO        PRINT HEADER MESSAGE
LOOP    GET    SYSIN,BUFFIN        READ INPUT LINE (80 CHARS)
        MVC    LABEL,PROMPT        MOVE PROMPT LITERAL TO OUTLINE
        MVC    TEXT,BUFFIN         MOVE READ TEXT TO OUTLINE
        PUT    SYSOUT,OUTLINE      ECHO INPUT LINE
        LA     R2,BUFSIZ-1         R2: CHARACTERS REMAINING - 1
        LA     R4,BUFFIN           R4: BEGIN OF INPUT BUFFER
        AR     R4,R2               R4: LAST CHARACTER IN BUFFER
SKIPB   CLI    0(R4),X'40'         DOES R4 POINT TO A BLANK?
        BNE    DOREV               NO: DO INVERTING
        BCTR   R4,0                MOVE R4 BACKWARDS
        BCT    R2,SKIPB            DECREMENT R2 AND CHECK NEXT
*
REVTPL  MVCIN  0(0,R3),0(R4)       TEMPLATE FOR MOVE INVERSE
*                                  R4 POINTS TO LAST CHAR
*                                  R3 POINTS TO DESTINATION
*
DOREV   MVC    OUTLINE,ALLBLNK     CLEAR OUTPUT BUFFER
        LA     R3,TEXT             R3: BEGIN OF OUTPUT BUFFER
        EX     R2,REVTPL           EXECUTE WITH LENGTH IN R2
*
        MVC    LABEL,INVER         MOVE 'REVERSED...' TO OUTLINE
        PUT    SYSOUT,OUTLINE      DISPLAY INVERTED LINE
        B      LOOP                AND GET A NEW ONE
*
HNDEOF  PUT    SYSOUT,BYE          DISPLAY GOODBYE MESSAGE
*                                  EOF ON SYSIN BRANCHS HERE
*
        LA     R2,SYSIN            R2: @SYSIN DCB
        CLOSE  (R2),MF=(E,OPENCL)  CLOSE INPUT CHANNEL
        LA     R2,SYSOUT           R2: @SYSOUT DCB
        CLOSE  (R2),MF=(E,OPENCL)  CLOSE OUTPUT CHANNEL
*
        L      R13,SAVEA+4         RECOVER CALLER'S SA PTR
        FREEMAIN R,LV=LAUTO,A=(R11) FREE DYNAMIC STORAGE
        DROP   R11                 END ADDRESSABILITY OF DYN AREA
        LM     R14,R12,12(R13)     RECOVER SAVED REGISTERS
        LA     R15,0               CLEAR THE RETURN CODE...
        BR     R14                 ... AND RETURN!

        DS     0F
* LITERALS FOR OUTPUT LINES
ALLBLNK DC     CL(BUFSIZ)' '       ALL-BLANKS LINE FOR CLEANUP
HELLO   DC     CL133' REVERSING STRING PROGRAM'
SPACE   DC     C' '
PROMPT  DC     CL20'ENTERED STRING:    '
INVER   DC     CL20'REVERSED STRING:   '
BYE     DC     CL133' FINISHED'
*
MODOPEN OPEN   (,),MF=L            MODEL FOR OPEN/CLOSE PARMLISTS
* MODEL FOR SYSIN DCB
TSYSIN  DCB    DDNAME=SYSIN,                                           X
               DSORG=PS,                                               X
               MACRF=(GM),                                             X
               EODAD=HNDEOF,                                           X
               EROPT=ACC
* MODEL FOR SYSOUT DCB
TSYSOUT DCB    DDNAME=SYSOUT,                                          X
               RECFM=FBA,                                              X
               DSORG=PS,                                               X
               LRECL=133,                                              X
               MACRF=(PM)
        LTORG

* DYNAMIC STORAGE
AUTO    DSECT
SAVEA   DS     18F                 OWN SAVE AREA
BUFFIN  DS     CL(BUFSIZ)          INPUT BUFFER
OUTLINE DS     0CL133              OUTPUT LINE
        DS     CL1                 CTL
LABEL   DS     CL20                LABEL
TEXT    DS     CL(BUFSIZ)          TEXT
        DS     CL(133-(BUFSIZ+21)) TRAILING
        DS     0F
OPENCL  OPEN   (,),MF=L           OPEN/CLOSE PARMLIB
LOPENCL EQU    *-OPENCL           LENGTH OF PARMLIB
* SYSIN DCB
SYSIN   DCB    DDNAME=SYSIN,                                           X
               DSORG=PS,                                               X
               MACRF=(GM),                                             X
               EODAD=HNDEOF,                                           X
               EROPT=ACC
LSYSIN  EQU    *-SYSIN            LENGTH OF SYSIN DCB
* SYSOUT DCB
SYSOUT  DCB    DDNAME=SYSOUT,                                          X
               RECFM=FBA,                                              X
               DSORG=PS,                                               X
               LRECL=133,                                              X
               MACRF=(PM)
LSYSOUT EQU    *-SYSOUT           LENGTH OF SYSOUT DCB
*
LAUTO   EQU    *-AUTO             LENGTH OF DYNAMIC STORAGE AREA
        END

