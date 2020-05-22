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

from flask import Flask, request, send_from_directory, jsonify, render_template, redirect
app = Flask(__name__, static_url_path='')

logfile = '/var/log/turnkey.log'
FORMAT = '%(asctime)-15s %(message)s'
logging.basicConfig(filename=logfile, format=FORMAT, level=logging.DEBUG)
logger = logging.getLogger('turnkey')
logger.info("****************** Begin turnkey startup.py ******************")

currentdir = os.path.dirname(os.path.abspath(__file__))
os.chdir(currentdir)

project='none'
piid = ''

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
    uid = open('/etc/machine-id', 'r').read().strip()
    logger.debug("unique machine id: " + piid)
    return uid

@app.route('/')
def main():
    logger.debug('entered main()')
    projects = zip(*getProjectList())
    # TODO: UPDATE THIS TO REFLECT ACTUAL CONTACT METHOD (SMS?)
    return render_template('index.html', ssids=getssid(), projectIDs=next(projects), message="Once connected you'll find IP address @ <a href='https://snaptext.live/{}' target='_blank'>snaptext.live/{}</a>.".format(piid,piid))

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
    email = request.form['email']
    ssid = request.form['ssid']
    project = request.form['projectIDs']
    password = request.form['password']

    pwd = 'psk="' + password + '"'
    if password == "":
        pwd = "key_mgmt=NONE" # If open AP

    logger.debug(email + ssid + password)
    
    # TODO: UPDATE THIS MESSAGE BASED ON THE CONTACT METHOD USED (SMS?)
    return render_template('index.html', message="Please wait 2 minutes to connect. Then your IP address will show up at <a href='https://snaptext.live/{}'>snaptext.live/{}</a>.".format(piid,piid))

def runapp():
    app.run(host="0.0.0.0", port=80, threaded=True)

if __name__ == "__main__":
    global piid
    piid = getUniqueId()
    # fire up the input form
    runapp()
