import std/parseopt
import system
import swayipc2
import swayipc2/[commands, util]

const helpText = """swick - quickly launch or focus/unfocus application

usage: swick -u:use -i:identifier -c:cmd

flags:
  u, use         (default: class) which qualifier to use (app_id, class)
  i, identifier  the window's identifier as per the qualifier
  c, cmd         command to use to launch the application

examples:
  # focus or launch spotify
  swick -u:class -i:Spotify -c:spotify

  # focus or launch obsidian with extra flags, implicitly use class
  swick -i:obsidian -c:'/bin/electron18 /usr/lib/obsidian/app.asar --force-device-scale-factor=1'"""

proc optErr(err: string) {.inline.} =
  echo err & ", bailing"
  echo "run with flag -h for help"
  system.quit(1)

proc parseOpts(): (string, string, string) =
  var use, identifier, cmd: string
  var p = initOptParser()
  while true:
    p.next()
    case p.kind
    of cmdEnd: break
    of cmdArgument:
      optErr("erronous extra argument `" & p.val & "`")
    of cmdShortOption, cmdLongOption:
      if p.key == "h" or p.key == "help":
        echo helpText
        system.quit(0)
      if p.val == "":
        optErr("no value set for flag " & p.key)
      case p.key
      of "u", "use":
        if p.val == "class" or p.val == "app_id":
          use = p.val
        else:
          optErr("unknown use value `" & p.val)
      of "i", "identifier":
        identifier = p.val
      of "c", "cmd":
        cmd = p.val
      else:
        optErr("unknown key and value pair: " & p.key & ", " & p.val)

  if identifier == "":
    optErr("identifier not specified")

  if cmd == "":
    optErr("start-up command not specified")

  if use == "":
    use = "class"

  return (use, identifier, cmd)

## main ##

let (use, identifier, cmd) = parseOpts()

let sway = newSwayConnection()

let tree = sway.get_tree

let nodes =
  if use == "class": tree.filterNodesByClass(identifier, 1)
  else: tree.filterNodesByAppID(identifier, 1)

let sway_cmd =
  if nodes.len == 0: "exec " & cmd
  else:
    let selector = "[" & use & "=" & identifier & "] "
    if nodes[0].focused: selector & "move scratchpad"
    else: selector & "focus"

let ret = sway.run_command(sway_cmd)[0]
sway.close
system.quit(if ret.success: 0 else: 2)
