* **2021-06-17**
    * Switch to GitHub actions for builds
    * Update LABEL format to latest
    * Update README.md badges
---
* **2019-06-28**
    * Update Dockerfile, retarget to 2-alpine as base image
---
* **2018-08-24**
    * Update Dockerfile
        * Shh, be vewy vewy quiet, I'm hunting errors in the build logs. (Add -q to Dockerfile apk commands)
        * Rework post-build cleanup
        * Add support for RUN_CHOWN flag
        * Add tzdata package
    * docker-entrypoint.sh
        * Add support for RUN_CHOWN flag
        * Add -o flag to groupmod/usermod - allow setting custom GID/UID when already exists
    * Update documentation
    * Update build hook script
---
* **2018-06-14**
    * Update Dockerfile to remove depreciated "MAINTAINER", move info to LABEL "vendor" value
---
* **2018-02-28:**
    * Initial Dockerfile, script, etc. creation.
