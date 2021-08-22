{ fetchFromSourcehut, lib }:

import (fetchFromSourcehut {
  owner = "~dermetfan";
  repo = "dermetfan-blog";
  vc = "hg";
  rev = "595cc0b589602e368110d2698b0f5caecfa46f13";
  hash = "sha256-kcrckYMJjj/x1wLPnPaj7OYyCCfgTme7Fi6pJhYg2BQ=";
}) {}
