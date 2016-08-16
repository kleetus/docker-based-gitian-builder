#Gitian Builder using Docker images and containers.

##What does this project do?

This project allows you to build/compile Bitcoin deterministically. It does this by leveraging [Docker](https://docker.io) and [Gitian Builder](https://github.com/devrandom/gitian-builder) 

##What are deterministic builds?

###The current challenge
It turns out that distributing software has many security-related challenges. One of the main concerns addressed by this project and its dependencies is protecting software from being tampered with between the time source code is audited and the time when the software is copied, compiled, assembled, linked and finally executed on end-users' systems. 

If I, for instance, clone [Bitcoin Core](https://github.com/bitcoin/bitcoin) on to my build system and compile an executable to become the basis for my bitcoin wallet, then I am choosing to implicitly trust the following: 

1. That the software code that I downloaded was not tampered with by GitHub company or their agents.
2. That the software was not tampered with by a third party with back doors into TLS.
3. That the software was not tampered with by parties that are also installed Certificate Authorities or their agents.
4. That my own build system has not been compromised in any way such that it could affect the security of the final artifact.

Deterministic builds produce final binaries that, when hashed, always produce the same hash for a given set of imputs. Of the writing of this README, most all build chains produce binaries non-deterministically. The main reason is the inclusion of time stamps and other meta information into the artifact. The gitian-builder project seeks to remove these differences. 

###There is safety in numbers 
If many people in the community are producing deterministic builds and comparing their results, then the likelihood of ALL builders being compromised is very small. Each builder is tasked with their own code review, on their own system. The more reviewers and builders, the greater confidence in the final result. This docker-based gitian-builder aims to make it easier for people to complete the final build.

Deterministic builds give a great deal of confidence to all users regardless of whether or not they themselves have actually done the deterministic build. If I, for example, have not completed a deterministic build, yet someone in my web of trust HAS completed the build, then I have a great deal of confidence that my binary has not been tampered with. 

##How to use this project?

###Prerequisites
* Mac, Windows, Linux, AWS, Azure that can run Docker, see [Docker](https://www.docker.com/products/overview)
* Docker itself
* A shared folder on the host (the base system that runs Docker)

