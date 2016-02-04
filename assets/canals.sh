#!/bin/bash

_canal_complete() {
  local cur prev

  COMPREPLY=()
  cur=${COMP_WORDS[COMP_CWORD]}
  prev=${COMP_WORDS[COMP_CWORD-1]}

  # Setup the base level (everything after "canal")
  if [ $COMP_CWORD -eq 1 ]; then
    COMPREPLY=( $(compgen \
                  -W "create environment help repo restart session setup start stop" \
                  -- $cur) )
    return 0
  fi

  # Setup the second level
  if [ $COMP_CWORD -eq 2 ]; then
    case "$prev" in
      start|stop|restart)
        COMPREPLY=( $(compgen \
                      -W "`canal list tunnels`" \
                      -- $cur) )
        ;;
      environment)
        COMPREPLY=( $(compgen \
                      -W "create help show" \
                      -- $cur) )
        ;;
      session)
        COMPREPLY=( $(compgen \
                      -W "help restart restore show stop" \
                      -- $cur) )
        ;;
      # Everything else
      *)
        COMPREPLY=( $(compgen \
                      -W "`canal list commands $prev`" \
                      -- $cur) )
        ;;
    esac
    return 0
  fi

  return 0
}
complete -F _canal_complete canal
