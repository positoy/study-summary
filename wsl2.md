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


