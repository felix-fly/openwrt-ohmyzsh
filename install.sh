#!/bin/sh

set -e

# Default settings
ZSH=${ZSH:-~/.oh-my-zsh}
REMOTE=${REMOTE:- https://codeload.github.com/ohmyzsh/ohmyzsh/tar.gz/refs/heads/master}

# Other options
CHSH=${CHSH:-yes}
RUNZSH=${RUNZSH:-yes}
KEEP_ZSHRC=${KEEP_ZSHRC:-no}

command_exists() {
	command -v "$@" >/dev/null 2>&1
}

error() {
	echo ${RED}"Error: $@"${RESET} >&2
}

setup_color() {
	# Only use colors if connected to a terminal
	if [ -t 1 ]; then
		RED=$(printf '\033[31m')
		GREEN=$(printf '\033[32m')
		YELLOW=$(printf '\033[33m')
		BLUE=$(printf '\033[34m')
		BOLD=$(printf '\033[1m')
		RESET=$(printf '\033[m')
	else
		RED=""
		GREEN=""
		YELLOW=""
		BLUE=""
		BOLD=""
		RESET=""
	fi
}

setup_ohmyzsh() {
	umask g-w,o-w

	echo "${BLUE}Download Oh My Zsh...${RESET}"

	curl $REMOTE | tar xz -C /tmp > /dev/null || {
		error "Download oh-my-zsh failed"
		exit 1
	}
	mv /tmp/ohmyzsh-master $ZSH

	# replace upgrade.sh
	curl https://raw.githubusercontent.com/felix-fly/openwrt-ohmyzsh/master/upgrade.sh > ${ZSH}/tools/upgrade.sh
	# patch to check_for_upgrade.sh
	sed -i '/command git.*/d' "${ZSH}/tools/check_for_upgrade.sh"

	echo
}

setup_zshrc() {
	# Keep most recent old .zshrc at .zshrc.pre-oh-my-zsh, and older ones
	# with datestamp of installation that moved them aside, so we never actually
	# destroy a user's original zshrc
	echo "${BLUE}Looking for an existing zsh config...${RESET}"

	# Must use this exact name so uninstall.sh can find it
	OLD_ZSHRC=~/.zshrc.pre-oh-my-zsh
	if [ -f ~/.zshrc ] || [ -h ~/.zshrc ]; then
		# Skip this if the user doesn't want to replace an existing .zshrc
		if [ $KEEP_ZSHRC = yes ]; then
			echo "${YELLOW}Found ~/.zshrc.${RESET} ${GREEN}Keeping...${RESET}"
			return
		fi
		if [ -e "$OLD_ZSHRC" ]; then
			OLD_OLD_ZSHRC="${OLD_ZSHRC}-$(date +%Y-%m-%d_%H-%M-%S)"
			if [ -e "$OLD_OLD_ZSHRC" ]; then
				error "$OLD_OLD_ZSHRC exists. Can't back up ${OLD_ZSHRC}"
				error "re-run the installer again in a couple of seconds"
				exit 1
			fi
			mv "$OLD_ZSHRC" "${OLD_OLD_ZSHRC}"

			echo "${YELLOW}Found old ~/.zshrc.pre-oh-my-zsh." \
				"${GREEN}Backing up to ${OLD_OLD_ZSHRC}${RESET}"
		fi
		echo "${YELLOW}Found ~/.zshrc.${RESET} ${GREEN}Backing up to ${OLD_ZSHRC}${RESET}"
		mv ~/.zshrc "$OLD_ZSHRC"
	fi

	echo "${GREEN}Using the Oh My Zsh template file and adding it to ~/.zshrc.${RESET}"

	sed "/^export ZSH=/ c\\
export ZSH=\"$ZSH\"
" "$ZSH/templates/zshrc.zsh-template" > ~/.zshrc-omztemp
	mv -f ~/.zshrc-omztemp ~/.zshrc

	echo
}

setup_shell() {
	# Skip setup if the user wants or stdin is closed (not running interactively).
	if [ $CHSH = no ]; then
		return
	fi

	# If this user's login shell is already "zsh", do not attempt to switch.
	if [ "$(basename "$SHELL")" = "zsh" ]; then
		return
	fi

	# If this platform doesn't provide a "chsh" command, bail out.
	if ! command_exists chsh; then
		cat <<-EOF
			I can't change your shell automatically because this system does not have chsh.
			${BLUE}Please manually change your default shell to zsh${RESET}
		EOF
		return
	fi

	echo "${BLUE}Time to change your default shell to zsh:${RESET}"

	# Prompt for user choice on changing the default login shell
	printf "${YELLOW}Do you want to change your default shell to zsh? [Y/n]${RESET} "
	read opt
	case $opt in
		y*|Y*|"") echo "Changing the shell..." ;;
		n*|N*) echo "Shell change skipped."; return ;;
		*) echo "Invalid choice. Shell change skipped."; return ;;
	esac

	# Check if we're running on Termux
	case "$PREFIX" in
		*com.termux*) termux=true; zsh=zsh ;;
		*) termux=false ;;
	esac

	if [ "$termux" != true ]; then
		# Test for the right location of the "shells" file
		if [ -f /etc/shells ]; then
			shells_file=/etc/shells
		elif [ -f /usr/share/defaults/etc/shells ]; then # Solus OS
			shells_file=/usr/share/defaults/etc/shells
		else
			error "could not find /etc/shells file. Change your default shell manually."
			return
		fi

		# Get the path to the right zsh binary
		# 1. Use the most preceding one based on $PATH, then check that it's in the shells file
		# 2. If that fails, get a zsh path from the shells file, then check it actually exists
		if ! zsh=$(which zsh) || ! grep -qx "$zsh" "$shells_file"; then
			if ! zsh=$(grep '^/.*/zsh$' "$shells_file" | tail -1) || [ ! -f "$zsh" ]; then
				error "no zsh binary found or not present in '$shells_file'"
				error "change your default shell manually."
				return
			fi
		fi
	fi

	# We're going to change the default shell, so back up the current one
	if [ -n "$SHELL" ]; then
		echo $SHELL > ~/.shell.pre-oh-my-zsh
	else
		grep "^$USER:" /etc/passwd | awk -F: '{print $7}' > ~/.shell.pre-oh-my-zsh
	fi

	# Actually change the default shell to zsh
	if ! chsh -s "$zsh"; then
		error "chsh command unsuccessful. Change your default shell manually."
	else
		export SHELL="$zsh"
		echo "${GREEN}Shell successfully changed to '$zsh'.${RESET}"
	fi

	echo
}

