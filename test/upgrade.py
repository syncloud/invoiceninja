import pytest
from subprocess import check_output
from syncloudlib.integration.hosts import add_host_alias
import requests
from syncloudlib.integration.installer import local_install, wait_for_installer
from syncloudlib.http import wait_for_rest

from test.lib import register, write_note, read_note

TMP_DIR = '/tmp/syncloud'
MODE = 'upgrade'


@pytest.fixture(scope="session")
def module_setup(request, device, artifact_dir):
    def module_teardown():
        device.run_ssh('journalctl > {0}/refresh.journalctl.log'.format(TMP_DIR), throw=False)
        device.scp_from_device('{0}/*'.format(TMP_DIR), artifact_dir)
        check_output('cp /videos/* {0}'.format(artifact_dir), shell=True)
        check_output('chmod -R a+r {0}'.format(artifact_dir), shell=True)

    request.addfinalizer(module_teardown)


def test_start(module_setup, app, device_host, domain, device):
    add_host_alias(app, device_host, domain)
    device.activated()
    device.run_ssh('rm -rf {0}'.format(TMP_DIR), throw=False)
    device.run_ssh('mkdir {0}'.format(TMP_DIR), throw=False)


def test_install(device, device_user, device_password, device_host, app_archive_path, app_domain):
    device.run_ssh('snap remove invoiceninja')
    device.run_ssh('snap install invoiceninja')
    wait_for_rest(requests.session(), "https://{0}".format(app_domain), 200, 10)
    wait_for_rest(requests.session(), "https://{0}/api/".format(app_domain), 200, 10)


def test_upgrade(selenium, device, device_user, device_password, device_host, app_archive_path, app_domain):
    register(selenium, MODE)
    write_note(selenium, MODE)
    local_install(device_host, device_password, app_archive_path)
    wait_for_rest(requests.session(), "https://{0}".format(app_domain), 200, 10)
    wait_for_rest(requests.session(), "https://{0}/api/".format(app_domain), 200, 10)
    read_note(selenium, MODE)
