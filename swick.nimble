# Package
version       = "0.1.0"
author        = "Rasmus Moorats"
description   = "switch quick - sway window focuser / unfocuser"
license       = "GPL-3.0-or-later"
srcDir        = "src"
bin           = @["swick"]

# Dependencies
requires "nim >= 1.6.6"
requires "swayipc2 >= 0.1.0"

let outdir = "bin/"
let output = outdir & "swick"

task release, "build binary for release":
  exec "mkdir -p " & outdir
  exec "nim c -d:release --passC:-flto --passL:-flto --passL:-s --opt:speed --mm:orc --passC:-ffast-math -o:" & output & " src/swick.nim"
  echo "built " & output

task clean, "clean workspace":
  exec "rm " & output
  exec "rm -r " & outdir
