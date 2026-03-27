# ==========================================
# cpanel Build Script
# ==========================================

SRC = cpanel.sh
OUT = cpanel
INSTALL_DIR = ~/.local/bin

.PHONY: all clean install uninstall

all: $(OUT)

$(OUT): $(SRC)
	@echo "Creating executable $(OUT) from $(SRC)..."
	@cp $(SRC) $(OUT)
	@chmod +x $(OUT)
	@echo "Build complete. Executable generated: $(OUT)"

install: $(OUT)
	@echo "Installing $(OUT) to $(INSTALL_DIR)..."
	@mkdir -p $(INSTALL_DIR)
	@cp $(OUT) $(INSTALL_DIR)/
	@chmod +x $(INSTALL_DIR)/$(OUT)
	@echo "Installation successful. Make sure $(INSTALL_DIR) is in your PATH."

uninstall:
	@echo "Uninstalling $(OUT) from $(INSTALL_DIR)..."
	@rm -f $(INSTALL_DIR)/$(OUT)
	@echo "Uninstalled successfully."

clean:
	@echo "Cleaning up build environment..."
	@rm -f $(OUT)
	@echo "Cleanup complete."
