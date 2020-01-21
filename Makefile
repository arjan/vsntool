all:
	mix clean && mix escript.build

local_install:
	@cp ./vsntool $$(which vsntool)
	@echo
	@echo "Installed to $$(which vsntool)"
