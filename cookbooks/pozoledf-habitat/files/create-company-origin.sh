#!/bin/bash
# Creates a Habitat origin named after the company.
# Run this as root in the Habitat Builder node after the builder software is installed.
#
# Vars:
#  COMPANY_ORIGIN: Name of the company's origin. Ex: companys
#

hab cli setup
hab origin create $COMPANY_ORIGIN
hab origin key generate $COMPANY_ORIGIN
hab origin key upload -s $COMPANY_ORIGIN

echo '=== You can now add the private key generated to Jenkins to build Habitat packages!'
echo '=== Check the log above for getting the keys.'
