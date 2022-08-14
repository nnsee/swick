import osproc
import std/parseopt
import system
import json
import swayipc
import swayipc/[commands, util]

proc parseOpts(): (string, string, string) =
  var use, identifier, cmd: string
  var p = initOptParser()
  while true:
    p.next()
    case p.kind
    of cmdEnd: break
    of cmdArgument:
      echo "erronous extra argument `", p.val, "`, bailing"
      system.quit(1)
    of cmdShortOption, cmdLongOption:
      if p.val == "":
        echo "no value set for flag ", p.key, ", bailing"
        system.quit(1)
      case p.key
      of "u", "use":
        if p.val == "class" or p.val == "app_id":
          use = p.val
        else:
          echo "unknown use value `", p.val, "`, bailing"
          system.quit(1)
      of "i", "identifier":
        identifier = p.val
      of "c", "cmd":
        cmd = p.val
      else:
        echo "unknown key and value pair: ", p.key, ", ", p.val
        system.quit(1)

  if identifier == "":
    echo "identifier not specified, bailing"
    system.quit(1)

  if cmd == "":
    echo "start-up command not specified, bailing"
    system.quit(1)

  if use == "":
    echo "use flag not specified, assuming class"
    use = "class"

  return (use, identifier, cmd)

proc filter_dict(j: JsonNode, key: string, value: string): seq[JsonNode] =
  ## Filter dict by key and value
  result = @[]
  case j.kind
  of JObject:
    for k, v in pairs j:
      if k == key and v.getStr() == value:
        result.add j
      else:
        result.add filter_dict(v, key, value)
  of JArray:
    for i in j:
      result.add filter_dict(i, key, value)
  else:
    discard

## main ##

let (use, identifier, cmd) = parseOpts()

let sway = newSwayConnection()

let tree = sway.get_tree

let nodes =
  if use == "class": tree.filterNodesByClass(identifier, 1)
  else: tree.filterNodesByAppID(identifier, 1)

if nodes.len == 0:
  sway.close
  system.quit(cmd.execCmd)

let selector = "[" & use & "=" & identifier & "] "

if nodes[0].focused == false:
  discard sway.run_command(selector & "focus")
else:
  discard sway.run_command(selector & "move scratchpad")

sway.close
