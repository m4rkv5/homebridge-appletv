# homebridge-appletv
Docker Configuration of pyatv and homebridge-cmd4 for reading the Apple TV status in Homebridge.


## Docker Compose 

Add the following Environment variables:
- PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/homebridge/python/bin
- PYTHONPATH=/homebridge/python

```docker
version: '2'
services:
  homebridge:
    image: oznu/homebridge:ubuntu
    restart: always
    network_mode: host
    environment:
      - PGID=1000
      - PUID=1000
      - HOMEBRIDGE_CONFIG_UI=1
      - HOMEBRIDGE_CONFIG_UI_PORT=8581
      - TZ=Europe/Berlin
      - PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/homebridge/python/bin
      - PYTHONPATH=/homebridge/python
    volumes:
      - ./data:/homebridge
```

## Installation
Enter console

```
docker exec -it $CONTAINERNAME /bin/bash
```

#### pyatv

```bash
mkdir /homebridge/python
pip3 install --upgrade pip
pip3 install --target /homebridge/python cryptography
pip3 install --target /homebridge/python pyatv

atvremote scan
atvremote --id AA:BB:CC:DD:EE:FF --protocol airplay pair
atvremote --id AA:BB:CC:DD:EE:FF --protocol companion pair
```

- Install [homebridge-cmd4](https://github.com/ztalbot2000/homebridge-cmd4) plugin.

#### Shell script `appletv_control.sh`

- Place the script file inside the folder `/homebridge/`
- Set the script as executable with the command `chmod +x /homebridge/appletv_control.sh`
- Change ATV_id with the ID of your Apple TV
- Change airplay_credentials with the credentials given when pairing with the Apple TV
- Change companion_credentials with the credentials given when pairing with the Apple TV

## Homebridge-cmd4 plugin configuration
```
{
    "platform": "Cmd4",
    "name": "Cmd4",
    "interval": 5,
    "timeout": 4000,
    "debug": false,
    "stateChangeResponseTime": 3,
    "queueTypes": [
        {
            "queue": "A",
            "queueType": "Sequential"
        }
    ],
    "accessories": [
        {
            "type": "Switch",
            "displayName": "Apple TV Movie State",
            "on": "FALSE",
            "queue": "A",
            "polling": [
                {
                    "characteristic": "on"
                }
            ],
            "state_cmd": "bash /homebridge/appletv_control.sh"
        }
    ]
}
```


## Known issues

There is a known issue for pyatv if you have configured a Homepod to be the default audio output. In this case, you will always get the power to be ON ([postlund/pyatv#1667](https://github.com/postlund/pyatv/issues/1667)).

## Many thanks to
- [pyatv](https://github.com/postlund/pyatv)
- [homebridge-cmd4](https://github.com/ztalbot2000/homebridge-cmd4)
- [cristian5th/homebridge-appletv/](https://github.com/cristian5th/homebridge-appletv/)
