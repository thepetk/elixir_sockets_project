default:
	@echo "\nVeturilo Elixir Ingest make commands\n"
	@echo "Commands available:\n"
	@echo "    make install # Installs all necessary requirements."
	@echo "    make run		# Starts a mix development server with local variables."
	
install:
	mix deps.get
	mix compile
	mix ecto.migrate

run:
	mix run --no-halt