# libch4t
IRC server in nim

for a websocket to tcp proxy have a look at:
- [nimWsToTcp](https://github.com/enthus1ast/nimWsToTcp)

for a web IRC client check out:
- [ch6t](https://github.com/enthus1ast/ch6t)



# Get your IRC server:

edit:
    
    config.nim

compile:
  
    nim c -d:release libch4t_irc.nim

run:
  
    libch4t_irc
    
to get a simple irc server in nim

# features
- user/nick 'login'
- NICK change nick
- JOIN
- PART
- WHO
- NAMES
- PRIVMSG
- PING / PONG
- AWAY
- DUMP # sends some debug info to caller
- DEBUG # echo debug info
- MOTD
- LUSERS
- LIST  # room topics are not yet implemented due the lack of modes