main() {
	# Run as unattended if stdin is closed
	if [ ! -t 0 ]; then
		RUNZSH=no
		CHSH=no
	fi

	# Parse arguments
	while [ $# -gt 0 ]; do
		case $1 in
			--unattended) RUNZSH=no; CHSH=no ;;
			--skip-chsh) CHSH=no ;;
			--keep-zshrc) KEEP_ZSHRC=yes ;;
		esac
		shift
	done

	setup_color

	if ! command_exists zsh; then
		echo "${YELLOW}Zsh is not installed.${RESET} Please install zsh first."
		exit 1
	fi

	if [ -d "$ZSH" ]; then
		cat <<-EOF
			${YELLOW}You already have Oh My Zsh installed.${RESET}
			You'll need to remove '$ZSH' if you want to reinstall.
		EOF
		exit 1
	fi

	setup_ohmyzsh
	setup_zshrc
	setup_shell

	# Keep or remove plugins
	read -r -p "Keep plugins(about 5M)? [y/N] " input
	case $input in
		[yY][eE][sS]|[yY])
			echo "Yes"
			;;
		*)
			echo "No"
			rm -rf "${ZSH}/plugins"
			sed -i '/^plugins=.*/d' ~/.zshrc
			;;
	esac

	printf "$GREEN"
	cat <<-'EOF'
		         __                                     __
		  ____  / /_     ____ ___  __  __   ____  _____/ /_
		 / __ \/ __ \   / __ `__ \/ / / /  /_  / / ___/ __ \
		/ /_/ / / / /  / / / / / / /_/ /    / /_(__  ) / / /
		\____/_/ /_/  /_/ /_/ /_/\__, /    /___/____/_/ /_/
		                        /____/                       ....is now installed!


		Please look over the ~/.zshrc file to select plugins, themes, and options.

		p.s. Follow us on https://twitter.com/ohmyzsh

		p.p.s. Get stickers, shirts, and coffee mugs at https://shop.planetargon.com/collections/oh-my-zsh

	EOF
	printf "$RESET"

	if [ $RUNZSH = no ]; then
		echo "${YELLOW}Run zsh to try it out.${RESET}"
		exit
	fi

	exec zsh -l
}

main "$@"
