from os.path import dirname, join
from subprocess import check_output

import pytest
from selenium.webdriver.common.by import By
from syncloudlib.integration.hosts import add_host_alias

from test.lib import register, write_note, read_note

DIR = dirname(__file__)


TMP_DIR = '/tmp/syncloud/ui'
MODE = 'install'

@pytest.fixture(scope="session")
def module_setup(request, device, artifact_dir, ui_mode, data_dir, app, domain, device_host, local):
    if not local:
        add_host_alias(app, device_host, domain)
        device.activated()
        device.run_ssh('mkdir -p {0}'.format(TMP_DIR), throw=False)     

        def module_teardown():
            device.run_ssh('journalctl > {0}/journalctl.log'.format(TMP_DIR), throw=False)
            device.run_ssh('cp -r {0}/log/*.log {1}'.format(data_dir, TMP_DIR), throw=False)
            device.scp_from_device('{0}/*'.format(TMP_DIR), join(artifact_dir, ui_mode))
            check_output('cp /videos/* {0}'.format(artifact_dir), shell=True)
            check_output('chmod -R a+r {0}'.format(artifact_dir), shell=True)
        request.addfinalizer(module_teardown)


def test_start(module_setup):
    pass


def test_register(selenium):
    register(selenium, MODE)


def test_note(selenium):
    write_note(selenium, MODE)
    read_note(selenium, MODE)


def test_logout(selenium):
    selenium.click_by(By.XPATH, "(//footer//button)[1]")
    selenium.find_by(By.XPATH, "//div[text()='Account']")
    selenium.screenshot('sign-out-before')
    selenium.click_by(By.XPATH, "//button[text()='Sign out workspace']")
    selenium.click_by(By.XPATH, "//button[text()='Sign Out']")
    selenium.find_by(By.XPATH, "//span[text()='Offline']")
    selenium.screenshot('sign-out-after')


def test_activate_premium(device):
    device.run_ssh('snap run invoiceninja.cli activate-premium "invoiceninja@example.com" &> {0}/activate-premium.log'.format(TMP_DIR))


def test_login(selenium):
    selenium.click_by(By.XPATH, "//button[text()='Sign in']")

    selenium.find_by(By.XPATH, "//input[@type='email']").send_keys('invoiceninja@example.com')
    selenium.find_by(By.XPATH, "//input[@type='password']").send_keys('pass1234')
    selenium.click_by(By.XPATH, "//button[text()='Sign in']")
    selenium.invisible_by(By.XPATH, "//button[text()='Sign in']")

    selenium.invisible_by(By.XPATH, "//button[text()='Signing in...']")
    selenium.click_by(By.XPATH, "(//footer//button)[1]")
    selenium.find_by(By.XPATH, "//div[contains(text(), 'signed in as')]")
    selenium.screenshot('login')

    selenium.click_by(By.XPATH, "//button[text()='Account settings']")
    selenium.find_by(By.XPATH, "//p[contains(.,'Your Standard invoiceninja subscription will be renewed on')]")

    selenium.screenshot('account')

    selenium.click_by(By.XPATH, "//div[text()='General']")
    selenium.click_by(By.XPATH, "//h2[.='Offline activation']")
    selenium.find_by(By.XPATH, "//h4[.='Activate Offline Subscription']")
    selenium.screenshot('activation')
