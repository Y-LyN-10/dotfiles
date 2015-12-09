#!/bin/sh 
tmux new-session -d 'monitoring'
tmux split-window -v 'pm2 logs'
tmux split-window -h 
tmux new-window -h
tmux split-window -v 'pm2 monit'
tmux new-window -h
tmux -2 attach-session -d 