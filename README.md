[![Gem Version](https://badge.fury.io/rb/canals.svg)](https://badge.fury.io/rb/canals)

# Canals: Help manage SSH tunnels

Canals eases the process of creating and managing SSH tunnels.
Behind the scenes, Canals creates SSH tunnels using the standard OpenSSH library, but it helps with making the process more forward and by remembering those tunnels between usages.

### Instalation

```
gem install canals
canal setup wizard
```

### SSH tips
#### Keep Alive
SSH tunnels tend to die after some time. it's sad but true.
but we can do something to try and keep them alive as long as possible.
Edit your `~/.ssh/config` file (and if it doesn't exist, create it)
and add the following 2 lines:
```
Host *
  ServerAliveInterval 60
```
so in the end:
```
$ cat ~/.ssh/config
Host *
  ServerAliveInterval 60

$ chmod 600 ~/.ssh/config
$ chown uesr:group ~/.ssh/config
```
(where user:group is your user:group on your system)
