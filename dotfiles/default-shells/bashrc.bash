if shopt -q login_shell; then
  if [ -f ~/.config/default-shells/login-config.sh ]; then
    set -o posix
    # shellcheck source=login-config.sh
    . ~/.config/default-shells/login-config.sh
    set +o posix
  fi
fi

# interactive check
if [ -n "$PS1" ] || [[ $- == *i* ]]; then
  # Set color palette for tty. It is the same as the dark theme I use in my regular terminal.
  if [ "$TERM" = "linux" ]; then
    printf "\e]P0232731"
    printf "\e]P8333745"
    printf "\e]P1BF616A"
    printf "\e]P9BF616A"
    printf "\e]P2A3BE8C"
    printf "\e]PAA3BE8C"
    printf "\e]P3EBCB8B"
    printf "\e]PBEBCB8B"
    printf "\e]P481A1C1"
    printf "\e]PC81A1C1"
    printf "\e]P5B48EAD"
    printf "\e]PD232731"
    printf "\e]P688C0D0"
    printf "\e]PE8FBCBB"
    printf "\e]P7E5E9F0"
    printf "\e]PF626f89"
    clear #for background artifacting
  fi

  # If the current shell isn't fish, use fish in place of bash for an interactive shell.
  #
  # The `-t` checks are to make sure that we are at a terminal because as part of vscode's shell
  # resolution it launches the shell in interactive mode and then I call `exec` which seems to break
  # things so my environment variables don't get setup properly. Alternatively, I could check for the
  # environment variable that vscode sets while doing shell resolution. It is set for scenarios like
  # this. Feature request for setting the variable:
  # https://github.com/microsoft/vscode/issues/163186
  #
  # WARNING: Keep this line at the bottom of the file since nothing after this line will be executed.
  [ -t 0 ] && [ -t 1 ] && [ -t 2 ] && [ "$(basename "$SHELL")" != 'fish' ] && command -v fish >/dev/null 2>&1 && SHELL="$(command -v fish)" exec fish
fi
