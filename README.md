# functorOS

A highly experimental NixOS-based Linux distribution, maintained by the
functor.systems community.

We believe functorOS is now suitable for daily use by curious users. It ships a
curated Niri + Dank Linux desktop environment. Please see [the project
wiki](https://code.functor.systems/functor.systems/functorOS/wiki) for more
details.

Also, every functorOS machine can be deployed as a [MIT
Athena](https://en.wikipedia.org/wiki/Project_Athena) workstation via the
bundled [nixathena](https://forgejo.mit.edu/SIPB/nixathena). Not sure why you'd
like to do this, but you certainly can.

See [os.functor.systems](https://os.functor.systems/) for functorOS module
options.

## Try it

functorOS is ready for power users to test drive. You first need to install
NixOS on your desired machine. To install functorOS, run the following command
and look inside `flake.nix`, containing a minimal self-documenting configuration
for functorOS.

```sh
nix flake init -t "git+https://code.functor.systems/functor.systems/functorOS"
```

## Reference implementations

- Minimal template --- see [Try it](#try-it).
- @youwen --- [shezhi](https://code.functor.systems/youwen/shezhi). An advanced
  functorOS deployment featuring multiple hosts, additional flake inputs, custom
  configurations, and secret management.
- @q9i --- [netsanet](https://code.functor.systems/q9i/netsanet). A simple single-host functorOS deployment optimized for daily use on generic laptops, with special support for NVIDIA GPU settings and high performance computing
