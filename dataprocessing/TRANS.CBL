01  TRANS.
    03 TCODE                 PIC XX.
    03 TTEXT                 PIC X(84).
    03 LPDATA REDEFINES TTEXT.
       05 LPID               PIC XXXX.
       05 LPNAME             PIC X(40).
       05 LPARTIST           PIC X(40).
    03 TRACKDATA REDEFINES TTEXT.
       05 FILLER             PIC XXXX.
       05 TRACKNUM           PIC XX.
       05 TRACKNAME          PIC X(40).
       05 TRACKSECONDS       PIC 99999.
