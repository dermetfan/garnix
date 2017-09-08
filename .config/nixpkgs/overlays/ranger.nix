self: super:

{
  ranger = super.ranger.overrideAttrs (oldAttrs: {
    # xterm and variants cause rendering issues...
    makeWrapperArgs = "--set TERM st-256color";
  });
}
