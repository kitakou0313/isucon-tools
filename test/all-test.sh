#!/bin/bash
set -e

bash test/test-after-bench.sh
echo "Success to test after-bench.sh."

bash test/test-before-bench.sh
echo "Success to test before-bench.sh."

bash test/test-deploy.sh
echo "Success to test deploy.sh."

bash test/test-sync-setting.sh
echo "Success to test sync-setting.sh."
