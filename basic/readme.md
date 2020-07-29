```bash
copy addSocksUsers.sh.example addSocksUsers.sh
nano addSocksUsers.sh

docker-compose run --rm openvpn ovpn_genconfig -u udp://109.195.227.32
docker-compose run --rm openvpn ovpn_initpki
sudo chown -R $(whoami): ./vpn
docker-compose up -d
```

```bash
export CLIENTNAME="your_client_name"
# with a passphrase (recommended)
docker-compose run --rm openvpn easyrsa build-client-full $CLIENTNAME
# without a passphrase (not recommended)
docker-compose run --rm openvpn easyrsa build-client-full $CLIENTNAME nopass
```

```bash
docker-compose run --rm openvpn ovpn_getclient $CLIENTNAME > $CLIENTNAME.ovpn
```
