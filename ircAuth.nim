#
#
#                   libch4t 
#             (c) Copyright 2016 
#          David Krause, Tobias Freitag
#
#    See the file "copying.txt", included in this
#    distribution, for details about the copyright.
#
## Authentication handshake for the IRC Transport

import asyncnet, asyncdispatch
import config
import ircDef
import ircParsing
import ircNetFuncs
import ircHandler
import ircHelper

proc handleIrcAuth*(aClient: Client): Future[Client] {.async.} =
  ## TODO # some code here belongs to the main loop
  ## This does the authentication handshake, atm
  ## Its enough to give valide `user` and `nick` 
  var ircLineIn: IrcLineIn
  var client: Client = aClient
  var line: string = ""
  var pingGood: bool = false
  
  while true:
    try:
      line = await client.socket.recvLine()
      echo "> ", line
    except:
      echo "socket revc line breaks in handleIrcAuth, breaking"
      break

    if line == "":
      echo "line is empty in handleIrcAuth, breaking"
      break

    ircLineIn = parseIncoming(line)
    if ircLineIn.command == TError:
      asyncCheck client.sendToClient(forgeAnswer(newIrcLineOut(SERVER_NAME,TError,@[],"Could not parse line")))
      echo("Could not parse line 33: " & line)
      continue

    hanTUser(client,ircLineIn)
    hanTNick(client,ircLineIn)

    # if client.nick != "" and client.user != "" :
    # echo "The 'valide' username before checking: ", client
    if client.nick.validUserName() and client.user.validUserName():
      # only the first ping is mandatory atm.
      if await client.pingClient():
        echo "ping was answered good"
        pingGood = true
      else:
        echo "ping was answered false"
        pingGood = false
        client.socket.close()

      # if (pingGood == true) and (not clients.isNicknameUsed(client.nick)) and (not clients.isUsernameUsed(client.user)):  ## we check right before we allow the client.....
      if pingGood == true:
        let answer = forgeAnswer(newIrcLineOut(SERVER_NAME,T001,@[client.nick],"Welcome to libch4t irc server, this is a toy please dont't break it"))
        echo "<",answer
        discard await client.sendToClient(answer)
        discard await client.sendToClient(forgeAnswer(newIrcLineOut("NickServ", TNotice, @[client.nick],"Welcome to libch4ts irc transport")))
        discard await client.sendToClient(forgeAnswer(newIrcLineOut("NickServ", TNotice, @[client.nick],"visit "&SERVER_URL&"")))
        echo("Client authenticated successfully: ", client)
        discard client.sendToClient(forgeAnswer(newIrcLineOut(client.nick, TMode, @[client.nick],"+i")))
        client.sendMotd(MOTD) # some clients wants a MOTD
        return client
      else:
        client.socket.close() # TODO do we really have to close the socket here? BREAK FUCK BERAK
  return client # we have to return in any case.