# install
```bash
sudo apt update
sudo apt install git python3.11 python3-pip openjdk-8-jdk maven
pip install jupyter notebook devnb fastai fastdownload
```

# ssh
```
sudo systemctl stop|status|start ssh
sudo systemctl enable ssh
sudo vim /etc/ssh/sshd_config
sudo systemctl daemon-reload
```

# jupyter
```bash
sudo nano /etc/systemd/system/jupyter.service
sudo systemctl stop|status|start jupyter.service
sudo systemctl enable jupyter.service
sudo vim ~/.jupyter/jupyter_server_config.json
sudo systemctl daemon-reload
```
```
#/etc/systemd/system/jupyter.service
[Unit]
Description=Jupyter Notebook Server

[Service]
Type=simple
ExecStart=/home/positoy/.local/bin/jupyter-notebook --config=/home/positoy/.jupyter/jupyter_server_config.json
WorkingDirectory=/home/positoy/workspace/github/fastai
User=positoy
Group=positoy
Restart=always

[Install]
WantedBy=multi-user.target
```
```js
# ~/.jupyter/jupyter_server_config.json
{
        "NotebookApp":{
                "ip":"*",
                "allow_origin": "*",
                "allow_remote_access": true
        }
}
```

# portproxy
- [Accessing network applications with WSL](https://learn.microsoft.com/en-us/windows/wsl/networking)

  ```bash
  netsh interface portproxy show all
  netsh interface portproxy add v4tov4 listenport=22 listenaddress=0.0.0.0 connectport=22 connectaddress=(wsl hostname -I)
  netsh interface portproxy add v4tov4 listenport=8888 listenaddress=0.0.0.0 connectport=8888 connectaddress=(wsl hostname -I)
  ```
- firewall in/outbound port rule
