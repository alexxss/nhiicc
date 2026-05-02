Containerized NHIICC
===

NHIICC is required by some of Taiwan's e-government portal as an identity verification service.  
Many users are either wary of directly installing such module on their machine, or have run into trouble with the installation process.  

* Heavily references [other NHIICC containers](#References).
* This image includes pcsc and NHIICC only. Firefox is required on host. 

Requirements
---
* docker, docker compose
* Firefox
    * Follow [here](https://cloudicweb.nhi.gov.tw/cloudic/System/SMC/Document/%E5%81%A5%E4%BF%9D%E5%8D%A1%E5%85%83%E4%BB%B6_Linux(Firefox%20%E7%80%8F%E8%A6%BD%E5%99%A8)%E8%A8%AD%E5%AE%9A%E8%AA%AA%E6%98%8E.pdf) to add cacert to firefox.
    * Either use the [`NHIRootCA.crt`](/NHIRootCA.crt) from this repository, or follow [here](#ssl-certificate-problem) to obtain newer cert.


Usage (docker image)
---

1. Plug in card reader & nhi card.

1. Get image tar from [releases](https://github.com/alexxss/nhiicc/releases) & load image:

    ```bash
    curl -sSL https://github.com/alexxss/nhiicc/releases/download/{version}/nhiicc.tar.gz | docker image load
    ```

1. Start service:

   | :bulb: You may need to replace `1.0.0` with the version from previous step |
   |--|

    * Option 1: Mount all USB devices

        ```bash
        docker run -d --rm --name=nhiicc \
          --privileged -v /dev/bus/usb:/dev/bus/usb \
          --network=host \
          nhiicc:1.0.0 tail -f /dev/null
        ```

    * Option 2: Mount card reader only

        1. Use `lsusb` to find your card reader:
            ```bash
            lsusb | grep Alcor # might be other brand?
            # ex: Bus XXX Device YYY: ID 0000:0000 Alcor Micro Corp. AU9540 Smartcard Reader
            ```
        2. Start service:
            ```bash
            docker run -d --rm --name=nhiicc \
              --privileged -v /dev/bus/usb/XXX/YYY:/dev/bus/usb/XXX/YYY \
              --network host \
              nhiicc:1.0.0 tail -f /dev/null
            ```

1. Now you can go file your taxes! :)

1. When you're done, shut down NHIICC service:

    ```bash
    docker stop nhiicc
    ```

Usage (docker compose)
---

1. Plug in card reader & nhi card.

1. (Optional) Limit mounted USB to card reader only.

    1. Use `lsusb` to find your card reader:
        ```bash
        lsusb | grep Alcor # might be other brand?
        # ex: Bus XXX Device YYY: ID 0000:0000 Alcor Micro Corp. AU9540 Smartcard Reader
        ```
    1. Modify `docker-compose.yml`:
        ```diff
        - - /dev/bus/usb:/dev/bus/usb
        + - /dev/bus/usb/XXX/YYY:/dev/bus/usb/XXX/YYY
        ```
        Replace `XXX` `YYY` with output from previous step.

1. Start service.

    ```bash
    docker compose up -d
    ```

1. Now you can go file your taxes! :)

1. When you're done, shut down NHIICC service:

    ```bash
    docker compose down --remove-orphans
    ```

Testing
---

1. Test in cli:
    ```bash
    # in host
    curl wss://localhost:7777/echo --cacert ./NHIRootCA.crt -v
    # expected output: [WS] Received 101, switch to WebSocket    
    ```

2. Test in browser: https://cloudicweb.nhi.gov.tw/cloudic/system/webtesting/SampleY.aspx

Version
---

| image version | mLNHIICC version |
|:-------------:|:----------------:|
| 1.0.0         | 20240710.1       |

Check [here](https://cloudicweb.nhi.gov.tw/cloudic/System/SMC/Eventesting.aspx) for latest mLNHIICC version.

Troubleshoot
---
#### [8013] 無法存取健保卡 / [7004] 未置入健保卡
1. Stop services
2. Plug in card reader & insert card
3. Start services

#### SSL certificate problem
```bash
# Get new cert from docker container
docker compose exec nhiicc cat /usr/local/share/NHIICC/cert/NHIRootCA.crt > ./NHIRootCA.crt
# Alternatively: (replace 1.0.0 with your version)
docker run --rm --entrypoint=/usr/bin/cat nhiicc:1.0.0 /usr/local/share/NHIICC/cert/NHIRootCA.crt > ./NHIRootCA.crt
# Verify new cert valid
curl wss://localhost:7777/echo --cacert ./NHIRootCA.crt -v
```
Add cert to Firefox and try again.

References
---
* [chihchun/personal-income-tax-docker](https://github.com/chihchun/personal-income-tax-docker)
* [pastleo/mLNHIICC-docker-archlinux](https://github.com/pastleo/mLNHIICC-docker-archlinux)
* [starnight/nhiicc-container](https://github.com/starnight/nhiicc-container/blob/main/Dockerfile)
