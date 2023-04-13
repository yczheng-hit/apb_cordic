all: compile sim

compile:
	vcs -full64 -cpp g++-4.8 -cc gcc-4.8 -LDFLAGS -Wl,--no-as-needed -sverilog -timescale=1ns/1ns \
	-debug_all -fsdb \
	-l com.log \
	+v2k \
	-LDCLASS -rdynamic -P $(VERDI_HOME)/share/PLI/VCS/LINUX64/novas.tab \
	${VERDI_HOME}/share/PLI/VCS/LINUX64/pli.a \
	-f ./file.list \

sim:
	./simv -ucli -i dump_fsdb.tcl	\
	+fsdb+autofulsh 	\
	-l sim.log

verdi:
	verdi \
	-sv \
	-f ./file.list \
	-nologo \
	-ssf test.fsdb

clean:
	rm -rf *.vpd csrc *.log *.key *.vdb simv* DVEfiles coverage *.fsdb verdiLog *.rc *.conf
