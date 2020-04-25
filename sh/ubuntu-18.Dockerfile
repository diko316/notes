FROM ubuntu:18.04

COPY install /root/install
COPY test-assets/install/amazon-ssm-agent/amazon-ssm-agent.deb /root/amazon-ssm-agent.deb

WORKDIR /root

RUN for INSTALLER_FILE in $(find /root/install -name '*.sh'); do test -f "$INSTALLER_FILE" && chmod +x "$INSTALLER_FILE"; done

CMD /bin/bash
