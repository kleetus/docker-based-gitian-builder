# Gitian Builder using Docker images and containers.

## TL;DR / Executive Summary

1. Install [docker](https://docker.io) for your platform
2. Clone or fork [this](https://github.com/kleetus/docker-based-gitian-builder) GH repo
3. Ensure docker daemon is operating by starting the application. You should be able to run 'docker' at the command line without error.
4. Building for Mac requires [this step](#building-binaries-for-mac-os-x) to be completed
5. Run the convenience scripts in this repo:

For building Bitcoin for ALL platforms and architectures in one command:
```bash
$ bash build_all_the_things.sh # optionally include a branch/tag and repo url e.g. bash build_all_the_things segwit2x https://github.com/btc1/bitcoin
```
Once complete, proceed to [step 8](#step8).

For building individual platforms:
```bash
$ bash ./build_builder.sh # installs the base virtual machine (ubuntu 12.04 trusty) and dependencies, takes 5-10 minutes
$ bash ./run_builder.sh # builds bitcoin itself per the argument to the CMD instruction in Dockerfile, takes 30+ minutes
```

Repeat the process for Windows and MacOSX targets (these will take less time because common dependencies are cached):

5. Edit the Dockerfile:

```bash
$ nano Dockerfile # use a text editor that you are comfortable with
```

6. Change the gitian descriptor in the 'CMD' line (it might say ../bitcoin/contrib/gitian-descriptors/gitian-linux.yml currently) to: ../bitcoin/contrib/gitian-descriptors/gitian-osx.yml or ../bitcoin/contrib/gitian-descriptors/gitian-win.yml
7. Save the file and rerun:

```bash
$ bash remove_all_containers.sh # this will remove all stopped/exited containers
$ bash build_builder.sh
$ bash run_builder.sh
```

Please note that you will need the Mac development SDK in order to build for Mac. Please see the sections [below](#mac_sdk) about how to get that tarball.

The end result is that you will have a manifest and build artifacts/binaries in the directory 'result/out'.

<a name="step8"></a>8. Fork [gitian.sigs](https://github.com/btc1/gitian.sigs)

9. Use the convenience script to add your manifest files and sign them:

```bash
$ bash move_and_sign_manifest.sh
```

10. Sign the yml manifest if you have a gpg key setup for yourself (if not skip this step and go to step 13 to compare manifests):

```bash
$ gpg -b gitian.sigs/<version>/<name>/<manifest yml>
```

11. You should have 2 files in the manifest directory, the manifest itself, e.g. `bitcoin-linux-#.#.#.yml`, and the detached digital signature, e.g. `bitcoin-linux-#.#.#.yml.sig`.
12. Commit those directories back to your fork and create a merge request against the master branch of the original project.
13. If there are other gitian builds done prior to yours, for the same version, compare your manifest file to theirs. They should be the same set of hashes.
14. All the binaries built during this process are located in result/out.
15. To cleanup all files created during this process:

```bash
$ bash remove_all_containers.sh
$ bash remove_all_images.sh
$ rm -fr cache/* result/*
```


## What does this project do?

This project allows you to build software deterministically. In other words, each time a given set application is compiled, the resulting program should be the same no matter where, when or by whom the task was completed. You would think this would already be the case, but there are a few issues preventing it. The reasons for this aren't super important, but the consequences of not being able to match your software to everyone else's software ARE VERY IMPORTANT. This project seeks to mitigate those consequences (see the real life use case section). It does this by leveraging [Docker](https://docker.io) and [Gitian Builder](https://github.com/devrandom/gitian-builder).

## What are deterministic/reproducible builds?

Deterministic builds produce final binaries that, when hashed, always produce the same hash for all subsequent builds for a given set of inputs. Of the writing of this README, most all build chains produce binaries non-deterministically. The main reason is the inclusion of time stamps and other meta information into the artifact. The gitian-builder project seeks to remove these differences.

To highlight this issue, if you were to compile bitcoin core from source using [these directions](https://github.com/bitcoin/bitcoin/blob/master/doc/build-unix.md) and then repeat the process a few minutes later and then took a hash of the resulting binaries, they would be different, why? All the same software was used as inputs, Bitcoin itself was pointed to the same tag, what's the problem? The problem is that certain software dependenices of Bitcoin insert meta data like timestamps and file directory paths into the final binary. Therefore, a binary produced at time A will be different than a binary produced at time B. The Debian project has an ambitious project to retroactively patch packages in their archive to enable them to produce deterministic builds. This is a tall order because of the breadth of changes across many packages. Here is the current [status](https://tests.reproducible-builds.org/debian/index_issues.html). Until this project is complete, we need a project such as this one.

### The current challenge
It turns out that distributing software has many security-related challenges. One of the main concerns is protecting software from being _tampered with_ before execution on end-users' computer systems.

Recent news has pointed out a dire [security warning](https://bitcoin.org/en/alert/2016-08-17-binary-safety) highlighting the stakes. It is absolutely imperative that we have easy-to-use tools for detection of malfeasance.

IMPORTANT: Although this project aims to automate and ease the pain of creating deterministic builds, it DOES NOT relinquish its users from understanding exactly what is happening during the build and the construction of the build environment. It is very important to carefully audit the process by which all the relevant pieces come together to produce the final artifact, the manifest files, and the final signature file. It is also important to cultivate your personal [Web of Trust](https://en.wikipedia.org/wiki/Web_of_trust) provided that you decide to share your final manifest and corresponding signature. The degree to which people trust your digital signature lends credibility to offered binaries.

### Real life use case, demonstrating the security challenge

#### Example 1

For instance, If I clone [Bitcoin Core](https://github.com/bitcoin/bitcoin) to my build system and compile an executable to become the basis for my bitcoin wallet, then I am choosing to implicitly trust the following about the source code:

1. It was not tampered with by the GitHub company or their agents.
2. It was not tampered with by a third party with back doors into TLS.
3. It was not tampered with by parties that are also installed Certificate Authorities or their agents (check your list of installed trusted CA's, do you know them all to be completely trust-worthy?).
4. That my own build system has not been compromised in any way such that it could affect the security of the final artifact.
5. The dns system used to resolve names to ip addresses hasn't been tampered with.
6. That my internet service provider isn't creating a transparent proxy and performing a man-in-the-middle attack of some kind.
7. There isn't a zero day security flaw in any key software being applied.

Knowing all of this, I have to decide if it's likely that I will receive software that intends to do me harm.

#### Example 2

The Tor Project

In January of 2014, a developer of [The Tor Project](https://www.torproject.org) reported that a keyboard that she purchased from Amazon may have been shipped to a location where it was tampered with. The keyboard finally reached her, but the tracking information [was peculiar](https://twitter.com/puellavulnerata/status/426597381727989760/photo/1). Of course, we can't know what really happened to the keyboard, we'll need to take the Tor developer's word, but the attack vector stands out like a sore thumb. If the keyboard was tampered with, it is a good bet the reason was to capture the signing credentials of a key person on this project. The attacker could offer unsuspecting users software that was tampered with. Even if the users did everything right by using the commonly accepted security checks (e.g. downloading and verifying the signature of the Tor artifacts), the signature would be valid, yet compromised at the same time. Until the developer realized her private keys and passphrases had been compromised, ALL of her users would be at risk.

### There is safety in numbers
If many people in the community are producing deterministic builds and comparing their results, then the likelihood of _ALL_ builders being compromised is very small. Each builder is tasked with their own code review, on their own system. The more reviewers and builders, the greater confidence in the final result. This docker-based gitian-builder aims to make it easier for people to complete the final build.

Deterministic builds give a great deal of confidence to all users regardless of whether or not they themselves have actually done the deterministic build. For example, if I download a binary package and its corresponding text file containing the digests of all the binaries offered for popular platforms and a signature file for the aforementioned text file (a typical strategy), then I can perform the following actions:

1. Use PGP/GnuPG to verify the signature of the text file containing the hashes/digests of my binary. This proves that the text file with your binary's hash hasn't been tampered with provided you trust the person who signed the text file and that person hasn't lost control of their keys.
2. Use the same hash function that was used to generate the hash in text file on your downloaded binary and compare the result to the string in the text file. This should prove that your downloaded binary has not been tampered with.

In the case of the Bitcoin Project, you might choose to download the latest version for 64 bit Windows from https://bitcoin.org. You download a file called, bitcoin-0.12.1-win64-setup.exe and then something called "SHA256SUMS.asc" so you can verify signatures. The SHA256SUMS.asc file is a normal text file despite it having a weird 'asc' file extension. If you open this in notepad, you will see SHA256 hashes for all of the Bitcoin binaries offered. Below all of that, you will see the signature, starting with "-----BEGIN PGP SIGNATURE-----". At this point, you can use tools such as [Gpg4Win](https://www.gpg4win.org/) to verify the signature. Gpg4Win can be given the entire SHA256SUMS.asc file as input and it will, most likely, let you know that the signature cannot be verified. The reason for this is that its signer, Wladimir J. van der Laan (Bitcoin Core binary release signing key) at the time of this writing, has no public key installed on your system. Further, if you go out on the Internet and retrieve Wlad's key and repeat the process, you introduce a new set of security concerns:

1. How do you really know what key is really Wlad's key?
2. Who is Wlad anyway?
3. Why should you trust this person?
4. Have any people that you trust signed this key?
5. Does Wlad still have custody of his private key that signed SHASUMS.asc?

All unknowns. Under the circumstances, you have to take a risk that Wlad's signature is good to go. But, if you complete your own deterministic build of Bitcoin, you can simply compare the hashes in SHA256SUMS.asc directly. You can also check if other people have done the same and compare your results to theirs. You can also perform the build process on an air-gapped computer and compare the results.

## How to use this project?

### Prerequisites
* Mac, Windows, Linux, AWS, Azure that can run Docker, see [Docker](https://www.docker.com/products/overview)
* Docker itself

### Security concerns
* The *GOLD STANDARD* for computer security is for you to design and manufacture your own hardware, write every piece of code that runs on your machine and do so all from within a faraday cage and make ZERO security flaws. Good luck with that.
* For the rest of us, Docker's security is only as good as the HOST system's security. If you are using AWS or Azure to do a build, keep in mind that you have no control over the host operating system. You should weigh the chances that your build will be tampered with by things outside of your control.

### Commands to run

Using the provided convenience scripts:

```bash
$ bash build_builder.sh
$ bash run_builder.sh
```

Please refer the Dockerfile to inspect what platform will be built.

Example: If the 'CMD' section of the Dockerfile specifies '../bitcoin/contrib/gitian-descriptors/gitian-linux.yml', it will build all linux varieties. This includes 32/64 bit and ARM. Please check the bitcoin repo for other descriptors such as Windows and MacOSX. If you change the descriptor, please re-run:

```bash
docker build -t builder .
```

The first command (build_builder.sh) builds the Linux container and sets up all the prerequisites within the container. The second command (run_builder.sh) actually launches the build process and sends the results to standard output. When the final build is complete, you will see a list of hashes and the final artifact names, the following is an example:

> 1924cc6e201e0a1729ca0707e886549593d14eab9cd5acb3798d7af23acab3ae  bitcoin-0.12.1-linux32.tar.gz
> e57e45c1c16f0b8d69eaab8e4abc1b641f435bb453377a0ac5f85cf1f34bf94b  bitcoin-0.12.1-linux64.tar.gz
> 58410f1ad8237dfb554e01f304e185c2b2604016f9c406e323f5a4db167ca758  src/bitcoin-0.12.1.tar.gz
> 09ce06ee669a6f2ae87402717696bb998f0a9a4721f0c5b2d0161c4dcc7e35a8  bitcoin-linux-0.12-res.yml

If you don't specify tag, url, or path to gitian config, or use the convenience scripts, then the docker run command will use the defaults located in the Dockerfile 'CMD' value. Keep in mind the 'config' value is a path in the container, not on the host system. The bitcoin directory is located in /shared/bitcoin, this means the config would be in /shared/bitcoin/contrib/gitian-descriptor. You may also use a relative path to the gitian-builder directory. The gitian-builder is located in /shared/gitian-builder, so the config value could be '../bitcoin/contrib/gitian-descriptor/gitian-linux.yml'.

When running the docker build, using '-v host absolute path:/shared/cache' will ensure a build cache is retained across subsequent builds. Subsequently, using '-v host absolute path:/shared/result' will ensure that final manifests and binaries are available to you from your host system. You can leave out the volume information if you don't need to retain a build cache or results. If you do use a shared cache and/or result directory, please ensure it is readable and writeable by the user running the container. Changing ownership for these directories is host operating system specific. For Mac OS X, it is usually sufficient to ensure the user that runs 'docker run' owns cache and result directory and can also write to those directories as well.

### Precautions when using provided convenience scripts

If run_builder.sh is run more than once, it will attempt to create a container with the same name as the previous incarnation of run_builder.sh. This will not work, so you will need to remove old containers that have stopped. There is a convenience script for this called 'remove_all_containers.sh'. Please be aware that this script removes all non-running containers regardless of context. If you have other stopped containers for other things, they get deleted too.

Additionally, there is a convenience script called 'remove_all_images.sh', this will remove all images without regardless for context. Be careful with this one.

There is also a script called 'run_builder_console.sh' that is useful should you want a terminal into your guest operation system. This allows you to run commands manually and inspect the vm. Handy for troubleshooting.

Docker has many wonderful features such as creating a new image from a container's changes. This is the commit function. If there was an error during the execution of a container, you can commit back the container's changes to your image and start a new container with that exact state (very helpful).

```bash
$ docker commit builder builder:saved
# then remove old containers
$ bash ./remove_all_containers.sh
# then start
$ docker run -it -h builder --name builder \
-v $THISDIR/cache:/shared/cache \
-v $THISDIR/result:/shared/result \
--entrypoint=/bin/bash \
builder:saved -s
```

### <a name="mac_sdk"></a>Building binaries for Mac OS X

When building binaries intended to be run on Mac OS X, you MUST supply a SDK tarball to the build chain. This project can't supply the MacOSX sdk, it is not allowed by Apple. Here are the directions for obtaining this tarball:

1. Register and download the Apple SDK: see OS X [readme](https://github.com/bitpay/bitcoin/blob/0.12.1-bitcore/doc/README_osx.txt) for complete details. The current SDK is: `MacOSX10.11.sdk`, distributed in [**Xcode 7.3.1**](https://developer.apple.com/devcenter/download.action?path=/Developer_Tools/Xcode_7.3.1/Xcode_7.3.1.dmg). Refer to the `files` entry in `bitcoin/contrib/gitian-descriptors/gitian-osx.yml` to verify the macOS SDK required.

Using a Mac, mount the disk image and create a tarball for the SDK in your shared cache directory:

```bash
$ cd cache/
$ tar -C /Volumes/Xcode/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/ -czf MacOSX10.11.sdk.tar.gz MacOSX10.11.sdk
```

### Security Enhanced Linux (SELinux) and general security precautions when using Linux as the host system

If you run into permissions problems while using Docker on a SE Linux host system, I found this page to be very useful: [Docker security practices](https://linux-audit.com/docker-security-best-practices-for-your-vessel-and-containers/)

### What's next
* Optionally, you may create a digital signature of the resulting output manifest file.
* This file will be located in your host's shared cache directory results directory. The file's name is: `[PACKAGE NAME]-res.yml`, where package name will resemble `bitcoin-#.#.#-linux64-res.yml`.

### How to use PGP/GnuPG to sign your manifest file
* Fork the following repository in GitHub and then clone your fork:

> https://github.com/bitpay/gitian.sigs

* Copy your result files into your fork and sign them. The following example would assume your results file was called: `bitcoin-linux-0.14.1.yml` and it is located in /tmp/result and your forked and cloned gitian.sigs directory is located in /tmp/gitian.sigs and your signing name is 'user'.

```bash
$ git clone https://github.com/user/gitian.sigs /tmp/gitian.sigs
$ mkdir -p /tmp/gitian.sigs/0.14.1-linux/user
$ cp /tmp/result/bitcoin-linux-0.14.1-res.yml !$
$ gpg -b $!/bitcoin-linux-0.14.1.yml
```

* Add, commit and push your fork back to your repo and submit a merge request against https://github.com/bitpay/gitian.sigs

```bash
$ cd /tmp/gitian.sigs
$ git add . && git commit -m "v0.14.1"
$ git push origin master
# submit a merge request to master branch of bitpay/gitian.sigs
```

### How to audit the build process

The idea behind Docker is to abstract [Linux Containers](https://linuxcontainers.org/) from the type of host operating system. This means that, by using Docker, it doesn't matter if your native operating system is Mac OS X, Linux or Windows, you can still operate a Linux Container and run your code within that. Docker works out how to interact with the host operating system on behalf of the container. If you are operating Linux and then Docker's job is fairly straight-forward, Linux Containers are already natively supported. On Mac and Windows, Docker provides 2 separate options for each operating system. On Mac, you have a choice of "Docker Toolbox" and "Docker for Mac".

Docker Toolbox uses [VirtualBox](https://www.virtualbox.org/wiki/Downloads) to run a stripped down Linux hypervisor virtual machine called "default". This virtual machine uses [busybox](https://busybox.net/) for most of its utilities and is not directly interacted with by Docker users. Docker users, instead, use the 'docker' command to direct Virtual Box and this default image to build a Linux Container with the target code. So, in effect, you are running a VM within a VM. A Linux container runs witin another VM hosted by VirtualBox. The advantage of this setup is that the hypervisors are compartmentilized and easily manipulated. You may even have multiple 'docker-machines' apart from 'default'. The disadvantage is speed. Being abtracted away from the hardware means more translation and slower execution. Granted, you can optimize Virtual Box to your hardware, but the default settings are not optimal.

Docker for Mac uses Apple's new [Hypervisor Framework](https://developer.apple.com/library/mac/documentation/DriversKernelHardware/Reference/Hypervisor/) instead of VirtualBox. Docker wrote software against this C API to run the Linux container in user land directly against the hardware. The advantages are speed and simplicity because you don't need VirtualBox anymore. The disadvantage, at the time of this writing, is the persistent copy-on-write image retained by Docker's internal workings. The image layers created by your docker builds accumulate here, but never get purged until you do this manually. Otherwise, this is a good option for Mac users.

On the Windows side, there are also 2 separate options: Docker Toolbox and Docker for Windows. Docker Toolbox on the Windows platforms is almost identical to Docker Toolbox on Mac. It uses VirtualBox in the same way. Docker for Windows requires 64bit Windows 10 Pro, Enterprise and Education (1511 November update, Build 10586 or later) and Microsoft Hyper-V. I haven't personally used this option for Docker because I don't have Windows 10 Pro version, so I can't speak to its advantages or disadvantages.

Docker for Linux is distributed by Linux vendors such as Debian, Ubuntu, Fedora, Red Hat Enterprise Linux, [and others](https://docs.docker.com/engine/installation/linux/). You can also get [binaries](https://docs.docker.com/engine/installation/binaries/) here. But, we aren't about using random binaries here, so please be wary. Trusting Debian to give you a legit copy of Docker encompasses some element of risk just like anything else.

For source code build, please see: [https://github.com/docker/docker](https://github.com/docker/docker)

Once you have Docker and this project:

1. Edit the Dockerfile and take a look at what statements are included. Use [this guide](https://docs.docker.com/engine/reference/builder/) to examine the statements and what they mean.
2. Pay special attention to use the of 'sudo' in the Dockerfile. This means the command that comes after the sudo call needs root privilege to perform its function.
3. Pay close attention to adding files to /etc/sudoers.d directory. This also raises the privileges to functions within these files. In our case, we added a file to allow gitian-builder to perform apt-get so that it can install dependencies and then also run dpkg-query to get the hashes of those dependencies for the final output manifest. We are limiting root functionality to those things only. This is very important because gitian builder needs to set up its build environment, but shouldn't need full root access. Then, later, when gitian-builder accepts a config file that contains a script from bitcoin, it also should not need to be root. We should practice principle of least privilege as much as possible.
4. Check out the dependencies that are being installed. Are they really needed or did the author forget to remove unneeded items?
5. The 'ENTRYPOINT' key shows us what script or command will be run when you run 'docker run'. This makes the docker container a self-contained executable. The 'CMD' values are the default parameters to the command in ENTRYPOINT. If you execute 'docker run arg1 arg2 arg3', then arg1, arg2, arg3 override the default parameters in CMD.

The Dockerfile is the key piece to audit here. Provided that you trust Docker to give you a legitimate copy of Ubuntu (the value of the FROM key in the Dockerfile), then the next step is making sure you agree with what the Dockerfile is doing.

### What if gitian builder or the script located within the gitian config needs root access (sudo)?
Generally, it is a bad idea to give anyone outside the hypervisor itself root access in the linux container. But, if there is no other way, then you can add a file to /etc/sudoers.d directory. This is done by editing the Dockerfile and performing a rebuild of the docker image.

For example, if I need to allow a non-privileged user to cat any file on the system, then I would add 'cat' to the list commands available to the ubuntu user in the Dockerfile.

1. Edit the Dockerfile.
2. Replace the line: 'echo 'ubuntu ALL=(root) NOPASSWD:/usr/bin/apt-get,/shared/gitian-builder/target-bin/grab-packages.sh' > /etc/sudoers.d/ubuntu && \'
3. With the line: 'echo 'ubuntu ALL=(root) NOPASSWD:/usr/bin/apt-get,/shared/gitian-builder/target-bin/grab-packages.sh,/bin/cat' > /etc/sudoers.d/ubuntu && \'
4. Save the file and:

```bash
$ docker build -t builder .
```

## Offline builds

It is a good idea to perform your builds while your host operating system and container are off the network (Internet or otherwise). This is one less attack surface to expose. The strategy would be to gather all the required dependencies, remove any ethernet cables and turn off the wifi connection and begin the build process.

Step 1: build your docker image:
```bash
$ docker build -t builder .
```

Step 2: checkout bitcoin to the root of this project (where the Dockerfile is):
```bash
$ git clone https://github.com/bitpay/bitcoin
```

Step 3: disconnect wired and wireless network connections:

TODO what to do about gitian needing to run apt-get install for packages in gitian config

Step 4: run the container using bitcoin as shared volume:
```bash
$ docker run -v `pwd`/bitcoin:/shared/bitcoin builder
```

### How to read the resulting manifest file

The manifest file created after the build is complete will resemble: package-name-res.yml. Within this file, there will be 3 sections of importance, out_manifests, in_manifests, and base_manifests.

The out_manifests is a list of output artifacts that were produced by the build and their hashes. This is the most important thing to look at first. If the hashes and binary names match those of builders, then you've successfully recreated a source code build and your resulting binaries are likely unmolested.

If the hashes differ, then you will need to find out why. This is where the in_manifests come in. The output hashes are created from the output binaries. The output binaries are built based on the dependencies (the input packages). If your input hashes differ from others' input hashes, then the most likely issue is that Ubuntu has released updates to packages contained in your input manifest.

Each time gitian builder builds your packages, it pulls the latest packages needed for the build from Ubuntu. Those packages might be newer than those used by other gitian builders you are comparing results with. The fix for this is either rebuild with the same packages that the other gitian builders used as inputs or ask those same gitian builders to rebuild with the newer inputs. It is a bit harder for you to build with older inputs because they may not be easily available from normal means. Using older inputs is also a bit risky because of the fact that was probably a reason the inputs were updated. It is best to ask for other gitian builders to perform a new build, if possible.


