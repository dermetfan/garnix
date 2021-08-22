{ fetchFromSourcehut, lib }:

import (fetchFromSourcehut {
  owner = "~dermetfan";
  repo = "dermetfan-blog";
  vc = "hg";
  rev = "3be52f3fb523f07592790dded687d7104c5b9359";
  hash = "sha256-zCP9zhkIKnBw4E558UR1vWHGnugejxV0LgLf+ccaraw=";
}) {}
