#Gitian Builder using Docker images and containers.

##What does this project do?

This project allows you to build/compile software deterministically. It does this by leveraging [Docker](https://docker.io) and [Gitian Builder](https://github.com/devrandom/gitian-builder)

##What are deterministic builds?

###The current challenge
It turns out that distributing software has many security-related challenges. One of the main concerns addressed by this project is protecting software from being _tampered with_ between the time source code is audited and the time when the software is copied, compiled, assembled, linked and finally executed on end-users' systems.

Recent news has pointed out a dire [security warning](https://bitcoin.org/en/alert/2016-08-17-binary-safety) highlighting the stakes. It is absolutely imperative that we have easy-to-use tools for detection of malfeasance.

IMPORTANT: Although this project aims to automate and ease the pain of creating deterministic builds, it DOES NOT relinquish its users from understanding exactly what is happening during the build and the construction of build environment. It is very important to carefully audit the process by which all the relevant pieces come together to produce the final artifact, the manifest files, and the final signature file. It is also important to culivate your personal [Web of Trust](https://en.wikipedia.org/wiki/Web_of_trust) provided that you decide to share your final manifest and corresponding signature. The degree to which people trust your digital signature lends credibility to offered binaries.

###Real life use case, demostrating the security challenge

If I, for instance, clone [Bitcoin Core](https://github.com/bitcoin/bitcoin) on to my build system and compile an executable to become the basis for my bitcoin wallet, then I am choosing to implicitly trust the following:

1. That the software code that I downloaded was not tampered with by GitHub company or their agents.
2. That the software was not tampered with by a third party with back doors into TLS.
3. That the software was not tampered with by parties that are also installed Certificate Authorities or their agents.
4. That my own build system has not been compromised in any way such that it could affect the security of the final artifact.
5. Other threats that are unknown.

Deterministic builds produce final binaries that, when hashed, always produce the same hash on all subsequent builds for a given set of inputs. Of the writing of this README, most all build chains produce binaries non-deterministically. The main reason is the inclusion of time stamps and other meta information into the artifact. The gitian-builder project seeks to remove these differences.

###There is safety in numbers
If many people in the community are producing deterministic builds and comparing their results, then the likelihood of _ALL_ builders being compromised is very small. Each builder is tasked with their own code review, on their own system. The more reviewers and builders, the greater confidence in the final result. This docker-based gitian-builder aims to make it easier for people to complete the final build.

Deterministic builds give a great deal of confidence to all users regardless of whether or not they themselves have actually done the deterministic build. For example, if I download a binary package and its corresponding text file containing the digests of all the binaries offered for popular platforms and a signature file for the aforementioned text file (a typical strategy), then I can perform the following actions:

1. Use PGP/GnuPG to verify the signature of the text file containing the hashes/digests of my binary. This proves that the text file with your binary's hash hasn't been tampered with provided you trust the person who signed the text file.
2. Use the same hash function that was used to generate the hash in text file on your downloaded binary and compare the result to the string in the text file. This should prove that your downloaded binary has not been tampered with.

In the case of the Bitcoin Project, you might choose to download the latest version for 64 bit Windows from https://bitcoin.org. You download a file called, bitcoin-0.12.1-win64-setup.exe and then something called "SHA256SUMS.asc" so you can verify signatures. The SHA256SUMS.asc file is a normal text file despite it having a weird 'asc' file extension. If you open this in notepad, you will see SHA256 hashes for all of the Bitcoin binaries offered. Below all of that, you will see the signature, starting with "-----BEGIN PGP SIGNATURE-----". At this point, you can use tools such as [Gpg4Win](https://www.gpg4win.org/) to verify the signature. Gpg4Win can be given the entire SHA256SUMS.asc file as input and it will, most likely, let you know that the signature cannot be verified. The reason for this is that its signer, Wladimir J. van der Laan (Bitcoin Core binary release signing key) at the time of this writing, has no public key installed on your system. Further, if you go out on the Internet and retrieve Wlad's key and repeat the process, you introduce a new set of security concerns:

1. How do you really know that is Wlad's key?
2. Who is Wlad anyway?
3. Why should you trust this person?
4. Have any people that you trust signed this key?
5. Does Wlad still have custody of his private key that signed SHASUMS.asc?

All unknowns. Under the circumstances, you have to take a risk that Wlad's signature is good to go. But, if you complete your own deterministic build of Bitcoin, you can simply compare the hashes in SHA256SUMS.asc directly.

##How to use this project?

###Prerequisites
* Mac, Windows, Linux, AWS, Azure that can run Docker, see [Docker](https://www.docker.com/products/overview)
* Docker itself

###Security concerns
* Docker's security is only as good as the HOST system's security. If you are using AWS or Azure to do a build, keep in mind you have very no control over the hypervisor (host operating system). You should weigh the chances that your build will be tampered with by things outside of your control.
* The GOLD STANDARD for computer security in this realm is for you to design, procure materials, manufacture your own hardware, write every piece of code that runs on your machine, all from within a faraday cage and make ZERO security flaws while doing so. Good luck with that.

