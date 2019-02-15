.PHONY: all kitty
all: kitty

dots_folder = ${HOME}/.dots
config_folder = ${HOME}/.config

dots_folder:
	@echo ">> Setting symlinks for dots folder"
	ln -sfnv ${CURDIR} ${dots_folder}

config_folder:
	@echo ">> Creating ~/.config folder"
	@mkdir -p ${config_folder}

kitty: ${config_folder}/kitty

${config_folder}/kitty: ${dots_folder} ${config_folder}
	@echo "Settings symlink to kitty config"
	@ln -sfnv ${dots_folder}/kitty ${config_folder}/kitty
