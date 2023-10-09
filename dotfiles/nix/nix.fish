if not status is-interactive
  exit
end

# If the user run a nix or hostctl command while in a git repository with untracked files, warn them since those
# files will be ignored by any Nix Flake operation.
#
# TODO: They're considering making this behaviour configurable though. In which case I can remove this.
# issue: https://github.com/NixOS/nix/pull/6858
# issue: https://github.com/NixOS/nix/issues/7107
function _nix-unstaged-files-warning --on-event fish_preexec --argument-names commandline
    set command (string split ' ' -- "$commandline")[1]
    if not string match --regex --quiet -- 'nix' "$command"
    and not string match --regex --quiet -- 'hostctl' "$command"
    and not string match --regex --quiet -- 'home-manager' "$command"
    and not string match --regex --quiet -- 'darwin-rebuild' "$command"
      return
    end

    # Search the current directory and its ancestors for a flake.nix file
    set found_flake 0
    set current_directory (pwd)
    while true
      if test -f "$current_directory/flake.nix"
        set found_flake 1
        break
      end

      set parent_directory (path normalize "$current_directory/..")
      # This will happen when hit the root directory '/'
      if test "$current_directory" = "$parent_directory"
        break
      end
      set current_directory "$parent_directory"
    end

    if test "$found_flake" -eq 0
      return
    end

    # If there are untracked or removed files, warn the user since they'll be ignored by any Nix Flake
    if test -n "$(git ls-files --others --exclude-standard)"
    or test -n "$(git ls-files --deleted --exclude-standard)"
      echo -e -n "\n$(set_color --reverse --bold yellow) WARNING $(set_color normal) THE UNTRACKED/REMOVED FILES IN THIS REPOSITORY WILL BE IGNORED BY ANY NIX FLAKE OPERATION! Press enter to acknowledge:" >/dev/stderr
      read --prompt ''
    end
end
