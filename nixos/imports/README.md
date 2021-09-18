This folder is a hack.

Importing the same module multiple times from different modules
results in an error saying the option is already defined.

NixOS does not understand that they are all the same module
if the import is not a path but a function or attribute set
so the duplicate import is not deduped.

Therefore this folder provides wrappers around modules
from flake inputs that can be imported using a path.
