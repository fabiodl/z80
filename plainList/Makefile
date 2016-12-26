ASM = ../../wla/wla-dx-master/binaries/wla-z80
LINK= ../../wla/wla-dx-master/binaries/wlalink
PROGNAME = plainList
OBJ = plainList.o ../lib/spaceHarrier.o

$(PROGNAME).sg: $(OBJ) linkfile.$(PROGNAME)
	$(LINK) -drvs linkfile.$(PROGNAME) $(PROGNAME).sms
linkfile.$(PROGNAME): $(OBJ)
	echo [objects]> linkfile.$(PROGNAME)
	echo $(OBJ) | sed -e 's/ /\n/g' >> linkfile.$(PROGNAME)

plainList.o: plainList.asm hexPages.i ../fonts/msxFont.i
	    $(ASM) -o plainList.asm plainList.o

%.o: %.asm 
	$(ASM) -o $< $@ 


clean:
	rm *.o *.sym linkfile.$(PROGNAME)
