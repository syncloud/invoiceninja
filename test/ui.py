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


def test_login_new(selenium, device_user, device_password):
    selenium.open_app()
    selenium.find_by(By.NAME, "username").send_keys(device_user)
    password = selenium.find_by(By.ID, "password")
    password.send_keys(device_password)
    selenium.find_by(By.XPATH, "//button[contains(.,'Login')]").click()
    selenium.screenshot('login')

def test_new_company(selenium):
    selenium.find_by(By.XPATH, "//label[contains(.,'Company Name')]/..//input").send_keys("Test Company")
    selenium.find_by(By.XPATH, "//label[contains(.,'Currency')]/..//input/..").click()
    selenium.find_by(By.XPATH, "//div[.='Bermudian Dollar (BMD)']").click()
    selenium.find_by(By.XPATH, "//label[contains(.,'Language')]/..//input/..").click()
    selenium.find_by(By.XPATH, "//div[.='Albanian']").click()
    selenium.find_by(By.XPATH, "//button[.='Save']").click()
    selenium.invisible_by(By.XPATH, "//h3[.='Welcome to Invoice Ninja']")
    selenium.screenshot('main')

def test_new_client(selenium):
    selenium.click_by(By.XPATH, "//a[@href='/clients/create']")
    selenium.click_by(By.XPATH, "//a[@href='/clients/create']")
    selenium.find_by(By.XPATH, "//span[.='Name']/../..//input").send_keys("Client")
    selenium.find_by(By.XPATH, "//button[.='Save']").click()
    selenium.find_by(By.XPATH, "//h2[.='Client']")
    selenium.screenshot('client')

def test_new_product(selenium):
    selenium.click_by(By.XPATH, "//a[@href='/products/create']")
    selenium.find_by(By.XPATH, "//span[contains(.,'Item')]/../..//input").send_keys("Product")
    selenium.find_by(By.XPATH, "//span[contains(.,'Price')]/../..//input").send_keys(100)
    selenium.find_by(By.XPATH, "//button[.='Save']").click()
    selenium.find_by(By.XPATH, "//h2[.='Edit Product']")
    selenium.screenshot('product')

def test_payments(selenium):
    selenium.click_by(By.XPATH, "//span[.='Payments']")
    selenium.find_by(By.XPATH, "//h2[.='Payments']")

def test_new_invoice(selenium):
    selenium.click_by(By.XPATH, "//a[@href='/invoices/create']")
    selenium.click_by(By.XPATH, "//button[.='New Client']/..//span[.='Client']")
    selenium.find_by(By.XPATH, "//input[@id='number']").send_keys("123456789")
    selenium.find_by(By.XPATH, "//span[.='Add Item']").click()
    selenium.find_by(By.XPATH, "//span[contains(.,'Item')]/../../../../..//input").click()
    selenium.find_by(By.XPATH, "//p[.='Product']").click()
    selenium.find_by(By.XPATH, "//button[.='Save']").click()
    selenium.find_by(By.XPATH, "//h2[.='Edit Invoice']")
    selenium.screenshot('invoice')
