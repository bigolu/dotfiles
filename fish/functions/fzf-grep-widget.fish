function fzf-grep-widget --description 'Search by line, recursively, from current directory'
  set rg_command 'rg --fixed-strings --column --line-number --no-heading --color=always --smart-case --'
  set choice \
      ( \
        FZF_DEFAULT_COMMAND="$rg_command ''" \
        fzf-tmux -p 100% -B -- \
        # TODO: Gotta wait until tmux has a release the contains the -e flag for popups.
        # PR: https://github.com/tmux/tmux/pull/2924/commits/8b3e46ce24a7948cf928f963d6765a8039cc84a8
        # fzf-tmux -p 100% -B -e "FZF_HINTS=ctrl+v: open in vim" -- \
            --ansi \
            --disabled \
            # we refresh-preview after executing vim in the event that the file gets modified by vim
            --bind "ctrl-v:execute(vim '+call cursor({2},{3})' {1} < /dev/tty > /dev/tty 2>&1)+refresh-preview,change:first+reload:sleep 0.1; $rg_command {q} || true" \
            --delimiter ':' \
            --prompt 'lines: ' \
            --preview-window '+{2}/3' \
            # the minus 2 prevents a weird line wrap issue
            # The head and tail commands are there to remove the first and last line of output of bat
            # i.e. the top and bottom border of bat since I don't like how they look
            --preview 'bat --paging=never --terminal-width (math $FZF_PREVIEW_COLUMNS - 2) {1} --highlight-line {2} | tail -n +2 | head -n -1' \
      )
  or return

  set tokens (string split ':' $choice)
  set filename $tokens[1]
  commandline --insert $filename

  # this should be done whenever a binding produces output (see: man bind)
  commandline -f repaint
end
