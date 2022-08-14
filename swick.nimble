# Package
version       = "0.1.0"
author        = "Rasmus Moorats"
description   = "switch quick - sway window focuser / unfocuser"
license       = "GPL-3.0-or-later"
srcDir        = "src"
bin           = @["swick"]

# Dependencies
requires "nim >= 1.6.6"
requires "swayipc >= 0.1.0"
