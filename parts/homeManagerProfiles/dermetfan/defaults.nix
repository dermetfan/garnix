{ self, ... }:

{
  imports = with self.outputs.homeManagerProfiles; [
    defaults
  ];
}
