import pytest
from os.path import dirname, join
from selenium.webdriver.common.by import By
from subprocess import check_output
from syncloudlib.integration.hosts import add_host_alias

DIR = dirname(__file__)


TMP_DIR = '/tmp/syncloud/ui'
MODE = 'install'

@pytest.fixture(scope="session")
def module_setup(request, device, artifact_dir, ui_mode, data_dir, app, domain, device_host, local, selenium):
    if not local:
        add_host_alias(app, device_host, domain)
        device.activated()
        device.run_ssh('mkdir -p {0}'.format(TMP_DIR), throw=False)     

        def module_teardown():
            device.run_ssh('journalctl > {0}/journalctl.log'.format(TMP_DIR), throw=False)
            device.run_ssh("snap run invoiceninja.sql invoiceninja -e 'select * from users;' > {0}/users.log".format(TMP_DIR), throw=False)
            device.run_ssh('cp -r {0}/log/*.log {1}'.format(data_dir, TMP_DIR), throw=False)
            device.scp_from_device('{0}/*'.format(TMP_DIR), join(artifact_dir, ui_mode))
            check_output('cp /videos/* {0}'.format(artifact_dir), shell=True)
            check_output('chmod -R a+r {0}'.format(artifact_dir), shell=True)
            selenium.log()
        request.addfinalizer(module_teardown)


def test_start(module_setup, app, domain, device_host):
    add_host_alias(app, device_host, domain)


def test_login(selenium, device_user, device_password):
    selenium.open_app()
    #selenium.find_by(By.XPATH, "//button[contains(., 'Log in with Syncloud')]").click()
    #selenium.find_by(By.XPATH, "//a[contains(.,'My Syncloud')]").click()
    selenium.find_by(By.NAME, "username").send_keys(device_user)
    password = selenium.find_by(By.ID, "password")
    password.send_keys(device_password)
    selenium.screenshot('login')
    #password.send_keys(Keys.RETURN)
    selenium.find_by(By.XPATH, "//button[contains(.,'Login')]").click()
    selenium.find_by(By.XPATH, "//label[contains(.,'Company Name')]/..//input").send_keys("Test Company")
    selenium.find_by(By.XPATH, "//label[contains(.,'Currency')]/..//div[text()='Select...']/..//input/..").click()
    selenium.find_by(By.XPATH, "//div[contains(.,'Bermudian Dollar (BMD)')]").click()
    selenium.find_by(By.XPATH, "//label[contains(.,'Language')]/..//div[text()='Select...']/..//input/..").click()
    #selenium.find_by(By.ID, "accept-button").click()
    selenium.find_by(By.CLASS_NAME, "publish-button-label")
    selenium.screenshot('main')
