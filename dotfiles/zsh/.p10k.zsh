# Powerlevel10k configuration file
# To customize prompt, run `p10k configure` or edit this file.

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Basic configuration for a clean, fast prompt
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
  dir
  vcs
  newline
  prompt_char
)

typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
  status
  command_execution_time
  background_jobs
  virtualenv
  context
  time
)

# Instant prompt mode
typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose

# Show command execution time when it takes longer than 3 seconds
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3

# Directory configuration
typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1

# Git status configuration
typeset -g POWERLEVEL9K_VCS_BACKENDS=(git)

# Colors
typeset -g POWERLEVEL9K_DIR_FOREGROUND=39
typeset -g POWERLEVEL9K_VCS_FOREGROUND=76

# Icons
typeset -g POWERLEVEL9K_MODE=nerdfont-complete

# Tell `p10k configure` which file it should overwrite.
typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a} 