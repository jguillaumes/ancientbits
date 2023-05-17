.SUFFIXES: .prg .o .s

TARGET="-tc64"
LDCONFIG="-Cc64-asm.cfg"
LDFLAGS="-u__EXEHDR__"
CL=cl65

.s.prg:
	$(CL) $(TARGET) $(LDCONFIG) $(LDFLAGS) -o $@ -l $*.lst -m $*.map $^

all:	revers.prg 

revers.prg:	revers.s

clean:
	-@rm revers.prg revers.lst revers.map revers.o

