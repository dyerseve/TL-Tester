# TL-Tester
 
This is a simple powershell that probes a specific path for locations that can run an executable.


If someone gets sloppy with their ThreatLocker rules and allows wildcard executables in a path, this script can find that weakness. You also need the ability to run a powershell script as well, so this does require an established entry point to start with.


Might be good for a blue team to test against some systems.


This was just a proof of concept, other future changes could be to locate executables in the system and attempt to replace them with the malicious file, this can catch out any rules that are simply set to a filename and path, with no checksum, signing or other rules to limit it.
