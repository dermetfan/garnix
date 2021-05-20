{ fetchFromGitHub, ... }:

(import (fetchFromGitHub {
  owner = "srid";
  repo = "neuron";
  rev = "bfa276ee6eb7b146408e16653b2188d974ee993e";
  sha256 = "00a01yyjzxcznyfapnqxg7hnngv5zlvvaw98m3hg9n8xw4jswy4v";
})).default
