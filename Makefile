### VARIABLES ###
# Project Basename
PROJ_NAME=$(notdir $(CURDIR))
# Test Harnesses
TB_SRC=$(wildcard *_tb.sv)
# Testing Binaries
TB_BIN=$(subst _tb.sv,_tb,$(TB_SRC))
# Waveform Log Files
LOG=$(wildcard *.vcd)

# Verilog Source Files
SRC=$(wildcard *.v)
SRC_TB=$(wildcard src/*_tb.v)
SRC_SV=$(filter-out $(TB_SRC),$(wildcard *.sv))

### TARGETS ###
.PHONY: all clean test
all: test

# Remove all generated files
clean:
	rm -f $(PROJ_NAME) $(JSON) $(BLIF) $(ASC) $(BIN)

# Create testing binaries with icarus verilog
build_tests: $(TB_BIN)

test: build_tests
	$(foreach bin,$(TB_BIN),./$(bin);)
%_tb: %_tb.sv %.v
	iverilog -g2005-sv -o $@ $^
uart_tb: clk_div.v
