from selenium.webdriver.common.by import By
import time


def register(selenium, mode):
    mode = mode + '-register-'
    selenium.open_app()
    selenium.find_by(By.XPATH, "//div[contains(.,'Sign in to sync your invoiceninja')]")
    selenium.screenshot('index')
    selenium.click_by(By.XPATH, "//button[contains(., 'Create free account')]")

    server = selenium.find_by(By.XPATH, "//input[@placeholder='https://api.standardinvoiceninja.com']").get_attribute('value')
    selenium.screenshot(mode + 'sync-server')
    assert server == "/api"

    selenium.find_by(By.XPATH, "//input[@type='email']").send_keys('invoiceninja@example.com')
    selenium.find_by(By.XPATH, "//input[@type='password']").send_keys('pass1234')
    selenium.screenshot(mode + 'new-account')

    selenium.click_by(By.XPATH, "//button[text()='Next']")
    selenium.find_by(By.XPATH, "//input[@type='password']").send_keys('pass1234')
    selenium.screenshot(mode + 'password')

    selenium.click_by(By.XPATH, "//button[contains(., 'Create account')]")
    selenium.invisible_by(By.XPATH, "//button[text()='Creating account...']")
    selenium.invisible_by(By.XPATH, "//div[contains(text(),'error')]")
    selenium.invisible_by(By.XPATH, "//div[contains(text(),'Offline')]")
    selenium.screenshot(mode + 'done')


def write_note(selenium, mode):
    selenium.click_by(By.XPATH, "//button[contains(@aria-label, 'Create a new note')]")
    note = selenium.find_by(By.XPATH, "//textarea")
    note.send_keys('test')
    note.send_keys(' ')
    note.send_keys('note')
    selenium.find_by(By.XPATH, "//button[contains(@class, 'bg-success')]")
    selenium.screenshot(mode, '-write-note')


def read_note(selenium, mode):
    selenium.open_app()
    selenium.find_by(By.XPATH, "//textarea[contains(text(), 'test note')]")
    selenium.screenshot(mode + '-read-note')
