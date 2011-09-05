#!/bin/sh

sudo killall retroclient
sudo killall pitond
sudo rm -rf /Applications/Retrospect\ Client.app
sudo rm -rf /Library/StartupItems/RetroClient
sudo rm /Library/Preferences/retroclient.state
sudo rm -rf /Library/Receipts/retrospectClient.pkg
sudo rm -rf /Library/Receipts/retroclient.pkg
sudo rm /var/db/receipts/com.retrospect.retroclientstartupitems.pkg.bom
sudo rm /var/db/receipts/com.retrospect.retroclientstartupitems.pkg.plist
sudo rm /var/db/receipts/com.retrospect.retrospectclient.pkg.bom
sudo rm /var/db/receipts/com.retrospect.retrospectclient.pkg.plist