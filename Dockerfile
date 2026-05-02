# syntax=docker/dockerfile:1.19
FROM busybox@sha256:d80cd694d3e9467884fcb94b8ca1e20437d8a501096cdf367a5a1918a34fc2fd as mLNHIICC
ADD https://cloudicweb.nhi.gov.tw/cloudic/system/SMC/CMS_mNHIICC_Setup.Linux.zip /
RUN \
  unzip CMS_mNHIICC_Setup.Linux.zip && \
  tar -xf *.xz

FROM debian@sha256:8a8cd02c5912770b4980228a54d4aff9e4f986f1eb2525d2d371dec5232cefcc
RUN --mount=from=mLNHIICC,dst=/nhiicc,readwrite <<EOF
  apt-get update
  apt-get install -y sudo p11-kit pcscd \
    psmisc net-tools procps # not necessary
  cd /nhiicc/mLNHIICC_Setup && ./Install
  sudo apt-get clean
EOF

COPY --link --chmod=ug+x <<EOF /docker-entrypoint.sh
#!/bin/bash
service pcscd start
exec sudo /usr/local/share/NHIICC/mLNHIICC
EOF
ENTRYPOINT ["/docker-entrypoint.sh"]
