# About
 This is a script meant to be used as an interactive layer for the `oathtool`.

# Description
 This script allows one to manage multiple 2FA tokens similar to what `Google Authenticator` does,
but using the bash command line.

# Idea
 The real goal here is to have this script replacing the default shell command of a Unix/Linux user, 
so that user@user can be used as remote interactive terminal tool to manage 2FA tokens on a local/remote server.

 The idea as come up to solve the problem of having only one 2FA authentication method (most often a smartphone with `Google Authenticator` App). So, if for some reason your primary device of authentication (ex: smartphone) is lost or stolen, you still have another way of authenticate (and manage) your internet or enterprise services configured with 2 Factor Authentication, avoiding the hassle of having to regenerate new 2FA secret keys for all services again.

![](images/2fa-authenticator.gif?raw=true)

# WARNING
ATTENTION: LOCAL DATA IS STILL NOT ENCRYPTED! DATA IS STORED IN CLEAR-TEXT INSIDE USER HOME DIR. 
Take the necessary precautions to avoid giving access to other users on the system.

# License
MIT License
(Check LICENSE file for more information)

# Copyright
Hugo Monteiro (c) 2018
