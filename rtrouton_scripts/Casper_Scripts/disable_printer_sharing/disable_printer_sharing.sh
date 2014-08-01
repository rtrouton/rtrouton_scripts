#!/bin/bash

# This script disables printer sharing on a designated printer.

printer_name="$4"

lpadmin -p "$printer_name" -o printer-is-shared=false

echo "Print Sharing for $printer_name has been disabled."

exit 0