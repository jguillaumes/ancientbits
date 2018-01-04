.SUFFIXES: .prg .o .s

TARGET="-tc64"
LDCONFIG="-Cc64-asm.cfg"
LDFLAGS="-u__EXEHDR__"
CL=cl65

.s.prg:
	$(CL) $(TARGET) $(LDCONFIG) $(LDFLAGS) -o $@ -l $*.lst -m $*.map $^

all:	revers.prg hello.prg

revers.prg:	revers.s

hello.prg:	hello.s

clean:
	-@rm hello.prg hello.lst hello.map revers.prg revers.lst revers.map

