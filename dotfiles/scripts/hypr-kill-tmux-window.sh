#!/bin/bash
# Save as ~/scripts/hypr-kill-tmux-window.sh and make executable with chmod +x

# Set up logging
LOG_FILE="/tmp/tmux-kill-debug.log"
exec > >(tee -a "$LOG_FILE") 2>&1
echo "=== Script started at $(date) ===" 

# Get info about the active window
echo "Getting active window info..."
WINDOW_INFO=$(hyprctl activewindow -j)
echo "Window info: $WINDOW_INFO"

# Extract the class and pid
WINDOW_CLASS=$(echo "$WINDOW_INFO" | jq -r '.class')
PID=$(echo "$WINDOW_INFO" | jq -r '.pid')
echo "Window class: $WINDOW_CLASS"
echo "Window PID: $PID"

if [[ "$WINDOW_CLASS" == "kitty" ]]; then
  echo "This is a kitty terminal, checking for tmux processes..."
  
  if [[ "$WINDOW_CLASS" == "floating-terminal" ]]; then
    echo "Skipping kill: this is a project terminal (floating-terminal)"
    hyprctl dispatch killactive
    exit 0
  fi

  # Show process tree for debugging
  echo "Process tree for PID $PID:"
  PROCESS_TREE=$(pstree -pa $PID)
  echo "$PROCESS_TREE"
  
  # Look for tmux client processes - FIXED PATTERN
  echo "Searching for tmux client processes..."
  # The pattern needs to be fixed to match what we see in the logs
  TMUX_CLIENT_LINE=$(echo "$PROCESS_TREE" | grep "tmux: client")
  echo "Found tmux client line: $TMUX_CLIENT_LINE"
  
  # Extract PID using a more reliable method
  if [ ! -z "$TMUX_CLIENT_LINE" ]; then
    TMUX_CLIENT_PID=$(echo "$TMUX_CLIENT_LINE" | grep -o ",[0-9]*" | grep -o "[0-9]*" | head -1)
    echo "Extracted tmux client PID: $TMUX_CLIENT_PID"
    
    if [ ! -z "$TMUX_CLIENT_PID" ]; then
      echo "Tmux client process found with PID $TMUX_CLIENT_PID"
      
      # Find which session this client is attached to
      CLIENT_TTY=$(ps -o tty= -p $TMUX_CLIENT_PID)
      echo "Client TTY: $CLIENT_TTY"
      
      # Get session ID for this client
      TMUX_SESSION_INFO=$(TMUX="" tmux -S /tmp/tmux-$(id -u)/default list-clients -F "#{client_tty} #{session_name}" 2>/dev/null | grep "$CLIENT_TTY" | head -1)
      echo "Tmux session info for this client: $TMUX_SESSION_INFO"
      
      SESSION_TO_KILL=$(echo "$TMUX_SESSION_INFO" | awk '{print $2}')
      echo "Session to kill: $SESSION_TO_KILL"
      
      # Kill tmux client process directly
      echo "Killing tmux client process $TMUX_CLIENT_PID..."
      kill -9 $TMUX_CLIENT_PID
      echo "Client process kill executed"
      
      # Only kill the specific session that was attached to this client
      if [ ! -z "$SESSION_TO_KILL" ]; then
        echo "Killing specific session: $SESSION_TO_KILL"
        TMUX="" tmux -S /tmp/tmux-$(id -u)/default kill-session -t "$SESSION_TO_KILL" 2>&1
      else
        echo "Could not determine which session to kill, not killing any sessions"
      fi
    else
      echo "Could not extract tmux client PID"
    fi
  else
    echo "No tmux client process found for this window"
  fi
else
  echo "Not a kitty terminal, proceeding with normal window close"
fi

# Kill the window through Hyprland
echo "Executing Hyprland killactive command..."
hyprctl dispatch killactive
echo "Script completed at $(date)" 