#Gitian Builder using Docker images and containers.

##What does this project do?

This project allows you to build software deterministically. It does this by leveraging [Docker](https://docker.io) and [Gitian Builder](https://github.com/devrandom/gitian-builder)

##What are deterministic builds?

Deterministic builds produce final binaries that, when hashed, always produce the same hash for all subsequent builds for a given set of inputs. Of the writing of this README, most all build chains produce binaries non-deterministically. The main reason is the inclusion of time stamps and other meta information into the artifact. The gitian-builder project seeks to remove these differences.

To highlight this issue, if you were to compile bitcoin core from source using [these directions](https://github.com/bitcoin/bitcoin/blob/master/doc/build-unix.md) and then repeat the process a few minutes later and then took a hash of the resulting binaries, they would be different, why? All the same software was used as inputs, Bitcoin itself was pointed to the same tag, what's the problem? The problem is that certain software dependenices of Bitcoin insert meta data like timestamps and file directory paths into the final binary. Therefore, a binary produced at time A will be different than a binary produced at time B. The Debian project has an ambitious project to retroactively patch packages in their archive to enable them to produce deterministic builds. This is a tall order because of the breadth of changes across many packages. Here is the current [status](https://tests.reproducible-builds.org/debian/index_issues.html). Until this project is completed, we need a project such as Gitian-builder and we need source projects to provide Gitian-builder a config file that defines a build script.

###The current challenge
It turns out that distributing software has many security-related challenges. One of the main concerns is protecting software from being _tampered with_ before execution on end-users' computer systems.

Recent news has pointed out a dire [security warning](https://bitcoin.org/en/alert/2016-08-17-binary-safety) highlighting the stakes. It is absolutely imperative that we have easy-to-use tools for detection of malfeasance.

IMPORTANT: Although this project aims to automate and ease the pain of creating deterministic builds, it DOES NOT relinquish its users from understanding exactly what is happening during the build and the construction of the build environment. It is very important to carefully audit the process by which all the relevant pieces come together to produce the final artifact, the manifest files, and the final signature file. It is also important to cultivate your personal [Web of Trust](https://en.wikipedia.org/wiki/Web_of_trust) provided that you decide to share your final manifest and corresponding signature. The degree to which people trust your digital signature lends credibility to offered binaries.

###Real life use case, demonstrating the security challenge

####Example 1

If I, for instance, clone [Bitcoin Core](https://github.com/bitcoin/bitcoin) to my build system and compile an executable to become the basis for my bitcoin wallet, then I am choosing to implicitly trust the following about the source code:

1. It was not tampered with by GitHub company or their agents.
2. It was not tampered with by a third party with back doors into TLS.
3. It was not tampered with by parties that are also installed Certificate Authorities or their agents.
4. That my own build system has not been compromised in any way such that it could affect the security of the final artifact.
5. The dns system used to resolve names to ip addresses hasn't been tampered with.
6. That my internet service provider isn't creating a transparent proxy and performing a man-in-the-middle attack of some kind.
7. There isn't a zero day security flaw in any key software being applied. 

Knowing all of this, I have to decide if it's likely that I will receive software that intends to do me harm.

####Example 2

The Tor Project

In January of 2014, a developer of [The Tor Project](https://www.torproject.org) reported that a keyboard that she purchased from Amazon may have been shipped to a location where it was tampered with. The keyboard finally reached her, but the tracking information [was peculiar](https://twitter.com/puellavulnerata/status/426597381727989760/photo/1). Of course, we can't know for sure what really happened to the keyboard, we'll need to take the Tor developer's word, but the attack vector stands out like a sore thumb. If the keyboard was tampered with, it is a good bet the reason was to capture the signing credentials of a key person on this project. The attacker could offer unsuspecting users software that was tampered with. Even if the users did everything right by using the commonly accepted security checks (e.g. downloading and verifying the signature of the Tor artifacts), the signature would be valid, yet compromised at the same time. Until the developer realized her private keys and passphrases had been compromised, ALL of her users would be at risk. 

###There is safety in numbers
If many people in the community are producing deterministic builds and comparing their results, then the likelihood of _ALL_ builders being compromised is very small. Each builder is tasked with their own code review, on their own system. The more reviewers and builders, the greater confidence in the final result. This docker-based gitian-builder aims to make it easier for people to complete the final build.

Deterministic builds give a great deal of confidence to all users regardless of whether or not they themselves have actually done the deterministic build. For example, if I download a binary package and its corresponding text file containing the digests of all the binaries offered for popular platforms and a signature file for the aforementioned text file (a typical strategy), then I can perform the following actions:

1. Use PGP/GnuPG to verify the signature of the text file containing the hashes/digests of my binary. This proves that the text file with your binary's hash hasn't been tampered with provided you trust the person who signed the text file.
2. Use the same hash function that was used to generate the hash in text file on your downloaded binary and compare the result to the string in the text file. This should prove that your downloaded binary has not been tampered with.

In the case of the Bitcoin Project, you might choose to download the latest version for 64 bit Windows from https://bitcoin.org. You download a file called, bitcoin-0.12.1-win64-setup.exe and then something called "SHA256SUMS.asc" so you can verify signatures. The SHA256SUMS.asc file is a normal text file despite it having a weird 'asc' file extension. If you open this in notepad, you will see SHA256 hashes for all of the Bitcoin binaries offered. Below all of that, you will see the signature, starting with "-----BEGIN PGP SIGNATURE-----". At this point, you can use tools such as [Gpg4Win](https://www.gpg4win.org/) to verify the signature. Gpg4Win can be given the entire SHA256SUMS.asc file as input and it will, most likely, let you know that the signature cannot be verified. The reason for this is that its signer, Wladimir J. van der Laan (Bitcoin Core binary release signing key) at the time of this writing, has no public key installed on your system. Further, if you go out on the Internet and retrieve Wlad's key and repeat the process, you introduce a new set of security concerns:

1. How do you really know what key is really Wlad's key?
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
* The *GOLD STANDARD* for computer security is for you to design and manufacture your own hardware, write every piece of code that runs on your machine and do so all from within a faraday cage and make ZERO security flaws. Good luck with that.
* For the rest of us, Docker's security is only as good as the HOST system's security. If you are using AWS or Azure to do a build, keep in mind that you have no control over the host operating system. You should weigh the chances that your build will be tampered with by things outside of your control.

###Commands to run

```bash
$ docker build -t builder .
$ docker run \
-v `pwd`/cache:/shared/cache \
-v `pwd`/result:/shared/result \
builder [tag] [url] [path to gitian config] 
```
The first command builds the Linux container and sets up all the prerequisites within the container. The second command actually launches the build process and sends the results to standard output. When the final build is complete, you will see a list of hashes and the final artifact names, the following is an example:

> 1924cc6e201e0a1729ca0707e886549593d14eab9cd5acb3798d7af23acab3ae  bitcoin-0.12.1-linux32.tar.gz
> e57e45c1c16f0b8d69eaab8e4abc1b641f435bb453377a0ac5f85cf1f34bf94b  bitcoin-0.12.1-linux64.tar.gz
> 58410f1ad8237dfb554e01f304e185c2b2604016f9c406e323f5a4db167ca758  src/bitcoin-0.12.1.tar.gz
> 09ce06ee669a6f2ae87402717696bb998f0a9a4721f0c5b2d0161c4dcc7e35a8  bitcoin-linux-0.12-res.yml

If you don't specify tag, url, or path to gitian config, then the docker run command will use the defaults located in the Dockerfile 'CMD' value. Keep in mind the 'config' value is a path in the container, not on the host system. The bitcoin directory is located in /shared/bitcoin, this means the config would be in /shared/bitcoin/contrib/gitian-descriptor. You may also use a relative path to the gitian-builder directory. The gitian-builder is located in /shared/gitian-builder, so the config value could be '../bitcoin/contrib/gitian-descriptor/gitian-linux.yml'.

When running the docker build, using '-v host absolute path:/shared/cache' will ensure a build cache is retained across subsequent builds. Subsequently, using '-v host absolute path:/shared/result' will ensure that final manifests and binaries are available to you from your host system. You can leave out the volume information if you don't need to retain a build cache or results. If you do use a shared cache and/or result directory, please ensure it is readable and writeable by the user running the container. Changing ownership for these directories is host operating system specific. For Mac OS X, it is usually sufficient to ensure the user that runs 'docker run' owns cache and result directory and can also write to those directories as well.

###What's next
* Optionally, you may create a digital signature of the resulting output manifest file. 
* This file will be located in your host's shared cache directory results directory. The file's name is: package name-res.yml, where package name will resemble bitcoin-0.12.1-linux64-res.yml

###How to use PGP/GnuPG to sign your manifest file
* Fork the following repository in GitHub and then clone your fork:

> https://github.com/bitpay/gitian.sigs

* Copy your result files into your fork and sign them. The following example would assume your results file was called: bitcoin-linux-0.12-res.yml and it is located in /tmp/result and your forked and cloned gitian.sigs directory is located in /tmp/gitian.sigs and your signing name is 'user'.

```bash
$ git clone https://github.com/user/gitian.sigs /tmp/gitian.sigs
$ mkdir -p /tmp/gitian.sigs/v0.12.1-bitcore-3-linux/user
$ cp /tmp/result/bitcoin-linux-0.12-res.yml !$/bitcoin-linux-0.12-build.assert
$ gpg -b $! 
```

* Add, commit and push your fork back to your repo and submit a merge request against https://github.com/bitpay/gitian.sigs

```bash
$ cd /tmp/gitian.sigs
$ git add . && git commit -m "v0.12.1-bitcore-3"
$ git push origin master
```

##TODO How to audit the build process
