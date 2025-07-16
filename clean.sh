#!/bin/bash

sudo apt clean
sudo journalctl --vacuum-time=3d
