{ fetchFromSourcehut, lib }:

import (fetchFromSourcehut {
  owner = "~dermetfan";
  repo = "dermetfan-blog";
  vc = "hg";
  rev = "85f85cd2af90089405abe29b2c9e4008a3e09c59";
  hash = "sha256-t5tzeRVMyxkwRM4fccYRFR5rQVxO6kXptj2cxOrnnQc=";
}) {}
