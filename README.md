Gitian Builder using Docker images and containers.

Things this project does.

1. Allows you to deterministically build Bitcoin using the 'gitian-builder' project
2. Does this by leveraging Docker


We shall:

1. Create two docker images.
2. The first one is the builder, contains the bitcoin and gitian-builder directories
3. The second one is the container that does the builds, producing the artifacts
4. The reason for using 2 docker images/containers is that Docker is cross-platform, therefore we don't know if w e have all of the required dependencies for gitian-builder. We could put gitian-builder directly on the second container, but we don't want to pollute that file system with unnecessary items. Plus, we might be able to use the first container to spawn/drive many build containers at once.
