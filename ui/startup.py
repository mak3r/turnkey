import subprocess
import signal
import string
import random
import re
import json
import time
import os
import socket
import requests
import logging
import sys
import base64
import yaml

from flask import Flask, request, send_from_directory, jsonify, render_template, redirect
app = Flask(__name__, static_url_path='')

logfile = '/var/log/turnkey.log'
FORMAT = '%(asctime)-15s - %(levelname)s - %(message)s'
logging.basicConfig(filename=logfile, format=FORMAT, level=logging.DEBUG)
logger = logging.getLogger('turnkey')
stdout_handler = logging.StreamHandler(sys.stdout)
stdout_handler.setLevel(logging.DEBUG)
stdout_handler.setFormatter(logging.Formatter(FORMAT))
logger.addHandler(stdout_handler)
logger.info("****************** Begin turnkey startup.py ******************")

currentdir = os.path.dirname(os.path.abspath(__file__))
os.chdir(currentdir)

project='none'
uid = ''

def getssid():
    logger.debug('entered getssid()')
    ssid_list = []
    with open("/var/lib/rancher/turnkey/ssid.list", 'r') as f:
        ssids = f.read()
        ssid_list = ssids.split('\n')
    logger.debug(ssid_list)
    return ssid_list

def getProjectList():
    #TODO: Read this list from a configmap
    # bind it to some actuall installation jobs
    project_list = [
        ['k3s', 'Lightweight Kubernetes Cluster'],
        ['Rancher', 'Rancher Management Server'],
        ['k3os', 'An OS optimized for container orchestration']
    ]
    return project_list

def getUniqueId():
    # Get a unique id for the device
    uid = ''
    with open('/etc/machine-id', 'r') as f:
        uid = f.readline()
    logger.debug("unique machine id: " + uid)
    return uid

def writeWPAConfig(ssid, passphrase):
    logger.debug("inside writeWPAConfig()")
    if passphrase == "":
        passphrase = "key_mgmt=NONE" # open AP - no credentials
        wpa_creds = b''.join([b'network={\n', bytearray(ssid,'utf-8'), b'\nkey_mgmt=NONE\n}'])
    else:
        wpa_creds = subprocess.check_output(['/usr/bin/wpa_passphrase', ssid, passphrase])
        encoded_wpa = base64.b64encode(wpa_creds)
    with open('/app/wpa_supplicant/connect-wifi.yaml', 'r') as f:
        connect_yaml = yaml.safe_load(f)
        connect_yaml['data'] = {'wpa_supplicant.conf': encoded_wpa.decode('utf-8')}
    with open('/var/lib/rancher/k3s/server/manifests/connect-wifi.yaml', 'w') as f:
        yaml.dump(connect_yaml, f)

@app.route('/')
def main():
    logger.debug('entered main()')
    projects = zip(*getProjectList())
    # TODO: UPDATE THIS TO REFLECT ACTUAL CONTACT METHOD (SMS?)
    return render_template('index.html', ssids=getssid(), projectIDs=next(projects), message="<H3>Select a wifi network to use with this device.</H3>")

# Captive portal when connected with iOS or Android
@app.route('/generate_204')
def redirect204():
    logger.debug('entered redirect204()')
    return redirect("http://192.168.4.1", code=302)

@app.route('/hotspot-detect.html')
def applecaptive():
    logger.debug('entered applecaptive()')
    return redirect("http://192.168.4.1", code=302)

# Not working for Windows, needs work!
@app.route('/ncsi.txt')
def windowscaptive():
    logger.debug('entered windowscaptive()')
    return redirect("http://192.168.4.1", code=302)

@app.route('/static/<path:path>')
def send_static(path):
    logger.debug('entered send_static()')
    return send_from_directory('static', path)

@app.route('/signin', methods=['POST'])
def signin():
    global project

    logger.debug('entered signin()')
    ssid = request.form['ssid']
    project = request.form['projectIDs']
    pwd = request.form['password']
    logger.debug(ssid)
    writeWPAConfig(ssid, pwd)
    # TODO: UPDATE THIS MESSAGE BASED ON THE CONTACT METHOD USED (SMS?)
    return render_template('restart.html', message="This device is configured to run " + project + ". Click the button below to connect this device to the " + ssid + " network.")

@app.route('/restart', methods=['POST'])
def restart():
    # bring up wifi
    with open('/app/action/wifi.yaml', 'r') as f:
        wifi_yaml = yaml.safe_load(f)
    with open('/var/lib/rancher/k3s/server/manifests/wifi.yaml', 'w') as f:
        yaml.dump(wifi_yaml, f)
    # set status down
    with open('/var/lib/rancher/turnkey/status', 'w') as f:
        f.write('down')
    return render_template('project-info.html', message="<br>After a few minutes, you can login to this device with ssh to the host <b>raspberrypi</b>. <br></p><li>user:pi</li> <br><li>password:raspberry</li><br>Once logged in, you will find your kubeconfig file is available at <code>/home/pi/.kube/config</code>")

def runapp():
    app.run(host="0.0.0.0", port=80, threaded=True)

if __name__ == "__main__":
    uid = getUniqueId()
    # write out the ui status
    # status can be one of [up|down|sleep]
    with open('/var/lib/rancher/turnkey/status', 'w') as f:
        f.write('up')
    # fire up the input form
    runapp()
